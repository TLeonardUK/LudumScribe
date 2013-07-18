/* *****************************************************************

		CThisExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CThisExpressionASTNode.h"
#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"
#include "CTranslationUnit.h"
#include "CSemanter.h"

#include "CDataType.h"
#include "CObjectDataType.h"
#include "CStringDataType.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CThisExpressionASTNode::CThisExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CThisExpressionASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CThisExpressionASTNode");

	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Make sure we are inside a method and 
	CClassASTNode*		 class_scope = this->FindClassScope(semanter);
	CClassMemberASTNode* method_scope = this->FindClassMethodScope(semanter);

	if (method_scope == NULL ||
		class_scope  == NULL)
	{
		semanter->GetContext()->FatalError("this keyword can only be used in class methods.", Token);		
	}
	if (method_scope->IsStatic == true)
	{
		semanter->GetContext()->FatalError("this keyword cannot be used in static methods.", Token);
	}

	if (class_scope->Identifier == "string")
	{
		ExpressionResultType = new CStringDataType(Token);
	}
	else
	{
		ExpressionResultType = class_scope->ObjectDataType;
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CThisExpressionASTNode::Clone(CSemanter* semanter)
{
	CThisExpressionASTNode* clone = new CThisExpressionASTNode(NULL, Token);
	

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CThisExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateThisExpression(this);
}