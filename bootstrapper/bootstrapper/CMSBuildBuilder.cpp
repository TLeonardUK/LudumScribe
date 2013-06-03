/* *****************************************************************

		CMSBuildBuilder.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CMSBuildBuilder.h"

#include "CBuilder.h"

#include "CPathHelper.h"
#include "CStringHelper.h"

#include "CASTNode.h"
#include "CPackageASTNode.h"

#include "CSemanter.h"

#include "CTranslationUnit.h"

#include "CCompiler.h"

// =================================================================
//	Build this mofo!
// =================================================================
bool CMSBuildBuilder::Build()
{
	std::string build_dir = m_context->GetCompiler()->GetBuildDirectory();
	CConfigState project_config = m_context->GetCompiler()->GetProjectConfig();

	std::vector<std::string> configs = CStringHelper::Split(project_config.GetString("SUPPORTED_CONFIGS"), '|');
	std::string config_name = project_config.GetString("CONFIG");

	// Gather all source files in the build folder.
	std::vector<std::string> source_files = CPathHelper::ListRecursiveFiles(build_dir, "cpp");

	// Gather all header files in the build folder.
	std::vector<std::string> header_files = CPathHelper::ListRecursiveFiles(build_dir, "hpp");

	// Work out include directories.
	std::vector<std::string> include_paths;
	for (auto iter = header_files.begin(); iter != header_files.end(); iter++)
	{
		std::string dir = CPathHelper::StripFilename(*iter) + "/";
		std::string relative = CPathHelper::GetRelativePath(dir, build_dir);
		if (relative == "")
		{
			relative = ".";
		}

		bool found = false;

		for (auto iter2 = include_paths.begin(); iter2 != include_paths.end(); iter2++)
		{
			if (relative == *iter2)
			{
				found = true;
				break;
			}
		}

		if (found == false)
		{
			include_paths.push_back(relative);
		}
	}
	
	std::string include_path = CStringHelper::Join(include_paths, ";");

	// Create a solution file.
	std::string project_name = CStringHelper::CleanExceptAlphaNum(CPathHelper::StripDirectory(CPathHelper::StripExtension(m_context->GetFilePath())), '_');
	std::string project_guid = "B6037403-B804-4B15-8193-1E54E39D188D"; // TODO: Should probably not hard code this.

	std::string solution_file_path = build_dir + "/" + project_name + ".sln";
	std::string solution_file = 
		std::string("Microsoft Visual Studio Solution File, Format Version 11.00\n") +
		"# Visual Studio 2010\n" +
		"Project(\"{" + project_guid + "}\") = \"" + project_name + "\", \"" + project_name + ".vcxproj\", \"{" + project_guid + "}\"\n" +
		"EndProject\n" +
		"Global\n" +
		"	GlobalSection(SolutionConfigurationPlatforms) = preSolution\n";
	
	solution_file += "		" + config_name + "|Win32 = " + config_name + "|Win32\n";

	solution_file += 
		std::string("	EndGlobalSection\n") +
		"	GlobalSection(ProjectConfigurationPlatforms) = postSolution\n";

	solution_file += "		{" + project_guid + "}." + config_name + "|Win32.ActiveCfg = " + config_name + "|Win32\n";
	solution_file += "		{" + project_guid + "}." + config_name + "|Win32.Build.0 = " + config_name + "|Win32\n";
	
	solution_file += 
		std::string("	EndGlobalSection\n") +
		"	GlobalSection(SolutionProperties) = preSolution\n" +
		"		HideSolutionNode = FALSE\n" +
		"	EndGlobalSection\n" +
		"EndGlobal\n";

	// Emit solution file.
	bool updated = true;
	std::string output = "";
	if (CPathHelper::LoadFile(solution_file_path, output))
	{
		if (output == solution_file)
		{
			updated = false;
		}
	}
	if (updated == true)
	{
		CPathHelper::SaveFile(solution_file_path, solution_file);
	}

	// Create a project file.
	std::string project_file_path = build_dir + "/" + project_name + ".vcxproj";
	std::string project_file = 
	std::string("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n") +
				"<Project DefaultTargets=\"Build\" ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n" +
				"  <ItemGroup Label=\"ProjectConfigurations\">\n";

	project_file += 
		std::string("    <ProjectConfiguration Include=\"" +  config_name+ "|Win32\">\n") +
					"      <Configuration>" + config_name + "</Configuration>\n" +
					"      <Platform>Win32</Platform>\n" +
					"    </ProjectConfiguration>\n";
	
	project_file += "  </ItemGroup>\n";
	project_file +=
		std::string("  <PropertyGroup Label=\"Globals\">\n") +
					"    <ProjectGuid>{" + project_guid + "}</ProjectGuid>\n" +
					"    <Keyword>Win32Proj</Keyword>\n" +
					"    <RootNamespace>" + project_name + "</RootNamespace>\n" +
					"  </PropertyGroup>\n" +
					"  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.Default.props\" />\n";

	if (config_name == "Debug")
	{
		project_file += 
			std::string("  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\" Label=\"Configuration\">\n") +
						"    <ConfigurationType>Application</ConfigurationType>\n" +
						"    <UseDebugLibraries>true</UseDebugLibraries>\n" +
						"    <CharacterSet>Unicode</CharacterSet>\n" +
						"  </PropertyGroup>\n";
	}
	else
	{
		project_file += 
			std::string("  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\" Label=\"Configuration\">\n") +
						"    <ConfigurationType>Application</ConfigurationType>\n" +
						"    <UseDebugLibraries>false</UseDebugLibraries>\n" +
						"    <WholeProgramOptimization>true</WholeProgramOptimization>\n" +
						"    <CharacterSet>Unicode</CharacterSet>\n" +
						"  </PropertyGroup>\n";
	}
	
	project_file +=
		std::string("  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.props\" />\n") +
		"  <ImportGroup Label=\"ExtensionSettings\">\n" +
		"  </ImportGroup>\n";

	project_file += 
		std::string("  <ImportGroup Label=\"PropertySheets\" Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n") +
					"    <Import Project=\"$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\" Condition=\"exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />\n" +
					"  </ImportGroup>\n";

	project_file += "  <PropertyGroup Label=\"UserMacros\" />\n";
	project_file += 
		std::string("  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n") +
					"    <LinkIncremental>true</LinkIncremental>\n" +
					"    <IncludePath>$(VCInstallDir)include;$(VCInstallDir)atlmfc\include;$(WindowsSdkDir)include;$(FrameworkSDKDir)\include;" + include_path + "$(IncludePath)</IncludePath>" + 
					"    <OutDir>$(SolutionDir)\\</OutDir>" + 
					"  </PropertyGroup>\n";

	if (config_name == "Debug")
	{
		project_file += 
			std::string("  <ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n") +
						"    <ClCompile>\n" +
						"      <PrecompiledHeader>NotUsing</PrecompiledHeader>\n" +
						"      <WarningLevel>Level3</WarningLevel>\n" +
						"      <Optimization>Disabled</Optimization>\n" +
						"      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>\n" +
						"      <ObjectFileName>$(IntDir)/%(RelativeDir)/</ObjectFileName>\n" +
						"    </ClCompile>\n" +
						"    <Link>\n" +
						"      <SubSystem>Console</SubSystem>\n" +
						"      <GenerateDebugInformation>true</GenerateDebugInformation>\n" +
						"      <OutputFile>$(SolutionDir)$(TargetName)$(TargetExt)</OutputFile>\n" + 
						"    </Link>\n" +
						"  </ItemDefinitionGroup>\n";
	}
	else
	{
		project_file += 
			std::string("  <ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n") +
						"    <ClCompile>\n" +
						"      <WarningLevel>Level3</WarningLevel>\n" +
						"      <PrecompiledHeader>NotUsing</PrecompiledHeader>\n" +
						"      <Optimization>MaxSpeed</Optimization>\n" +
						"      <FunctionLevelLinking>true</FunctionLevelLinking>\n" +
						"      <IntrinsicFunctions>true</IntrinsicFunctions>\n" +
						"      <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>\n" +
						"      <ObjectFileName>$(IntDir)/%(RelativeDir)/</ObjectFileName>\n" +
						"    </ClCompile>\n" +
						"    <Link>\n" +
						"      <SubSystem>Console</SubSystem>\n" +
						"      <GenerateDebugInformation>true</GenerateDebugInformation>\n" +
						"      <EnableCOMDATFolding>true</EnableCOMDATFolding>\n" +
						"      <OptimizeReferences>true</OptimizeReferences>\n" +
						"    </Link>\n" +
						"  </ItemDefinitionGroup>\n";
	}

	// Include files.
	project_file += "  <ItemGroup>\n";	
	for (auto iter = header_files.begin(); iter != header_files.end(); iter++)
	{
		std::string relative = CPathHelper::GetRelativePath(*iter, project_file_path);
		project_file += "    <ClInclude Include=\"" + relative + "\" />\n";
	}
	project_file += "  </ItemGroup>\n";

	// Source files.
	project_file += "  <ItemGroup>\n";
	for (auto iter = source_files.begin(); iter != source_files.end(); iter++)
	{
		std::string relative = CPathHelper::GetRelativePath(*iter, project_file_path);
		project_file += "    <ClCompile Include=\"" + relative + "\" />\n";
	}
	project_file += "  </ItemGroup>\n";

	project_file += 
		std::string("  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.targets\" />\n") +
					"  <ImportGroup Label=\"ExtensionTargets\">\n" +
					"  </ImportGroup>\n" +
					"</Project>\n";

	// Emit solution file.
	updated = true;
	output = "";
	if (CPathHelper::LoadFile(project_file_path, output))
	{
		if (output == project_file)
		{
			updated = false;
		}
	}
	if (updated == true)
	{
		CPathHelper::SaveFile(project_file_path, project_file);
	}

	// Try and find location of msbuild.
	std::string path = CPathHelper::CleanPath(project_config.GetString("MSBUILD_PATH"));
	if (!CPathHelper::IsFile(path))
	{
		m_context->FatalError("Could not find MSBuild at expected location, are you sure it is installed? Expected Location: " + path);
	}

	// Execute!
	std::string flags = project_config.GetString("MSBUILD_FLAGS", "", false);
	std::string cmd_line =  "\"" + solution_file_path + "\" /t:Build /p:Configuration=" + config_name + " " + flags; 
	if (!m_context->Execute(path, cmd_line))
	{
		m_context->FatalError("MSBuild could not compile output.");
	}

	return true;
}
