/* *****************************************************************

		CApplication.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <stdio.h>
#include <string>
#include <assert.h>

#include "CCommandLineParser.h"
#include "CStringHelper.h"
#include "CPathHelper.h"

// =================================================================
//	Prints the syntax this parser accepts into stdout.
// =================================================================
void CCommandLineParser::PrintSyntax()
{
	printf("\n");
	printf("USAGE:\n");
	printf("\t%s [options]\n", m_exeName.c_str());
	printf("\n");

	printf("OPTIONS:\n");

	for (unsigned int i = 0; i < m_arguments.size(); i++)
	{
		CCommandLineArgument& arg = m_arguments.at(i);

		std::string example = "\t";
		example += arg.Name;
		
		// Show <1|2|3> if we are options.
		if ((arg.Flags & CMDLINE_ARG_FLAG_OPTIONS) == CMDLINE_ARG_FLAG_OPTIONS)
		{
			example += " <";

			for (unsigned int i = 0; i < arg.Options.size(); i++)
			{
				if (i > 0)
				{
					example += "|";
				}
				example += arg.Options.at(i);
			}

			example += "> ";
		}

		// Show <value> if we are not a toggle.
		else if ((arg.Flags & CMDLINE_ARG_FLAG_BOOL) == 0)
		{
			example += " <value> ";
		}

		example = CStringHelper::PadRight(example, 30, " ");
		example += arg.Description;
		example += "\n";

		printf(example.c_str());
	}
}

// =================================================================
//	Defines a new argument that can be parsed.
// =================================================================
void CCommandLineParser::AddCommand(std::string name, std::string shortName, int flags, std::string defaultValue, std::string description, std::string options)
{
	// If we are an options arguments, we NEED to have some available options.
	assert((flags & CMDLINE_ARG_FLAG_OPTIONS) == 0 || options.length() > 0);

	CCommandLineArgument arg;
	arg.Name			= name;
	arg.ShortName		= shortName;
	arg.Flags			= flags;
	arg.DefaultValue	= defaultValue;
	arg.Description		= description;
	arg.Options			= CStringHelper::Split(options, '|');

	m_arguments.push_back(arg);
}

// =================================================================
//	Gets the string value of the given command.
// =================================================================
std::string CCommandLineParser::GetString(std::string name)
{
	for (unsigned int j = 0; j < m_arguments.size(); j++)
	{
		CCommandLineArgument& checkArg = m_arguments.at(j);
		if ((checkArg.Name == name || checkArg.ShortName == name))//  && checkArg.Exists == true)
		{
			return checkArg.Value;
		}
	}

	return "";
}

// =================================================================
//	Gets the boolean value of the given command.
// =================================================================
bool CCommandLineParser::GetBool(std::string name)
{	
	for (unsigned int j = 0; j < m_arguments.size(); j++)
	{
		CCommandLineArgument& checkArg = m_arguments.at(j);
		if ((checkArg.Name == name || checkArg.ShortName == name))// && checkArg.Exists == true)
		{
			return checkArg.Value != "0" && 
				   checkArg.Value != "" && 
				   checkArg.Value != "false";
		}
	}

	return false;
}

// =================================================================
//	Returns true if the given argument exists.
// =================================================================
bool CCommandLineParser::ArgumentExists(std::string name)
{
	for (unsigned int j = 0; j < m_arguments.size(); j++)
	{
		CCommandLineArgument& checkArg = m_arguments.at(j);
		if ((checkArg.Name == name || checkArg.ShortName == name) && checkArg.Exists == true)
		{
			return true;
		}
	}

	return false;
}

// =================================================================
//	Parses command line arguments and stores them.
// =================================================================
bool CCommandLineParser::Parse(int argc, char* argv[])
{
	m_exeName = CPathHelper::StripDirectory(argv[0]);

	for (unsigned int i = 0; i < m_arguments.size(); i++)
	{
		CCommandLineArgument& arg = m_arguments.at(i);
		arg.Value  = arg.DefaultValue;
		arg.Exists = false;
	}

	for (int i = 1; i < argc; i++)
	{
		std::string argString = argv[i];		
		CCommandLineArgument* arg = NULL;

		// See if this argument is valid.
		for (unsigned int j = 0; j < m_arguments.size(); j++)
		{
			CCommandLineArgument& checkArg = m_arguments.at(j);
			if (checkArg.Name == argString || checkArg.ShortName == argString)
			{
				arg = &checkArg;
				break;
			}
		}

		// Nope? :(
		if (arg == NULL)
		{
			printf("Unexpected or invalid argument: %s\n", argString.c_str());
			return false;
		}

		// Boolean value?
		if ((arg->Flags & CMDLINE_ARG_FLAG_BOOL) == CMDLINE_ARG_FLAG_BOOL)
		{
			arg->Value  = "1";
			arg->Exists = true;
		}

		// Standard value?
		else 
		{
			if (++i >= argc)
			{
				printf("Expected value to follow argument: %s\n", argString.c_str());
				return false;
			}

			arg->Value  = argv[i];
			arg->Exists = true;

			// If we are options, check value is valid.
			if ((arg->Flags & CMDLINE_ARG_FLAG_OPTIONS) == CMDLINE_ARG_FLAG_OPTIONS)
			{
				bool foundOption = false;

				for (unsigned int k = 0; k < arg->Options.size(); k++)
				{
					if (arg->Options[k] == arg->Value)
					{
						foundOption = true;
						break;
					}
				}

				if (foundOption == false)
				{
					printf("%s is invalid value for argument %s\n", arg->Value, argString.c_str());
					return false;
				}
			}
		}
	}

	// Check that we found all of the required arguments.
	for (unsigned int i = 0; i < m_arguments.size(); i++)
	{
		CCommandLineArgument& arg = m_arguments.at(i);

		if ((arg.Flags & CMDLINE_ARG_FLAG_REQUIRED) == CMDLINE_ARG_FLAG_REQUIRED &&
			arg.Exists == false)
		{
			printf("Required argument not provided: %s\n", arg.Name.c_str());
			return false;
		}
	}

	return true;
}
