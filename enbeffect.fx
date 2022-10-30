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

/**
 * @brief Size of bloom.
 *
 * @param X Width.
 * @param Y 1 / Width.
 * @param Z Aspect Ratio.
 * @param W 1 / Aspect Ratio.
 */
float4 BloomSize;

/**
 * @section Keyboard controlled temporary values.
 * @details Press and hold key 1, 2, 3 . . . 0 together with Page Up or Page Down
 *			to modify. By default all are 1.0.
 */

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

/// @brief Skyrim SE parameters.
float4 Params01[7];

/**
 * @brief ENB parameters.
 *
 * @param X Bloom amount.
 * @param Y Lens amount.
 */
float4 ENBParams01;

/// @brief HDR color.
/// @details In multipass mode, it's previous pass' 32-bit LDR, except when
///          temporary render targets are used.
Texture2D TextureColor;

/// @brief Vanilla or ENB bloom.
Texture2D TextureBloom;

/// @brief ENB lens FX.
Texture2D TextureLens;

/// @brief Scene depth.
Texture2D TextureDepth;

/// @brief Vanilla or ENB adaptation
Texture2D TextureAdaptation;

/// @brief Current frame's aperture.
/// @details In 1:1 aspect ratio, single-channel (R) 32-bit floating point HDR.
/// 		 computed in DOF shader.
Texture2D TextureAperture;

/// @brief ENB palette texture.
/// @details Only if loaded and enabled in ENBSeries.INI, section [colorcorrection]
Texture2D TexturePalette;

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
VS_OUTPUT_POST VS_Draw(VS_INPUT_POST IN)
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

/// @brief The mode of exposure to use.
int ExposureMode <
	string UIName = "Exposure Mode";
	string UIWidget = "Dropdown";
	string UIList = "Manual (Simple), Manual (SBS), Manual (SOS), Automatic";
>;

/// @brief The aperture size to use for calculating the f/number.
int ApertureSize <
	string UIName = "    Aperture:";
	string UIWidget = "Dropdown";
	string UIList = "\x83/1.8, \x83/2.0, \x83/2.2, \x83/2.5, \x83/2.8, "
					"\x83/3.2, \x83/3.5, \x83/4.0, \x83/4.5, \x83/5.0, "
					"\x83/5.6, \x83/6.3, \x83/7.1, \x83/8.0, \x83/9.0, "
					"\x83/10.0, \x83/11.0, \x83/13.0, \x83/14.0, \x83/16.0, "
					"\x83/18.0, \x83/20.0, \x83/22.0";
> = {0};

/// @brief The list of available ISOs
int ISORating <
	string UIName = "    ISO Rating:";
	string UIWidget = "Dropdown";
	string UIList = "ISO100, ISO200, ISO400, ISO800";
>;

/// @brief Shutter speed.
int ShutterSpeed <
	string UIName = "    Shutter Speed:";
	string UIWidget = "Dropdown";
	string UIList = "1s, 1/2s, 1/4s, 1/8s, 1/15s, 1/30s, 1/60s, 1/125s, "
					"1/250s, 1/500s, 1/1000s, 1/2000s, 1/4000s";
>;

/// @brief Key Value (Exposure bias).
float KeyValue <
	string UIName = "    Key Value (Auto-Exposure Bias):";
	string UIWidget = "Spinner";
	float UIMin = 0.0f;
	float UIMax = 0.5f;
> = {0.115f};

/// @brief Manual Exposure.
float ManualExposure <
	string UIName = "    Manual Exposure:";
	string UIWidget = "Spinner";
	float UIMin = -32.0f;
	float UIMax = 32.0f;
> = {-16.0f};

/// @brief Bit of spacing.
int Spacer1 <
	string UIName = " ";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief An offset (in EVs) to offset exposure by at day.
float EVDay <
	string UIName = "    Exposure Value Day:                           EV \xB1";
	string UIWidget = "Spinner";
	float UIMin = -100.0f;
	float UIMax = 100.0f;
> = {0.0f};

/// @brief An offset (in EVs) to offset exposure by at night.
float EVNight <
	string UIName = "    Exposure Value Night:                         EV \xB1";
	string UIWidget = "Spinner";
	float UIMin = -100.0f;
	float UIMax = 100.0f;
