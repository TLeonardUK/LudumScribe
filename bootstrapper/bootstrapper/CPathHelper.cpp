/* *****************************************************************

		CPathHelper.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <stdio.h>
#include <string>
#include <assert.h>
#include <algorithm>

#ifdef _WIN32

#include <Windows.h>
#include <direct.h>
#define _CRT_SECURE_NO_DEPRECATE

#else defined(__linux__) || defined(__GNUC__)

#include <unistd.h> 
#include <sys/types.h>  
#include <sys/stat.h>   
#include <fcntl.h>
#include <sys/sendfile.h>
#include <dirent.h>
#include <cstring>

#endif

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
#ifdef _WIN32
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
#elif defined(__linux__) || defined(__GNUC__)
	if (access(value.c_str(), 0) != 0)
	{
		return false;
	}

	struct stat status;
	stat(value.c_str(), &status);

	if ((status.st_mode & S_IFDIR) == 0)
	{
		return false;
	}	

	return true;
#else
	assert(0);
#endif	
}

// =================================================================
//	Returns true if the path is a file.
// =================================================================
bool CPathHelper::IsFile(std::string value)
{
#ifdef _WIN32
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
#elif defined(__linux__) || defined(__GNUC__)
	if (access(value.c_str(), 0) != 0)
	{
		return false;
	}

	struct stat status;
	stat(value.c_str(), &status);
	
	if ((status.st_mode & S_IFDIR) != 0)
	{
		return false;
	}	

	return true;
#else
	assert(0);
#endif	
}

// =================================================================
//	Returns true if the path is relative.
// =================================================================
bool CPathHelper::IsRelative(std::string value)
{
#ifdef _WIN32
	if (value.size() <= 2)
	{
		return true;
	}

	if (value.at(1) != ':')
	{
		return true;
	}

	return false;
#elif defined(__linux__) || defined(__GNUC__)
	if (value.size() <= 1)
	{
		return true;
	}

	if (value.at(0) != '/')
	{
		return true;
	}

	return false;
#else
	assert(0);
#endif	
}

// =================================================================
//	Returns the current path.
// =================================================================
std::string	CPathHelper::CurrentPath()
{
#ifdef _WIN32
	char buffer[512];
	GetCurrentDirectoryA(512, buffer);
	return std::string(buffer);
#elif defined(__linux__) || defined(__GNUC__)
	char buffer[512];
	getcwd(buffer, 512);
	return std::string(buffer);
#else
	assert(0);
#endif	
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
#ifdef _WIN32
	CopyFileA(src.c_str(), dst.c_str(), false);
#elif defined(__linux__) || defined(__GNUC__)
	int source_fd = open(src.c_str(), O_RDWR);
	int dest_fd   = open(dst.c_str(), O_RDWR);          

	struct stat stats;
	fstat(source_fd, &stats);

	sendfile(dest_fd, source_fd, 0, stats.st_size);
	
	close(source_fd);
	close(dest_fd);
#else
	assert(0);
#endif	
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
#ifdef _WIN32
			CreateDirectoryA(path.c_str(), NULL);
#elif defined(__linux__) || defined(__GNUC__)
			mkdir(path.c_str(), 0777);
#else
			assert(0);
#endif	
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
//	List all files in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListFiles(std::string value)
{
	std::vector<std::string>	files;

	value = CleanPath(value);
	if (value.at(value.size() - 1) != '/')
	{
		value += "/";
	}
	
#ifdef _WIN32
	WIN32_FIND_DATAA			data;
	HANDLE						handle;

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
#elif defined(__linux__) || defined(__GNUC__)
	DIR* dir;
	struct dirent* file;
	
	dir = opendir(value.c_str());
	if (dir != NULL)
	{
		while (true)
		{
			file = readdir(dir);
			if (file == NULL)
			{
				break;
			}
			
			std::string full_path = value + file->d_name;
			if (IsFile(full_path))
			{
				files.push_back(file->d_name);
			}			
		}
		closedir(dir);
	}	
#else
	assert(0);
#endif	

	return files;
}

// =================================================================
//	List all dirs in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListDirs(std::string value)
{
	std::vector<std::string>	files;
	value = CleanPath(value);

	if (value.at(value.size() - 1) != '/')
	{
		value += "/";
	}

#ifdef _WIN32
	WIN32_FIND_DATAA			data;
	HANDLE						handle;

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
#elif defined(__linux__) || defined(__GNUC__)
	DIR* dir;
	struct dirent* file;
	
	dir = opendir(value.c_str());
	if (dir != NULL)
	{
		while (true)
		{
			file = readdir(dir);
			if (file == NULL)
			{
				break;
			}
			
			std::string full_path = value + file->d_name;
			if (IsDirectory(full_path) == true &&
				strcmp(file->d_name, ".") != 0 && 
				strcmp(file->d_name, "..") != 0)
			{
				files.push_back(file->d_name);
			}			
		}
		closedir(dir);
	}	
#else
	assert(0);
#endif	

	return files;
}

// =================================================================
//	List all files and dirs in a directory.
// =================================================================
std::vector<std::string> CPathHelper::ListAll(std::string value)
{
	std::vector<std::string>	files;

#ifdef _WIN32
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
#elif defined(__linux__) || defined(__GNUC__)
	DIR* dir;
	struct dirent* file;
	
	dir = opendir(value.c_str());
	if (dir != NULL)
	{
		while (true)
		{
			file = readdir(dir);
			if (file == NULL)
			{
				break;
			}
			
			std::string full_path = value + file->d_name;
			if (strcmp(file->d_name, ".") != 0 && 
				strcmp(file->d_name, "..") != 0)
			{
				files.push_back(file->d_name);
			}			
		}
		closedir(dir);
	}	
#else
	assert(0);
#endif	

	return files;
}