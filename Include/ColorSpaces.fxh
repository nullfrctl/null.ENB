/**
 * Copyright (C) 2022 nullfractal
 * SPDX-License-Identifier: Unlicense <https://unlicense.org>
 */

/// @brief error < 0.2 degrees, saves about 40% vs atan2 
/// @author Lord of Lunacy and Marty McFly
float fastAtan2(float y, float x)
{
    bool a = abs(y) < abs(x);    
    float i = (a) ? (y * rcp(x)) : (x * rcp(y));    
    i = i * (1.0584 + abs(i) * -0.273);
    float piadd = y > 0 ? Pi : -Pi;     
    i = a ? (x < 0 ? piadd : 0) + i : 0.5 * piadd - i;
    return i;
}

/// @brief Matrix for RGB to CIE-XYZ conversion.
static const float3x3 RGBtoXYZMatrix = {
    0.4124564, 0.3575761, 0.1804375,
    0.2126729, 0.7151522, 0.0721750,
    0.0193339, 0.1191920, 0.9503041
};

/// @brief Matrix for CIE-XYZ to RGB conversion.
static const float3x3 XYZtoRGBMatrix = {
    3.2404542, -1.5371385, -0.4985314,
   -0.9692660,  1.8760108,  0.0415560,
    0.0556434, -0.2040259,  1.0572252
};

static const float3x3 RGBtoLMSMatrix = {
	0.4122214708, 0.5363325363, 0.0514459929,
	0.2119034982, 0.6806995451, 0.1073969566,
	0.0883024619, 0.2817188376, 0.6299787005
};

static const float3x3 LMStoOklabMatrix = {
    0.2104542553,  0.7936177850, -0.0040720468,
    1.9779984951, -2.4285922050,  0.4505937099,
    0.0259040371,  0.7827717662, -0.8086757660
};

static const float3x3 LMStoRGBMatrix = {
	 4.0767416621, -3.3077115913,  0.2309699292,
	-1.2684380046,  2.6097574011, -0.3413193965,
	-0.0041960863, -0.7034186147,  1.7076147010
};

/// @brief Generic Lab struct.
struct Lab 
{
	float L;
	float a;
	float b;
};

/// @brief Generic LCh struct.
struct LCh
{
	float L;
	float C;
	float h; // Should be expressed in degrees, but radians work too.
};

/// @brief Convert a linear sRGB color to CIE-XYZ space.
float3 RGBtoXYZ(float3 inputRGB)
{
	return mul(RGBtoXYZMatrix, inputRGB);
}

static const float3 ReferenceWhite = { 0.950489f, 1.000f, 1.088840f };

/// @brief Convert CIE-XYZ to CIE-L*a*b*
Lab XYZtoCIELab(float3 inputXYZ)
{
	float3 res = max(inputXYZ / ReferenceWhite, 0.0f);

	res = res > 0.008856
		? pow(res, rcp(3.0f))
		: (903.3f * res + 16.0f) / 116.0f;

	Lab retValue;
	retValue.L = 116.0f * res.y - 16.0f;
	retValue.a = 500.0f * (res.x - res.y);
	retValue.b = 200.0f * (res.y - res.z);

	return retValue;
}

/// @brief Convert any Lab color-space to an LCh* representation
LCh LabToLCh(Lab inputLab)
{
	float hue = RadToDeg(fastAtan2(inputLab.b, inputLab.a));

	LCh retValue;
	retValue.L = inputLab.L; // L*
	retValue.C = sqrt((inputLab.a * inputLab.a) + (inputLab.b * inputLab.b)); // C*
	retValue.h = hue >= 0.0f ? hue : hue + 360; // h*

	return retValue;
}

/// @brief Convert an LCh* space to a Lab color-space.
Lab LChToLab(LCh inputLCh)
{
	Lab retValue;
	retValue.L = inputLCh.L; // L*
	retValue.a = inputLCh.C * cos(DegToRad(inputLCh.h)); // a*
	retValue.b = inputLCh.C * sin(DegToRad(inputLCh.h)); // b*

	return retValue;
}

/// @brief Convert CIE-L*a*b* to CIE-XYZ
float3 CIELabToXYZ(Lab inputLab)
{
	float3 res;

	res.y = (inputLab.L + 16.0f) / 116.0f;
	res.x = inputLab.a / 500.0f + res.y;
	res.z = res.y - inputLab.b / 200.0f;

	res.x = (res.x * res.x * res.x) > 0.008856
		  ? (res.x * res.x * res.x)
		  : (116.0f * res.x - 16.0f) / 903.3f;

	res.y = inputLab.L > (903.3f * 0.008856)
		  ? (res.y * res.y * res.y)
		  : inputLab.L / 903.3f;

	res.z = (res.z * res.z * res.z) > 0.008856
		  ? (res.z * res.z * res.z)
		  : (116.0f * res.z - 16.0f) / 903.3f;

	return res * ReferenceWhite;
}

/// @brief Convert CIE-XYZ to RGB
float3 XYZtoRGB(float3 inputXYZ)
{
	return mul(XYZtoRGBMatrix, inputXYZ);
}

/* Macros */

/// @brief Macro to convert RGB to CIE-L*a*b*
Lab RGBtoCIELab(float3 inputRGB)
{
	return XYZtoCIELab(RGBtoXYZ(inputRGB));
}

Lab RGBtoOklab(float3 inputRGB)
{
	float3 LMS = mul(RGBtoLMSMatrix, inputRGB);
	LMS = pow(abs(LMS), rcp(3));
	LMS = mul(LMStoOklabMatrix, LMS);

	Lab retValue;
	retValue.L = LMS.x;
	retValue.a = LMS.y;
	retValue.b = LMS.z;

	return retValue;
}

/// @brief Macro to convert CIE-L*a*b* to RGB
float3 CIELabToRGB(Lab inputLab)
{
	return XYZtoRGB(CIELabToXYZ(inputLab));
}

/// @brief Convert Oklab to RGB
float3 OklabToRGB(Lab inputOklab)
{
	float3 LMS;
	LMS.x = inputOklab.L + 0.3963377774 * inputOklab.a + 0.2158037573 * inputOklab.b;
    LMS.y = inputOklab.L - 0.1055613458 * inputOklab.a - 0.0638541728 * inputOklab.b;
    LMS.z = inputOklab.L - 0.0894841775 * inputOklab.a - 1.2914855480 * inputOklab.b;

	LMS *= (LMS * LMS);

	return mul(LMStoRGBMatrix, LMS);
}

/// @brief Macro to convert RGB to CIE-L*C*h*
LCh RGBtoCIELChab(float3 inputRGB)
{
	return LabToLCh(RGBtoCIELab(inputRGB));
}

/// @brief Macro to convert CIE-L*C*h*(ab)
float3 CIELChabToRGB(LCh inputLCh)
{
	return CIELabToRGB(LChToLab(inputLCh));
}