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

// Debug function used to make a trace of function calls during semantation.
#ifdef _NDEBUG
#define SEMANT_TRACE(...) 
#else
extern int g_semant_trace_index;
#define SEMANT_TRACE(...) \
	printf("[Trace:%i] ", ++g_semant_trace_index); \
	printf(__VA_ARGS__); \
	printf("\n");// \
	//if (g_semant_trace_index == 301761) __debugbreak();
#endif

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

