/* *****************************************************************

		CPreprocessor.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CPREPROCESSOR_H_
#define _CPREPROCESSOR_H_

#include "CToken.h"

#include "EvaluationResult.h"

class CCompiler;
class CTranslationUnit;

// =================================================================
//	Responsible for preprocessing a source file.
// =================================================================
class CPreprocessor
{
private:
	std::vector<std::string>	m_lines;
	unsigned int				m_line_index;
	std::string					m_result;
	std::vector<CDefine>*		m_defines;
	CTranslationUnit*			m_context;
	CToken						m_lineToken;
	std::string					m_currentLine;

	bool						m_accept_input;
		
	std::vector<std::string> SplitLine			(std::string line);
	std::string				 ReplaceDefineTags	(std::string line);

	bool		EndOfLines		();
	void		ParseLine		(std::string line);
	std::string ReadLine		();
	std::string LookAheadLine	();
	std::string CurrentLine		();
	void		Output			(std::string output);

	void		ParseIfBlock	();
	void		SkipIfBlock		();

	void		ParseIf			(std::string line);
	void		ParseDefine		(std::string line);
	void		ParseUndefine	(std::string line);
	void		ParseError		(std::string line);
	void		ParseWarning	(std::string line);
	void		ParseInfo		(std::string line);

public:
	bool Process(CTranslationUnit* context);
	EvaluationResult Evaluate(CTranslationUnit* context, CToken& token, std::string expr, std::vector<CDefine>* defines);

};

#endif

