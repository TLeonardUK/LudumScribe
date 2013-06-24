// -----------------------------------------------------------------------------
// 	directory.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common directory operations.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_SYSTEM_DIRECTORY__
#define __LS_PACKAGES_NATIVE_WIN32_SYSTEM_DIRECTORY__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	This class is used to perform several common directory operations.
// -----------------------------------------------------------------------------
class lsDirectory
{
private:
	static lsArray<lsString>* ListInternal(lsString from, int types, lsString base, lsArray<lsString>* result, bool recursive);

public:
	static bool Create(lsString path, bool recursive);
	static bool Delete(lsString path, bool recursive);
	static bool Copy(lsString path, lsString from, bool merge);
	static bool Rename(lsString from, lsString to);
	static bool Exists(lsString path);

	static lsString GetWorkingDirectory();
	static bool SetWorkingDirectory(lsString path);
	
	static lsArray<lsString>* List(lsString from, int types, bool recursive);
	static lsArray<lsString>* ListVolumes();
	
};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_DIRECTORY_

