// -----------------------------------------------------------------------------
// 	runtime.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the default runtime functionality.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------

#include "Packages/Compiler/Support/Native/Win32/Runtime.hpp"

// -----------------------------------------------------------------------------
//	Called at the start of the entry point, initializes the runtime.
// -----------------------------------------------------------------------------
void lsRuntimeInit()
{
}

// -----------------------------------------------------------------------------
//	Called at the end of the entry point, deinitializes the runtime.
// -----------------------------------------------------------------------------
void lsRuntimeDeInit()
{
}


void IO::Print(lsString value)
{
	printf(value.ToCString());
}
 