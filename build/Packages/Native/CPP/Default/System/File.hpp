// -----------------------------------------------------------------------------
// 	file.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common file operations.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_FILE__
#define __LS_PACKAGES_NATIVE_CPP_DEFAULT_SYSTEM_FILE__

#include "Packages/Native/CPP/Default/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	This class is used to perform several common file operations.
// -----------------------------------------------------------------------------
class lsFile
{
public:
	static bool Create	(lsString path);
	static bool Delete	(lsString path);
	static bool Copy	(lsString path, lsString from, bool overwrite);
	static bool Rename	(lsString from, lsString to);
	static bool Exists	(lsString path);
	
	static lsString LoadText(lsString path);
	static void     SaveText(lsString path, lsString value);

};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_FILE__

