// -----------------------------------------------------------------------------
// 	file.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common file operations.
// -----------------------------------------------------------------------------

#include <windows.h>
#include "Packages/Native/Win32/Compiler/Support/Exceptions.hpp"
#include "Packages/Native/Win32/Compiler/Support/Types.hpp"
#include "Packages/Native/Win32/System/File.hpp"

bool lsFile::Create(lsString path, bool recursive)
{
	HANDLE handle = CreateFileA(path.ToCString(),
								GENERIC_READ | GENERIC_WRITE,
								FILE_SHARE_DELETE | FILE_SHARE_READ | FILE_SHARE_WRITE,
								NULL,
								CREATE_NEW,
								FILE_ATTRIBUTE_NORMAL,
								NULL);
	
	if (handle != INVALID_HANDLE_VALUE)
	{
		CloseHandle(handle);
		return true;
	}
	
	return false;
}

bool lsFile::Delete(lsString path)
{
	int result = DeleteFileA(path.ToCString());
	return (result != 0);
}

bool lsFile::Copy(lsString from, lsString to, bool overwrite)
{
	int result = CopyFileA(from.ToCString(), to.ToCString(), !overwrite);
	return (result != 0);
}

bool lsFile::Rename(lsString from, lsString to)
{
	// Make sure we are renaming a directory.
	if (!Exists(from))
	{
		return false;
	}
	
	int result = MoveFileA(from.ToCString(), to.ToCString());
	return (result != 0);
}

bool lsFile::Exists(lsString path)
{	
	DWORD flags = GetFileAttributesA(path.ToCString());
	if (flags == INVALID_FILE_ATTRIBUTES)
	{
		return false;
	}
	if ((flags & FILE_ATTRIBUTE_DIRECTORY) != 0)
	{
		return false;
	}
	return true;
}
