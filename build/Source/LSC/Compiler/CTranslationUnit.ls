// -----------------------------------------------------------------------------
// 	CTranslationUnit.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// -----------------------------------------------------------------------------
//	Throw when we attempt to insert an already existing key into a collection.
// -----------------------------------------------------------------------------
public class CompileException : Exception
{
	string m_level;
	
	public CompileException(string level)
	{
		m_level = level;
	}
	
	public override string ToString()
	{
		return "A "+m_level+" occured and compilation had to be aborted.";
	}	
}

// =================================================================
//	This class stores non-transient data that needs to be passed
//  around during the compilation process.
// =================================================================
public class CTranslationUnit
{
	private CCompiler m_compiler;
	private string m_file_path;
	private string m_filename;
	
	private string m_source;
	
	private CLexer m_lexer						= new CLexer();
	private CParser m_parser					= new CParser();
	private CSemanter m_semanter				= new CSemanter();
	private CPreprocessor m_preprocessor		= new CPreprocessor();
	
	private List<CToken> m_token_list			= new List<CToken>();
	private List<string> m_using_files			= new List<string>();
	private List<string> m_native_files			= new List<string>();
	private List<string> m_copy_files			= new List<string>();
	private List<string> m_library_files		= new List<string>();
	private List<string> m_translated_files		= new List<string>();
	
	private int m_last_line_row;
	private int m_last_line_column;
	
	private List<CTranslationUnit> m_imported_units	= new List<CTranslationUnit>();
	private List<CDefine> m_defines					= new List<CDefine>();
	private List<CDataType> m_identifier_data_types	= new List<CDataType>();
	
	private CClassMemberASTNode m_entry_point;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CTranslationUnit(CCompiler compiler, string file_path, List<CDefine> defines)
	{
		m_compiler  	= compiler;
		m_file_path 	= file_path;
		m_filename  	= Path.StripDirectory(m_file_path);
		m_defines   	= defines;
		m_entry_point 	= null;
	}
		
	// =================================================================
	//	Get the compiler being used to compile this translation unit.
	// =================================================================
	public CCompiler GetCompiler()
	{
		return m_compiler;
	}
		
	// =================================================================
	//	Returns the semanter used by this translation unit.
	//	TODO: This really shouldn't be needed, its only here because
	//		  calls to .GetClass .FindDeclaration etc require it and
	//		  translators need to call them.
	// =================================================================
	public CSemanter GetSemanter()
	{
		return m_semanter;
	}
	
	// =================================================================
	//	Get the root node of the AST.
	// =================================================================
	public CASTNode GetASTRoot()
	{
		return m_parser.GetASTRoot();
	}
		
	// =================================================================
	//	Get source-code for this translation unit.
	// =================================================================
	public string GetSource()
	{
		return m_source;
	}
		
	// =================================================================
	//	Set source-code for this translation unit.
	// =================================================================
	public void SetSource(string source)
	{
		m_source = source;
	}
	// =================================================================
	//	Get file-path for this translation unit.
	// =================================================================
	public string GetFilePath()
	{
		return m_file_path;
	}
		
	// =================================================================
	//	Gets entry point member.
	// =================================================================
	public CClassMemberASTNode GetEntryPoint()
	{
		return m_entry_point;
	}	

	// =================================================================
	//	Get file-path for this translation unit.
	// =================================================================
	public List<CToken> GetTokenList()
	{
		return m_token_list;
	}

	// =================================================================
	//	Set file-path for this translation unit.
	// =================================================================
	public void SetTokenList(List<CToken> value)
	{
		m_token_list = value;
	}	
	
	// =================================================================
	//	Get a list of files that are imported using the using decl.
	// =================================================================
	public List<string> GetUsingFileList()
	{
		return m_using_files;
	}
		
	// =================================================================
	//	Get a list of native files that are imported.
	// =================================================================
	public List<string> GetNativeFileList()
	{
		return m_native_files;
	}
		
	// =================================================================
	//	Get a list of native files that need to be copied to output.
	// =================================================================
	public List<string> GetCopyFileList()
	{
		return m_copy_files;
	}
		
	// =================================================================
	//	Get a list of native files that need to be copied to output.
	// =================================================================
	public List<string> GetLibraryFileList()
	{
		return m_library_files;
	}
		
