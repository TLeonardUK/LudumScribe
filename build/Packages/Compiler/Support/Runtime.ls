// -----------------------------------------------------------------------------
// 	runtime.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the default runtime functionality.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.Runtime;

public static native("IO") class IO : null
{
	public static native("Print") void Print(string value);
}