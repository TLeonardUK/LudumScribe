// -----------------------------------------------------------------------------
// 	math.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common math operations.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_MATH__
#define __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_MATH__

#include "Packages/Native/CPP/Default/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	This class is used to perform several common math operations.
// -----------------------------------------------------------------------------
class lsMath
{
public:
	static float Abs		(float v);
	static int   Abs		(int v);
	static float Acos		(float v);
	static float Asin		(float v);
	static float Atan		(float v);
	static float Atan2		(float y, float x);
	static float Ceiling	(float v);
	static float Floor		(float v);
	static float Cos		(float v);
	static float Cosh		(float v);
	static float Exp		(float v);
	static float Log		(float v);
	static float Log10		(float v);
	static float Pow		(float v1, float v2);
	static float Round		(float v);
	static float Sin		(float v);
	static float Sinh		(float v);
	static float Sqrt		(float v);
	static float Tan		(float v);
	static float Tanh		(float v);
	static float Truncate	(float v);

	static bool IsInf		(float v);
	static bool IsNAN		(float v);

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_MATH_