> = {0.0f};

/// @brief An offset (in EVs) to offset exposure by at night.
float EVInterior <
	string UIName = "    Exposure Value Interior:                     EV \xB1";
	string UIWidget = "Spinner";
	float UIMin = -100.0f;
	float UIMax = 100.0f;
> = {0.0f};

/// @brief Bit of spacing.
int Spacer2 <
	string UIName = "  ";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

int Kelvin <
	string UIName = "Color Temperature:";
	string UIWidget = "Spinner";
	int UIMin = 0;
> = {6500};

/// @brief Bit of spacing.
int Spacer3 <
	string UIName = "   ";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief Copyright info.
int CopyrightInfo0 <
	string UIName = "Copyright \xA9 2022 nullfractal";
	int UIMin = 0;
	int UIMax = 0;
> = {0};

/// @brief The list of aperture numbers to pick.
static const float FNumbers[23] =
{
    1.8f, 2.0f, 2.2f, 2.5f, 2.8f, 3.2f, 3.5f, 4.0f, 4.5f, 5.0f, 5.6f, 6.3f, 7.1f,
	8.0f, 9.0f, 10.0f, 11.0f, 13.0f, 14.0f, 16.0f, 18.0f, 20.0f, 22.0f
};

/// @brief The list of ISO numbers to use.
static const float ISOValues[4] =
{
	100.0f, 200.0f, 400.0f, 800.0f
};

/// @brief The available shutter speeds in seconds.
static const float ShutterSpeedValues[13] =
{
    1.0f / 1.0f, 1.0f / 2.0f, 1.0f / 4.0f, 1.0f / 8.0f, 1.0f / 15.0f, 
	1.0f / 30.0f, 1.0f / 60.0f, 1.0f / 125.0f, 1.0f / 250.0f, 1.0f / 500.0f, 
	1.0f / 1000.0f, 1.0f / 2000.0f, 1.0f / 4000.0f
};

/// @brief Scale factor used for storing physical light units in FP16 floats.
static const float FP16Scale = 0.0009765625f;

/// @brief Simple manual exposure mode.
static const int ExposureModes_ManualSimple = 0;

/// @brief Saturation-based exposure mode.
static const int ExposureModes_Manual_SBS = 1;

/// @brief Standard-based exposure mode.
static const int ExposureModes_Manual_SOS = 2;

/// @brief Automatic exposure mode.
static const int ExposureModes_Automatic = 3;

/// @brief The aperture f/number to use for exposure.
static const float ApertureFNumber = FNumbers[ApertureSize];

/// @brief The ISO number to use for exposure.
static const float ISO = ISOValues[ISORating];

/// @brief The shutter speed to use for PB-Exposure
static const float ShutterSpeedValue = ShutterSpeedValues[ShutterSpeed];

/// @author MJP
#include "Include/Exposure.fxh"

/// @author TreyM
#include "Include/TriDither.fxh"

/// @brief Apply a 3D LUT.
float3 ApplyLUT(in float3 image, in Texture2D lutTexture)
{
	/// @brief Get dimensions of input texture.
	uint2 lutDimensions;
	lutTexture.GetDimensions(lutDimensions.x, lutDimensions.y);

	/// @brief Get block size of input texture.
	uint lutBlockSize = lutDimensions.x / lutDimensions.y;

	/// @brief Get pixel size in input texture.
	float2 lutPixelSize = rcp(lutDimensions);

	/// @brief Image in subpixel coordinates.
	float3 lut3D = image * (lutBlockSize - 1);

	/// @brief 2D LUT coordinates.
	float2 lut2D[2];

	// Front
	lut2D[0].x = floor(lut3D.z) * lutBlockSize + lut3D.x;
	lut2D[0].y = lut3D.y;

	// Back
	lut2D[1].x = ceil(lut3D.z) * lutBlockSize + lut3D.x;
	lut2D[1].y = lut3D.y;

	// Convert from texel to texture coords.
	lut2D[0] = (lut2D[0] + 0.5) * lutPixelSize;
	lut2D[1] = (lut2D[1] + 0.5) * lutPixelSize;

	// LUT interpolation
	return lerp(
		lutTexture.SampleLevel(Sampler1, lut2D[0], 0).rgb,
		lutTexture.SampleLevel(Sampler1, lut2D[1], 0).rgb,
		frac(lut3D.z)
	);
}


