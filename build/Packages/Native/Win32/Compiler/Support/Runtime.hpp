// -----------------------------------------------------------------------------
// 	runtime.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the default runtime functionality.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_RUNTIME__
#define __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_RUNTIME__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	These functions are called at the start and end of the entry point 
//	respectively and are responsible for starting and shutting down the runtime.
// -----------------------------------------------------------------------------
void lsRuntimeInit();
void lsRuntimeDeInit();

#endif // __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_RUNTIME__

