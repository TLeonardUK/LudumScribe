/* *****************************************************************

		CTranslationUnit.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTRANSLATIONUNIT_H_
#define _CTRANSLATIONUNIT_H_

#include <vector>
#include <string>

#include "CCompiler.h"
#include "CLexer.h"
#include "CParser.h"
#include "CSemanter.h"
#include "CPreprocessor.h"

class CCompiler;

// =================================================================
//	This class stores non-transient data that needs to be passed
//  around during the compilation process.
// =================================================================
class CTranslationUnit
{
private:
	CCompiler*					m_compiler;
	std::string					m_file_path;
	std::string					m_filename;
	
	std::string					m_source;

	CLexer						m_lexer;
	CParser						m_parser;
	CSemanter					m_semanter;
	CPreprocessor				m_preprocessor;

	std::vector<CToken>			m_token_list;
	std::vector<std::string>	m_using_files;
	std::vector<std::string>	m_native_files;
	std::vector<std::string>	m_translated_files;

	int							m_last_line_row;
	int							m_last_line_column;

	std::vector<CTranslationUnit*>	m_imported_units;

	std::vector<CDefine>			m_defines;

	std::vector<CDataType*>			m_identifier_data_types;

	CClassMemberASTNode*			m_entry_point;

public:
	~CTranslationUnit();
	CTranslationUnit(CCompiler* compiler, std::string file_path, std::vector<CDefine> defines);

	bool Evaluate	(std::string expr);
	bool Compile	(bool importedPackage = false, CTranslationUnit* importingPackage = NULL);

	bool PreProcess	();

	CCompiler*					GetCompiler			();
	CASTNode*					GetASTRoot			();
	std::string&				GetSource			();
	std::string&				GetFilePath			();
	std::vector<CToken>&		GetTokenList		();
	std::vector<std::string>&	GetUsingFileList	();
	std::vector<std::string>&	GetNativeFileList	();
	std::vector<std::string>&	GetTranslatedFiles	();
	std::vector<CDefine>&		GetDefines			();
	CSemanter*					GetSemanter			();

	CClassMemberASTNode*&		GetEntryPoint		();

	int							GetLastLineRow		();
	int							GetLastLineColumn	();

	bool						Execute				(std::string path, std::string cmd_line);

	bool						AddUsingFile		(std::string file, bool isNative);

	void FatalError	(std::string msg, std::string source="internal", int row=1, int column=1);
	void FatalError	(std::string msg, CToken& token);
	void Error		(std::string msg, std::string source="internal", int row=1, int column=1);
	void Error		(std::string msg, CToken& token);
	void Warning	(std::string msg, std::string source="internal", int row=1, int column=1);
	void Warning	(std::string msg, CToken& token);
	void Info		(std::string msg, std::string source="internal", int row=1, int column=1);
	void Info		(std::string msg, CToken& token);

};

#endif