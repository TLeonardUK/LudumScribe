/* *****************************************************************

		CReturnStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CReturnStatementASTNode.h"

#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"
#include "CThisExpressionASTNode.h"

#include "CDataType.h"
#include "CVoidDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CStringHelper.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CReturnStatementASTNode::CReturnStatementASTNode(CASTNode* parent, CToken token) :
	CASTNode(parent, token),
	ReturnExpression(NULL)
{
}

// =================================================================
// Performs semantic analysis of this node.
// =================================================================
CASTNode* CReturnStatementASTNode::Semant(CSemanter* semanter)
{	
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Find statement we are in.
	CClassMemberASTNode* scope = this->FindClassMethodScope(semanter);

	// Check we don't have a manual return expression
	// for constructors.
	if (scope->IsConstructor == true)
	{
		if (ReturnExpression != NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Constructor '%s' can not return a value.", scope->Identifier.c_str()), Token);		
		}

		// Return the class instance.
		ReturnExpression = new CThisExpressionASTNode(NULL, Token);
		AddChild(ReturnExpression);
	}

	// Semant the expression.
	if (ReturnExpression != NULL)
	{
		if (dynamic_cast<CVoidDataType*>(scope->ReturnType) != NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Method '%s' does not expect a return value.", scope->Identifier.c_str()), Token);
		}

		ReturnExpression = dynamic_cast<CExpressionBaseASTNode*>(ReplaceChild(ReturnExpression, ReturnExpression->Semant(semanter)));
		ReturnExpression = dynamic_cast<CExpressionBaseASTNode*>(ReplaceChild(ReturnExpression, ReturnExpression->CastTo(semanter, scope->ReturnType, Token)));
	}
	else
	{
		if (dynamic_cast<CVoidDataType*>(scope->ReturnType) == NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Method '%s' expects return value of type '%s'.", scope->Identifier.c_str(), scope->ReturnType->ToString().c_str()), Token);
		}
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CReturnStatementASTNode::Clone(CSemanter* semanter)
{
	CReturnStatementASTNode* clone = new CReturnStatementASTNode(NULL, Token);

	if (ReturnExpression != NULL)
	{
		clone->ReturnExpression = dynamic_cast<CExpressionASTNode*>(ReturnExpression->Clone(semanter));
		clone->AddChild(clone->ReturnExpression);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CReturnStatementASTNode::Translate(CTranslator* translator)
{
	translator->TranslateReturnStatement(this);
}