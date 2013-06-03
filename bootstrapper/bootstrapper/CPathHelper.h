/* *****************************************************************

		CPathHelper.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CPATHHELPER_H_
#define _CPATHHELPER_H_

#include <string>
#include <vector>

// =================================================================
//	Class contains several path / IO related helper functions.
// =================================================================
class CPathHelper
{
private:
	CPathHelper();

public:
	static bool						IsDirectory		(std::string value);
	static bool						IsFile			(std::string value);
	static bool						IsRelative		(std::string value);

	static bool						LoadFile		(std::string path, std::string& output);
	static bool						SaveFile		(std::string path, std::string output);

	static std::string				GetRelativePath	(std::string path, std::string relative);

	static std::string				RealPathCase	(std::string value);
	static std::string				CleanPath		(std::string value);
	static std::string				StripDirectory	(std::string value);
	static std::string				StripFilename	(std::string value);
	static std::string				ExtractExtension(std::string value);
	static std::string				StripExtension	(std::string value);
	static std::string				GetAbsolutePath	(std::string value);
	
	static std::string				CurrentPath		();

	static void						MakeDirectory	(std::string value);
	static void						CopyFileTo		(std::string from, std::string to);

	static std::vector<std::string> ListFiles			(std::string value);
	static std::vector<std::string> ListDirs			(std::string value);
	static std::vector<std::string> ListAll				(std::string value);
	
	static std::vector<std::string> ListRecursiveFiles	(std::string value, std::string extension="");


};

#endif