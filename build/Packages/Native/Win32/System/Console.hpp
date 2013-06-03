// -----------------------------------------------------------------------------
// 	console.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the console.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_SYSTEM_CONSOLE__
#define __LS_PACKAGES_NATIVE_WIN32_SYSTEM_CONSOLE__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	Used as a base for all objects which can be thrown.
// -----------------------------------------------------------------------------
class lsConsole
{
public:

	// -------------------------------------------------------------------------
	//	Writes a string of text to the console.
	// -------------------------------------------------------------------------
	static void Write		(lsString output);

	// -------------------------------------------------------------------------
	//	Writes a string of text to the console followed by a new line.
	// -------------------------------------------------------------------------
	static void WriteLine	(lsString output);

	// -------------------------------------------------------------------------
	//  Reads a character from the console. Blocks if character is not available.
	// -------------------------------------------------------------------------
	static int  ReadChar	();

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_CONSOLE__

