// -----------------------------------------------------------------------------
// 	gc.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the console.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_GC__
#define __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_GC__

#include "Packages/Native/CPP/Default/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	Used as a base for all objects which can be thrown.
// -----------------------------------------------------------------------------
class lsGC
{
public:

	// -------------------------------------------------------------------------
	//  Runs a garbage collection cycle. If full is true then all garbage will
	//	be collected, if false then garbage will be collected incrementally.
	// -------------------------------------------------------------------------
	static void Collect(bool full);
	
	// -------------------------------------------------------------------------
	//  Gets the number of bytes currently allocated.
	// -------------------------------------------------------------------------
	static int GetBytesAllocated();

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_GC__

