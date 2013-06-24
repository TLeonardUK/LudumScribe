// -----------------------------------------------------------------------------
// 	debug.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to expose
//	debugging functionality.
// -----------------------------------------------------------------------------

#include <windows.h>
#include "Packages/Native/Win32/System/Debug.hpp"

// -----------------------------------------------------------------------------
//	Shows an error message to the user.
// -----------------------------------------------------------------------------
void lsDebug::Error(lsString message)
{
	MessageBoxA(NULL, "Debug Error", message.ToCString(), MB_OK|MB_ICONERROR);
}

// -----------------------------------------------------------------------------
//	Triggers a breakpoint.
// -----------------------------------------------------------------------------
void lsDebug::Break()
{
	__debugbreak();
}
