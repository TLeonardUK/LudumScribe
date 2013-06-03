// -----------------------------------------------------------------------------
// 	console.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to interact with
//	the output console.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.System.Console;

// -----------------------------------------------------------------------------
//	This class is used to read/write from the standard output console.
// -----------------------------------------------------------------------------
public static native("lsConsole") class Console
{
	public static native("Write") 		void Write		(string output);
	public static native("WriteLine") 	void WriteLine	(string output);
	public static native("ReadChar") 	int  ReadChar	();
}
