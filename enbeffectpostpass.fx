/**
 * Copyright (C) 2022 nullfractal
 * SPDX-License-Identifier: Unlicense <https://unlicense.org>
 */

/**
 * @brief Timer value with 4 different vectors.
 *
 * @param X Generic timer in range 0..1, period of 16777216ms (4.6 hours).
 * @param Y Average FPS.
 * @param W Frametime elapsed (in seconds).
 */
float4 Timer;

/**
 * @brief Screen size value with 4 vectors.
 *
 * @param X Width.
 * @param Y 1 / Width.
 * @param Z Aspect ratio.
 * @param W 1 / Aspect ratio.
 */
float4 ScreenSize;

/**
 * @brief Quality changing in a range of 0..1.
 *
 * @details 0 means full quality, 1 lowest dyanmic quality. (0.33, 0.66 are limits)
 */
float AdaptiveQuality;

/**
 * @brief Weather indexes in 4 vectors.
 *
 * @details Weather index is value from weather.ini file, for example, WEATHER002
 *			means index == 2, but index == 0 means that no weather is captured.
 *
 * @param X Current weather index.
 * @param Y Outgoing weather index.
 * @param Z Weather transition.
 * @param W Time of day in 24 hour time.
 */
float4 Weather;

/**
 * @brief Time of day interpolators.
 * 
 * @details Interpolators range from 0..1.
 *
 * @param X Dawn.
 * @param Y Sunrise.
 * @param Z Day.
 * @param W Sunset.
 */
float4 TimeOfDay1;

/**
 * @brief Time of day interpolators, after daytime.
 * 
 * @details Interpolators range from 0..1.
 *
 * @param X Dusk.
 * @param Y Night.
 */
float4 TimeOfDay2;

/**
 * @brief Time of day between day and night.
 * @details 0 means night, 1 equals day.
 */
float ENightDayFactor;

/// @brief Current status. 0 means exterior, 1 means interior.
float EInteriorFactor;

/// @brief 1st temporary value.
/// @details 0, 1, 2, 3.
float4 tempF1;

/// @brief 2nd temporary value.
/// @details 5, 6, 7, 8.
float4 tempF2;

/// @brief 3rd temporary value.
/// @details 9, 0.
float4 tempF3;

/**
 * @brief Temporary info (1)
 *
 * @details W values are as follow:
 *			0: none, 1: left, 2: right, 3: left + right, 4: middle,
 *			5: left + middle, 6: right + middle, 7: left + right + middle.
 *
 * @param X Cursor position X vector in range 0 .. 1.
 * @param Y Cursor position Y vector in range 0 .. 1.
 * @param Z If shader editor window is active.
 * @param W Mouse buttons with values 0 .. 7.
 */
float4 tempInfo1;

/**
 * @brief Temporary info (2)
 *
 * @param X Position of previous left mouse click, X vector.
 * @param Y Position of previous left mouse click, Y vector.
 */
float4 tempInfo2;

/// @brief HDR color.
/// @details In multipass mode, it's previous pass' 32-bit LDR, except when
///          temporary render targets are used.
Texture2D TextureColor;

/// @brief Scene depth.
Texture2D TextureDepth;

/// @brief Original game color in 64-bit HDR format.
Texture2D TextureOriginal;

// self-explanatory, 2 lazy to document.
Texture2D RenderTargetRGBA32;
Texture2D RenderTargetRGBA64;
Texture2D RenderTargetRGBA64F;
Texture2D RenderTargetR16F;
Texture2D RenderTargetR32F;
Texture2D RenderTargetRGB32F;

/// @brief First sampler state.
/// @details Uses clamp UV and point filter.
SamplerState Sampler0
{
	Filter = MIN_MAG_MIP_POINT;
	AddressU = Clamp;
	AddressV = Clamp;
};

/// @brief Second sampler state.
/// @details Uses clamp UV and linear filter.
SamplerState Sampler1
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

/// @brief Vertex Shader input struct.
struct VS_INPUT_POST
{
	float3 pos : POSITION;
	float2 texcoord : TEXCOORD0;
};

/// @brief Vertex Shader output struct.
struct VS_OUTPUT_POST
{
	float4 pos : SV_POSITION;
	float2 texcoord0 : TEXCOORD0;
};

/// @brief Dummy VS output.
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	float4 pos;
	pos.xyz = IN.pos.xyz;
	pos.w = 1.0;

	OUT.pos = pos;
	OUT.texcoord0.xy = IN.texcoord.xy;
	
	return OUT;
}


/// @brief Bit of spacing.
int Spacer0 <
	string UIName = "\x97\x97\x97\x97\x97\x97\x97\x97\x97\x97\x97\x97\x97\x97"
					"\x97\x97\x97\x97\x97\x97\x97\x97";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief Linear contrast toggle.
