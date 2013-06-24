// -----------------------------------------------------------------------------
// 	path.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common path operations.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_SYSTEM_PATH__
#define __LS_PACKAGES_NATIVE_WIN32_SYSTEM_PATH__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	This class is used to perform several common path operations.
// -----------------------------------------------------------------------------
class lsPath
{
public:
	static bool 				IsRelative			(lsString path);
	static bool 				IsAbsolute			(lsString path);
	
	static lsString 			Normalize			(lsString path);
	static lsString 			GetRelative			(lsString path, lsString relative);
	static lsString 			GetAbsolute			(lsString path);
	
	static lsString 			StripDirectory		(lsString path);
	static lsString 			StripFilename		(lsString path);
	static lsString 			StripExtension		(lsString path);
	static lsString 			StripVolume			(lsString path);

	static lsString 			ChangeExtension		(lsString path, lsString newFragment);
	static lsString 			ChangeFilename		(lsString path, lsString newFragment);
	static lsString 			ChangeDirectory		(lsString path, lsString newFragment);
	static lsString 			ChangeVolume		(lsString path, lsString newFragment);
	
	static lsString 			ExtractDirectory	(lsString path);
	static lsString 			ExtractFilename		(lsString path);
	static lsString 			ExtractExtension	(lsString path);
	static lsString 			ExtractVolume		(lsString path);
	
	static lsString   			Join				(lsArray<lsString>* path);
	static lsArray<lsString>* 	Crack				(lsString path);	
};

#endif // __LS_PACKAGES_NATIVE_WIN32_SYSTEM_PATH_

