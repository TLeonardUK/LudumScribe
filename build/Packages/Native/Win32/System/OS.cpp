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
#include "Packages/Native/Win32/System/Path.hpp"

// String methods declared in ludumscribe code.
extern lsString lsString_Replace(lsString haystack, lsString needle, lsString needle_to);

// -------------------------------------------------------------------------
//	Gets an arbitrary tick counter (in milliseconds).
// -------------------------------------------------------------------------
int lsOS::GetTicks()
{
	return GetTickCount();
}

// -------------------------------------------------------------------------
//	Prematurely returns control to the OS with the given exit code.
// -------------------------------------------------------------------------
void lsOS::Exit(int exitcode)
{
	exit(exitcode);
}

// -------------------------------------------------------------------------
//	Executes a program and returns true on success.
// -------------------------------------------------------------------------
bool lsOS::Execute(lsString path, lsString cmd_line)
{
	PROCESS_INFORMATION pi = { 0 };
	STARTUPINFOA		si = { sizeof(si) };
	
	path = lsString_Replace(path, "/", "\\");

	lsString dir = lsPath::StripFilename(path);

	if (!CreateProcessA(NULL, (LPSTR)((lsString("\"") + path + "\" " + cmd_line).ToCString()), NULL, NULL, true, CREATE_DEFAULT_ERROR_MODE, NULL, (LPSTR)dir.ToCString(), &si, &pi)) 
	{
		return false;		
	}

	WaitForSingleObject(pi.hProcess, INFINITE);

	int res = GetExitCodeProcess(pi.hProcess, (DWORD*)&res) ? res : -1;

	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	return (res == 0);
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