// -----------------------------------------------------------------------------
// 	CMSBuildBuilder.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for compiling translated source code into a final
//	binary executable using MSBuild.
// =================================================================
public class CMSBuildBuilder : CBuilder
{
	protected override bool Build()
	{
		string build_dir = Path.GetAbsolute(m_context.GetCompiler().GetBuildDirectory()) + "/";
		CConfigState project_config = m_context.GetCompiler().GetProjectConfig();

		string project_dir = m_context.GetCompiler().GetProjectDirectory();
		
		string output_file_name = project_config.GetString("OUTPUT_FILE");
		
		string[] configs = project_config.GetString("SUPPORTED_CONFIGS").Split('|');
		string config_name = project_config.GetString("CONFIG");

		List<string> files = m_context.GetTranslatedFiles();

		string output_dir = project_config.GetString("OUTPUT_DIR") + "/";
		if (Path.IsRelative(output_dir))
		{
			output_dir = project_dir + output_dir;
		}
		output_dir = Path.Normalize(Path.GetAbsolute(output_dir));

		// Gather all source files in the build folder.
		List<string> source_files = new List<string>();
		List<string> header_files = new List<string>();
		List<string> library_files = new List<string>();
		foreach (string iter in files)
		{
			string file = Path.Normalize(iter);
			string ext = Path.ExtractExtension(file.ToLower());

			if (ext == "hpp" || ext == "h")
			{
				header_files.AddLast(Path.GetAbsolute(file));
			}
			else if (ext == "lib")
			{
				library_files.AddLast(Path.GetAbsolute(file));
			}
			else 
			{
				source_files.AddLast(Path.GetAbsolute(file));
			}
		}

		// Work out include directories.
		List<string> include_paths = new List<string>();
		foreach (string iter in header_files)
		{
			string dir = Path.StripFilename(iter) + "/";
			string relative = Path.GetRelative(dir, build_dir);
			if (relative == "")
			{
				relative = ".";
			}

			bool found = false;

			foreach (string iter2 in include_paths)
			{
				if (relative == iter2)
				{
					found = true;
					break;
				}
			}

			if (found == false)
			{
				include_paths.AddLast(relative);
			}
		}
		
		string include_path = ";".Join(include_paths);
		
		// Work out library directories.
		List<string> full_library_paths = new List<string>();
		List<string> full_library_names = new List<string>();
		foreach (string iter in library_files)
		{
			string dir = Path.StripFilename(iter) + "/";
			string relative = Path.GetRelative(dir, build_dir);
			if (relative == "")
			{
				relative = ".";
			}

			bool found = false;

			foreach (string iter2 in full_library_paths)
			{
				if (relative == iter2)
				{
					found = true;
					break;
				}
			}

			if (found == false)
			{
				full_library_paths.AddLast(relative);
				full_library_names.AddLast(Path.StripDirectory(iter));
			}
		}

		string library_names = ";".Join(full_library_names);
		string library_paths = ";".Join(full_library_paths);

		// Create a solution file.
		string project_name = Path.StripDirectory(Path.StripExtension(m_context.GetFilePath())).Filter("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "_");
		string project_guid = "B6037403-B804-4B15-8193-1E54E39D188D"; // TODO: Should probably not hard code this.

		string solution_file_path = Path.Normalize(build_dir + "/" + project_name + ".sln");
		string solution_file = 
			"Microsoft Visual Studio Solution File, Format Version 11.00\n" +
			"# Visual Studio 2010\n" +
			"Project(\"{" + project_guid + "}\") = \"" + project_name + "\", \"" + project_name + ".vcxproj\", \"{" + project_guid + "}\"\n" +
			"EndProject\n" +
			"Global\n" +
			"	GlobalSection(SolutionConfigurationPlatforms) = preSolution\n";
		
		solution_file += "		" + config_name + "|Win32 = " + config_name + "|Win32\n";

		solution_file += 
			"	EndGlobalSection\n" +
			"	GlobalSection(ProjectConfigurationPlatforms) = postSolution\n";

		solution_file += "		{" + project_guid + "}." + config_name + "|Win32.ActiveCfg = " + config_name + "|Win32\n";
		solution_file += "		{" + project_guid + "}." + config_name + "|Win32.Build.0 = " + config_name + "|Win32\n";
		
		solution_file += 
			"	EndGlobalSection\n" +
			"	GlobalSection(SolutionProperties) = preSolution\n" +
			"		HideSolutionNode = FALSE\n" +
			"	EndGlobalSection\n" +
			"EndGlobal\n";

		// Emit solution file.
		string output = "";
		
		try
		{
			output = File.LoadText(solution_file_path);
		}
		catch (OperationFailedException ex)
		{
			m_context.FatalError("Could not read file '" + solution_file_path + "'.");
		}
		
		if (output != solution_file)
		{
			try
			{
				File.SaveText(solution_file_path, solution_file);
			}
			catch (OperationFailedException ex)
			{
				m_context.FatalError("Could not write file '" + solution_file_path + "'.");
			}
		}

		// Create a project file.
		string project_file_path = build_dir + "/" + project_name + ".vcxproj";
		string project_file = 
				"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
					"<Project DefaultTargets=\"Build\" ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n" +
					"  <ItemGroup Label=\"ProjectConfigurations\">\n";

		project_file += 
				  "    <ProjectConfiguration Include=\"" +  config_name+ "|Win32\">\n" +
						"      <Configuration>" + config_name + "</Configuration>\n" +
						"      <Platform>Win32</Platform>\n" +
						"    </ProjectConfiguration>\n";
		
		project_file += "  </ItemGroup>\n";
		project_file +=
					"  <PropertyGroup Label=\"Globals\">\n" +
						"    <ProjectGuid>{" + project_guid + "}</ProjectGuid>\n" +
						"    <Keyword>Win32Proj</Keyword>\n" +
						"    <RootNamespace>" + project_name + "</RootNamespace>\n" +
						"  </PropertyGroup>\n" +
						"  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.Default.props\" />\n";

		if (config_name == "Debug")
		{
			project_file += 
						"  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\" Label=\"Configuration\">\n" +
							"    <ConfigurationType>Application</ConfigurationType>\n" +
							"    <UseDebugLibraries>true</UseDebugLibraries>\n" +
							"    <CharacterSet>Unicode</CharacterSet>\n" +
							"  </PropertyGroup>\n";
		}
		else
		{
			project_file += 
					"  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\" Label=\"Configuration\">\n" +
							"    <ConfigurationType>Application</ConfigurationType>\n" +
							"    <UseDebugLibraries>false</UseDebugLibraries>\n" +
							"    <WholeProgramOptimization>true</WholeProgramOptimization>\n" +
							"    <CharacterSet>Unicode</CharacterSet>\n" +
							"  </PropertyGroup>\n";
		}
		
		project_file +=
				"  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.props\" />\n" +
			"  <ImportGroup Label=\"ExtensionSettings\">\n" +
			"  </ImportGroup>\n";

		project_file += 
				"  <ImportGroup Label=\"PropertySheets\" Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n" +
						"    <Import Project=\"$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\" Condition=\"exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />\n" +
						"  </ImportGroup>\n";

		project_file += "  <PropertyGroup Label=\"UserMacros\" />\n";
		project_file += 
				"  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n" +
						"    <LinkIncremental>false</LinkIncremental>\n" +
						"    <IncludePath>$(ProjectDir)Source;$(VCInstallDir)include;$(VCInstallDir)atlmfc\\include;$(WindowsSdkDir)include;$(FrameworkSDKDir)\\include;" + include_path + ";$(IncludePath)</IncludePath>" + 
						"    <OutDir>" + output_dir + "</OutDir>" + 
						"  </PropertyGroup>\n";

		if (config_name == "Debug")
		{
			project_file += 
					"  <ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n" +
							"    <ClCompile>\n" +
							"      <PrecompiledHeader>NotUsing</PrecompiledHeader>\n" +
							"      <WarningLevel>Level3</WarningLevel>\n" +
							"      <Optimization>Disabled</Optimization>\n" +
							"      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>\n" +
							"      <ObjectFileName>$(IntDir)/%(RelativeDir)/</ObjectFileName>\n" +
							"    </ClCompile>\n" +
							"    <Link>\n" +
							"	   <AdditionalDependencies>" + library_names + ";%(AdditionalDependencies)</AdditionalDependencies>" +
							"	   <AdditionalLibraryDirectories>" + library_paths + ";%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>" + 
							"      <SubSystem>Console</SubSystem>\n" +
							"      <GenerateDebugInformation>true</GenerateDebugInformation>\n" +
							"      <OutputFile>" + output_dir + output_file_name + "</OutputFile>\n" + 
							"    </Link>\n" +
							"  </ItemDefinitionGroup>\n";
		}
		else
		{
			project_file += 
					"  <ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='" + config_name + "|Win32'\">\n" +
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
							"	   <AdditionalDependencies>" + library_names + ";%(AdditionalDependencies)</AdditionalDependencies>" +
							"	   <AdditionalLibraryDirectories>" + library_paths + ";%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>" + 
							"      <SubSystem>Console</SubSystem>\n" +
							"      <GenerateDebugInformation>true</GenerateDebugInformation>\n" +
							"      <EnableCOMDATFolding>true</EnableCOMDATFolding>\n" +
							"      <OptimizeReferences>true</OptimizeReferences>\n" +
							"      <OutputFile>" + output_dir + output_file_name + "</OutputFile>\n" + 
							"    </Link>\n" +
							"  </ItemDefinitionGroup>\n";
		}

		// Include files.
		project_file += "  <ItemGroup>\n";	
		foreach (string iter in header_files)
		{
			string relative = Path.GetRelative(iter, project_file_path);
			project_file += "    <ClInclude Include=\"" + relative + "\" />\n";
		}
		project_file += "  </ItemGroup>\n";

		// Source files.
		project_file += "  <ItemGroup>\n";
		foreach (string iter in source_files)
		{
			string relative = Path.GetRelative(iter, project_file_path);
			project_file += "    <ClCompile Include=\"" + relative + "\" />\n";
		}
		project_file += "  </ItemGroup>\n";

		project_file += 
				"  <Import Project=\"$(VCTargetsPath)\\Microsoft.Cpp.targets\" />\n" +
						"  <ImportGroup Label=\"ExtensionTargets\">\n" +
						"  </ImportGroup>\n" +
						"</Project>\n";

		// Emit solution file.
		output = "";
		try
		{
			output = File.LoadText(project_file_path);
		}
		catch (OperationFailedException ex)
		{
			m_context.FatalError("Could not read file '" + solution_file_path + "'.");
		}
		
		if (output != project_file)
		{
			try
			{
				File.SaveText(project_file_path, project_file);
			}
			catch (OperationFailedException ex)
			{
				m_context.FatalError("Could not write file '" + solution_file_path + "'.");
			}
		}

		// Try and find location of msbuild.
		string path = Path.Normalize(project_config.GetString("MSBUILD_PATH"));
		if (!File.Exists(path))
		{
			m_context.FatalError("Could not find MSBuild at expected location, are you sure it is installed? Expected Location: " + path);
		}

		// Execute!
		string flags = project_config.GetString("MSBUILD_FLAGS", "", false);
		string cmd_line =  "\"" + solution_file_path + "\" /t:Build /p:Configuration=" + config_name + " " + flags; 
		if (!OS.Execute(path, cmd_line))
		{
			m_context.FatalError("MSBuild failed to compile output.");
		}

		return true;
	}	
}