/// @brief Convert an HDR linear image into ARRI LogC4.
/// @author TreyM
float3 LogC4(float3 HDRLinear)
{
    float3 LogColor;

    LogColor = (HDRLinear <=  -0.0180570)
             ? (HDRLinear  - (-0.0180570)) / 0.113597
             : (log2(2231.826309067688 * HDRLinear + 64.0) - 6.0) / 14.0 
			 * 0.9071358748778104 + 0.0928641251221896;

    return LogColor;
}


/// @brief These functions avoid pow() to efficiently approximate sRGB with an error < 0.4%.
/// @author James Stanard (Microsoft)
float3 ApplySRGBCurve_Fast( float3 x )
{
    return x < 0.0031308 
			 ? 12.92 * x 
			 : 1.13005 * sqrt(x - 0.00228) - 0.13448 * x + 0.005719;
}

float3 RemoveSRGBCurve_Fast( float3 x )
{
    return x < 0.04045 
			 ? x / 12.92 
			 : -7.43605 * x - 31.24297 * sqrt(-0.53792 * x + 1.279924) + 35.34864;
}

/// @brief Convert a Kelvin value in K and convert to an RGB value.
/// @author Prod80 (Bas Veth)
/// @copyright MIT, Copyright (c) 2020 prod80
float3 KelvinToRGB( in float k )
{
    float3 ret;
    float kelvin     = clamp( k, 1000.0f, 40000.0f ) / 100.0f;
    if( kelvin <= 66.0f )
    {
        ret.r        = 1.0f;
        ret.g        = saturate( 0.39008157876901960784f * log( kelvin ) - 0.63184144378862745098f );
    }
    else
    {
        float t      = max( kelvin - 60.0f, 0.0f );
        ret.r        = saturate( 1.29293618606274509804f * pow( t, -0.1332047592f ));
        ret.g        = saturate( 1.12989086089529411765f * pow( t, -0.0755148492f ));
    }
    if( kelvin >= 66.0f )
        ret.b        = 1.0f;
    else if( kelvin < 19.0f )
        ret.b        = 0.0f;
    else
        ret.b        = saturate( 0.54320678911019607843f * log( kelvin - 10.0f ) - 1.19625408914f );
    return ret;
}

#define DN( day, night ) lerp(night, day, ENightDayFactor)
#define DNI( day, night, interior ) lerp(DN(day, night), interior, EInteriorFactor)
#define DNIAdditive( day, night, interior ) (DN(day, night) + (interior * EInteriorFactor))

Texture2D LogC4ToSRGB <
	string ResourceName = "Include/Textures/LUTs/logc4tosrgb.png"; 
>;

