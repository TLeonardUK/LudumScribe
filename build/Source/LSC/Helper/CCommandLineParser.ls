// -----------------------------------------------------------------------------
// 	CCommandLineParser.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Command line flags.
// =================================================================
public enum CommandLineFlags
{
	String		= 0x00000001,
	Bool		= 0x00000002,
	Options		= 0x00000004,
	Required   	= 0x10000000
}

// =================================================================
//	Stores information on an argument that can be parsed.
// =================================================================
public class CCommandLineArgument
{
	public string Name;
	public string ShortName;
	public int Flags;
	public string DefaultValue;
	public string Description;
	public string[] Options;
	
	public string Value;
	public bool Exists;
}

// =================================================================
//	Class deals with parsing and storing command line arguments.
// =================================================================
public class CCommandLineParser
{
	private List<CCommandLineArgument> m_arguments = new List<CCommandLineArgument>();
	private string m_exeName;
		
	// =================================================================
	//	Defines a new argument that can be parsed.
	// =================================================================
	public void AddCommand(string name, string shortName, int flags, string defaultValue, string description, string options = "")
	{
		// If we are an options arguments, we NEED to have some available options.
		Debug.Assert((flags & CommandLineFlags.Options) == 0 || options.Length() > 0);

		CCommandLineArgument arg = new CCommandLineArgument();
		arg.Name			= name;
		arg.ShortName		= shortName;
		arg.Flags			= flags;
		arg.DefaultValue	= defaultValue;
		arg.Description		= description;
		arg.Options			= options.Split("|");
		
		m_arguments.AddLast(arg);
	}
		
	// =================================================================
	//	Prints the syntax this parser accepts into stdout.
	// =================================================================
	public void PrintSyntax()
	{
		Console.WriteLine("");
		Console.WriteLine("USAGE:");
		Console.WriteLine("\t" + m_exeName + " [options]");
		Console.WriteLine("");

		Console.WriteLine("OPTIONS:");

		foreach (CCommandLineArgument arg in m_arguments)
		{
			string example = "\t";
			example += arg.Name;
			
			// Show <1|2|3> if we are options.
			if ((arg.Flags & CommandLineFlags.Options) == CommandLineFlags.Options)
			{
				example += " <";

				for (int i = 0; i < arg.Options.Length(); i++)
				{
					if (i > 0)
					{
						example += "|";
					}
					example += arg.Options[i];
				}
				example += "> ";
			}

			// Show <value> if we are not a toggle.
			else if ((arg.Flags & CommandLineFlags.Bool) == 0)
			{
				example += " <value> ";
			}

			example = example.PadRight(30, " ");
			example += arg.Description;

			Console.WriteLine(example);
		}
	}
		
	// =================================================================
	//	Parses command line arguments and stores them.
	// =================================================================
	public bool Parse(string[] argv)
	{
		m_exeName = Path.StripDirectory(argv[0]);

		foreach (CCommandLineArgument arg in m_arguments)
		{
			arg.Value  = arg.DefaultValue;
			arg.Exists = false;
		}

		for (int i = 1; i < argv.Length(); i++)
		{
			string argString = argv[i];		
			CCommandLineArgument arg = null;

			// See if this argument is valid.
			foreach (CCommandLineArgument checkArg in m_arguments)
			{
				if (checkArg.Name == argString || checkArg.ShortName == argString)
				{
					arg = checkArg;
					break;
				}
			}

			// Nope? :(
			if (arg == null)
			{
				Console.WriteLine("Unexpected or invalid argument: " + argString);
				return false;
			}

			// Boolean value?
			if ((arg.Flags & CommandLineFlags.Bool) == CommandLineFlags.Bool)
			{
				arg.Value  = "1";
				arg.Exists = true;
			}

			// Standard value?
			else 
			{
				if (++i >= argv.Length())
				{
					Console.WriteLine("Expected value to follow argument: " + argString);
					return false;
				}

				arg.Value  = argv[i];
				arg.Exists = true;

				// If we are options, check value is valid.
				if ((arg.Flags & CommandLineFlags.Options) == CommandLineFlags.Options)
				{
					bool foundOption = false;

					foreach (string op in arg.Options)
					{
						if (op == arg.Value)
						{
							foundOption = true;
							break;
						}
					}

					if (foundOption == false)
					{
						Console.WriteLine(arg.Value + " is invalid value for argument " + argString);
						return false;
					}
				}
			}
		}

		// Check that we found all of the required arguments.
		foreach (CCommandLineArgument arg in m_arguments)
		{
			if ((arg.Flags & CommandLineFlags.Required) == CommandLineFlags.Required &&
				arg.Exists == false)
			{
				Console.WriteLine("Required argument not provided: " + arg.Name);
				return false;
			}
		}

		return true;
	}
		
	// =================================================================
	//	Gets the string value of the given command.
	// =================================================================
	public string GetString(string name)
	{
		foreach (CCommandLineArgument arg in m_arguments)
		{
			if ((arg.Name == name || arg.ShortName == name))//  && checkArg.Exists == true)
			{
				return arg.Value;
			}
		}

		return "";
	}
		
	// =================================================================
	//	Gets the boolean value of the given command.
	// =================================================================
	public bool GetBool(string name)
	{
		foreach (CCommandLineArgument arg in m_arguments)
		{
			if ((arg.Name == name || arg.ShortName == name))// && checkArg.Exists == true)
			{
				return arg.Value != "0" && 
					   arg.Value != "" && 
					   arg.Value != "false";
			}
		}

		return false;
	}
		
	// =================================================================
	//	Returns true if the given argument exists.
	// =================================================================
	public bool ArgumentExists(string name)
	{
		foreach (CCommandLineArgument arg in m_arguments)
		{
			if ((arg.Name == name || arg.ShortName == name) && arg.Exists == true)
			{
				return true;
			}
		}

		return false;
	}
}