	// =================================================================
	//	Get a list of files that have been translated and need building.
	// =================================================================
	public List<string> GetTranslatedFiles()
	{
		return m_translated_files;
	}
		
	// =================================================================
	//	Gets a list of defines.
	// =================================================================
	public List<CDefine> GetDefines()
	{
		return m_defines;
	}
		
	// =================================================================
	//	Returns the last row of the file.
	// =================================================================
	public int GetLastLineRow()
	{
		CToken token = m_token_list.GetIndex(m_token_list.Count() - 1);
		return token.Row;
	}
		
	// =================================================================
	//	Returns the last column on the last line of the file.
	// =================================================================
	public int GetLastLineColumn()
	{
		CToken token = m_token_list.GetIndex(m_token_list.Count() - 1);
		return token.Column + token.Literal.Length();
	}
		
	// =================================================================
	//	Adds a new using file, returns true on success, false on
	//  duplicate using file.
	// =================================================================
	public bool AddUsingFile(string file, bool isNative, bool isLibrary, bool isCopy)
	{
		string cleaned = Path.Normalize(file);

		if (isLibrary == true)
		{
			foreach (string clean_iter in m_library_files)
			{
				if (cleaned.ToLower() == clean_iter.ToLower())
				{
					return false;
				}
			}
			m_library_files.AddLast(cleaned);
		}
		else if (isCopy == true)
		{
			foreach (string clean_iter in m_copy_files)
			{
				if (cleaned.ToLower() == clean_iter.ToLower())
				{
					return false;
				}
			}
			m_copy_files.AddLast(cleaned);
		}
		else if (isNative == true)
		{	
			foreach (string clean_iter in m_native_files)
			{
				if (cleaned.ToLower() == clean_iter.ToLower())
				{
					return false;
				}
			}
			m_native_files.AddLast(cleaned);
		}
		else
		{
			foreach (string clean_iter in m_using_files)
			{
				if (cleaned.ToLower() == clean_iter.ToLower())
				{
					return false;
				}
			}
			m_using_files.AddLast(cleaned);
		}

		return true;
	}
		
	// =================================================================
	//	Emits a fatal error and aborts compilation of this translation
	//  unit.
	// =================================================================
	public void FatalError(string msg, string source="internal", int row=1, int column=1)
	{
		string line = "";
		
		if (source == m_file_path)
		{
			line = m_source.GetLine(row - 1).Replace("\t", "    ");
		}
		else
		{
			line = "(could not retrieve source code)";
			foreach (CTranslationUnit unit in m_imported_units)
			{
				if (unit.m_file_path == source)
				{
					line = unit.m_source.GetLine(row - 1).Replace("\t", "    ");;
					break;
				}
			}
		}	
		
		string arrow_line = "^".PadLeft(column - 1);

		Console.Write("\n");
		Console.Write(source + "(" + row + ":" + column + "): Fatal: " + msg + "\n");
		Console.Write(line + "\n");
		Console.Write(arrow_line + "\n");

		throw new CompileException("Fatal Error");
	}
	public void FatalError(string msg, CToken token)
	{
		FatalError(msg, token.SourceFile, token.Row, token.Column);
	}
	
	// =================================================================
	//	Emits an error and continues.
	// =================================================================
	public void Error(string msg, string source="internal", int row=1, int column=1)
	{
		string line = "";
		
		if (source == m_file_path)
		{
			line = m_source.GetLine(row - 1).Replace("\t", "    ");
		}
		else
		{
			line = "(could not retrieve source code)";
			foreach (CTranslationUnit unit in m_imported_units)
			{
				if (unit.m_file_path == source)
				{
					line = unit.m_source.GetLine(row - 1).Replace("\t", "    ");;
					break;
				}
			}
		}	
		
		string arrow_line = "^".PadLeft(column - 1);
		
		Console.Write("\n");
		Console.Write(source + "(" + row + ":" + column + "): Error: " + msg + "\n");
		Console.Write(line + "\n");
		Console.Write(arrow_line + "\n");
	}
	public void Error(string msg, CToken token)
	{
		Error(msg, token.SourceFile, token.Row, token.Column);
	}
		
