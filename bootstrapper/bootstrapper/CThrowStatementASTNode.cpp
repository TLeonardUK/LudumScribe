/* *****************************************************************

		CThrowStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CThrowStatementASTNode.h"
#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CDataType.h"

#include "CClassASTNode.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CThrowStatementASTNode::CThrowStatementASTNode(CASTNode* parent, CToken token) :
	CASTNode(parent, token),
	Expression(NULL)
{
}
// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CThrowStatementASTNode::Semant(CSemanter* semanter)
{ 	
	SEMANT_TRACE("CThrowStatementASTNode");

	Expression = dynamic_cast<CExpressionBaseASTNode*>(ReplaceChild(Expression, Expression->Semant(semanter)));

	CDataType* exception_base = FindDataType(semanter, "Exception", std::vector<CDataType*>());
	if (exception_base == NULL ||
		exception_base->GetClass(semanter) == NULL)
	{
		semanter->GetContext()->FatalError("Internal error, could not find base 'Exception' class.");
	}

	CDataType* catch_type = Expression->ExpressionResultType;
	if (catch_type == NULL ||
		catch_type->GetClass(semanter)->InheritsFromClass(semanter, exception_base->GetClass(semanter)) == false)
	{
		semanter->GetContext()->FatalError("Thrown exceptions must inherit from 'Exception' class.", Token);
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CThrowStatementASTNode::Clone(CSemanter* semanter)
{
	CThrowStatementASTNode* clone = new CThrowStatementASTNode(NULL, Token);

	if (Expression != NULL)
	{
		clone->Expression = dynamic_cast<CExpressionASTNode*>(Expression->Clone(semanter));
		clone->AddChild(clone->Expression);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CThrowStatementASTNode::Translate(CTranslator* translator)
{
	translator->TranslateThrowStatement(this);
}