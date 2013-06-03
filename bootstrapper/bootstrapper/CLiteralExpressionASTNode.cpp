/* *****************************************************************

		CLiteralExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CLiteralExpressionASTNode.h"
#include "CDataType.h"

#include "CTranslationUnit.h"

#include "CBoolDataType.h"
#include "CIntDataType.h"
#include "CFloatDataType.h"
#include "CStringDataType.h"
#include "CNullDataType.h"

#include "CStringHelper.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CLiteralExpressionASTNode::CLiteralExpressionASTNode(CASTNode* parent, CToken token, CDataType* type, std::string lit) :
	CExpressionBaseASTNode(parent, token), 
	Type(type), 
	Literal(lit)
{

}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CLiteralExpressionASTNode::Clone(CSemanter* semanter)
{
	CLiteralExpressionASTNode* clone = new CLiteralExpressionASTNode(NULL, Token, Type, Literal);

	return clone;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CLiteralExpressionASTNode::Semant(CSemanter* semanter)
{ 
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	ExpressionResultType = Type->Semant(semanter, this);

	return this;
}

// =================================================================
//	Evalulates the constant value of this node.
// =================================================================
EvaluationResult CLiteralExpressionASTNode::Evaluate(CTranslationUnit* unit)
{
	if (dynamic_cast<CBoolDataType*>(ExpressionResultType) != NULL)
	{
		return EvaluationResult(Literal == "0" || CStringHelper::ToLower(Literal) == "false" || Literal == "" ? false : true);
	}
	else if (dynamic_cast<CIntDataType*>(ExpressionResultType) != NULL)
	{
		return EvaluationResult(CStringHelper::ToInt(Literal));
	}
	else if (dynamic_cast<CFloatDataType*>(ExpressionResultType) != NULL)
	{
		return EvaluationResult(CStringHelper::ToFloat(Literal));
	}
	else if (dynamic_cast<CStringDataType*>(ExpressionResultType) != NULL)
	{
		return EvaluationResult(Literal);
	}
	
	unit->FatalError("Invalid constant operation.", Token);
	return EvaluationResult(false);
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CLiteralExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateLiteralExpression(this);
}