	// =================================================================
	//	Emits a warning and continues.
	// =================================================================
	public void Warning(string msg, string source="internal", int row=1, int column=1)
	{
		string line = "";
		
		if (source == m_file_path)
		{
			line = m_source.GetLine(row - 1).Replace("\t", "    ");
		}
		else
		{
			line = "(could not retrieve source code)";
			foreach (CTranslationUnit unit in m_imported_units)
			{
				if (unit.m_file_path == source)
				{
					line = unit.m_source.GetLine(row - 1).Replace("\t", "    ");;
					break;
				}
			}
		}	
		
		string arrow_line = "^".PadLeft(column - 1);
		
		Console.Write("\n");
		Console.Write(source + "(" + row + ":" + column + "): Warning: " + msg + "\n");
		Console.Write(line + "\n");
		Console.Write(arrow_line + "\n");
	}
	public void Warning(string msg, CToken token)
	{
		Warning(msg, token.SourceFile, token.Row, token.Column);
	}
		
	// =================================================================
	//	Emits info message and continues.
	// =================================================================
	public void Info(string msg, string source="internal", int row=1, int column=1)
	{
		string line = "";
		
		if (source == m_file_path)
		{
			line = m_source.GetLine(row - 1).Replace("\t", "    ");
		}
		else
		{
			line = "(could not retrieve source code)";
			foreach (CTranslationUnit unit in m_imported_units)
			{
				if (unit.m_file_path == source)
				{
					line = unit.m_source.GetLine(row - 1).Replace("\t", "    ");;
					break;
				}
			}
		}	
		
		string arrow_line = "^".PadLeft(column - 1);
		
		Console.Write(source + "(" + row + ":" + column + "): Info: " + msg + "\n");
	}
	public void Info(string msg, CToken token)
	{
		Info(msg, token.SourceFile, token.Row, token.Column);
	}
		
	// =================================================================
	//	Attempts to compile this translation unit. 
	//	Returns true on success.
	// =================================================================
	public bool Evaluate(string expr)
	{
		try
		{
			m_file_path = "<eval>";
			m_source = expr;
				
			// Tokenize.
			if (!m_lexer.Process(this))
			{
				return false;
			}

			// Replace all identifier tokens with defines.
			foreach (CToken token in m_token_list)
			{
				if (token.Type == TokenIdentifier.IDENTIFIER)
				{
					foreach (CDefine define in m_defines)
					{
						if (define.Name == token.Literal)
						{
							switch (define.Type)
							{
								case DefineType.Bool:
								{
									if (define.Value.ToLower() == "false" ||
										define.Value == "0" ||
										define.Value == "")
									{									
										token.Type = TokenIdentifier.KEYWORD_FALSE;
										token.Literal = "0";
									}
									else
									{
										token.Type = TokenIdentifier.KEYWORD_TRUE;
										token.Literal = "1";
									}
									break;
								}
								case DefineType.Int:
								{
									token.Type = TokenIdentifier.INT_LITERAL;
									token.Literal = define.Value;
									break;
								}
								case DefineType.Float:
								{
									token.Type = TokenIdentifier.FLOAT_LITERAL;
									token.Literal = define.Value;
									break;
								}
								case DefineType.String:
								{
									token.Type = TokenIdentifier.STRING_LITERAL;
									token.Literal = define.Value;
									break;
								}
							}
						}
					}
				}
			}

			// Parse.
			if (!m_parser.Evaluate(this))
			{
				return false;
			}

			// Semant.
			if (!m_semanter.Process(this))
			{
				return false;
			}

			return true;
		}
		catch (CompileException ex)
		{
			return false;
		}
	}
		