bool ApplyLinearContrast <
	string UIName = "Linear Contrast";
> = {true};

/// @brief Linear contrast pivot (center point).
float3 LinearContrastPivot <
	string UIName = "    Pivot:";
	string UIWidget = "Color";
> = {0.5, 0.5, 0.5};

/// @brief Linear contrast.
int LinearContrast <
	string UIName = "    Contrast:                                                 %";
	string UIWidget = "Spinner";
	int UIMin = 0;
> = {100};

/// @brief Bit of spacing.
int Spacer1 <
	string UIName = " ";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief Wether to apply color transforms.
bool ApplyColorTransforms <
	string UIName = "Perceptual Color Transforms";
> = {true};

int LChLuminance <
	string UIName = "    Luminance:                                              %";
	string UIWidget = "Spinner";
	float UIMin = 0;
> = {100};

/// @brief Amount of saturation (colorfulness).
int LChSaturation <
	string UIName = "    Colorfulness:                                           %";
	string UIWidget = "Spinner";
	float UIMin = 0;
> = {100};

/// @brief Hue to shift in LCh
int LChHue <
	string UIName = "    Hue:";
	string UIWidget = "Spinner";
	int UIMin = -180;
	int UIMax = 180;	
> = {0};

/// @brief Bit of spacing.
int Spacer2 <
	string UIName = "  ";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief Multiplier for a of Oklab
int aMult < 
	string UIName = "    Oklab-a Multiplier:";
	string UIWidget = "Spinner";
	int UIMin = 0;
> = {100};

/// @brief Multiplier for b of Oklab
int bMult < 
	string UIName = "    Oklab-b Multiplier:";
	string UIWidget = "Spinner";
	int UIMin = 0;
> = {100};

// These functions avoid pow() to efficiently approximate sRGB with an error < 0.4%.

/// @brief Apply (remove) an sRGB curve.
/// @author James Stanard (Microsoft)
float3 ApplySRGBCurve_Fast( float3 x )
{
    return x < 0.0031308 ? 12.92 * x : 1.13005 * sqrt(x - 0.00228) - 0.13448 * x + 0.005719;
}

/// @brief Remove (apply) an sRGB curve.
/// @author James Stanard (Microsoft)
float3 RemoveSRGBCurve_Fast( float3 x )
{
    return x < 0.04045 ? x / 12.92 : -7.43605 * x - 31.24297 * sqrt(-0.53792 * x + 1.279924) + 35.34864;
}

static const float3 ReferenceWhite = { 0.950489f, 1.000f, 1.088840f };
static const float Pi = acos(-1);

#define DegToRad(x) ((x)*Pi/180)
#define RadToDeg(x) ((x)/Pi*180)

#include "Include/TriDither.fxh"
#include "Include/ColorSpaces.fxh"

float4 PS_PostProcess(VS_OUTPUT_POST IN, float4 vpos : SV_POSITION) : SV_TARGET
{
	/// @brief Output color.
	float4 res;

	/// @brief Input color.
	float4 color = TextureColor.Sample(Sampler0, IN.texcoord0.xy);

	// Remove sRGB gamma.
	color.rgb = ApplySRGBCurve_Fast(color.rgb);

	/// @brief Get luma.
	float luma = dot(color.rgb, RGBtoXYZMatrix[1]);

	// Apply color transforms.
	if (ApplyColorTransforms)
	{
		/// @brief Oklab representation of color.
		Lab labColor = RGBtoOklab(color.rgb);

		labColor.L *= LChLuminance * 0.01f; // Modify L*
		labColor.a *= aMult * 0.01f; // Modify a*
		labColor.b *= bMult * 0.01f; // Modify b*

		/// @brief CIE-L*C*h*(ab) of color.
		LCh lchColor = LabToLCh(labColor);
		float offsetHue = lchColor.h + LChHue;

		lchColor.C *= LChSaturation * 0.01f; // Modify C* (saturation)
		lchColor.h  = offsetHue >= 360 
					? offsetHue - 360
					: offsetHue;

		color.rgb = OklabToRGB(LChToLab(lchColor)); // Convert CIE-L*C*h*(ab) to RGB
	}

	// Apply linear contrast.
	if (ApplyLinearContrast)
	{
		color.rgb = lerp(LinearContrastPivot, color.rgb, LinearContrast * 0.01f);
	}	

	// Apply sRGB gamma.
	color.rgb = RemoveSRGBCurve_Fast(color.rgb);

	// Dither to 8-bit.
	color.rgb += TriDither(color.rgb, IN.texcoord0.xy, 8);

	res.rgb = saturate(color.rgb);
	res.a = 1.0f;

	return res;
}

technique11 PostProcess < string UIName = "ENBSeries"; >
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_PostProcess()));
		SetPixelShader(CompileShader(ps_5_0, PS_PostProcess()));
	}
}