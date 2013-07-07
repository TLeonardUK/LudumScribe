// -----------------------------------------------------------------------------
// 	directory.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common directory operations.
// -----------------------------------------------------------------------------

#include <windows.h>
#include "Packages/Native/Win32/Compiler/Support/Exceptions.hpp"
#include "Packages/Native/Win32/Compiler/Support/Types.hpp"
#include "Packages/Native/Win32/System/Directory.hpp"
#include "Packages/Native/Win32/System/File.hpp"
#include "Packages/Native/Win32/System/Path.hpp"

bool lsDirectory::Create(lsString path, bool recursive)
{
	if (recursive == true)
	{
		lsArray<lsString>* cracked = lsPath::Crack(path);
		lsString crackPath = "";
		
		for (int i = 0; i < cracked->Length(); i++)
		{
			if (crackPath != "")
			{
				crackPath += "\\";
			}
			crackPath = cracked->GetIndex(i);
			
			if (!Exists(crackPath))
			{
				bool result = Create(crackPath, false);
				if (result == false)
				{
					return false;
				}
			}
		}
	}
	else
	{
		int result = CreateDirectoryA(path.ToCString(), NULL);
		return (result != 0);
	}
}

bool lsDirectory::Delete(lsString path, bool recursive)
{
	// Delete internal files recursively.
	lsArray<lsString>* files = List(path, 2, false);
	for (int i = 0; i < files->Length(); i++)
	{
		bool result = lsFile::Delete(path + "\\" + files->GetIndex(i));
		if (result == false)
		{
			return false;
		}
	}
	
	// Delete sub directories recursively.
	lsArray<lsString>* dirs = List(path, 2, false);
	for (int i = 0; i < dirs->Length(); i++)
	{
		bool result = Delete(path + "\\" + dirs->GetIndex(i), false);
		if (result == false)
		{
			return false;
		}
	}
	
	// Delete the actual directory.
	int result = RemoveDirectoryA(path.ToCString());
	return (result != 0);
}

bool lsDirectory::Copy(lsString from, lsString to, bool merge)
{
	// Copy directory if requried.
	if (Exists(to) == false)
	{
		Create(to, false);
	}
	
	// Copy internal files recursively.
	lsArray<lsString>* files = List(from, 2, false);
	for (int i = 0; i < files->Length(); i++)
	{
		lsString move_from = from + "\\" + files->GetIndex(i);
		lsString move_to   = to + "\\" + files->GetIndex(i);
		
		if (merge == true && lsFile::Exists(move_to))
		{
			lsFile::Delete(move_to);
		}

		bool result = lsFile::Copy(move_from, move_to, false);
		if (result == false)
		{
			return false;
		}
	}
	
	// Copy sub directories recursively.
	lsArray<lsString>* dirs = List(from, 2, false);
	for (int i = 0; i < dirs->Length(); i++)
	{
		lsString move_from = from + "\\" + dirs->GetIndex(i);
		lsString move_to   = to + "\\" + dirs->GetIndex(i);
		
		bool result = Copy(move_from, move_to, merge);
		if (result == false)
		{
			return false;
		}
	}

	return true;
}

bool lsDirectory::Rename(lsString from, lsString to)
{
	// Make sure we are renaming a directory.
	if (!Exists(from))
	{
		return false;
	}
	
	int result = MoveFileA(from.ToCString(), to.ToCString());
	return (result != 0);
}

bool lsDirectory::Exists(lsString path)
{
	DWORD flags = GetFileAttributesA(path.ToCString());
	if (flags == INVALID_FILE_ATTRIBUTES)
	{
		return false;
	}
	if ((flags & FILE_ATTRIBUTE_DIRECTORY) == 0)
	{
		return false;
	}
	return true;
}

lsString lsDirectory::GetWorkingDirectory()
{
	char buffer[1024];
	int result = GetCurrentDirectoryA(1024, buffer);
	if (result == 0)
	{
		return lsString("");
	}
	return lsString(buffer);
}

bool lsDirectory::SetWorkingDirectory(lsString path)
{
	int result = SetCurrentDirectoryA(path.ToCString());
	return (result != 0);
}

lsArray<lsString>* lsDirectory::ListInternal(lsString from, int types, lsString base, lsArray<lsString>* result, bool recursive)
{
	WIN32_FIND_DATAA	data;
	HANDLE				handle;
	
	handle = FindFirstFileA((from + "\\*").ToCString(), &data);
	if (handle == INVALID_HANDLE_VALUE)
	{
		return NULL;
	}


	while (true)
	{
		lsString full_path = from + "\\" + data.cFileName;
		lsString rel_path = base + (base != "" ? "\\" : "") + data.cFileName;
		
		if (strcmp(data.cFileName, ".") != 0 && 
			strcmp(data.cFileName, "..") != 0)
		{
			// Is it a directory?
			if (Exists(full_path) && (types & 1) != 0)
			{
				result->Resize(result->Length() + 1);
				result->SetIndex(result->Length() - 1, rel_path);

				if (recursive == true)
				{
					lsArray<lsString>* internalResult = ListInternal(full_path, types, rel_path, result, recursive);
					if (internalResult == NULL)
					{
						return NULL;
					}
				}
			}
			
			// A file?
			else if (lsFile::Exists(full_path) && (types & 2) != 0)
			{
				result->Resize(result->Length() + 1);
				result->SetIndex(result->Length() - 1, rel_path);			
			}
		}

		if (FindNextFileA(handle, &data) == 0)
		{
			break;
		}
	}

	FindClose(handle);
	return result;
}

lsArray<lsString>* lsDirectory::List(lsString from, int types, bool recursive)
{
	lsArray<lsString>* result = new lsArray<lsString>(0);
	while (from[from.Length() - 1] == '/' ||
		   from[from.Length() - 1] == '\\')
    {
		from = from.GetSlice(0, from.Length() - 1);
    }
	return ListInternal(from, types, "", result,  recursive);
}

lsArray<lsString>* lsDirectory::ListVolumes()
{
	char buffer[256];
	int count = GetLogicalDriveStringsA(256, buffer);
	if (count <= 0 || count >= 256)
	{
		return NULL;
	}

	lsArray<lsString>* result = new lsArray<lsString>(count);
	for (int i = 0; i < count; i++)
	{
		result->SetIndex(i, lsString(buffer[i]));
	}
	
	return result;
}
