// -----------------------------------------------------------------------------
// 	runtime.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the default runtime functionality.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_COMPILER_SUPPORT_NATIVE_WIN32_RUNTIME__
#define __LS_PACKAGES_COMPILER_SUPPORT_NATIVE_WIN32_RUNTIME__

#include "Packages/Compiler/Support/Native/Win32/Types.hpp"

// -----------------------------------------------------------------------------
//	These functions are called at the start and end of the entry point 
//	respectively and are responsible for starting and shutting down the runtime.
// -----------------------------------------------------------------------------
void lsRuntimeInit();
void lsRuntimeDeInit();

class IO
{
public:
	static void Print(lsString value);
};

#endif // __LS_COMPILER_SUPPORT_NATIVE_WIN32_RUNTIME__

