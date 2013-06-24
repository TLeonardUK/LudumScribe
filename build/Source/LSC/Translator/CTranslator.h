/* *****************************************************************

		CTranslator.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTRANSLATOR_H_
#define _CTRANSLATOR_H_

#include "CToken.h"

class CTranslationUnit;
class CPackageASTNode;
class CClassASTNode;
class CClassMemberASTNode;
class CDataType;
class CExpressionASTNode;
class CExpressionBaseASTNode;

class CBlockStatementASTNode;
class CBreakStatementASTNode;
class CContinueStatementASTNode;
class CDoStatementASTNode;
class CForEachStatementASTNode;
class CForStatementASTNode;
class CIfStatementASTNode;
class CReturnStatementASTNode;
class CSwitchStatementASTNode;
class CThrowStatementASTNode;
class CTryStatementASTNode;
class CWhileStatementASTNode;

class CVariableStatementASTNode;
class CAssignmentExpressionASTNode;
class CBaseExpressionASTNode;
class CBinaryMathExpressionASTNode;
class CCastExpressionASTNode;
class CClassRefExpressionASTNode;
class CCommaExpressionASTNode;
class CComparisonExpressionASTNode;
class CFieldAccessExpressionASTNode;
class CIdentifierExpressionASTNode;
class CIndexExpressionASTNode;
class CLiteralExpressionASTNode;
class CLogicalExpressionASTNode;
class CMethodCallExpressionASTNode;
class CNewExpressionASTNode;
class CPostFixExpressionASTNode;
class CPreFixExpressionASTNode;
class CSliceExpressionASTNode;
class CTernaryExpressionASTNode;
class CThisExpressionASTNode;
class CTypeExpressionASTNode;
class CArrayInitializerASTNode;

class CSemanter;

// =================================================================
//	Responsible for translating a parsed AST tree into a 
//	native language.
// =================================================================
class CTranslator
{
protected:
	CTranslationUnit* m_context;
	CSemanter* m_semanter;

public:
	bool				Process							(CTranslationUnit* context);
	CTranslationUnit*	GetContext						();
	
	virtual std::vector<std::string> GetTranslatedFiles	() = 0;

	virtual std::string TranslateDataType				(CDataType* dt) = 0;
		
	virtual void TranslatePackage						(CPackageASTNode* node) = 0;
	virtual void TranslateClass							(CClassASTNode* node) = 0;
	virtual void TranslateClassMember					(CClassMemberASTNode* node) = 0;
	virtual void TranslateVariableStatement				(CVariableStatementASTNode* node) = 0;

	virtual void TranslateBlockStatement				(CBlockStatementASTNode* node) = 0;
	virtual void TranslateBreakStatement				(CBreakStatementASTNode* node) = 0;
	virtual void TranslateContinueStatement				(CContinueStatementASTNode* node) = 0;
	virtual void TranslateDoStatement					(CDoStatementASTNode* node) = 0;
	virtual void TranslateForEachStatement				(CForEachStatementASTNode* node) = 0;
	virtual void TranslateForStatement					(CForStatementASTNode* node) = 0;
	virtual void TranslateIfStatement					(CIfStatementASTNode* node) = 0;
	virtual void TranslateReturnStatement				(CReturnStatementASTNode* node) = 0;
	virtual void TranslateSwitchStatement				(CSwitchStatementASTNode* node) = 0;
	virtual void TranslateThrowStatement				(CThrowStatementASTNode* node) = 0;
	virtual void TranslateTryStatement					(CTryStatementASTNode* node) = 0;
	virtual void TranslateWhileStatement				(CWhileStatementASTNode* node) = 0;
	virtual void TranslateExpressionStatement			(CExpressionASTNode* node) = 0;
	
	virtual std::string	TranslateExpression				(CExpressionASTNode* node) = 0;
	virtual std::string	TranslateAssignmentExpression	(CAssignmentExpressionASTNode* node) = 0;
	virtual std::string	TranslateBaseExpression			(CBaseExpressionASTNode* node) = 0;
	virtual std::string	TranslateBinaryMathExpression	(CBinaryMathExpressionASTNode* node) = 0;
	virtual std::string	TranslateCastExpression			(CCastExpressionASTNode* node) = 0;
	virtual std::string	TranslateClassRefExpression		(CClassRefExpressionASTNode* node) = 0;
	virtual std::string	TranslateCommaExpression		(CCommaExpressionASTNode* node) = 0;
	virtual std::string	TranslateComparisonExpression	(CComparisonExpressionASTNode* node) = 0;
	virtual std::string	TranslateFieldAccessExpression	(CFieldAccessExpressionASTNode* node) = 0;
	virtual std::string	TranslateIdentifierExpression	(CIdentifierExpressionASTNode* node) = 0;
	virtual std::string	TranslateIndexExpression		(CIndexExpressionASTNode* node, bool set = false, std::string set_expr = "", bool postfix = false) = 0;
	virtual std::string	TranslateLiteralExpression		(CLiteralExpressionASTNode* node) = 0;
	virtual std::string	TranslateLogicalExpression		(CLogicalExpressionASTNode* node) = 0;
	virtual std::string	TranslateMethodCallExpression	(CMethodCallExpressionASTNode* node) = 0;
	virtual std::string	TranslateNewExpression			(CNewExpressionASTNode* node) = 0;
	virtual std::string	TranslatePostFixExpression		(CPostFixExpressionASTNode* node) = 0;
	virtual std::string	TranslatePreFixExpression		(CPreFixExpressionASTNode* node) = 0;
	virtual std::string	TranslateSliceExpression		(CSliceExpressionASTNode* node) = 0;
	virtual std::string	TranslateTernaryExpression		(CTernaryExpressionASTNode* node) = 0;
	virtual std::string	TranslateThisExpression			(CThisExpressionASTNode* node) = 0;
	virtual std::string	TranslateTypeExpression			(CTypeExpressionASTNode* node) = 0;
	virtual std::string TranslateArrayInitializerExpression	(CArrayInitializerASTNode* node) = 0;
	
};

#endif

