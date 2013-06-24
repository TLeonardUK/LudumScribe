// -----------------------------------------------------------------------------
// 	CPreprocessor.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for preprocessing a source file.
// =================================================================
public class CPreprocessor
{
	private List<string> m_lines;
	private int m_line_index;
	private string m_result;
	private List<CDefine> m_defines;
	private CTranslationUnit m_context;
	private CToken m_lineToken;
	private string m_currentLine;
	
	private bool m_accept_input;
	
	private List<string> SplitLine(string line)
	{
	}
	private string ReplaceDefineTags(string line)
	{
	}
	
	private bool EndOfLines()
	{
	}
	private void ParseLine(string line)
	{
	}
	private string ReadLine()
	{
	}
	private string LookAheadLine()
	{
	}
	private string CurrentLine()
	{
	}
	private void Output(string output)
	{
	}
	
	private void ParseIfBlock()
	{
	}
	private void SkipIfBlock()
	{
	}
	
	private void ParseIf(string line)
	{
	}
	private void ParseDefine(string line)
	{
	}
	private void ParseUndefine(string line)
	{
	}
	private void ParseError(string line)
	{
	}
	private void ParseWarning(string line)
	{
	}
	private void ParseInfo(string line)
	{
	}
	
	public bool Process(CTranslationUnit context)
	{
	}
	public EvaluationResult Evaluate(CTranslationUnit context, CToken token, string expr, List<CDefine> defines)
	{
	}
}