float4 PS_Draw(VS_OUTPUT_POST IN, float4 v0 : SV_POSITION0, uniform uint toneMapper) : SV_TARGET
{
	// Output color.
	float4 res;

	// Input HDR color.
	float4 color; 
	color = TextureColor.Sample(Sampler0, IN.texcoord0.xy);

	// Lens texture.
	float3 lens = TextureLens.Sample(Sampler1, IN.texcoord0.xy).rgb;

	// Lens amount.
	color.rgb += lens * ENBParams01.y;

	// Bloom texture.
	float3 bloom = TextureBloom.Sample(Sampler1, IN.texcoord0.xy).rgb;

	// Isolate bloom from color.
	bloom = bloom - color.rgb;
	bloom = max(bloom, 0.0);

	// Bloom amount.
	color.rgb += bloom * ENBParams01.x;

	// Get adapt texture.
	float grayadaptation = TextureAdaptation.Load(uint3(0, 0, 0)).x;
	float exposure;

	// Calculate EV offset.
	float ExposureValue = DNI(EVDay, EVNight, EVInterior);

	// Do PB-Exposure
	color.rgb = CalcExposedColor(color.rgb, grayadaptation, ExposureValue, exposure);

	// Apply color temperature
	color.rgb *= KelvinToRGB(Kelvin);

	/* Primaries */

	// Apply LogC4 to linear color.
	color.rgb = LogC4(color.rgb);

	/* Conversion */

	// Convert LogC4 to sRGB
	color.rgb = ApplyLUT(color.rgb, LogC4ToSRGB);

	// Apply sRGB curve.
	color.rgb = RemoveSRGBCurve_Fast(color.rgb);

	// Dither to 10-bit for postpass.
	color.rgb += TriDither(color.rgb, IN.texcoord0.xy, 10);

	// Finalize.
	res.rgb = saturate(color.rgb);
	res.a = 1.0;

	// Return.	
	return res;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//Vanilla post process. Do not modify
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
float4	PS_DrawOriginal(VS_OUTPUT_POST IN, float4 v0 : SV_Position0) : SV_Target
{
	float4	res;
	float4	color;

	float2	scaleduv=Params01[6].xy*IN.texcoord0.xy;
	scaleduv=max(scaleduv, 0.0);
	scaleduv=min(scaleduv, Params01[6].zy);

	color=TextureColor.Sample(Sampler0, IN.texcoord0.xy); //hdr scene color

	float4	r0, r1, r2, r3;
	r1.xy=scaleduv;
	r0.xyz = color.xyz;
	if (0.5<=Params01[0].x) r1.xy=IN.texcoord0.xy;
	r1.xyz = TextureBloom.Sample(Sampler1, r1.xy).xyz;
	r2.xy = TextureAdaptation.Sample(Sampler1, IN.texcoord0.xy).xy; //in skyrimse it two component

	r0.w=dot(float3(2.125000e-001, 7.154000e-001, 7.210000e-002), r0.xyz);
	r0.w=max(r0.w, 1.000000e-005);
	r1.w=r2.y/r2.x;
	r2.y=r0.w * r1.w;
	if (0.5<Params01[2].z) r2.z=0xffffffff; else r2.z=0;
	r3.xy=r1.w * r0.w + float2(-4.000000e-003, 1.000000e+000);
	r1.w=max(r3.x, 0.0);
	r3.xz=r1.w * 6.2 + float2(5.000000e-001, 1.700000e+000);
	r2.w=r1.w * r3.x;
	r1.w=r1.w * r3.z + 6.000000e-002;
	r1.w=r2.w / r1.w;
	r1.w=pow(r1.w, 2.2);
	r1.w=r1.w * Params01[2].y;
	r2.w=r2.y * Params01[2].y + 1.0;
	r2.y=r2.w * r2.y;
	r2.y=r2.y / r3.y;
	if (r2.z==0) r1.w=r2.y; else r1.w=r1.w;
	r0.w=r1.w / r0.w;
	r1.w=saturate(Params01[2].x - r1.w);
	r1.xyz=r1 * r1.w;
	r0.xyz=r0 * r0.w + r1;
	r1.x=dot(r0.xyz, float3(2.125000e-001, 7.154000e-001, 7.210000e-002));
	r0.w=1.0;
	r0=r0 - r1.x;
	r0=Params01[3].x * r0 + r1.x;
	r1=Params01[4] * r1.x - r0;
	r0=Params01[4].w * r1 + r0;
	r0=Params01[3].w * r0 - r2.x;
	r0=Params01[3].z * r0 + r2.x;
	r0.xyz=saturate(r0);
	r1.xyz=pow(r1.xyz, Params01[6].w);
	//active only in certain modes, like khajiit vision, otherwise Params01[5].w=0
	r1=Params01[5] - r0;
	res=Params01[5].w * r1 + r0;

//	res.xyz = color.xyz;
//	res.w=1.0;
	return res;
}

technique11 arriLogC4 <string UIName="ARRI LogC4";>
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
		SetPixelShader(CompileShader(ps_5_0, PS_Draw(0)));
	}
}

technique11 reinhard <string UIName = "Reinhard";>
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
		SetPixelShader(CompileShader(ps_5_0, PS_Draw(1)));
	}
}

technique11 ORIGINALPOSTPROCESS <string UIName="Vanilla";> //do not modify this technique
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
		SetPixelShader(CompileShader(ps_5_0, PS_DrawOriginal()));
	}
}