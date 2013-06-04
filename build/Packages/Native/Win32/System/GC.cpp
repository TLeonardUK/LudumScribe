// -----------------------------------------------------------------------------
// 	gc.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the console.
// -----------------------------------------------------------------------------

#include "Packages/Native/Win32/System/GC.hpp"

#include "Packages/Native/Win32/System/GC/include/gc.h"

// -------------------------------------------------------------------------
//  Runs a garbage collection cycle. If full is true then all garbage will
//	be collected, if false then garbage will be collected incrementally.
// -------------------------------------------------------------------------
void lsGC::Collect(bool full)
{
	lsGCObject::GCCollect(full);
}

// -------------------------------------------------------------------------
//  Gets the number of bytes currently allocated.
// -------------------------------------------------------------------------
int lsGC::GetBytesAllocated()
{
	return GC_get_total_bytes();
}