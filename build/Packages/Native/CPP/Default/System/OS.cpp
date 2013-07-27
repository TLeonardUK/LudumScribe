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

#ifdef _WIN32

#include <Windows.h>

#else defined(__linux__)

#include <sys/time.h>
#include <ctime>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

#endif

#include "Packages/Native/CPP/Default/System/OS.hpp"
#include "Packages/Native/CPP/Default/System/Path.hpp"

// String methods declared in ludumscribe code.
extern lsString lsString_Replace(lsString haystack, lsString needle, lsString needle_to);

// -------------------------------------------------------------------------
//	Gets an arbitrary tick counter (in milliseconds).
// -------------------------------------------------------------------------
int lsOS::GetTicks()
{
#ifdef _WIN32
	return GetTickCount();
#else defined(__linux__) 
	return clock() / (CLOCKS_PER_SEC / 1000);
#endif
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
#ifdef _WIN32
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
#else defined(__linux__)
	pid_t pid = fork();
	int status;

	switch (pid) 
	{
	case -1: 
		return 0;
	
	case 0: 
		execl(path.ToCString(), path.ToCString(), cmd_line.ToCString(), NULL); 
		exit(1);
		
	default: 
		while (!WIFEXITED(status)) 
		{
			waitpid(pid, &status, 0); 
		}

		return (WEXITSTATUS(status) == 0);
	}
#endif
}

// -------------------------------------------------------------------------
//	Gets the environment strings in the format;
//
//		key=value|key=value|key=value
//
// -------------------------------------------------------------------------
lsString lsOS::GetEnvironmentString()
{
	lsString result;

#ifdef _WIN32 = ""
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
#else defined(__linux__)
	extern char** environ;

	std::string newvar = "";
	char* var = NULL;
	int i = 0;
	
	while (true)
	{
		var = *(environ + (i++));
		if (var == NULL)
		{
			break;
		}
		
		newvar = std::string(var);
	 
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
	}
#endif

	return result;
}