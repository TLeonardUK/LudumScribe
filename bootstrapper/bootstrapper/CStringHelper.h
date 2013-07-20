/* *****************************************************************

		CStringHelper.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CSTRINGHELPER_H_
#define _CSTRINGHELPER_H_

#include <string>
#include <sstream>
#include <vector>
#include <ctime>
#include <map>

#ifdef _WIN32
#include <stdarg.h>
#else
#include <cstdarg>
#endif

// =================================================================
//	Class contains several string related helper functions.
// =================================================================
class CStringHelper
{
private:
	CStringHelper();

public:
	static std::string				PadRight		(std::string value, int length, std::string padding = " ");
	static std::string				PadLeft			(std::string value, int length, std::string padding = " ");
	static std::vector<std::string> Split			(std::string value, char deliminator);
	static std::string				Join			(std::vector<std::string> value, std::string glue);

	static std::string				Replace			(std::string value, std::string from, std::string to);
	static bool						IsHex			(char x);
	static std::string				ToHexString		(int code);
	
	static int						ToInt			(const std::string& str);
	static float					ToFloat			(const std::string& str);

	template<typename T>
	static std::string				ToString		(const T& value)
	{
		std::ostringstream oss;
		oss << value;
		return oss.str();
	}

	static std::string				GetLineInString		(std::string value, int lineIndex);

	static std::string				FormatString		(std::string value, ...);
	static std::string				FormatStringVarArgs	(std::string value, va_list& va);

	static std::string				ToLower				(std::string value);
	static std::string				ToUpper				(std::string value);
	static std::string				StripWhitespace		(std::string value);
	static std::string				StripChar			(std::string value, char chr);
	static std::string				MultiplyString		(std::string value, int counter);

	static std::string				CleanExceptAlphaNum	(std::string value, char chr);

	static std::string				GetDateTimeStamp	();
	
	static std::map<std::string, std::string> GetEnvironmentVariables();

};

#endif