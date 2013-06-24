/* *****************************************************************

		CTranslator.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCPPTRANSLATOR_H_
#define _CCPPTRANSLATOR_H_

#include "CToken.h"
#include "CTranslator.h"

class CASTNode;
class CTranslationUnit;
class CClassASTNode;
class CDataType;
class CExpressionBaseASTNode;
class CExpressionASTNode;
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

// =================================================================
//	Responsible for translating a parsed AST tree into a 
//	C++ representation.
// =================================================================
class CCPPTranslator : public CTranslator
{
private:
	//std::vector<std::string> m_file_paths; 
	std::vector<std::string> m_native_file_paths;
	std::vector<std::string> m_library_file_paths;

	std::string m_base_directory;
	std::string m_dst_directory;
	std::string m_package_directory;
	std::string m_source_directory;
	std::string m_source_package_directory;

	CPackageASTNode* m_package;

	FILE* m_header_file_handle;
	FILE* m_source_file_handle;

	int m_header_indent_level;
	int m_source_indent_level;

	bool m_last_source_was_newline;
	bool m_last_header_was_newline;

	std::string m_source_source;
	std::string m_header_source;

	std::string m_include_guard;

	int m_internal_var_counter;
	std::string m_switchBreakJumpLabel;

	int m_last_gc_collect_emit;
	int m_emit_source_counter;

	std::vector<std::string> m_created_files;

public:

	CCPPTranslator();
	
	virtual std::vector<std::string> GetTranslatedFiles();

	void OpenSourceFile								(std::string format);
	void OpenHeaderFile								(std::string format);
	void CloseSourceFile							();
	void CloseHeaderFile							();

	void GenerateEntryPoint							(CPackageASTNode* node);

	void EmitSourceFile								(std::string text, ...);
	void EmitHeaderFile								(std::string text, ...);

	void EmitGCCollect								();
	
	std::string NewInternalVariableName				();
	std::string EscapeCString						(std::string val);
	std::string Enclose								(std::string val);

	bool		IsKeyword							(std::string value);

	std::string FindIncludePath						(std::string path);
	void		EmitRequiredClassIncludes			(CClassASTNode* node);

	std::vector<CClassASTNode*> FindReferencedClasses(CASTNode* node);

	virtual std::string TranslateDataType			(CDataType* dt);

	virtual void TranslatePackage					(CPackageASTNode* node);
	virtual void TranslateClass						(CClassASTNode* node);
	virtual void TranslateClassMember				(CClassMemberASTNode* node);
	virtual void TranslateVariableStatement			(CVariableStatementASTNode* node);
	virtual void TranslateBlockStatement			(CBlockStatementASTNode* node);
	virtual void TranslateBreakStatement			(CBreakStatementASTNode* node);
	virtual void TranslateContinueStatement			(CContinueStatementASTNode* node);
	virtual void TranslateDoStatement				(CDoStatementASTNode* node);
	virtual void TranslateForEachStatement			(CForEachStatementASTNode* node);
	virtual void TranslateForStatement				(CForStatementASTNode* node);
	virtual void TranslateIfStatement				(CIfStatementASTNode* node);
	virtual void TranslateReturnStatement			(CReturnStatementASTNode* node);
	virtual void TranslateSwitchStatement			(CSwitchStatementASTNode* node);
	virtual void TranslateThrowStatement			(CThrowStatementASTNode* node);
	virtual void TranslateTryStatement				(CTryStatementASTNode* node);
	virtual void TranslateWhileStatement			(CWhileStatementASTNode* node);
	virtual void TranslateExpressionStatement		(CExpressionASTNode* node);

	virtual std::string	TranslateExpression				(CExpressionASTNode* node);
	virtual std::string	TranslateAssignmentExpression	(CAssignmentExpressionASTNode* node);
	virtual std::string	TranslateBaseExpression			(CBaseExpressionASTNode* node);
	virtual std::string	TranslateBinaryMathExpression	(CBinaryMathExpressionASTNode* node);
	virtual std::string	TranslateCastExpression			(CCastExpressionASTNode* node);
	virtual std::string	TranslateClassRefExpression		(CClassRefExpressionASTNode* node);
	virtual std::string	TranslateCommaExpression		(CCommaExpressionASTNode* node);
	virtual std::string	TranslateComparisonExpression	(CComparisonExpressionASTNode* node);
	virtual std::string	TranslateFieldAccessExpression	(CFieldAccessExpressionASTNode* node);
	virtual std::string	TranslateIdentifierExpression	(CIdentifierExpressionASTNode* node);
	virtual std::string	TranslateIndexExpression		(CIndexExpressionASTNode* node, bool set = false, std::string set_expr = "", bool postfix = false);
	virtual std::string	TranslateLiteralExpression		(CLiteralExpressionASTNode* node);
	virtual std::string	TranslateLogicalExpression		(CLogicalExpressionASTNode* node);
	virtual std::string	TranslateMethodCallExpression	(CMethodCallExpressionASTNode* node);
	virtual std::string	TranslateNewExpression			(CNewExpressionASTNode* node);
	virtual std::string	TranslatePostFixExpression		(CPostFixExpressionASTNode* node);
	virtual std::string	TranslatePreFixExpression		(CPreFixExpressionASTNode* node);
	virtual std::string	TranslateSliceExpression		(CSliceExpressionASTNode* node);
	virtual std::string	TranslateTernaryExpression		(CTernaryExpressionASTNode* node);
	virtual std::string	TranslateThisExpression			(CThisExpressionASTNode* node);
	virtual std::string	TranslateTypeExpression			(CTypeExpressionASTNode* node);
	virtual std::string TranslateArrayInitializerExpression	(CArrayInitializerASTNode* node);

};

#endif

