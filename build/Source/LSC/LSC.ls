// -----------------------------------------------------------------------------
// 	LSC.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This file imports and sets up everything ready to compile the users choice
//	of ludumscribe file!
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

using Helper.*;
using Builder.*;
using Builder.MSBuild.*;
using Compiler.*;
using Lexer.*;
using Parser.*;
using Parser.Nodes.*;
using Parser.Nodes.Expressions.*;
using Parser.Nodes.Expressions.Assignment.*;
using Parser.Nodes.Expressions.Branching.*;
using Parser.Nodes.Expressions.Math.*;
using Parser.Nodes.Expressions.Polymorphism.*;
using Parser.Nodes.Expressions.Types.*;
using Parser.Nodes.Statements.*;
using Parser.Nodes.TopLevel.*;
using Parser.Types.*;
using Parser.Types.Helper.*;
using Preprocessor.*;
using Semanter.*;
using Translator.*;
using Translator.CPP.*;

public class LudumScribe
{
	public static int Main(string[] args)
	{
		CCompiler compiler = new CCompiler();
		compiler.Process(args);		
	}
}
