// -----------------------------------------------------------------------------
// 	file.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common file operations.
// -----------------------------------------------------------------------------

#ifdef _WIN32

#include <Windows.h>
#include <direct.h>
#define _CRT_SECURE_NO_DEPRECATE

#else defined(__linux__) || defined(__APPLE__) 

#include <unistd.h> 
#include <sys/types.h>  
#include <sys/stat.h>   
#include <fcntl.h>
#include <dirent.h>
#include <cstring>

#endif

#include "Packages/Native/CPP/Default/Compiler/Support/Types.hpp"
#include "Packages/Native/CPP/Default/System/File.hpp"
#include "Packages/Native/CPP/Default/System/Path.hpp"

bool lsFile::Create(lsString path)
{
	if (Exists(path))
	{
		return true;
	}

#ifdef _WIN32
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
#else defined(__linux__) || defined(__APPLE__) 
	FILE* file = fopen(path.ToCString(), "wb");
	if (file == NULL)
	{
		return false;
	}
	fclose(file);
#endif
	
	return Exists(path);
}

bool lsFile::Delete(lsString path)
{
#ifdef _WIN32
	int result = DeleteFileA(path.ToCString());
	return (result != 0);
#else defined(__linux__) || defined(__APPLE__)  
	int result = unlink(path.ToCString());
	return (result == 0);
#endif
}

bool lsFile::Copy(lsString src, lsString dst, bool overwrite)
{
	src = lsPath::Normalize(src);
	dst = lsPath::Normalize(dst);
#ifdef _WIN32
	int result = CopyFileA(src.ToCString(), dst.ToCString(), !overwrite);
	return (result != 0);
#elif defined(__linux__) || defined(__APPLE__)  
	if (Exists(dst) == true)
	{
		unlink(dst.ToCString());
	}

	int source_fd = open(src.ToCString(), O_RDWR);
	int dest_fd   = open(dst.ToCString(), O_RDWR|O_CREAT|O_TRUNC, 0777);  
	if (source_fd < 0 || dest_fd < 0)
	{
		return false;
	}

	struct stat stats;
	fstat(source_fd, &stats);
	
    char buf[1024];
    size_t size;

	while ((size = read(source_fd, buf, 1024)) > 0) 
	{
        write(dest_fd, buf, size);
    }

	close(source_fd);
	close(dest_fd);
	
	return true;
#endif	
}

bool lsFile::Rename(lsString from, lsString to)
{
	// Make sure we are renaming a directory.
	if (!Exists(from))
	{
		return false;
	}
	
#ifdef _WIN32
	int result = MoveFileA(from.ToCString(), to.ToCString());
	return (result != 0);
#else defined(__linux__) || defined(__APPLE__) 
	int result = rename(from.ToCString(), to.ToCString());
	return (result == 0);
#endif
}

bool lsFile::Exists(lsString value)
{	
#ifdef _WIN32
	DWORD flags = GetFileAttributesA(value.ToCString());
	if (flags == INVALID_FILE_ATTRIBUTES)
	{
		return false;
	}

	if ((flags & FILE_ATTRIBUTE_DIRECTORY) != 0)
	{
		return false;
	}

	return true;
#elif defined(__linux__) || defined(__APPLE__) 
	if (access(value.ToCString(), 0) != 0)
	{
		return false;
	}

	struct stat status;
	stat(value.ToCString(), &status);
	
	if ((status.st_mode & S_IFDIR) != 0)
	{
		return false;
	}	

	return true;
#endif	
}

lsString lsFile::LoadText(lsString path)
{
	FILE* file = fopen(path.ToCString(), "rb");
	if (file == NULL)
	{
		throw new lsOperationFailedException();
		return "";
	}

	lsString output = "";
	while (!feof(file))
	{
		int c = fgetc(file);
		if (c != EOF)
		{
			// Patch up \r\n newlines into simply \n
			if (c == '\r')
			{
				int c2 = fgetc(file);
				if (c2 == '\n')
				{
					output += (char)c2;
				}
				else
				{					
					output += (char)c;
					if (c2 != EOF)
					{
						output += (char)c2;
					}
					else
					{
						break;
					}
				}
			}
			else
			{
				output += (char)c;
			}
		}
	}

	fclose(file);
	return output;
}

void lsFile::SaveText(lsString path, lsString value)
{
	FILE* file = fopen(path.ToCString(), "wb");
	if (file == NULL)
	{
		throw new lsOperationFailedException();
		return;
	}

	unsigned int counter = 0;
	while (counter < value.Length())
	{
		counter += fwrite(value.ToCString() + counter, 1, value.Length() - counter, file);
	}

	fclose(file);
	return;
}