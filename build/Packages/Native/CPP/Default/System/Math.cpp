// -----------------------------------------------------------------------------
// 	math.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common math operations.
// -----------------------------------------------------------------------------

#include <math.h>
#include "Packages/Native/CPP/Default/System/Math.hpp"

float lsMath::Abs(float v)
{
	return fabs(v);
}

int lsMath::Abs(int v)
{
	return abs(v);
}

float lsMath::Acos(float v)
{
	return acos(v);
}

float lsMath::Asin(float v)
{
	return asin(v);
}

float lsMath::Atan(float v)
{
	return atan(v);
}

float lsMath::Atan2(float y, float x)
{
	return atan2(y, x);
}

float lsMath::Ceiling(float v)
{
	return ceil(v);
}

float lsMath::Floor(float v)
{
	return floor(v);
}

float lsMath::Cos(float v)
{
	return cos(v);
}

float lsMath::Cosh(float v)
{
	return cosh(v);
}

float lsMath::Exp(float v)
{
	return exp(v);
}

float lsMath::Log(float v)
{
	return log(v);
}

float lsMath::Log10(float v)
{
	return log10(v);
}

float lsMath::Pow(float v1, float v2)
{
	return pow(v1, v2);
}

float lsMath::Round(float v)
{
	// the round() func dosen't seem to be available in VS's implementation
	// of the cmath library :(
	return floor(v + 0.5f);
}

float lsMath::Sin(float v)
{
	return sin(v);
}

float lsMath::Sinh(float v)
{
	return sinh(v);
}

float lsMath::Sqrt(float v)
{
	return sqrt(v);
}

float lsMath::Tan(float v)
{
	return tan(v);
}

float lsMath::Tanh(float v)
{
	return tanh(v);
}

float lsMath::Truncate(float v)
{
	// the trunc() func dosen't seem to be available in VS's implementation
	// of the cmath library :(
	return (v > 0) ? floor(v) : ceil(v); 
}

bool lsMath::IsInf(float v)
{    
	// the isinf() func dosen't seem to be available in VS's implementation
	// of the cmath library :(
	return !IsNAN(v) && IsNAN(v - v);
}

bool lsMath::IsNAN(float v)
{
	// the isnan() func dosen't seem to be available in VS's implementation
	// of the cmath library :(
	volatile double d = v;
    return d != d;
}
