// -----------------------------------------------------------------------------
// 	debug.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to expose
//	debugging functionality.
// -----------------------------------------------------------------------------

#ifdef _WIN32
#include <windows.h>
#elif defined(__linux__) || defined(__APPLE__) 
#include <csignal>
#endif

#include <typeinfo>
#include "Packages/Native/CPP/Default/System/Debug.hpp"

// -----------------------------------------------------------------------------
//	Shows an error message to the user.
// -----------------------------------------------------------------------------
void lsDebug::Error(lsString message)
{
#ifdef _WIN32
	MessageBoxA(NULL, "Debug Error", message.ToCString(), MB_OK|MB_ICONERROR);
#elif defined(__linux__) || defined(__APPLE__) 
	printf("Debug Error: %s\n", message.ToCString());
#endif
}

// -----------------------------------------------------------------------------
//	Triggers a breakpoint.
// -----------------------------------------------------------------------------
void lsDebug::Break()
{
#ifdef _WIN32
	__debugbreak();
#elif defined(__linux__) || defined(__APPLE__) 
	raise(SIGTRAP);
#endif
}
