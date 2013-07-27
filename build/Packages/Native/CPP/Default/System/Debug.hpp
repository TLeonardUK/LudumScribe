// -----------------------------------------------------------------------------
// 	debug.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to expose
//	debugging functionality.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_DEBUG__
#define __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_DEBUG__

#include "Packages/Native/CPP/Default/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	This class is used to expose debugging functionality.
// -----------------------------------------------------------------------------
class lsDebug
{
public:
	static void Error(lsString message);
	static void Break();

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_MATH_

