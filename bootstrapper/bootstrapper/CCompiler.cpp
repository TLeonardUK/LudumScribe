/* *****************************************************************

		CCompiler.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <string>
#include <map>
#include <stdio.h>
#include <assert.h>

#include "CCompiler.h"
#include "CLexer.h"
#include "CParser.h"
#include "CStringHelper.h"
#include "CPathHelper.h"
#include "CTranslationUnit.h"

#include "CCPPTranslator.h"

#include "CMSBuildBuilder.h"

#include <windows.h>

// =================================================================
//	Merges two config states and returns the result. The passed
//	config state overrides settings in the first state.
// =================================================================
CConfigState CConfigState::Merge(CConfigState other)
{
	CConfigState result = *this;
	
	for (auto iter = other.Defines.begin(); iter != other.Defines.end(); iter++)
	{
		CDefine def = *iter;
		bool found = false;
		
		for (auto iter2 = result.Defines.begin(); iter2 != result.Defines.end(); iter2++)
		{
			CDefine& otherDef = *iter2;
			if (def.Name == otherDef.Name)
			{
				otherDef.Value = def.Value;
				otherDef.Type = def.Type;
				found = true;

				break;
			}
		}

		if (found == false)
		{
			result.Defines.push_back(def);
		}
	}

	return result;
}

// =================================================================
//	Gets a string value from a configuration state.
// =================================================================
std::string CConfigState::GetString(std::string name, std::string defaultValue, bool errorOnNotExists)
{
	for (auto iter = Defines.begin(); iter != Defines.end(); iter++)
	{
		CDefine def = *iter;
		if (def.Name == name)
		{
			return def.Value;
		}
	}

	if (errorOnNotExists == true)
	{
		printf("Expected value '%s' in configuration file '%s'.", name.c_str(), Path.c_str());
		exit(0);
	}
	else
	{
		return defaultValue;
	}
}

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CCompiler::CCompiler()
{
	// Create command line parser.
	m_cmdLineParser.AddCommand("-action", "-a", CMDLINE_ARG_FLAG_OPTIONS|CMDLINE_ARG_FLAG_REQUIRED,	"compile",	"Selects the action the application should perform.",		"compile|help");
	m_cmdLineParser.AddCommand("-source", "-s", CMDLINE_ARG_FLAG_STRING,							"",			"Project file that should be compiled.");
	m_cmdLineParser.AddCommand("-config", "-c", CMDLINE_ARG_FLAG_STRING,							"Release",	"Defines what configuration to be used when compiling.");
	m_cmdLineParser.AddCommand("-platform", "-p", CMDLINE_ARG_FLAG_STRING,							"Win32",	"Defines what platform to target when compiling.");

	// Some general settings.
	m_fileExtension	= "ls";
	
	// Make list of translators.
	m_translators.insert(std::pair<std::string, CTranslator*>("CCPPTranslator", new CCPPTranslator()));

	// Make list of builders.
	m_builders.insert(std::pair<std::string, CBuilder*>("CMSBuildBuilder", new CMSBuildBuilder()));
}

// =================================================================
//	Validates installation and configuration is correct.
// =================================================================
bool CCompiler::ValidateConfig()
{
	// See if we can find the platforms folder.
	m_platformDirectory = CPathHelper::CleanPath(CPathHelper::GetAbsolutePath(m_executable_dir + "/../Config/Platforms"));
	if (!CPathHelper::IsDirectory(m_platformDirectory))
	{
		printf("Could not platforms configuration directory at: %s\n", m_platformDirectory.c_str());
		return false;
	}

	// See if we can find the builders folder.
	m_builderDirectory = CPathHelper::CleanPath(CPathHelper::GetAbsolutePath(m_executable_dir + "/../Config/Builders"));
	if (!CPathHelper::IsDirectory(m_builderDirectory))
	{
		printf("Could not builders configuration directory at: %s\n", m_builderDirectory.c_str());
		return false;
	}
	
	// See if we can find the translators folder.
	m_translatorDirectory = CPathHelper::CleanPath(CPathHelper::GetAbsolutePath(m_executable_dir + "/../Config/Translators"));
	if (!CPathHelper::IsDirectory(m_translatorDirectory))
	{
		printf("Could not translators configuration directory at: %s\n", m_translatorDirectory.c_str());
		return false;
	}

	// See if we can find the package folder.
	m_packageDirectory = CPathHelper::CleanPath(CPathHelper::GetAbsolutePath(m_executable_dir + "/../Packages"));
	if (!CPathHelper::IsDirectory(m_packageDirectory))
	{
		printf("Could not file package directory at: %s\n", m_packageDirectory.c_str());
		return false;
	}

	// Can we parse command line arguments?
	if (!m_cmdLineParser.Parse(m_cmdline_args_count, m_cmdline_args))
	{
		return false;
	}
	
	// Setup defines.
	m_defines.push_back(CDefine(DefineType::String, "CONFIG",   m_cmdLineParser.GetString("-config")));
	m_defines.push_back(CDefine(DefineType::String, "PLATFORM", m_cmdLineParser.GetString("-platform")));
#if defined(_WIN32) || defined(__MINGW32__)
	m_defines.push_back(CDefine(DefineType::String, "OS",		"Win32"));
#elif defined(__linux__) || defined(__GNUC__)
	m_defines.push_back(CDefine(DefineType::String, "OS",		"Linux"));
#elif defined(__APPLE__)
	m_defines.push_back(CDefine(DefineType::String, "OS",		"MacOS"));
#else
	#error "Unknown or unsupported platform."
#endif

	// Define environment variables.
	std::map<std::string, std::string> environments = CStringHelper::GetEnvironmentVariables();
	for (auto iter = environments.begin(); iter != environments.end(); iter++)
	{
		std::string name = CStringHelper::ToUpper((*iter).first);
		if (name != "OS" &&
			name != "CONFIG" &&
			name != "PLATFORM")
		{
			m_defines.push_back(CDefine(DefineType::String, name, (*iter).second));
		}
	}

	// Load platform definition files.
	if (!LoadPlatformConfig())
	{
		return false;
	}
	
	// Load translator definition files.
	if (!LoadTranslatorConfig())
	{
		return false;
	}
	
	// Load builder definition files.
	if (!LoadBuilderConfig())
	{
		return false;
	}

	// Check platform given is valid.
	std::string platform_name   = m_cmdLineParser.GetString("-platform");
	auto	    plat			= m_platform_configs.find(platform_name);
	if (plat == m_platform_configs.end())
	{
		printf("Platform '%s' does not exist.\n", platform_name.c_str());
		return false;
	}
	m_platform_config = (*plat).second;

	// Check translator config is valid.
	std::string translator_name = m_platform_config.GetString("PLATFORM_TRANSLATOR");
	auto		trans			= m_translator_configs.find(translator_name);
	if (trans == m_translator_configs.end())
	{
		printf("Translator '%s' configuration does not exist.\n", translator_name.c_str());
		return false;
	}
	m_translator_config = (*trans).second;
	
	// Grab the actual translator instance.
	std::string internal_translator_name = m_translator_config.GetString("TRANSLATOR_INTERNAL_NAME");
	auto		internal_trans			 = m_translators.find(internal_translator_name);
	if (internal_trans == m_translators.end())
	{
		printf("Translator '%s' is not implemented.\n", internal_translator_name.c_str());
		return false;
	}
	m_translator = (*internal_trans).second;
	
	// Check builder config is valid.
	std::string builder_name = m_platform_config.GetString("PLATFORM_BUILDER");
	auto		builder		 = m_builder_configs.find(builder_name);
	if (builder == m_builder_configs.end())
	{
		printf("Builder '%s' configuration does not exist.\n", builder_name.c_str());
		return false;
	}
	m_builder_config = (*builder).second;
	
	// Grab the actual builder instance.
	std::string internal_builder_name = m_builder_config.GetString("BUILDER_INTERNAL_NAME");
	auto		internal_builder	  = m_builders.find(internal_builder_name);
	if (internal_builder == m_builders.end())
	{
		printf("Builder '%s' is not implemented.\n", internal_builder_name.c_str());
		return false;
	}
	m_builder = (*internal_builder).second;

	// All is good!
	return true;
}

// =================================================================
//	Processes input and performs the actions requested.
// =================================================================
int CCompiler::Process(int argc, char* argv[])
{	
	bool showHelp = false;

	// Banner.
	printf("=============================================================\n");
	printf(" LudumScribe Bootstrapper Transcompiler, version 1.0\n");
	printf(" Copyright (C) TwinDrills. All rights reserved.\n");
	printf("=============================================================\n");
	printf("\n");

	// Store executable info.
	m_cmdline_args			= argv;
	m_cmdline_args_count	= argc;
	m_executable_path		= argv[0];
	m_executable_dir		= CPathHelper::StripFilename(argv[0]);

	// Check configuration.
	if (ValidateConfig())
	{
		// Do whatever the user asked for.
		std::string action = m_cmdLineParser.GetString("-action");	
		if (action == "compile")
		{		
			if (!m_cmdLineParser.ArgumentExists("-source"))
			{
				printf("Expecting argument -source.\n");
				showHelp = true;
			}
			else
			{
				std::string source = CPathHelper::CleanPath(m_cmdLineParser.GetString("-source"));								

				if (!CompilePackage(source, m_defines))
				{
					showHelp = true;
				}
			}
		}	
		else if (action == "help")
		{
			showHelp = true;
		}
		else
		{
			assert(false); // Should never be possible to get to this point! Parse should fail first.
		}
	}	
	else
	{
		showHelp = true;
	}
	
	if (showHelp == true)
	{
		m_cmdLineParser.PrintSyntax();
	}

	return showHelp ? 1 : 0;
}

// =================================================================
//	Compiles the given package file.
// =================================================================
bool CCompiler::CompilePackage(std::string path, std::vector<CDefine> defines)
{	
	// Load project configuration.
	CTranslationUnit* unit = new CTranslationUnit(this, path, defines);
	if (!unit->PreProcess())
	{
		printf("Could not parse project file: %s\n", path.c_str());			
		return false;
	}

	m_project_config = m_platform_config;
	m_project_config = m_project_config.Merge(m_translator_config);
	m_project_config = m_project_config.Merge(m_builder_config);
	m_project_config = m_project_config.Merge(CConfigState(path, unit->GetDefines()));
	m_project_config.Path = path;

	// Check this platform is supported.
	std::vector<std::string> platforms = CStringHelper::Split(m_project_config.GetString("SUPPORTED_PLATFORMS"), '|');
	std::string platform = m_project_config.GetString("PLATFORM");

	bool found = false;
	for (auto iter = platforms.begin(); iter != platforms.end(); iter++)
	{
		if (*iter == platform)
		{
			found = true;
			break;
		}
	}

	if (found == false)
	{
		printf("Project does not support platform: %s\n", platform.c_str());			
		return false;
	}

	// Check this configuration is supported.
	std::vector<std::string> configs = CStringHelper::Split(m_project_config.GetString("SUPPORTED_CONFIGS"), '|');
	std::string config = m_project_config.GetString("CONFIG");

	found = false;
	for (auto iter = configs.begin(); iter != configs.end(); iter++)
	{
		if (*iter == config)
		{
			found = true;
			break;
		}
	}

	if (found == false)
	{
		printf("Project does not support configuration: %s\n", config.c_str());			
		return false;
	}

	// Find the file we want to compile.
	std::string compile_file_path = m_project_config.GetString("COMPILE_FILE");
	if (CPathHelper::IsRelative(compile_file_path) == true)
	{
		compile_file_path = CPathHelper::CleanPath(CPathHelper::StripFilename(path) + "/" + compile_file_path);
	}
	if (!CPathHelper::IsFile(compile_file_path))
	{
		printf("Could not find file to compile: %s\n", compile_file_path.c_str());			
		return false;
	}

	// Create output directory.
	m_buildDirectory = m_project_config.GetString("BUILD_DIR");
	if (CPathHelper::IsRelative(m_buildDirectory) == true)
	{
		m_buildDirectory = CPathHelper::CleanPath(CPathHelper::StripFilename(path) + "/" + m_buildDirectory);
	}
	if (!CPathHelper::IsDirectory(m_buildDirectory))
	{
		CPathHelper::MakeDirectory(m_buildDirectory);
	}
	if (!CPathHelper::IsDirectory(m_buildDirectory))
	{
		printf("Could not create build directory '%s'.\n", m_buildDirectory.c_str());
		return false;
	}

	// Attempt to compile!
	CTranslationUnit context(this, compile_file_path, m_project_config.Defines);
	context.Compile();

	return true;
}

// =================================================================
//	Loads all platform configuration files.
// =================================================================
bool CCompiler::LoadPlatformConfig()
{
	std::vector<std::string> dirs = CPathHelper::ListDirs(m_platformDirectory);
	for (auto iter = dirs.begin(); iter != dirs.end(); iter++)
	{
		std::string directory = CPathHelper::CleanPath(m_platformDirectory + "/" + *iter);
		std::string platformfile = CPathHelper::CleanPath(m_platformDirectory + "/" + *iter + "/" + *iter + ".lsplatform");
			
		if (CPathHelper::IsFile(platformfile))
		{
			CTranslationUnit* unit = new CTranslationUnit(this, platformfile, m_defines);
			if (!unit->PreProcess())
			{
				printf("Could not process platform configuration file at: %s\n", platformfile.c_str());			
				return false;
			}

			CConfigState state(platformfile, unit->GetDefines());
			m_platform_configs.insert(std::pair<std::string, CConfigState>(state.GetString("PLATFORM_SHORT_NAME", "", true), state));
		}
		else
		{
			printf("Could not find expected platform configuration file at: %s\n", platformfile.c_str());
			return false;
		}
	}

	return true;
}

// =================================================================
//	Loads all builder configuration files.
// =================================================================
bool CCompiler::LoadBuilderConfig()
{
	std::vector<std::string> dirs = CPathHelper::ListDirs(m_builderDirectory);
	for (auto iter = dirs.begin(); iter != dirs.end(); iter++)
	{
		std::string directory = CPathHelper::CleanPath(m_builderDirectory + "/" + *iter);
		std::string platformfile = CPathHelper::CleanPath(m_builderDirectory + "/" + *iter + "/" + *iter + ".lsbuilder");
			
		if (CPathHelper::IsFile(platformfile))
		{
			CTranslationUnit* unit = new CTranslationUnit(this, platformfile, m_defines);
			if (!unit->PreProcess())
			{
				printf("Could not process builder configuration file at: %s\n", platformfile.c_str());			
				return false;
			}

			CConfigState state(platformfile, unit->GetDefines());
			m_builder_configs.insert(std::pair<std::string, CConfigState>(state.GetString("BUILDER_SHORT_NAME", "", true), state));
		}
		else
		{
			printf("Could not find expected builder configuration file at: %s\n", platformfile.c_str());
			return false;
		}
	}

	return true;
}

// =================================================================
//	Loads all translator configuration files.
// =================================================================
bool CCompiler::LoadTranslatorConfig()
{
	std::vector<std::string> dirs = CPathHelper::ListDirs(m_translatorDirectory);
	for (auto iter = dirs.begin(); iter != dirs.end(); iter++)
	{
		std::string directory = CPathHelper::CleanPath(m_translatorDirectory + "/" + *iter);
		std::string platformfile = CPathHelper::CleanPath(m_translatorDirectory + "/" + *iter + "/" + *iter + ".lstranslator");
			
		if (CPathHelper::IsFile(platformfile))
		{
			CTranslationUnit* unit = new CTranslationUnit(this, platformfile, m_defines);
			if (!unit->PreProcess())
			{
				printf("Could not process translator configuration file at: %s\n", platformfile.c_str());			
				return false;
			}

			CConfigState state(platformfile, unit->GetDefines());
			m_translator_configs.insert(std::pair<std::string, CConfigState>(state.GetString("TRANSLATOR_SHORT_NAME", "", true), state));
		}
		else
		{
			printf("Could not find expected translator configuration file at: %s\n", platformfile.c_str());
			return false;
		}
	}

	return true;
}

// =================================================================
//	Gets the directory that packages are stored in.
// =================================================================
std::string CCompiler::GetPackageDirectory()
{
	return m_packageDirectory;
}

// =================================================================
//	Gets the directory that builds are stored in.
// =================================================================
std::string CCompiler::GetBuildDirectory()
{
	return m_buildDirectory;
}

// =================================================================
//	Gets the translator to use when compiling files.
// =================================================================
CTranslator* CCompiler::GetTranslator()
{
	return m_translator;
}

// =================================================================
//	Gets the builder to use when compiling files.
// =================================================================
CBuilder* CCompiler::GetBuilder()
{
	return m_builder;
}

// =================================================================
//	Gets the configuration for the project.
// =================================================================
CConfigState CCompiler::GetProjectConfig()
{
	return m_project_config;
}

// =================================================================
//	Gets the file extension the compiler uses.
// =================================================================
std::string CCompiler::GetFileExtension()
{
	return m_fileExtension;
}