	// =================================================================
	//	Attempts to compile this translation unit. 
	//	Returns true on success.
	// =================================================================
	public bool Compile(bool importedPackage = false, CTranslationUnit importingPackage = null)
	{
		try
		{
			int start_tick_count = OS.GetTicks();

			if (importedPackage == false)
			{
				Info("Generating Package: " + m_filename);
			}

			// Read source from disk.
			try
			{
				m_source == File.LoadText(m_file_path);
			}
			catch (OperationFailedException ex)
			{
				FatalError("Could not read file: " + m_file_path);
			}
				
			// Preprocess the source file.
			m_preprocessor.Process(this);

			// Convert source file into a stream of tokens.
			m_lexer.Process(this);
			
			// Convert the token stream info an AST representation.
			m_parser.Process(this);

			// Import support files?
			if (importedPackage == false)
			{
				string	 support_dir = m_compiler.GetPackageDirectory() + "/Compiler/Support";
				string[] files		 = Directory.List(support_dir, DirectoryListType.Files, false);

				foreach (string file in files)
				{
					AddUsingFile(support_dir + "/" + file, false, false, false);
				}
			}

			// Import all packages we are using and insert them into the AST tree.
			if (m_using_files.Count() > 0 || m_native_files.Count() > 0)
			{
				// If we are an imported package ourselves, then pass the import up to the main package.
				if (importedPackage == true)
				{
					foreach (string file in m_using_files)
					{
						importingPackage.AddUsingFile(file, false, false, false);
					}
					foreach (string file in m_native_files)
					{
						importingPackage.AddUsingFile(file, true, false, false);
					}
					foreach (string file in m_library_files)
					{
						importingPackage.AddUsingFile(file, false, true, false);
					}
					foreach (string file in m_copy_files)
					{
						importingPackage.AddUsingFile(file, false, false, true);
					}
				}

				// If we are the main package, compile and import all packages.
				else
				{			
					List<string> imported_files;
					while (imported_files.Count() != m_using_files.Count())
					{			
						foreach (string iter in m_using_files)
						{
							bool imported = false;
							foreach (string iter2 in imported_files)
							{
								if (iter == iter2)
								{
									imported = true;
									break;
								}
							}

							if (imported == false)
							{							
								CTranslationUnit unit = new CTranslationUnit(m_compiler, iter, m_defines);
								unit.Compile(true, this);

								CASTNode unitRoot = unit.GetASTRoot();
								CASTNode realRoot = GetASTRoot();
								
								foreach (CASTNode childIter in unitRoot.Children)
								{
									realRoot.AddChild(childIter);
								}

								m_imported_units.AddLast(unit);
								imported_files.AddLast(iter);

								break;
							}
						}
						
					}
				}
			}
			
			// If we are importing this package then everything that follows
			// is done by the importer.
			if (importedPackage == true)
			{
				Info("Imported " + m_filename + " in " + (OS.GetTicks() - start_tick_count) + "ms");
				return true;
			}
			
			// Check semantics are correct for AST.
			m_semanter.Process(this);
			
			// Check we have an entry point.
			if (GetEntryPoint() == null)
			{
				FatalError("No entry point was found in program. Entry point with the following signature is expected: int Main(string[])");
			}

			// Translate into target language.
			int tick_count = OS.GetTicks();
			m_compiler.GetTranslator().Process(this);		
			m_translated_files = m_compiler.GetTranslator().GetTranslatedFiles();
			Info("Translated "+m_filename+" using '"+m_compiler.GetProjectConfig().GetString("TRANSLATOR_NAME")+"' translator in "+(OS.GetTicks() - tick_count)+" ms.");

			// Invoke native compiler.
			tick_count = OS.GetTicks();
			m_compiler.GetBuilder().Process(this);
			Info("Compiled "+m_filename+" using '"+m_compiler.GetProjectConfig().GetString("BUILDER_NAME")+"' builder in "+(OS.GetTicks() - tick_count)+" ms.");

			// Work out elapsed time.
			Info("Generated " + m_filename + " in " + (OS.GetTicks() - start_tick_count) + "ms");

			return true;
		}
		catch (CompileException ex)
		{
			Error("Failed to compile file: " + m_filename);
			return false;
		}
	}
		
	// =================================================================
	//	Attempts to preprocess the translation unit.
	//	Returns true on success.
	// =================================================================
	public bool PreProcess()
	{
		try
		{
			// Read source from disk.
			try
			{
				m_source == File.LoadText(m_file_path);
			}
			catch (OperationFailedException ex)
			{
				FatalError("Could not read file: " + m_file_path);
			}
				
			// Preprocess the source file.
			m_preprocessor.Process(this);

			return true;
		}
		catch (CompileException ex)
		{
			Error("Failed to process file: " + m_filename);
			return false;
		}
	}
	
}

