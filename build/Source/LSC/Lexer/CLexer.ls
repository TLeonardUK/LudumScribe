// -----------------------------------------------------------------------------
// 	CLexer.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Class deals with process input and compiling the correct
//	files as requested.
// =================================================================
public class CLexer
{
	private string 					m_source;
	private string 					m_file_path;
	private int 					m_token_start;
	private CToken 					m_token;
	private int 					m_token_column;
	private int 					m_token_row;
	private CTranslationUnit		m_context;
	
	private TokenMnemonicTableEntry	m_mnemonic_table_entry;

	// =================================================================
	//	Trys to find token mnemonic entry based on a string.
	// =================================================================
	private bool FindTokenMnemonicEntry(string name)
	{
		foreach (TokenMnemonicTableEntry entry in CToken.TOKEN_MNEMONIC_TABLE)
		{
			if (entry.Literal == name)
			{
				m_mnemonic_table_entry = entry;
				return true;
			}
		}
		
		m_mnemonic_table_entry = null;
		return false;
	}
		
	// =================================================================
	//	Reads the next token at the given position.
	// =================================================================
	private bool LexToken()
	{
		string next_char  = m_source[m_token_start];
		string la_char    = (m_token_start + 1 < m_source.Length()) ? m_source[m_token_start + 1] : "";
		string la_la_char = (m_token_start + 2 < m_source.Length()) ? m_source[m_token_start + 2] : "";
		
		// ====================================================================================
		// Whitespace.
		// ====================================================================================
		if (next_char == " " ||
			next_char == "\t" || 
			next_char == "\n" ||
			next_char == "\r")
		{	
			m_token_start++;	
			m_token_column++;

			if (next_char == '\n')
			{
				m_token_row++;
				m_token_column = 1;
			}	

			if (next_char == '\t')
			{
				m_token_column += 3;
			}

			m_token = null;
			return true;
		}
	
		// ====================================================================================
		// Line Comment Start.
		// ====================================================================================
		else if (next_char == '/' && la_char == '/')			
		{
			m_token_start += 2;			
			m_token_column += 2;

			// Keep skipping till we get to the end of the file, or the next line.
			while (m_token_start < m_source.Length())
			{
				next_char = m_source[m_token_start];
				if (next_char == '\n')
				{
					break;
				}			
				
				m_token_column++;
				m_token_start++;
			}

			m_token = null;
			return true;
		}
		
		// ====================================================================================
		// Block Comment Start.
		// ====================================================================================
		else if (next_char == '/' && la_char == '*')				// /* */
		{
			m_token_column += 2;
			m_token_start += 2;
			
			int block_depth = 1;

			// Keep skipping till we get to the end of the file, or closing block.
			while (m_token_start < m_source.Length())
			{
				next_char = m_source[m_token_start];
				la_char   = m_token_start + 1 < m_source.Length() ? m_source[m_token_start + 1] : '';
				
				if (next_char == '/' &&
					la_char   == '*')
				{
					block_depth++;
					m_token_column += 2;
					m_token_start += 2;
					continue;
				}

				else if (next_char == '*' &&
						 la_char   == '/')
				{
					block_depth--;
					m_token_column += 2;
					m_token_start += 2;

					if (block_depth <= 0)
					{
						break;
					}
				}
				else if (next_char == '\n')
				{
					m_token_row++;
					m_token_column = 1;
					m_token_start++;
				}	
				else if (next_char == '\t')
				{
					m_token_column += 3;
					m_token_start++;
				}
				else
				{
					m_token_column++;
					m_token_start++;
				}
			}

			m_token = null;
			return true;
		}
		
		// ====================================================================================
		// String start.
		// ====================================================================================
		else if (next_char == '"' ||								// "herp derp"
				 next_char == '\'' ||								// 'herp derp'
				 (next_char == '@' && la_char == '"') ||			// @"herp derp"
				 (next_char == '@' && la_char == '\''))				// @'herp derp'
		{
			bool		escapable	= true;
			string		start_char	= next_char;
			string 		result		= "";

			if (next_char == '@')
			{			
				m_token_column++;	
				m_token_start++;

				escapable = false;
				start_char = la_char;
			}
			
			m_token_column++;	
			m_token_start++;
			
			// Keep skipping till we get to the end of the file, or closing block.
			while (m_token_start < m_source.Length())
			{
				next_char = m_source[m_token_start];
				la_char   = m_token_start + 1 < m_source.Length() ? m_source[m_token_start + 1] : '\0';
			
				if (next_char == start_char)
				{		
					m_token_column++;
					m_token_start++;			
					break;
				}
				else if (next_char == '\\' && escapable == true)
				{
					m_token_column += 2;
					m_token_start += 2;

					// All our delicious escape strings!
					switch (la_char)
					{
						case '\\': { result += "\\"; break; }
						case '\'': { result += "'"; break; }
						case '"':  { result += "\""; break; }
						case '0':  { result += "\0"; break; }
						case 'a':  { result += "\a"; break; }
						case 'b':  { result += "\b"; break; }
						case 'f':  { result += "\f"; break; }
						case 'n':  { result += "\n"; break; }
						case 'r':  { result += "\r"; break; }
						case 't':  { result += "\t"; break; }
						case 'v':  { result += "\v"; break; }
						case '?':  { result += "?"; break; }

						// Hex escape strings. Format \Xnn
						case 'x', 'X': 
							{
								if (m_token_start + 2 >= m_source.Length())
								{
									m_context.FatalError("Invalid escape sequence, hexidecimal characters must be in the format \\Xnn.", m_file_path, m_token_row, m_token_column);
									return false;
								}
								else
								{
									next_char = m_source[m_token_start];
									la_char   = m_source[m_token_start + 1];

									m_token_column += 2;
									m_token_start += 2;

									if (next_char.IsHex() &&
										la_char.IsHex())
									{
										result += string.FromChar((next_char + la_char).HexToInt());
									}
									else
									{
										m_context.FatalError("Invalid hexidecimal escape sequence, hexidecimal characters must be 0-9 or A-F.", m_file_path, m_token_row, m_token_column);
										return false;
									}
								}
								break;
							}

						// ???
						default:
							{
								m_context.FatalError("Unexpected escape character in string '" + la_char + "'.", m_file_path, m_token_row, m_token_column);
								return false;
							}
					}
				}
				else
				{
					result += next_char;
		
					m_token_column++;
					m_token_start++;			
				}
			}
			
			m_token				= new CToken();
			m_token.Type		= TokenIdentifier.STRING_LITERAL;
			m_token.SourceFile	= m_file_path;
			m_token.Row			= m_token_row;
			m_token.Column		= m_token_column;
			m_token.Literal		= result;

			return true;
		}
	
		// ====================================================================================
		// Numeric value.
		// ====================================================================================
		else if (next_char.IsNumeric() ||											// 0.123
				 (next_char == '.' && (la_char.IsNumeric() || (la_char == 'e' && (la_la_char == '-' || la_la_char == '+')))))	// .1231 .e-12
		{
			TokenIdentifier numberType		= TokenIdentifier.INT_LITERAL;
			string			result			= "";
			bool			isHex			= false;
			bool			isFloat			= false;
			bool			foundRadix		= false;
			bool			foundExp		= false;
			int				expPosition		= 0;
			int				numberCount		= 0;
			int				numberOffset    = 0;
			string			startChar		= m_source[m_token_start];
			int				startOffset		= m_token_start;

			while (m_token_start < m_source.Length())
			{			
				next_char = m_source[m_token_start];
				
				// Hex prefix 0X or 0x
				if ((next_char == 'x' || next_char == 'X') && numberOffset == 1 && startChar == '0')
				{
					isHex	 = true;		
				}

				// Floating point radix.
				else if (next_char == '.' && isHex == false && foundRadix == false && foundExp == false)
				{
					isFloat		 = true;			
					foundRadix	 = true;
					numberType	 = TokenIdentifier.FLOAT_LITERAL;
				}	

				// Exponent
				else if (next_char == 'e' && numberCount > 0 && isHex == false && foundExp == false)
				{
					isFloat		 = true;			
					foundExp 	 = true;
					expPosition  = numberOffset;
					numberType	 = TokenIdentifier.FLOAT_LITERAL;
				}	

				// Exponent sign +/-
				else if ((next_char == '-' || next_char == '+') && (foundExp == true && expPosition == numberOffset - 1))
				{
					result += next_char;
				}		

				// Hex digit.
				else if (((next_char >= 'A' && next_char <= 'F') || (next_char >= 'a' && next_char <= 'f')) && isHex == true)
				{
					numberCount++;
				}

				// Standard digit.
				else if (next_char >= '0' && next_char <= '9')
				{
					numberCount++;
				}
				
				// Character! Baaaad
				else if ((next_char >= 'A' && next_char <= 'Z') || (next_char >= 'a' && next_char <= 'z'))
				{
					m_context.FatalError("Identifiers cannot start with numbers.", m_file_path, m_token_row, m_token_column);
					return false;
				}

				// lolwut
				else
				{
					break;
				}

				numberOffset++;
				m_token_start++;
			}

			m_token				= new CToken();
			m_token.Type			= numberType;
			m_token.SourceFile	= m_file_path;
			m_token.Row			= m_token_row;
			m_token.Column		= m_token_column;
			m_token.Literal		= m_source.SubString(startOffset, m_token_start - startOffset);

			m_token_column 		+= (m_token_start - startOffset);

			return true;
		}
		
		// ====================================================================================
		// Identifier/Keyword
		// ====================================================================================
		else if ((next_char >= 'A' && next_char <= 'Z') ||
				 (next_char >= 'a' && next_char <= 'z') ||
				 next_char == '_' ||
				 next_char == '@') 	
		{
			bool notKeyword = false;

			// Ignore the @, just stops us acting as a keyword.
			if (next_char == '@')
			{
				notKeyword = true;
				m_token_column++;	
				m_token_start++;
			}

			int startOffset = m_token_start;

			while (m_token_start < m_source.Length())
			{			
				next_char = m_source[m_token_start];
				
				// A-Z, a-z, 0-9
				if ((next_char >= 'A' && next_char <= 'Z') ||
					(next_char >= 'a' && next_char <= 'z') ||
					(next_char >= '0' && next_char <= '9') ||
					next_char == '_')
				{
					// Ok!
				}

				// lolwut
				else
				{
					break;
				}

				m_token_start++;
				m_token_column++;
			}
			
			string result = m_source.SubString(startOffset, m_token_start - startOffset);
			
			m_token = new CToken();
			if (notKeyword == false && FindTokenMnemonicEntry(result))
			{
				m_token.Type		= m_mnemonic_table_entry.TokenType;
			}
			else
			{
				m_token.Type		= TokenIdentifier.IDENTIFIER;
			}
			m_token.SourceFile	= m_file_path;
			m_token.Row			= m_token_row;
			m_token.Column		= m_token_column;
			m_token.Literal		= result;

			return true;
		}
		
		// ====================================================================================
		// Operator
		// ====================================================================================
		else
		{
			string					result = "";
			TokenMnemonicTableEntry mnemonic;
			int						startOffset = m_token_start;

			while (m_token_start < m_source.Length())
			{
				next_char = m_source[m_token_start];

				if (!FindTokenMnemonicEntry(result + next_char))
				{
					break;
				}
				else
				{
					mnemonic = m_mnemonic_table_entry;
				}

				result += next_char;

				m_token_start++;			
				m_token_column++;
			}
			
			if (result != "")
			{
				m_token				= new CToken();
				m_token.Type		= mnemonic.TokenType;
				m_token.SourceFile	= m_file_path;
				m_token.Row			= m_token_row;
				m_token.Column		= m_token_column;
				m_token.Literal		= result;
				return true;
			}
		}
			
		m_context.FatalError("Unexpected character in input '" + next_char + "'.", m_file_path, m_token_row, m_token_column);
		return false;
	}
		
	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		m_token_start 	= 0;
		m_token 		= null;
		m_token_column 	= 1;
		m_token_row 	= 1;
		m_source 		= context.GetSource();
		m_file_path 	= context.GetFilePath();
		m_context		= context;
		
		List<CToken> token_list = new List<CToken>();
		
		while (m_token_start < m_source.Length())
		{
			if (LexToken())
			{
				if (m_token != null)
				{
					token_list.AddLast(m_token);
				}
			}
			else
			{
				return false;
			}
		}
		
		context.SetTokenList(token_list);
		return true;
	}

}



