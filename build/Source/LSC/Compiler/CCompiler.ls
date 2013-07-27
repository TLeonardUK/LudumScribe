// -----------------------------------------------------------------------------
// 	Compiler.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This file contains the code required to host a compilation action.
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Type of definition.
// =================================================================
public enum DefineType
{
	String,
	Int,
	Float,
	Bool,
}

// =================================================================
//	Used to define a preprocessor value.
// =================================================================
public class CDefine
{
	public DefineType	Type;
	public string		Name;
	public string		Value;

	public CDefine()
	{
	}
	
	public CDefine(DefineType type, string name, string value)
	{
		Type = type;
		Name = name;
		Value = value;
	}
}

// =================================================================
//	Defines a a configuration state used during compilation
//	(eg. platform config, etc).
// =================================================================
public class CConfigState
{
	List<CDefine> 	Defines = new List<CDefine>();
	string 			ConfigPath;

	public CConfigState()
	{
	}
	
	public CConfigState(string path, List<CDefine> defs)
	{
		ConfigPath 	= path;
		Defines 	= defs;
	}

	public CConfigState Merge(CConfigState other)
	{
		CConfigState result = this;
		
		foreach (CDefine def in Defines)
		{
			bool found = false;
			
			foreach (CDefine otherDef in result.Defines)
			{
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
				result.Defines.AddLast(def);
			}
		}

		return result;	
	}
	
	public string GetString(string name, string defaultValue = "", bool errorOnNotExists = true)
	{
		foreach (CDefine def in Defines)
		{
			if (def.Name == name)
			{
				return def.Value;
			}
		}

		if (errorOnNotExists == true)
		{
			Console.WriteLine("Expected value '" + name + "' in configuration file '" + ConfigPath + "'.");
			OS.Exit(0);
		}
		else
		{
			return defaultValue;
		}
	}
}

// =================================================================
//	Class deals with process input and compiling the correct
//	files as requested.
// =================================================================
public class CCompiler
{
	private CCommandLineParser						m_cmdLineParser				= new CCommandLineParser();
	private string									m_packageDirectory;
	private string									m_platformDirectory;
	private string									m_builderDirectory;
	private string									m_translatorDirectory;
	private string									m_buildDirectory;
	private string									m_baseDirectory;

	private string									m_fileExtension;

	private List<CDefine>							m_defines 					= new List<CDefine>();
	
	private Map<string, CConfigState>				m_translator_configs 		= new Map<string, CConfigState>();
	private Map<string, CTranslator>				m_translators 				= new Map<string, CTranslator>();;
	private CConfigState							m_translator_config;
	private CTranslator								m_translator;
	
	private Map<string, CConfigState>				m_builder_configs 			= new Map<string, CConfigState>();
	private Map<string, CBuilder>					m_builders 					= new Map<string, CBuilder>();
	private CConfigState							m_builder_config;
	private CBuilder								m_builder;

	private Map<string, CConfigState>				m_platform_configs 			= new Map<string, CConfigState>();
	private CConfigState							m_platform_config;

	private CConfigState							m_project_config;

	private string									m_executable_path;
	private string									m_executable_dir;

	private string[]								m_cmdline_args;

	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	CCompiler()
	{
		// Create command line parser.
		m_cmdLineParser.AddCommand("-action", "-a",   CommandLineFlags.Options|CommandLineFlags.Required,	"compile",	"Selects the action the application should perform.",		"compile|help");
		m_cmdLineParser.AddCommand("-source", "-s",   CommandLineFlags.String,								"",			"Project file that should be compiled.");
		m_cmdLineParser.AddCommand("-config", "-c",   CommandLineFlags.String,								"Release",	"Defines what configuration to be used when compiling.");
		m_cmdLineParser.AddCommand("-platform", "-p", CommandLineFlags.String,								"Win32",	"Defines what platform to target when compiling.");

		// Some general settings.
		m_fileExtension	= "ls";
		
		// Make list of translators.
		m_translators.Insert("CCPPTranslator", new CCPPTranslator());

		// Make list of builders.
		m_builders.Insert("CMSBuildBuilder", new CMSBuildBuilder());
	}

