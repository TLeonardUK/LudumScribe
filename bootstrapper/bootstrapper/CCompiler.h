/* *****************************************************************

		CCompiler.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCOMPILER_H_
#define _CCOMPILER_H_

#include <map>
#include "CCommandLineParser.h"

class CTranslator;
class CBuilder;

// =================================================================
//	Type of definition.
// =================================================================
namespace DefineType
{
	enum Type
	{
		String,
		Int,
		Float,
		Bool,
	};
};

// =================================================================
//	Used to define a preprocessor value.
// =================================================================
struct CDefine
{
public:
	DefineType::Type	Type;
	std::string			Name;
	std::string			Value;

	CDefine()
	{
	}
	CDefine(DefineType::Type type, std::string name, std::string value)
	{
		Type = type;
		Name = name;
		Value = value;
	}

};

// =================================================================
//	Defines a a configuration state used during compilation
//	(eg. platform config, etc).
// =================================================================
struct CConfigState
{
public:
	std::vector<CDefine> Defines;
	std::string Path;

	CConfigState()
	{
	}
	CConfigState(std::string path, std::vector<CDefine> defs)
	{
		Path = path;
		Defines = defs;
	}

	CConfigState Merge(CConfigState other);
	std::string GetString(std::string name, std::string defaultValue = "", bool errorOnNotExists = true);

};

// =================================================================
//	Class deals with process input and compiling the correct
//	files as requested.
// =================================================================
class CCompiler
{
private:
	CCommandLineParser					m_cmdLineParser;
	std::string							m_packageDirectory;
	std::string							m_platformDirectory;
	std::string							m_builderDirectory;
	std::string							m_translatorDirectory;
	std::string							m_buildDirectory;
	std::string							m_baseDirectory;

	std::string							m_fileExtension;

	std::vector<CDefine>				m_defines;
	
	std::map<std::string, CConfigState>	m_translator_configs;
	std::map<std::string, CTranslator*>	m_translators;
	CConfigState						m_translator_config;
	CTranslator*						m_translator;
	
	std::map<std::string, CConfigState>	m_builder_configs;
	std::map<std::string, CBuilder*>	m_builders;
	CConfigState						m_builder_config;
	CBuilder*							m_builder;

	std::map<std::string, CConfigState>	m_platform_configs;
	CConfigState						m_platform_config;

	CConfigState						m_project_config;

	std::string							m_executable_path;
	std::string							m_executable_dir;

	char**								m_cmdline_args;
	int									m_cmdline_args_count;

public:
	CCompiler();

	std::string GetPackageDirectory		();	
	std::string GetBuildDirectory		();	
	std::string GetProjectDirectory		();	
	std::string GetFileExtension		();

	CTranslator* GetTranslator			();
	CBuilder*	 GetBuilder				();
	CConfigState GetProjectConfig		();

	bool		 ValidateConfig			();

	int			Process					(int argc, char* argv[]);
	bool		LoadPlatformConfig		();
	bool		LoadBuilderConfig		();
	bool		LoadTranslatorConfig	();
	bool		CompilePackage			(std::string source, std::vector<CDefine> defines);

};

#endif