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
	private string[]			m_lines;
	private int 				m_line_index;
	private string 				m_result;
	private List<CDefine> 		m_defines		= new List<CDefine>();
	private CTranslationUnit 	m_context;
	private CToken 				m_lineToken		= new CToken();
	private string 				m_currentLine;
	private bool 				m_accept_input;	

	// =================================================================
	//	Splits a line into command and value.
	// =================================================================
	private List<string> SplitLine(string line)
	{
		List<string> result = new List<string>();

		// Find starting hash.
		string starting_int		   = '\0';
		int	   starting_int_offset = 0;
		for ( int j = 0; j < line.Length(); j++)
		{
			string start = line[j];
			if (start != '\t' &&
				start != '\n' &&
				start != '\r' &&
				start != ' ')
			{
				starting_int = start;
				starting_int_offset = j;
				break;
			}
		}

		// Is this a command?
		if (starting_int == '#')
		{
			string expr			= line.SubString(starting_int_offset);
			int	   space_index 	= expr.IndexOf(' ');
			string cmd			= expr;
			string value		= "";

			if (space_index == -1)
			{
				space_index = expr.IndexOf('\t');
			}

			if (space_index != -1)
			{
				cmd   = expr.SubString(0, space_index).Trim();
				value = expr.SubString(space_index + 1).Trim();
			}

			result.AddLast(cmd);
			result.AddLast(value);
			return result;
		}

		return result;
	}
		
	// =================================================================
	//	Replaces all define tags in a string.
	// =================================================================
	private string ReplaceDefineTags(string line)
	{
		// Replace defines on this line.
		if (line.IndexOf('{') != -1 &&
			line.IndexOf('}') != -1)
		{
			foreach (CDefine define in m_defines)
			{
				line = line.Replace("{" + define.Name + "}", define.Value);
			}
		}

		return line;
	}
		
	// =================================================================
	//	Returns true if we are at the end of lines.
	// =================================================================
	private bool EndOfLines()
	{
		return m_line_index >= m_lines.Length();
	}	
		
	// =================================================================
	//	Parses the given line of text.
	// =================================================================
	private void ParseLine(string line)
	{
		// Split line.
		List<string> split = SplitLine(line);

		// Is this a command?
		if (split.Count() > 0)
		{
			string cmd			= split.GetIndex(0);
			string value		= split.Count() > 1 ? split.GetIndex(1) : "";

			if (cmd == "#if" || cmd == "#ifdef")
			{
				ParseIf(value);
			}
			else if (cmd == "#define" || cmd == "#def")
			{
				ParseDefine(value);
			}
			else if (cmd == "#undefine" || cmd == "#undef")
			{
				ParseUndefine(value);
			}
			else if (cmd == "#error" || cmd == "#err")
			{
				ParseError(value);
			}
			else if (cmd == "#warning" || cmd == "#warn")
			{
				ParseWarning(value);
			}
			else if (cmd == "#info")
			{
				ParseInfo(value);
			}
			else
			{
				ParseError("Unknown preprocessor command '" + cmd + "'.");
			}
		}
		else
		{		
			Output(line + "\n");
		}
	}	
		
	// =================================================================
	//	Reads the next line of text in the input.
	// =================================================================
	private string ReadLine()
	{
		m_lineToken.Column		= 1;
		m_lineToken.Row			= m_line_index + 1;
		m_lineToken.Literal		= "";
		m_lineToken.Type		= TokenIdentifier.PreProcessor;
		m_lineToken.SourceFile	= m_context.GetFilePath();

		if (m_line_index >= m_lines.Length())
		{
			return "";
		}

		string line = m_lines[m_line_index++];

		line = ReplaceDefineTags(line);
		m_currentLine = line;

		return line;
	}
		
	// =================================================================
	//	Reads the next line of text in the input without advancing
	//  the read pointer.
	// =================================================================
	private string LookAheadLine()
	{
		if (m_line_index >= m_lines.Length())
		{
			return "";
		}

		string line = m_lines[m_line_index];

		line = ReplaceDefineTags(line);

		return line;
	}

	// =================================================================
	//	Reads the current line.
	// =================================================================
	private string CurrentLine()
	{
		return m_currentLine;
	}
		
	// =================================================================
	//	Appends the given text to the resulting preprocessed text.
	// =================================================================
	private void Output(string output)
	{
		m_result += output;
	}
		
	// =================================================================
	//	Parses an if block.
	// =================================================================
	private void ParseIfBlock()
	{
		while (!EndOfLines())
		{		
			List<string> split = SplitLine(LookAheadLine());
			if (split.Count() > 1)
			{
				string cmd = split.GetIndex(0);
				if (cmd == "#endif" || cmd == "#end")
				{
					ReadLine();
					Output("\n");
					break;
				}
				else if (cmd == "#else" || cmd == "#elif" || cmd == "#elseif")
				{
					ReadLine();
					Output("\n");
					break;
				}
				else
				{
					ParseLine(ReadLine());
				}
			}
			else
			{
				ParseLine(ReadLine());
			}
		}
	}
		
	// =================================================================
	//	Skips an if block.
	// =================================================================
	private void SkipIfBlock()
	{
		int depth = 1;

		while (!EndOfLines())
		{		
			List<string> split = SplitLine(LookAheadLine());
			if (split.Count() >= 1)
			{
				string cmd = split.GetIndex(0);
				if (cmd == "#if")
				{
					ReadLine();
					Output("\n");
					depth++;
				}
				else if (cmd == "#endif" || cmd == "#end")
				{
					ReadLine();
					Output("\n");
					depth--;

					if (depth <= 0)
					{
						break;
					}
				}
				else if (cmd == "#else" || cmd == "#elseif" || cmd == "#elif")
				{
					ReadLine();
					Output("\n");

					if (depth <= 1)
					{
						break;
					}
				}
				else
				{
					ReadLine();
					Output("\n");
				}
			}
			else
			{
				ReadLine();
				Output("\n");
			}
		}
	}
		
	// =================================================================
	//	Parses an if statement.
	// =================================================================
	private void ParseIf(string line)
	{
		Output("\n");

		// Accept if block.
		bool accept = Evaluate(m_context, m_lineToken, line, m_defines).GetBool();
		if (accept == true)
		{
			ParseIfBlock();
		}
		else
		{
			SkipIfBlock();
		}	

		// Keep parsing else blocks.
		while (true)
		{
			List<string> split = SplitLine(CurrentLine());
			string cmd = split.GetIndex(0);
			string val = split.Count() > 1 ? split.GetIndex(1) : "";

			if (cmd == "#endif" || cmd == "#end")
			{
				break;
			}
			else if (cmd == "#elif" || cmd == "#elseif")
			{	
				if (accept == true)
				{
					SkipIfBlock();
				}
				else
				{
					accept = Evaluate(m_context, m_lineToken, val, m_defines).GetBool();
					if (accept == true)
					{
						ParseIfBlock();
					}
					else
					{
						SkipIfBlock();
					}
				}	
			}
			else if (cmd == "#else")
			{	
				if (accept == true)
				{
					SkipIfBlock();
				}
				else
				{
					ParseIfBlock();
				}	
				break;
			}
		}
	}	
		
	// =================================================================
	//	Parses an define block.
	// =================================================================
	private void ParseDefine(string value)
	{
		Output("\n");

		value = value.Trim();
					
		int space_index = value.IndexOf(' ');
		if (space_index == -1)
		{
			space_index = value.IndexOf('\t');
		}

		string		 def_name  = value.Trim();
		string		 def_value = "1";
		DefineType   def_type  = DefineType.Bool;

		if (space_index != -1)
		{
			def_name  = value.SubString(0, space_index).Trim();
			def_value = value.SubString(space_index + 1).Trim();

			EvaluationResult result = Evaluate(m_context, m_lineToken, def_value, m_defines);
			switch (result.GetType())
			{
				case EvaluationDataType.Bool:	def_type = DefineType.Bool;
				case EvaluationDataType.Float:	def_type = DefineType.Float;
				case EvaluationDataType.Int:	def_type = DefineType.Int;
				case EvaluationDataType.String:	def_type = DefineType.String;
			}
			def_value = result.GetString();
		}

		CDefine define = new CDefine(def_type, def_name, def_value);
		m_defines.AddLast(define);
	}	
		
	// =================================================================
	//	Parses an undefine block.
	// =================================================================
	private void ParseUndefine(string line)
	{
		Output("\n");

		string name = line.Trim();
					
		foreach (CDefine def in m_defines)
		{
			if (def.Name == name)
			{
				m_defines.Remove(def);
				break;
			}
		}
	}	
		
	// =================================================================
	//	Parses an error block.
	// =================================================================
	private void ParseError(string line)
	{
		Output("\n");

		CToken token 		= new CToken();
		token.Column		= 1;
		token.Row			= m_line_index + 1;
		token.Literal		= "";
		token.Type			= TokenIdentifier.PreProcessor;
		token.SourceFile	= m_context.GetFilePath();
		
		m_context.FatalError(Evaluate(m_context, m_lineToken, line, m_defines).GetString(), m_lineToken);	
	}	
		
	// =================================================================
	//	Parses an warning block.
	// =================================================================
	private void ParseWarning(string line)
	{
		Output("\n");

		CToken token 		= new CToken();
		token.Column		= 1;
		token.Row			= m_line_index + 1;
		token.Literal		= "";
		token.Type			= TokenIdentifier.PreProcessor;
		token.SourceFile	= m_context.GetFilePath();
		
		m_context.Warning(Evaluate(m_context, m_lineToken, line, m_defines).GetString(), m_lineToken);		
	}	
		
	// =================================================================
	//	Parses an info block.
	// =================================================================
	private void ParseInfo(string line)
	{
		Output("\n");
		m_context.Info(Evaluate(m_context, m_lineToken, line, m_defines).GetString(), m_lineToken);		
	}
		
	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		m_lines			= context.GetSource().Split('\n');
		m_result		= "";
		m_defines		= context.GetDefines();
		m_line_index	= 0;
		m_context		= context;

		while (!EndOfLines())
		{
			ParseLine(ReadLine());
		}

		context.SetSource(m_result);

		return true;
	}	
		
	// =================================================================
	//	Evaluates a string expression.
	// =================================================================
	public EvaluationResult Evaluate(CTranslationUnit context, CToken token, string expr, List<CDefine> defines)
	{
		CTranslationUnit unit = new CTranslationUnit(context.GetCompiler(), "<eval>", defines);
		bool result = unit.Evaluate(expr);	
		if (result == true)
		{
			try
			{
				EvaluationResult res = unit.GetASTRoot().Evaluate(unit);
				return res;
			}
			catch (CompileException ex)
			{
				return new EvaluationResult(false);
			}
		}
		else
		{
			context.FatalError("Invalid preprocessor expression.", token);
		}
		return new EvaluationResult(result);
	}
}



