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
	public List<string> Options;
	
	public string Value;
	public bool Exists;
}

// =================================================================
//	Class deals with parsing and storing command line arguments.
// =================================================================
public class CCommandLineParser
{
	private List<CCommandLineArgument> m_arguments;
	private string m_exeName;
	
	public void AddCommand(string name, string shortName, int flags, string defaultValue, string description, string options = "")
	{
	}
	public void PrintSyntax()
	{
	}
	public bool Parse(string[] argv)
	{
	}
	
	public string GetString(string name)
	{
	}
	public bool GetBool(string name)
	{
	}
	public bool ArgumentExists(string name)
	{
	}
	
}

