// -----------------------------------------------------------------------------
// 	path.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common path operations.
// -----------------------------------------------------------------------------

#include "Packages/Native/Win32/Compiler/Support/Exceptions.hpp"
#include "Packages/Native/Win32/Compiler/Support/Types.hpp"
#include "Packages/Native/Win32/System/Path.hpp"
#include "Packages/Native/Win32/System/Directory.hpp"

// Forward declare some of the ludumscribe-implemented string extension functions.
extern int lsString_IndexOf(lsString ext_this, lsString needle, int start_index);
extern int lsString_IndexOfAny(lsString ext_this, lsArray<lsString>* needles, int start_index);
extern int lsString_LastIndexOf(lsString ext_this, lsString needle, int start_index);
extern int lsString_LastIndexOfAny(lsString ext_this, lsArray<lsString>* needles, int start_index);
extern lsString lsString_Trim(lsString ext_this, lsString chr);
extern lsString lsString_Replace(lsString ext_this, lsString from, lsString to);
extern lsString lsString_SubString(lsString ext_this, int start, int end);
extern lsArray<lsString>* lsString_Split(lsString ext_this, lsString needle, int max_splits, bool remove_duplicates);

bool lsPath::IsRelative(lsString path)
{
	int index = lsString_IndexOf(path, ":", 0);
	return (index < 0);
}

bool lsPath::IsAbsolute(lsString path)
{
	int index = lsString_IndexOf(path, ":", 0);
	return (index >= 0);
}

lsString lsPath::Normalize(lsString path)
{
	path = lsString_Replace(path, "/", "\\");
	path = lsString_Replace(path, "\\\\", "\\");
	return path;	
}

lsString lsPath::GetRelative(lsString path, lsString relative)
{
	path     = Normalize(path);
	relative = Normalize(relative);

	lsString path_file     = StripDirectory(path);
	lsString relative_file = StripDirectory(relative);

	lsString path_dir      = StripFilename(path) + "\\";
	lsString relative_dir  = StripFilename(relative) + "\\";
	
	int min_size = path_dir.Length() < relative_dir.Length() ? path_dir.Length() : relative_dir.Length();
	int same_path_offset = 0;
	for (int i = 0; i < min_size; i++)
	{
		if (path_dir[i] == relative_dir[i])
		{
			same_path_offset++;
		}
	}

	lsString same_path_dir     = lsString_Trim(same_path_offset <= 0 ? path_dir	 : lsString_SubString(path_dir, same_path_offset, -1), "\\");
	lsString same_relative_dir = lsString_Trim(same_path_offset <= 0 ? relative_dir : lsString_SubString(relative_dir, same_path_offset, -1), "\\");

	lsArray<lsString>* cracked_path		     = Crack(same_path_dir);
	lsArray<lsString>* cracked_relative_path = Crack(same_relative_dir);

	lsString result = "";
	if (same_path_dir.Length() > same_relative_dir.Length())
	{
		result = same_path_dir + "/" + path_file;
	}
	else if (same_relative_dir.Length() > same_path_dir.Length())
	{
		for (int i = 0; i < cracked_relative_path->Length(); i++)
		{
			result += "../";
		}
		result += path_file;
	}
	else
	{
		result = path_file;
	}

	return result;
}

lsString lsPath::GetAbsolute(lsString path)
{
	// Add current directory.
	if (IsRelative(path) == true)
	{
		path = lsDirectory::GetWorkingDirectory() + "/" + path;
	}

	path = Normalize(path);

	// Strip out all .. and . references.
	lsArray<lsString>* crackedPath = Crack(path);
	lsString		   finalPath   = "";

	for (int i = crackedPath->Length() - 1; i >= 0; i--)
	{
		lsString part = crackedPath->GetIndex(i);
		if (part == "..")
		{
			i--;
		}
		else if (part == ".")
		{
			continue;
		}
		else
		{
			if (finalPath == "")
			{
				finalPath = part;
			}
			else
			{
				finalPath = part + "/" + finalPath;
			}
		}
	}

	return finalPath;
}

lsString lsPath::StripDirectory(lsString path)
{
	int offset = lsString_LastIndexOfAny(path, lsConstructArray<lsString>(2, "/", "\\"), 0);
	if (offset < 0)
	{
		return path;
	}
	else
	{
		return lsString_SubString(path, offset + 1, -1);
	}
}

lsString lsPath::StripFilename(lsString path)
{
	int offset = lsString_LastIndexOfAny(path, lsConstructArray<lsString>(2, "/", "\\"), 0);
	if (offset < 0)
	{
		return path;
	}
	else
	{
		return lsString_SubString(path, 0, offset);
	}
}

lsString lsPath::StripExtension(lsString path)
{
	int offset = lsString_LastIndexOf(path, ".", 0);
	if (offset < 0)
	{
		return path;
	}
	else
	{
		return lsString_SubString(path, 0, offset);
	}
}

lsString lsPath::StripVolume(lsString path)
{
	int offset = lsString_IndexOf(path, ":", 0);
	if (offset < 0)
	{
		return path;
	}
	else
	{
		return lsString_SubString(path, offset + 1, -1);
	}
}

lsString lsPath::ChangeExtension(lsString path, lsString newFragment)
{
	return StripExtension(path) + newFragment;
}

lsString lsPath::ChangeFilename(lsString path, lsString newFragment)
{
	return StripFilename(path) + newFragment;
}

lsString lsPath::ChangeDirectory(lsString path, lsString newFragment)
{
	return newFragment + StripDirectory(path);
}

lsString lsPath::ChangeVolume(lsString path, lsString newFragment)
{
	if (!IsAbsolute(path))
	{
		return path;
	}
	return newFragment + StripVolume(path);
}

lsString lsPath::ExtractDirectory(lsString path)
{
	int offset = lsString_LastIndexOfAny(path, lsConstructArray<lsString>(2, "/", "\\"), 0);
	if (offset < 0)
	{
		return "";
	}
	else
	{
		return lsString_SubString(path, 0, offset);
	}
}

lsString lsPath::ExtractFilename(lsString path)
{
	int offset = lsString_LastIndexOfAny(path, lsConstructArray<lsString>(2, "/", "\\"), 0);
	if (offset < 0)
	{
		return path;
	}
	else
	{
		return lsString_SubString(path, offset + 1, -1);
	}
}

lsString lsPath::ExtractExtension(lsString path)
{
	int offset = lsString_LastIndexOf(path, ".", 0);
	if (offset < 0)
	{
		return "";
	}
	else
	{
		return lsString_SubString(path, offset + 1, -1);
	}
}

lsString lsPath::ExtractVolume(lsString path)
{
	int offset = lsString_IndexOf(path, ":", 0);
	if (offset < 0)
	{
		return "";
	}
	else
	{
		return lsString_SubString(path, 0, offset);
	}
}

lsString lsPath::Join(lsArray<lsString>* path)
{
	lsString result = "";
	for (int i = 0; i < path->Length(); i++)
	{
		if (result != "")
		{
			result += "\\";
		}
		result += path->GetIndex(i);
	}
	return result;
}

lsArray<lsString>* lsPath::Crack(lsString path)
{	
	path = Normalize(path);
	
	lsArray<lsString>* cracked = lsString_Split(path, "\\", -1, true);
	return cracked;
}
	