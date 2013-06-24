// -----------------------------------------------------------------------------
// 	os.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the OS.
// -----------------------------------------------------------------------------

#include <stdio.h>
#include <string>
#include <assert.h>
#include <algorithm>
#include <stdarg.h>
#include <map>
#include <Windows.h>

#include "Packages/Native/Win32/System/OS.hpp"

// -------------------------------------------------------------------------
//	Prematurely returns control to the OS with the given exit code.
// -------------------------------------------------------------------------
void lsOS::Exit(int exitcode)
{
	exit(exitcode);
}

// -------------------------------------------------------------------------
//	Gets the environment strings in the format;
//
//		key=value|key=value|key=value
//
// -------------------------------------------------------------------------
lsString lsOS::GetEnvironmentString()
{
	lsString result = "";

	LPTCH str = GetEnvironmentStrings();
	
	std::string newvar = "";
	unsigned int offset = 0;
	while (true)
	{
		char chr = str[offset];
		if (chr == '\0')
		{
			// Should be in the format of name=value.
			unsigned int idx = newvar.find('=');
			if (idx > 0) // Ignore envvars that start with an = sign 
							// (some wierd variables we don't care are reported at the start like this).
			{
				if (result != "")
				{
					result = result + "|";
				}
				result = result + lsString(newvar.substr(0, idx).c_str()) + "=" + lsString(newvar.substr(idx + 1).c_str());
			}

			// End of values?
			if (str[offset + 1] == '\0')
			{
				break;
			}

			newvar = "";
		}
		else
		{
			newvar += chr;
		}

		offset++;
	}
			
	FreeEnvironmentStrings(str);

	return result;
}