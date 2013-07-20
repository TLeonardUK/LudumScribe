/* *****************************************************************

		CStringHelper.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <string>
#include <assert.h>
#include <algorithm>

#ifdef _WIN32
#include <stdarg.h>
#include <Windows.h>
#else
#include <cstdarg>
#endif

#include <map>

#include "CStringHelper.h"

// =================================================================
//	Converts a string to an int.
// =================================================================
int	CStringHelper::ToInt(const std::string& str)
{
	return atoi(str.c_str());
}

// =================================================================
//	Converts a string to a float.
// =================================================================
float CStringHelper::ToFloat(const std::string& str)
{
	return (float)atof(str.c_str());
}

// =================================================================
//	Pads the right side of a string with the given character until
//  it is greater or equal to the length given.
// =================================================================
std::string CStringHelper::PadRight(std::string value, int length, std::string padding)
{
	assert(padding.length() > 0);
	
	if (length <= 0)
	{
		return value;
	}

	while (value.length() < (unsigned int)length)
	{
		value += padding;
	}

	return value;
}

// =================================================================
//	Pads the left side of a string with the given character until
//  it is greater or equal to the length given.
// =================================================================
std::string CStringHelper::PadLeft(std::string value, int length, std::string padding)
{
	assert(padding.length() > 0);

	if (length <= 0)
	{
		return value;
	}

	while (value.length() < (unsigned int)length)
	{
		value = padding + value;
	}

	return value;
}

// =================================================================
//	Splits a string up into multiple strings based on the given 
//	deliminator.
// =================================================================
std::vector<std::string> CStringHelper::Split(std::string value, char deliminator)
{
	std::vector<std::string> splits;

	int startIndex = 0;

	while (true)
	{
		int offset = value.find(deliminator, startIndex);
		if (offset <= 0)
		{
			break;
		}
	
		splits.push_back(value.substr(startIndex, offset - startIndex));

		startIndex = offset + 1;
	}

	splits.push_back(value.substr(startIndex, value.size() - startIndex));

	return splits;
}

// =================================================================
//	Glus an array of strings together.
// =================================================================
std::string CStringHelper::Join(std::vector<std::string> values, std::string glue)
{
	std::string result = "";

	for (auto iter = values.begin(); iter != values.end(); iter++)
	{
		if (iter != values.begin())
		{
			result += glue;
		}
		result += *iter;
	}

	return result;
}

// =================================================================
//	Replaces a string within another string.
// =================================================================
std::string CStringHelper::Replace(std::string value, std::string from, std::string to)
{
	while (true)
	{
		int pos = value.find(from);
		if (pos == std::string::npos)
		{
			break;
		}

		std::string left = value.substr(0, pos);
		std::string right = value.substr(pos + from.size());
		value = left + to + right;
	}

	return value;
}

// =================================================================
//	Returns true if the given character is hexidecimal.
// =================================================================
bool CStringHelper::IsHex(char x)
{
	return ((x >= '0' && x <= '9') ||
			(x >= 'A' && x <= 'F') ||
			(x >= 'a' && x <= 'f'));
}

// =================================================================
//  Converts a number to a hex string. 
// =================================================================
std::string CStringHelper::ToHexString(int code)
{
	std::stringstream sstream;
	sstream << std::hex << code;
	return sstream.str();
}

// =================================================================
//	Uses variable arguments to format a string.
// =================================================================
std::string	CStringHelper::FormatString(std::string value, ...)
{
	va_list va;
	va_start(va, value);
	value = CStringHelper::FormatStringVarArgs(value, va);
	va_end(va);

	return value;
}

// =================================================================
//	Uses variable arguments to format a string.
// =================================================================
std::string	CStringHelper::FormatStringVarArgs(std::string value, va_list& va)
{
	int size = vsnprintf(NULL, NULL, value.c_str(), va);

	char* buffer = new char[size + 1];

	vsnprintf(buffer, size, value.c_str(), va);
	buffer[size] = '\0';

	std::string result = buffer;

	delete[] buffer;

	return result;
}

// =================================================================
//  Get the specific line in the string.
// =================================================================
std::string CStringHelper::GetLineInString(std::string value, int lineIndex)
{
	std::string line;
	int lineOffset = 0;
	int startIndex = 0;

	while (true)
	{
		int offset = value.find('\n', startIndex);
		if (offset <= 0)
		{
			break;
		}
	
		line = value.substr(startIndex, offset - startIndex);
		if (lineOffset == lineIndex)
		{
			return line;
		}
		lineOffset++;

		startIndex = offset + 1;
	}

	line = value.substr(startIndex, value.size() - startIndex);

	if (lineOffset == lineIndex)
	{
		return line;
	}
	else
	{
		return "";
	}
}

// =================================================================
//  Converts a string to a lowercase representation.
// =================================================================
std::string CStringHelper::ToLower(std::string value)
{
	std::transform(value.begin(), value.end(), value.begin(), ::tolower);
	return value;
}

// =================================================================
//  Converts a string to a uppercase representation.
// =================================================================
std::string CStringHelper::ToUpper(std::string value)
{
	std::transform(value.begin(), value.end(), value.begin(), ::toupper);
	return value;
}

// =================================================================
//  Strips whitespace from string.
// =================================================================
std::string	CStringHelper::StripWhitespace(std::string value)
{
	while (value.size() > 0 &&
  		   (value[0] == ' ' || 
		    value[0] == '\r' || 
			value[0] == '\n' || 
			value[0] == '\t' || 
			value[0] == '\v'))
	{
		value = value.substr(1, value.size() - 1);
	}

	while (value.size() > 0 &&
  		   (value[value.size() - 1] == ' ' || 
		    value[value.size() - 1] == '\r' || 
			value[value.size() - 1] == '\n' || 
			value[value.size() - 1] == '\t' || 
			value[value.size() - 1] == '\v'))
	{
		value = value.substr(0, value.size() - 1);
	}

	return value;
}

// =================================================================
//  Strips a given character from a string.
// =================================================================
std::string	CStringHelper::StripChar(std::string value, char chr)
{
	while (value.size() > 0 &&
  		   (value[0] == chr))
	{
		value = value.substr(1, value.size() - 1);
	}

	while (value.size() > 0 &&
  		   (value[value.size() - 1] == chr))
	{
		value = value.substr(0, value.size() - 1);
	}

	return value;
}

// =================================================================
//  MReplaces all character in the string except alpha numeric.
// =================================================================
std::string CStringHelper::CleanExceptAlphaNum(std::string value, char chr)
{
	std::string result = "";
	for (unsigned int i = 0; i < value.size(); i++)
	{
		char rchr = value.at(i);
		if ((rchr >= '0' && rchr <= '9') ||
			(rchr >= 'a' && rchr <= 'z') ||
			(rchr >= 'A' && rchr <= 'Z'))
		{
			result += rchr;
		}
		else
		{			
			result += chr;
		}
	}
	return result;
}

// =================================================================
//  Multiplies the string the given number of times.
// =================================================================
std::string CStringHelper::MultiplyString(std::string value, int counter)
{
	std::string result = "";

	for (int i = 0; i < counter; i++)
	{
		result += value;
	}

	return result;
}

// =================================================================
//  Multiplies the string the given number of times.
// =================================================================
std::string CStringHelper::GetDateTimeStamp()
{
	char buffer[1024];
	time_t rawtime;
	struct tm * timeinfo;

	time(&rawtime);
	timeinfo = localtime(&rawtime);

	strftime(buffer, 1024, "%d/%m/%Y %H:%M", timeinfo);

	return std::string(buffer);
}

// =================================================================
//  Gets all available environment variables.
// =================================================================
std::map<std::string, std::string> CStringHelper::GetEnvironmentVariables()
{
	std::map<std::string, std::string> vars;

#ifdef _WIN32
	
	LPTCH str = GetEnvironmentStrings();
	
	std::string newvar = "";
	unsigned int offset = 0;
	while (true)
	{
		char chr = str[offset];
		if (chr == '\0')
		{
			// Should be in the format of name=value.
			unsigned int idx = newvar.find('=');
			if (idx > 0) // Ignore envvars that start with an = sign 
							// (some wierd variables we don't care are reported at the start like this).
			{
				vars.insert(std::pair<std::string, std::string>(newvar.substr(0, idx), newvar.substr(idx + 1)));
			}

			// End of values?
			if (str[offset + 1] == '\0')
			{
				break;
			}

			newvar = "";
		}
		else
		{
			newvar += chr;
		}

		offset++;
	}
			
	FreeEnvironmentStrings(str);

#else
	
	assert(0);
	
#endif
	
	return vars;
}
