// -----------------------------------------------------------------------------
// 	os.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the OS.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_SYSTEM_OS__
#define __LS_PACKAGES_NATIVE_WIN32_SYSTEM_OS__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	Contains methods used to interact with the operating system.
// -----------------------------------------------------------------------------
class lsOS
{
public:
	static void Exit(int exitcode);
	static lsString GetEnvironmentString();

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_GC__

