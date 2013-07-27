// -----------------------------------------------------------------------------
// 	math.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common math operations.
// -----------------------------------------------------------------------------
using native {NATIVE_PACKAGE_NAMESPACE}.System.Math;

// -----------------------------------------------------------------------------
//	This class is used to perform several common math operations.
// -----------------------------------------------------------------------------
public static native("lsMath") class Math
{
	public const float PI = 3.14159265358979;
	public const float E  = 2.71828182845904;
	
	public static native("Abs") 		float Abs		(float v);
	public static native("Abs") 		int   Abs		(int v);
	public static native("Acos") 		float Acos		(float v);
	public static native("Asin") 		float Asin		(float v);
	public static native("Atan") 		float Atan		(float v);
	public static native("Atan2") 		float Atan2		(float y, float x);
	public static native("Ceiling") 	float Ceiling	(float v);
	public static native("Floor") 		float Floor		(float v);
	public static native("Cos") 		float Cos		(float v);
	public static native("Cosh") 		float Cosh		(float v);
	public static native("Exp") 		float Exp		(float v);
	public static native("Log") 		float Log		(float v);
	public static native("Log10") 		float Log10		(float v);
	public static native("Pow") 		float Pow		(float v1, float v2);
	public static native("Round") 		float Round		(float v);
	public static native("Sin") 		float Sin		(float v);
	public static native("Sinh") 		float Sinh		(float v);
	public static native("Sqrt") 		float Sqrt		(float v);
	public static native("Tan") 		float Tan		(float v);
	public static native("Tanh") 		float Tanh		(float v);
	public static native("Truncate") 	float Truncate	(float v);
	public static native("IsInf") 		bool  IsInf		(float v);
	public static native("isNan") 		bool  IsNAN		(float v);

	public static int Sign(float v)
	{
		return (v > 0 ? 1 : (v < 0 ? -1 : 0));
	}	
	public static int Sign(int v)
	{
		return (v > 0 ? 1 : (v < 0 ? -1 : 0));
	}
	
	public static float Max(float v1, float v2)
	{
		return (v1 > v2 ? v1 : v2);	
	}
	public static int Max(int v1, int v2)
	{
		return (v1 > v2 ? v1 : v2);	
	}
	
	public static float Min(float v1, float v2)
	{
		return (v1 < v2 ? v1 : v2);
	}
	public static int Min(int v1, int v2)
	{
		return (v1 < v2 ? v1 : v2);	
	}
	
	public static int Cap(int v1, int min, int max)
	{
		if (v1 < min)
		{
			v1 = min;
		}
		if (v1 > max)
		{
			v1 = max;
		}
		return v1;
	}
	public static float Cap(float v1, float min, int max)
	{
		if (v1 < min)
		{
			v1 = min;
		}
		if (v1 > max)
		{
			v1 = max;
		}
		return v1;
	}
	
	public static float DegToRad(float v)
	{
		return v * (PI / 180);
	}
	public static float RadToDeg(float v)
	{
		return v * (180 / PI);
	}
}
