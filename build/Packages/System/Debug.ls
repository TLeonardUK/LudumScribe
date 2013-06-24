// -----------------------------------------------------------------------------
// 	debug.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to expose
//	debugging functionality.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.System.Debug;
using System.OS;

// -----------------------------------------------------------------------------
//	This class is used to expose debugging functionality.
// -----------------------------------------------------------------------------
public static native("lsDebug") class Debug
{
	public static native("Error") 	  void 				Error(string message);
	public static native("Break") 	  void 				Break();
	//public static native("TraceStack") StackFrame[] 	TraceStack();
	
	public static 				  void Assert(bool result)
	{
#if CONFIG=="Debug"
		if (!result)
		{
			Error("Assert Failed");		
//			Error("Assert Failed:\n\n" + callstack);
			Break();
			OS.Exit(0);
		}
#endif
	}
}
