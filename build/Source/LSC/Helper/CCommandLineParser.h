/* *****************************************************************

		CCommandLineArguments.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCOMMANDLINEARGUMENTS_H_
#define _CCOMMANDLINEARGUMENTS_H_

#include <string>
#include <vector>

// Argument type.
#define CMDLINE_ARG_FLAG_STRING		0x00000001
#define CMDLINE_ARG_FLAG_BOOL		0x00000002
#define CMDLINE_ARG_FLAG_OPTIONS	0x00000004

// Additional flags.
#define CMDLINE_ARG_FLAG_REQUIRED   0x10000000

// =================================================================
//	Stores information on an argument that can be parsed.
// =================================================================
struct CCommandLineArgument
{
public:
	std::string					Name;
	std::string					ShortName;
	int							Flags;
	std::string					DefaultValue;
	std::string					Description;
	std::vector<std::string>	Options;

	std::string					Value;
	bool						Exists;
};

// =================================================================
//	Class deals with parsing and storing command line arguments.
// =================================================================
class CCommandLineParser
{
private:
	std::vector<CCommandLineArgument> m_arguments;
	std::string m_exeName;

public:
	void		AddCommand(std::string name, std::string shortName, int flags, std::string defaultValue, std::string description, std::string options = "");
	void		PrintSyntax();
	bool		Parse(int argc, char* argv[]);

	std::string GetString(std::string name);
	bool		GetBool(std::string name);
	bool		ArgumentExists(std::string name);

};

#endif