	// =================================================================
	//	Validates installation and configuration is correct.
	// =================================================================
	bool ValidateConfig()
	{
		// See if we can find the platforms folder.
		m_platformDirectory = Path.Normalize(Path.GetAbsolute(m_executable_dir + "/../Config/Platforms"));
		if (!Directory.Exists(m_platformDirectory))
		{
			Console.WriteLine("Could not platforms configuration directory at: " + m_platformDirectory);
			return false;
		}

		// See if we can find the builders folder.
		m_builderDirectory = Path.Normalize(Path.GetAbsolute(m_executable_dir + "/../Config/Builders"));
		if (!Directory.Exists(m_builderDirectory))
		{
			Console.WriteLine("Could not builders configuration directory at: " + m_builderDirectory);
			return false;
		}
		
		// See if we can find the translators folder.
		m_translatorDirectory = Path.Normalize(Path.GetAbsolute(m_executable_dir + "/../Config/Translators"));
		if (!Directory.Exists(m_translatorDirectory))
		{
			Console.WriteLine("Could not translators configuration directory at: " + m_translatorDirectory);
			return false;
		}

		// See if we can find the package folder.
		m_packageDirectory = Path.Normalize(Path.GetAbsolute(m_executable_dir + "/../Packages"));
		if (!Directory.Exists(m_packageDirectory))
		{
			Console.WriteLine("Could not file package directory at: " + m_packageDirectory);
			return false;
		}

		// Can we parse command line arguments?
		if (!m_cmdLineParser.Parse(m_cmdline_args))
		{
			return false;
		}
		
		// Setup defines.
		m_defines.AddLast(new CDefine(DefineType.String, "CONFIG",   m_cmdLineParser.GetString("-config")));
		m_defines.AddLast(new CDefine(DefineType.String, "PLATFORM", m_cmdLineParser.GetString("-platform")));
		m_defines.AddLast(new CDefine(DefineType.String, "OS", "{PLATFORM}"));

		// Define environment variables.
		Map<string, string> environments = OS.GetEnvironmentMap();
		foreach (MapPair<string, string> pair in environments)
		{
			string name = pair.Key.ToUpper();
			if (name != "OS" &&
				name != "CONFIG" &&
				name != "PLATFORM")
			{
				m_defines.AddLast(new CDefine(DefineType.String, name, pair.Value));
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
		string platform_name  = m_cmdLineParser.GetString("-platform");		
		if (!m_platform_configs.ContainsKey(platform_name))
		{
			Console.WriteLine("Platform '" + platform_name + "' does not exist.");
			return false;
		}
		m_platform_config = m_platform_configs.GetValue(platform_name);

		// Check translator config is valid.
		string translator_name = m_platform_config.GetString("PLATFORM_TRANSLATOR");
		if (!m_translator_configs.ContainsKey(translator_name))
		{
			Console.WriteLine("Translator '" + translator_name + "' configuration does not exist.");
			return false;
		}
		m_translator_config = m_translator_configs.GetValue(translator_name);
		
		// Grab the actual translator instance.
		string internal_translator_name = m_translator_config.GetString("TRANSLATOR_INTERNAL_NAME");
		if (!m_translators.ContainsKey(internal_translator_name))
		{
			Console.WriteLine("Translator '" + internal_translator_name + "' is not implemented.");
			return false;
		}
		m_translator = m_translators.GetValue(internal_translator_name);
		
		// Check builder config is valid.
		string builder_name = m_platform_config.GetString("PLATFORM_BUILDER");
		if (!m_builder_configs.ContainsKey(builder_name))
		{
			Console.WriteLine("Builder '" + builder_name + "' configuration does not exist.");
			return false;
		}
		m_builder_config = m_builder_configs.GetValue(builder_name);
		
		// Grab the actual builder instance.
		string internal_builder_name = m_builder_config.GetString("BUILDER_INTERNAL_NAME");
		if (!m_builders.ContainsKey(internal_builder_name))
		{
			Console.WriteLine("Builder '" + internal_builder_name + "' is not implemented.");
			return false;
		}
		m_builder = m_builders.GetValue(internal_builder_name);

		// All is good!
		return true;
	}

	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	int Process(string[] args)
	{	
		bool showHelp = false;

		// Banner.
		Console.WriteLine("=============================================================");
		Console.WriteLine(" LudumScribe Self-Hosting Transcompiler, version 1.0");
		Console.WriteLine(" Copyright (C) TwinDrills. All rights reserved.");
		Console.WriteLine("=============================================================");
		Console.WriteLine("");

		// Store executable info.
		m_cmdline_args			= args;
		m_executable_path		= args[0];
		m_executable_dir		= Path.StripFilename(Path.GetAbsolute(args[0]));

		// Check configuration.
		if (ValidateConfig())
		{
			// Do whatever the user asked for.
			string action = m_cmdLineParser.GetString("-action");	
			if (action == "compile")
			{		
				if (!m_cmdLineParser.ArgumentExists("-source"))
				{
					Console.WriteLine("Expecting argument -source.\n");
					showHelp = true;
				}
				else
				{
					string source = Path.Normalize(m_cmdLineParser.GetString("-source"));								

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
				Debug.Assert(false); // Should never be possible to get to this point! Parse should fail first.
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
	bool CompilePackage(string path, List<CDefine> defines)
	{	
		// Load project configuration.
		CTranslationUnit unit = new CTranslationUnit(this, path, defines);
		if (!unit.PreProcess())
		{
			Console.WriteLine("Could not parse project file: "+path+"\n");			
			return false;
		}

		m_project_config = m_platform_config;
		m_project_config = m_project_config.Merge(m_translator_config);
		m_project_config = m_project_config.Merge(m_builder_config);
		m_project_config = m_project_config.Merge(new CConfigState(path, unit.GetDefines()));
		m_project_config.ConfigPath = path;

		// Check this platform is supported.
		string[] platforms = m_project_config.GetString("SUPPORTED_PLATFORMS").Split('|');
		string platform = m_project_config.GetString("PLATFORM");

		bool found = false;
		foreach (string iter in platforms)
		{
			if (iter == platform)
			{
				found = true;
				break;
			}
		}

		if (found == false)
		{
			Console.WriteLine("Project does not support platform: " + platform);			
			return false;
		}

		// Check this configuration is supported.
		string[] configs = m_project_config.GetString("SUPPORTED_CONFIGS").Split('|');
		string config = m_project_config.GetString("CONFIG");

		found = false;
		foreach (string iter in configs)
		{
			if (iter == config)
			{
				found = true;
				break;
			}
		}

		if (found == false)
		{
			Console.WriteLine("Project does not support configuration: " + config);			
			return false;
		}

		// Find the file we want to compile.
		string compile_file_path = m_project_config.GetString("COMPILE_FILE");
		if (Path.IsRelative(compile_file_path) == true)
		{
			compile_file_path = Path.Normalize(Path.GetAbsolute(Path.StripFilename(path) + "/" + compile_file_path));
		}
		if (!File.Exists(compile_file_path))
		{
			Console.WriteLine("Could not find file to compile: " + compile_file_path);			
			return false;
		}

		// Find base directory.
		m_baseDirectory = m_project_config.GetString("BUILD_DIR");
		if (Path.IsRelative(m_baseDirectory) == true)
		{
			m_baseDirectory = Path.GetAbsolute(Path.Normalize(Path.StripFilename(path)));
		}
 
		// Create output directory.
		m_buildDirectory = m_project_config.GetString("OUTPUT_DIR");
		if (Path.IsRelative(m_buildDirectory) == true)
		{
			m_buildDirectory = Path.GetAbsolute(Path.Normalize(Path.StripFilename(path) + "/" + m_buildDirectory));
		}
		if (!Directory.Exists(m_buildDirectory))
		{
			Directory.Create(m_buildDirectory);
		}
		if (!Directory.Exists(m_buildDirectory))
		{
			Console.WriteLine("Could not create build directory '" + m_buildDirectory + "'.");
			return false;
		}

		// Attempt to compile!
		CTranslationUnit context = new CTranslationUnit(this, compile_file_path, m_project_config.Defines);
		context.Compile();

		return true;
	}

	// =================================================================
	//	Loads all platform configuration files.
	// =================================================================
	bool LoadPlatformConfig()
	{
		string[] dirs = Directory.List(m_platformDirectory, DirectoryListType.Directories);
		foreach (string iter in dirs)
		{
			string directory    = Path.Normalize(m_platformDirectory + "/" + iter);
			string platformfile = Path.Normalize(m_platformDirectory + "/" + iter + "/" + iter + ".lsplatform");
				
			if (File.Exists(platformfile))
			{
				CTranslationUnit unit = new CTranslationUnit(this, platformfile, m_defines);
				if (!unit.PreProcess())
				{
					Console.WriteLine("Could not process platform configuration file at: " + platformfile);			
					return false;
				}

				CConfigState state = new CConfigState(platformfile, unit.GetDefines());
				m_platform_configs.Insert(state.GetString("PLATFORM_SHORT_NAME", "", true), state);
			}
			else
			{
				Console.WriteLine("Could not find expected platform configuration file at: " + platformfile);
				return false;
			}
		}

		return true;
	}

	// =================================================================
	//	Loads all builder configuration files.
	// =================================================================
	bool LoadBuilderConfig()
	{
		string[] dirs = Directory.List(m_builderDirectory, DirectoryListType.Directories);
		foreach (string iter in dirs)
		{
			string directory = Path.Normalize(m_builderDirectory + "/" + iter);
			string platformfile = Path.Normalize(m_builderDirectory + "/" + iter + "/" + iter + ".lsbuilder");
				
			if (File.Exists(platformfile))
			{
				CTranslationUnit unit = new CTranslationUnit(this, platformfile, m_defines);
				if (!unit.PreProcess())
				{
					Console.WriteLine("Could not process builder configuration file at: " + platformfile);			
					return false;
				}

				CConfigState state = new CConfigState(platformfile, unit.GetDefines());
				m_builder_configs.Insert(state.GetString("BUILDER_SHORT_NAME", "", true), state);
			}
			else
			{
				Console.WriteLine("Could not find expected builder configuration file at: " + platformfile);
				return false;
			}
		}

		return true;
	}

	// =================================================================
	//	Loads all translator configuration files.
	// =================================================================
	bool LoadTranslatorConfig()
	{
		string[] dirs = Directory.List(m_translatorDirectory, DirectoryListType.Directories);
		foreach (string iter in dirs)
		{
			string directory    = Path.Normalize(m_translatorDirectory + "/" + iter);
			string platformfile = Path.Normalize(m_translatorDirectory + "/" + iter + "/" + iter + ".lstranslator");
				
			if (File.Exists(platformfile))
			{
				CTranslationUnit unit = new CTranslationUnit(this, platformfile, m_defines);
				if (!unit.PreProcess())
				{
					Console.WriteLine("Could not process translator configuration file at: " + platformfile);			
					return false;
				}

				CConfigState state = new CConfigState(platformfile, unit.GetDefines());
				m_translator_configs.Insert(state.GetString("TRANSLATOR_SHORT_NAME", "", true), state);
			}
			else
			{
				Console.WriteLine("Could not find expected translator configuration file at: " + platformfile);
				return false;
			}
		}

		return true;
	}

	// =================================================================
	//	Gets the directory that packages are stored in.
	// =================================================================
	string GetPackageDirectory()
	{
		return m_packageDirectory;
	}

	// =================================================================
	//	Gets the directory that builds are stored in.
	// =================================================================
	string GetBuildDirectory()
	{
		return m_buildDirectory;
	}
	
	// =================================================================
	//	Gets the directory thatthe project is in.
	// =================================================================
	string GetProjectDirectory()
	{
		return m_baseDirectory;
	}
		
	// =================================================================
	//	Gets the translator to use when compiling files.
	// =================================================================
	CTranslator GetTranslator()
	{
		return m_translator;
	}

	// =================================================================
	//	Gets the builder to use when compiling files.
	// =================================================================
	CBuilder GetBuilder()
	{
		return m_builder;
	}

	// =================================================================
	//	Gets the configuration for the project.
	// =================================================================
	CConfigState GetProjectConfig()
	{
		return m_project_config;
	}

	// =================================================================
	//	Gets the file extension the compiler uses.
	// =================================================================
	string GetFileExtension()
	{
		return m_fileExtension;
	}

}