/* *****************************************************************

		CPathHelper.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <string>
#include <assert.h>
#include <algorithm>
#include <direct.h>
#include <windows.h>

#include "CPathHelper.h"
#include "CStringHelper.h"

// =================================================================
//	Returns true if the path is a directory.
// =================================================================
bool CPathHelper::LoadFile(std::string path, std::string& output)
{
	FILE* file = fopen(path.c_str(), "r");
	if (file == NULL)
	{
		return false;
	}

	output = "";
	while (!feof(file))
	{
		int c = fgetc(file);
		if (c != EOF)
		{
			output += (char)c;
		}
	}

	fclose(file);
	return true;
}

// =================================================================
//	Returns true if the path is a directory.
// =================================================================
bool CPathHelper::SaveFile(std::string path, std::string output)
{
	FILE* file = fopen(path.c_str(), "w");
	if (file == NULL)
	{
		return false;
	}

	unsigned int counter = 0;
	while (counter < output.size())
	{
		counter += fwrite(output.c_str() + counter, 1, output.size() - counter, file);
	}

	fclose(file);
	return true;
}

// =================================================================
//	Returns true if the path is a directory.
// =================================================================
bool CPathHelper::IsDirectory(std::string value)
{
	DWORD flags = GetFileAttributesA(value.c_str());
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

// =================================================================
//	Returns true if the path is a file.
// =================================================================
bool CPathHelper::IsFile(std::string value)
{
	DWORD flags = GetFileAttributesA(value.c_str());
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

// =================================================================
//	Returns true if the path is relative.
// =================================================================
bool CPathHelper::IsRelative(std::string value)
{
	if (value.size() <= 2)
	{
		return true;
	}

	if (value.at(1) != ':')
	{
		return true;
	}

	return false;
}

// =================================================================
//	Returns the current path.
// =================================================================
std::string	CPathHelper::CurrentPath()
{
	char buffer[512];
	GetCurrentDirectoryA(512, buffer);
	return std::string(buffer);
}

// =================================================================
//	Returns the correct case of a given path.
// =================================================================
std::string CPathHelper::RealPathCase(std::string value)
{
	std::vector<std::string> crackedPath = CStringHelper::Split(value, '/');
	std::string path = "";

	for (unsigned int i = 0; i < crackedPath.size(); i++)
	{
		std::string crack = crackedPath.at(i);
		if (path != "")
		{
			std::vector<std::string> files = ListAll(path + "/");
			for (auto iter = files.begin(); iter != files.end(); iter++)
			{
				std::string lower1 = CStringHelper::ToLower(*iter);
				std::string lower2 = CStringHelper::ToLower(crack);
				if (lower1 == lower2)
				{
					crack = *iter;
					break;
				}
			}
		}

		if (path != "")
		{
			path += "/";
		}
		path += crack;
	}

	return path;
}

// =================================================================
//	Standardizes the path.
// =================================================================
std::string	CPathHelper::CleanPath(std::string value)
{
	value = CStringHelper::Replace(value, "\\", "/"); // Turn backslashes into forward slashes.
	value = CStringHelper::Replace(value, "//", "/"); // Remove duplicate path seperators.
//	value = RealPathCase(value);					  // Convert path to correct case.
	return value;
}

// =================================================================
//	Strips the directory of a file path.
// =================================================================
std::string	CPathHelper::StripDirectory(std::string value)
{
	int offset = value.find_last_of("/\\");
	if (offset < 0)
	{
		return value;
	}
	else
	{
		return value.substr(offset + 1);
	}
}

// =================================================================
//	Strips the filename of a file path.
// =================================================================
std::string	CPathHelper::StripFilename(std::string value)
{
	int offset = value.find_last_of("/\\");
	if (offset < 0)
	{
		return value;
	}
	else
	{
		return value.substr(0, offset);
	}
}

// =================================================================
//	Strips the extension of a file path.
// =================================================================
std::string	CPathHelper::StripExtension(std::string value)
{
	int offset = value.find_last_of(".");
	if (offset < 0)
	{
		return value;
	}
	else
	{
		return value.substr(0, offset);
	}
}

// =================================================================
//	Extracts the extension of a file path.
// =================================================================
std::string	CPathHelper::ExtractExtension(std::string value)
{
	int offset = value.find_last_of(".");
	if (offset < 0)
	{
		return "";
	}
	else
	{
		return value.substr(offset + 1);
	}
}

// =================================================================
//	Copies a file from one to another.
// =================================================================
void CPathHelper::CopyFileTo(std::string src, std::string dst)
{
	src = CleanPath(src);
	dst = CleanPath(dst);
	CopyFileA(src.c_str(), dst.c_str(), false);
}

// =================================================================
//	Creates a new directory.
// =================================================================
void CPathHelper::MakeDirectory(std::string value)
{
	std::vector<std::string> crackedPath = CStringHelper::Split(value, '/');
	for (unsigned int i = 0; i < crackedPath.size(); i++)
	{
		std::string path = "";
		for (unsigned int k = 0; k < i; k++)
		{
			path += crackedPath.at(k);
			if (k + 1 < i)
			{
				path += "/";
			}
		}

		path = CleanPath(path);
		if (!IsDirectory(path))
		{
			CreateDirectoryA(path.c_str(), NULL);
		}
	}
}

// =================================================================
//	Removes . and .. entries in a path and appends the current
//  directory if its relative.
// =================================================================
std::string	CPathHelper::GetAbsolutePath(std::string value)
{
	// Add current directory.
	if (IsRelative(value) == true)
	{
		value = CurrentPath() + "/" + value;
	}

	value = CleanPath(value);

	// Strip out all .. and . references.
	std::vector<std::string> crackedPath = CStringHelper::Split(value, '/');
	std::string				 finalPath   = "";

	for (int i = crackedPath.size() - 1; i >= 0; i--)
	{
		std::string part = crackedPath.at(i);
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

// =================================================================
//	Gets the relative path from one file to another.
// =================================================================
std::string	CPathHelper::GetRelativePath(std::string path, std::string relative)
{
	std::string path_file     = CPathHelper::StripDirectory(path);
	std::string relative_file = CPathHelper::StripDirectory(relative);

	std::string path_dir     = CPathHelper::StripFilename(path) + "/";
	std::string relative_dir = CPathHelper::StripFilename(relative) + "/";
	
	int min_size = path_dir.size() < relative_dir.size() ? path_dir.size() : relative_dir.size();
	int same_path_offset = 0;
	for (int i = 0; i < min_size; i++)
	{
		if (path_dir[i] == relative_dir[i])
		{
			same_path_offset++;
		}
	}

	std::string same_path_dir     = CStringHelper::StripChar(same_path_offset <= 0 ? path_dir	 : path_dir.substr(same_path_offset), '/');
	std::string same_relative_dir = CStringHelper::StripChar(same_path_offset <= 0 ? relative_dir : relative_dir.substr(same_path_offset), '/');

	std::vector<std::string> cracked_path		   = CStringHelper::Split(same_path_dir, '/');
	std::vector<std::string> cracked_relative_path = CStringHelper::Split(same_relative_dir, '/');

	std::string result = "";
	if (same_path_dir.size() > same_relative_dir.size())
	{
		result = same_path_dir + "/" + path_file;
	}
	else if (same_relative_dir.size() > same_path_dir.size())
	{
		for (unsigned int i = 0; i < cracked_relative_path.size(); i++)
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

// =================================================================
//	List all files in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListFiles(std::string value)
{
	std::vector<std::string>	files;
	WIN32_FIND_DATAA			data;
	HANDLE						handle;

	value = CleanPath(value);
	if (value.at(value.size() - 1) != '/')
	{
		value += "/";
	}

	handle = FindFirstFileA((value + "*").c_str(), &data);
	if (handle != INVALID_HANDLE_VALUE)
	{
		while (true)
		{
			std::string full_path = value + data.cFileName;
			if (IsFile(full_path))
			{
				files.push_back(data.cFileName);
			}

			if (FindNextFileA(handle, &data) == 0)
			{
				break;
			}
		}
		FindClose(handle);
	}

	return files;
}


// =================================================================
//	List all files in a directory recursively.
// =================================================================
std::vector<std::string> CPathHelper::ListRecursiveFiles(std::string path, std::string extension)
{
	std::vector<std::string> result;
	
	std::vector<std::string> files = ListFiles(path);
	std::vector<std::string> dirs  = ListDirs(path);

	std::vector<std::string> abs_files;
	for (auto iter = files.begin(); iter != files.end(); iter++)
	{
		std::string file_path = CPathHelper::CleanPath(path + "/" + (*iter));
		
		if (extension != "")
		{
			if (CPathHelper::ExtractExtension(file_path) != extension)
			{
				continue;
			}
		}
		
		abs_files.push_back(file_path);
		result.push_back(file_path);
	}
	
	std::vector<std::string> abs_dirs;
	for (auto iter = dirs.begin(); iter != dirs.end(); iter++)
	{
		std::string dir_path = CPathHelper::CleanPath(path + "/" + (*iter));
		abs_dirs.push_back(dir_path);

		std::vector<std::string> rel_abs_files = ListRecursiveFiles(dir_path, extension);
		for (auto iter2 = rel_abs_files.begin(); iter2 != rel_abs_files.end(); iter2++)
		{
			result.push_back(*iter2);
		}
	}

	return result;
}

// =================================================================
//	List all dirs in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListDirs(std::string value)
{
	std::vector<std::string>	files;
	WIN32_FIND_DATAA			data;
	HANDLE						handle;

	value = CleanPath(value);
	if (value.at(value.size() - 1) != '/')
	{
		value += "/";
	}

	handle = FindFirstFileA((value + "*").c_str(), &data);
	if (handle != INVALID_HANDLE_VALUE)
	{
		while (true)
		{
			std::string full_path = value + data.cFileName;
			if (IsDirectory(full_path) == true &&
				strcmp(data.cFileName, ".") != 0 && 
				strcmp(data.cFileName, "..") != 0)
			{
				files.push_back(data.cFileName);
			}

			if (FindNextFileA(handle, &data) == 0)
			{
				break;
			}
		}
		FindClose(handle);
	}

	return files;
}

// =================================================================
//	List all files and dirs in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListAll(std::string value)
{
	std::vector<std::string>	files;
	WIN32_FIND_DATAA			data;
	HANDLE						handle;

	//value = CleanPath(value);
	//if (value.at(value.size() - 1) != '/')
	//{
	//	value += "/";
	//}

	handle = FindFirstFileA((value + "*").c_str(), &data);
	if (handle != INVALID_HANDLE_VALUE)
	{
		while (true)
		{
			std::string full_path = value + data.cFileName;
			if (strcmp(data.cFileName, ".") != 0 && 
				strcmp(data.cFileName, "..") != 0)
			{
				files.push_back(data.cFileName);
			}

			if (FindNextFileA(handle, &data) == 0)
			{
				break;
			}
		}
		FindClose(handle);
	}

	return files;
}