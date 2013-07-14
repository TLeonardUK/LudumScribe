/* *****************************************************************

		CTranslationUnit.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CTranslationUnit.h"
#include "CCompiler.h"

#include "CStringHelper.h"
#include "CPathHelper.h"

#include "CBuilder.h"

#include "CASTNode.h"

#include "CIdentifierDataType.h"

#include "CTranslator.h"

#include <stdexcept>
#include <windows.h>

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CTranslationUnit::CTranslationUnit(CCompiler* compiler, std::string file_path, std::vector<CDefine> defines)
{
	m_compiler  = compiler;
	m_file_path = file_path;
	m_filename  = CPathHelper::StripDirectory(m_file_path);
	m_defines   = defines;
	m_entry_point = NULL;
}

// =================================================================
//	Destructs an instance of this class.
// =================================================================
CTranslationUnit::~CTranslationUnit()
{
	for (auto iter = m_imported_units.begin(); iter != m_imported_units.end(); iter++)
	{
		delete *iter;
	}
	m_imported_units.clear();

	for (auto iter = m_identifier_data_types.begin(); iter != m_identifier_data_types.end(); iter++)
	{
		delete *iter;
	}
	m_identifier_data_types.clear();
}

// =================================================================
//	Get the compiler being used to compile this translation unit.
// =================================================================
CCompiler* CTranslationUnit::GetCompiler() 
{ 
	return m_compiler;
}

// =================================================================
//	Returns the semanter used by this translation unit.
//	TODO: This really shouldn't be needed, its only here because
//		  calls to ->GetClass ->FindDeclaration etc require it and
//		  translators need to call them.
// =================================================================
CSemanter* CTranslationUnit::GetSemanter()
{
	return &m_semanter;
}

// =================================================================
//	Get the root node of the AST.
// =================================================================
CASTNode* CTranslationUnit::GetASTRoot() 
{ 
	return m_parser.GetASTRoot();
}

// =================================================================
//	Get source-code for this translation unit.
// =================================================================
std::string& CTranslationUnit::GetSource() 
{ 
	return m_source;
}

// =================================================================
//	Get file-path for this translation unit.
// =================================================================
std::string& CTranslationUnit::GetFilePath() 
{ 
	return m_file_path;
}

// =================================================================
//	Gets entry point member.
// =================================================================
CClassMemberASTNode*& CTranslationUnit::GetEntryPoint()
{
	return m_entry_point;
}

// =================================================================
//	Get file-path for this translation unit.
// =================================================================
std::vector<CToken>& CTranslationUnit::GetTokenList() 
{ 
	return m_token_list;
}

// =================================================================
//	Get a list of files that are imported using the using decl.
// =================================================================
std::vector<std::string>& CTranslationUnit::GetUsingFileList() 
{ 
	return m_using_files;
}

// =================================================================
//	Get a list of native files that are imported.
// =================================================================
std::vector<std::string>& CTranslationUnit::GetNativeFileList() 
{ 
	return m_native_files;
}

// =================================================================
//	Get a list of native files that need to be copied to output.
// =================================================================
std::vector<std::string>& CTranslationUnit::GetCopyFileList() 
{ 
	return m_copy_files;
}

// =================================================================
//	Get a list of native files that need to be copied to output.
// =================================================================
std::vector<std::string>& CTranslationUnit::GetLibraryFileList() 
{ 
	return m_library_files;
}

// =================================================================
//	Get a list of files that have been translated and need building.
// =================================================================
std::vector<std::string>& CTranslationUnit::GetTranslatedFiles() 
{ 
	return m_translated_files;
}

// =================================================================
//	Gets a list of defines.
// =================================================================
std::vector<CDefine>& CTranslationUnit::GetDefines()
{
	return m_defines;
}

// =================================================================
//	Returns the last row of the file.
// =================================================================
int CTranslationUnit::GetLastLineRow()
{
	CToken& token = m_token_list.at(m_token_list.size() - 1);
	return token.Row;
}

// =================================================================
//	Returns the last column on the last line of the file.
// =================================================================
int CTranslationUnit::GetLastLineColumn()
{
	CToken& token = m_token_list.at(m_token_list.size() - 1);
	return token.Column + token.Literal.size();
}

// =================================================================
//	Adds a new using file, returns true on success, false on
//  duplicate using file.
// =================================================================
bool CTranslationUnit::AddUsingFile(std::string file, bool isNative, bool isLibrary, bool isCopy)
{
	std::string cleaned = CPathHelper::CleanPath(file);

	if (isLibrary == true)
	{
		for (auto iter = m_library_files.begin(); iter != m_library_files.end(); iter++)
		{
			std::string clean_iter = *iter;
			if (CStringHelper::ToLower(cleaned) == CStringHelper::ToLower(clean_iter))
			{
				return false;
			}
		}
		m_library_files.push_back(cleaned);
	}
	else if (isCopy == true)
	{
		for (auto iter = m_copy_files.begin(); iter != m_copy_files.end(); iter++)
		{
			std::string clean_iter = *iter;
			if (CStringHelper::ToLower(cleaned) == CStringHelper::ToLower(clean_iter))
			{
				return false;
			}
		}
		m_copy_files.push_back(cleaned);
	}
	else if (isNative == true)
 	{
		for (auto iter = m_native_files.begin(); iter != m_native_files.end(); iter++)
		{
			std::string clean_iter = *iter;
			if (CStringHelper::ToLower(cleaned) == CStringHelper::ToLower(clean_iter))
			{
				return false;
			}
		}
		m_native_files.push_back(cleaned);
	}
	else
	{
		for (auto iter = m_using_files.begin(); iter != m_using_files.end(); iter++)
		{
			std::string clean_iter = *iter;
			if (CStringHelper::ToLower(cleaned) == CStringHelper::ToLower(clean_iter))
			{
				return false;
			}
		}
		m_using_files.push_back(cleaned);
	}

	return true;
}

// =================================================================
//	Emits a fatal error and aborts compilation of this translation
//  unit.
// =================================================================
void CTranslationUnit::FatalError(std::string msg, std::string source, int row, int column)
{
	std::string line	   = "";
	
	if (source == m_file_path)
	{
		line = CStringHelper::Replace(CStringHelper::GetLineInString(m_source, row - 1), "\t", "    ");
	}
	else
	{
		line = "(could not retrieve source code)";
		for (auto iter = m_imported_units.begin(); iter != m_imported_units.end(); iter++)
		{
			CTranslationUnit* unit = *iter;
			if (unit->m_file_path == source)
			{
				line = CStringHelper::Replace(CStringHelper::GetLineInString(unit->m_source, row - 1), "\t", "    ");;
				break;
			}
		}
	}	
	
	std::string arrow_line = CStringHelper::PadLeft("^", column - 1);

	printf("\n");
	printf("%s(%i:%i): Fatal: %s\n", source.c_str(), row, column, msg.c_str());
	printf("%s\n", line.c_str());
	printf("%s\n", arrow_line.c_str());

  	throw std::runtime_error("Fatal Error");
}

// =================================================================
//	Emits a fatal error and aborts compilation of this translation
//  unit.
// =================================================================
void CTranslationUnit::FatalError(std::string msg, CToken& token)
{
	FatalError(msg, token.SourceFile, token.Row, token.Column);
}

// =================================================================
//	Emits an error and continues.
// =================================================================
void CTranslationUnit::Error(std::string msg, std::string source, int row, int column)
{
	std::string line	   = CStringHelper::GetLineInString(m_source, row - 1);
	std::string arrow_line = CStringHelper::PadLeft("^", column - 1);
	
	printf("\n");
	printf("%s(%i:%i): Error: %s\n", source.c_str(), row, column, msg.c_str());
	printf("%s\n", line.c_str());
	printf("%s\n", arrow_line.c_str());
}

// =================================================================
//	Emits an error and continues.
// =================================================================
void CTranslationUnit::Error(std::string msg, CToken& token)
{
	Error(msg, token.SourceFile, token.Row, token.Column);
}

// =================================================================
//	Emits a warning and continues.
// =================================================================
void CTranslationUnit::Warning(std::string msg, std::string source, int row, int column)
{
	std::string line	   = CStringHelper::GetLineInString(m_source, row - 1);
	std::string arrow_line = CStringHelper::PadLeft("^", column - 1);
	
	printf("\n");
	printf("%s(%i:%i): Warning: %s\n", source.c_str(), row, column, msg.c_str());
	printf("%s\n", line.c_str());
	printf("%s\n", arrow_line.c_str());
}

// =================================================================
//	Emits a warning message and continues.
// =================================================================
void CTranslationUnit::Warning(std::string msg, CToken& token)
{
	Warning(msg, token.SourceFile, token.Row, token.Column);
}

// =================================================================
//	Emits info message and continues.
// =================================================================
void CTranslationUnit::Info(std::string msg, std::string source, int row, int column)
{
	std::string line	   = CStringHelper::GetLineInString(m_source, row - 1);
	std::string arrow_line = CStringHelper::PadLeft("^", column - 1);
	
	printf("%s(%i:%i): Info: %s\n", source.c_str(), row, column, msg.c_str());
	//printf("%s\n", line.c_str());
	//printf("%s\n", arrow_line.c_str());
}

// =================================================================
//	Emits info message and continues.
// =================================================================
void CTranslationUnit::Info(std::string msg, CToken& token)
{
	Info(msg, token.SourceFile, token.Row, token.Column);
}

// =================================================================
//	Attempts to compile this translation unit. 
//	Returns true on success.
// =================================================================
bool CTranslationUnit::Evaluate(std::string expr)
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
		for (auto iter = m_token_list.begin(); iter != m_token_list.end(); iter++)
		{
			CToken& token = *iter;
			if (token.Type == TokenIdentifier::IDENTIFIER)
			{
				for (auto defIter = m_defines.begin(); defIter != m_defines.end(); defIter++)
				{
					CDefine& define = *defIter;
					if (define.Name == token.Literal)
					{
						switch (define.Type)
						{
							case DefineType::Bool:
							{
								if (CStringHelper::ToLower(define.Value) == "false" ||
									define.Value == "0" ||
									define.Value == "")
								{									
									token.Type = TokenIdentifier::KEYWORD_FALSE;
									token.Literal = "0";
								}
								else
								{
									token.Type = TokenIdentifier::KEYWORD_TRUE;
									token.Literal = "1";
								}
								break;
							}
							case DefineType::Int:
							{
								token.Type = TokenIdentifier::INT_LITERAL;
								token.Literal = define.Value;
								break;
							}
							case DefineType::Float:
							{
								token.Type = TokenIdentifier::FLOAT_LITERAL;
								token.Literal = define.Value;
								break;
							}
							case DefineType::String:
							{
								token.Type = TokenIdentifier::STRING_LITERAL;
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
	catch (std::runtime_error ex)
	{
		return false;
	}
}

// =================================================================
//	Attempts to compile this translation unit. 
//	Returns true on success.
// =================================================================
bool CTranslationUnit::Compile(bool importedPackage, CTranslationUnit* importingPackage)
{
	try
	{
		int start_tick_count = GetTickCount();

		if (importedPackage == false)
		{
			Info("Generating Package: " + m_filename);
		}
		else
		{
		//	Info("Importing Package: " + m_filename);
		}

		// Read source from disk.
		//Info("Loading Source ...");
		if (!CPathHelper::LoadFile(m_file_path, m_source))
		{
			FatalError("Could not read file: " + m_file_path);
		}
			
		// Preprocess the source file.
		m_preprocessor.Process(this);

		// Convert source file into a stream of tokens.
		//Info("Lexical Analysis ...");
		m_lexer.Process(this);
		
		// Convert the token stream info an AST representation.
		//Info("Parsing ...");
		m_parser.Process(this);

		// Import support files?
		if (importedPackage == false)
		{
			std::string					support_dir = m_compiler->GetPackageDirectory() + "/Compiler/Support";
			std::vector<std::string>	files		= CPathHelper::ListFiles(support_dir);

			for (auto iter = files.begin(); iter != files.end(); iter++)
			{
				AddUsingFile(support_dir + "/" + (*iter), false, false, false);
			}
		}

		// Import all packages we are using and insert them into the AST tree.
		if (m_using_files.size() > 0 || m_native_files.size() > 0)
		{
			// If we are an imported package ourselves, then pass the import up to the main package.
			if (importedPackage == true)
			{
				for (auto iter = m_using_files.begin(); iter != m_using_files.end(); iter++)
				{
					importingPackage->AddUsingFile(*iter, false, false, false);
				}
				for (auto iter = m_native_files.begin(); iter != m_native_files.end(); iter++)
				{
					importingPackage->AddUsingFile(*iter, true, false, false);
				}
				for (auto iter = m_library_files.begin(); iter != m_library_files.end(); iter++)
				{
					importingPackage->AddUsingFile(*iter, false, true, false);
				}
				for (auto iter = m_copy_files.begin(); iter != m_copy_files.end(); iter++)
				{
					importingPackage->AddUsingFile(*iter, false, false, true);
				}
			}

			// If we are the main package, compile and import all packages.
			else
			{			
				//Info("Importing Packages ...");	
				std::vector<std::string> imported_files;
				while (imported_files.size() != m_using_files.size())
				{			
					for (auto iter = m_using_files.begin(); iter != m_using_files.end(); iter++)
					{
						bool imported = false;
						for (auto iter2 = imported_files.begin(); iter2 != imported_files.end(); iter2++)
						{
							if (*iter == *iter2)
							{
								imported = true;
								break;
							}
						}

						if (imported == false)
						{							
							CTranslationUnit* unit = new CTranslationUnit(m_compiler, *iter, m_defines);
							unit->Compile(true, this);

							CASTNode* unitRoot = unit->GetASTRoot();
							CASTNode* realRoot = GetASTRoot();
							
							for (auto childIter = unitRoot->Children.begin(); childIter != unitRoot->Children.end(); childIter++)
							{
								realRoot->AddChild(*childIter);
							}

							m_imported_units.push_back(unit);
							imported_files.push_back(*iter);

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
			int elapsed = GetTickCount() - start_tick_count;
			Info("Imported " + m_filename + " in " + CStringHelper::ToString(elapsed) + "ms");
			return true;
		}
		
		// Check semantics are correct for AST.
		//Info("Semantic Analysis ...");
		m_semanter.Process(this);
		
		// Check we have an entry point.
		if (GetEntryPoint() == NULL)
		{
			FatalError("No entry point was found in program. Entry point with the following signature is expected: int Main(string[])");
		}

		// Translate into target language.
		int tick_count = GetTickCount();
		m_compiler->GetTranslator()->Process(this);		
		m_translated_files = m_compiler->GetTranslator()->GetTranslatedFiles();
		Info(CStringHelper::FormatString("Translated %s using '%s' translator in %s ms.",
										m_filename.c_str(), 
										m_compiler->GetProjectConfig().GetString("TRANSLATOR_NAME").c_str(), 
										CStringHelper::ToString(GetTickCount() - tick_count).c_str()));

		// Invoke native compiler.
		tick_count = GetTickCount();
		m_compiler->GetBuilder()->Process(this);
		Info(CStringHelper::FormatString("Compiled %s using '%s' builder in %s ms.",
								m_filename.c_str(), 
								m_compiler->GetProjectConfig().GetString("BUILDER_NAME").c_str(), 
								CStringHelper::ToString(GetTickCount() - tick_count).c_str()));

		// Work out elapsed time.
		int elapsed = GetTickCount() - start_tick_count;
		Info("Generated " + m_filename + " in " + CStringHelper::ToString(elapsed) + "ms");

		return true;
	}
	catch (std::runtime_error ex)
	{
		Error("Failed to compile file: " + m_filename);
		return false;
	}
}

// =================================================================
//	Attempts to preprocess the translation unit.
//	Returns true on success.
// =================================================================
bool CTranslationUnit::PreProcess()
{
	try
	{
		// Read source from disk.
		if (!CPathHelper::LoadFile(m_file_path, m_source))
		{
			FatalError("Could not read file: " + m_file_path);
		}
			
		// Preprocess the source file.
		m_preprocessor.Process(this);

		return true;
	}
	catch (std::runtime_error ex)
	{
		Error("Failed to process file: " + m_filename);
		return false;
	}
}

// =================================================================
//	Runs an executable witht he given arguments and emits the 
//	output to the stdout.
// =================================================================
bool CTranslationUnit::Execute(std::string path, std::string cmd_line)
{
	PROCESS_INFORMATION pi = { 0 };
	STARTUPINFOA		si = { sizeof(si) };
	
	path = CStringHelper::Replace(path, "/", "\\");

	std::string dir = CPathHelper::StripFilename(path);

	if (!CreateProcessA(NULL, (LPSTR)("\"" + path + "\" " + cmd_line).c_str(), NULL, NULL, true, CREATE_DEFAULT_ERROR_MODE, NULL, (LPSTR)dir.c_str(), &si, &pi)) 
	{
		int err = GetLastError();
		return false;		
	}

	WaitForSingleObject(pi.hProcess, INFINITE);

	int res = GetExitCodeProcess(pi.hProcess, (DWORD*)&res) ? res : -1;

	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	return (res == 0);
}

