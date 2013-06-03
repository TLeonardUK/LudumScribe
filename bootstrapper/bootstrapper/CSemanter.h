/* *****************************************************************

		CSemanter.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CSEMANTER_H_
#define _CSEMANTER_H_

#include "CToken.h"

class CCompiler;
class CTranslationUnit;
class CDataType;
class CASTNode;
class CDeclarationASTNode;
class CPackageASTNode;
class CClassASTNode;
class CClassMemberASTNode;
class CExpressionASTNode;

// =================================================================
//	Responsible for semantic analysis of a parsed AST.
// =================================================================
class CSemanter
{
private:
	CTranslationUnit*			m_context;
	std::vector<CASTNode*>		m_scope_stack;
	std::vector<std::string>	m_mangled;
	
	int m_internal_var_counter;

public:	
	std::string			NewInternalVariableName				();
	
	CExpressionASTNode*	ConstructDefaultAssignmentExpr		(CASTNode* parent, CToken& token, CDataType* type);

	bool				 Process							(CTranslationUnit* context);
	
	CTranslationUnit*	 GetContext							();

	std::string		 	 GetMangled							(std::string mangled);

	CDataType*	 		 BalanceDataTypes					(CDataType* lvalue, CDataType* rvalue);

};

#endif

