/* *****************************************************************

		CClassRefExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CClassRefExpressionASTNode.h"
#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"
#include "CTranslationUnit.h"
#include "CSemanter.h"

#include "CDataType.h"
#include "CObjectDataType.h"
#include "CClassReferenceDataType.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CClassRefExpressionASTNode::CClassRefExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CClassRefExpressionASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CClassRefExpressionASTNode");

	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Make sure we are inside a method and 
	CClassASTNode* class_scope = this->FindClassScope(semanter);
	ExpressionResultType = new CClassReferenceDataType(Token, class_scope);

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CClassRefExpressionASTNode::Clone(CSemanter* semanter)
{
	CClassRefExpressionASTNode* clone = new CClassRefExpressionASTNode(NULL, Token);
	
	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CClassRefExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateClassRefExpression(this);
}