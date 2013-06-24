// -----------------------------------------------------------------------------
// 	CTranslationUnit.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

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
	
	private CLexer m_lexer;
	private CParser m_parser;
	private CSemanter m_semanter;
	private CPreprocessor m_preprocessor;
	
	private List<CToken> m_token_list;
	private List<string> m_using_files;
	private List<string> m_native_files;
	private List<string> m_copy_files;
	private List<string> m_library_files;
	private List<string> m_translated_files;
	
	private int m_last_line_row;
	private int m_last_line_column;
	
	private List<CTranslationUnit> m_imported_units;
	
	private List<CDefine> m_defines;
	
	private List<CDataType> m_identifier_data_types;
	
	private CClassMemberASTNode m_entry_point;
	
	public CTranslationUnit(CCompiler compiler, string file_path, List<CDefine> defines)
	{
	}
	
	public bool Evaluate(string expr)
	{
	}
	public bool Compile(bool importedPackage = false, CTranslationUnit importingPackage = null)
	{
	}
	
	public bool PreProcess()
	{
	}
	
	public CCompiler GetCompiler()
	{
	}
	public CASTNode GetASTRoot()
	{
	}
	public string GetSource()
	{
	}
	public string GetFilePath()
	{
	}
	public List<CToken> GetTokenList()
	{
	}
	public List<string> GetUsingFileList()
	{
	}
	public List<string> GetNativeFileList()
	{
	}
	public List<string> GetCopyFileList()
	{
	}
	public List<string> GetLibraryFileList()
	{
	}
	public List<string> GetTranslatedFiles()
	{
	}
	public List<CDefine> GetDefines()
	{
	}
	public CSemanter GetSemanter()
	{
	}
	
	public CClassMemberASTNode GetEntryPoint()
	{
	}
	
	public int GetLastLineRow()
	{
	}
	public int GetLastLineColumn()
	{
	}
	
	public bool Execute(string path, string cmd_line)
	{
	}
	
	public bool AddUsingFile(string file, bool isNative, bool isLibrary, bool isCopy)
	{
	}
	
	public void FatalError(string msg, string source="internal", int row=1, int column=1)
	{
	}
	public void FatalError(string msg, CToken token)
	{
	}
	public void Error(string msg, string source="internal", int row=1, int column=1)
	{
	}
	public void Error(string msg, CToken token)
	{
	}
	public void Warning(string msg, string source="internal", int row=1, int column=1)
	{
	}
	public void Warning(string msg, CToken token)
	{
	}
	public void Info(string msg, string source="internal", int row=1, int column=1)
	{
	}
	public void Info(string msg, CToken token)
	{
	}
	
}

