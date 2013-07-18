/* *****************************************************************

		CComparisonExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CComparisonExpressionASTNode.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"
#include "CBoolDataType.h"
#include "CObjectDataType.h"
#include "CStringHelper.h"

#include "CIntDataType.h"
#include "CFloatDataType.h"
#include "CStringDataType.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CComparisonExpressionASTNode::CComparisonExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token),
	LeftValue(NULL),
	RightValue(NULL),
	CompareResultType(NULL)
{
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CComparisonExpressionASTNode::Clone(CSemanter* semanter)
{
	CComparisonExpressionASTNode* clone = new CComparisonExpressionASTNode(NULL, Token);

	if (LeftValue != NULL)
	{
		clone->LeftValue = dynamic_cast<CASTNode*>(LeftValue->Clone(semanter));
		clone->AddChild(clone->LeftValue);
	}
	if (RightValue != NULL)
	{
		clone->RightValue = dynamic_cast<CASTNode*>(RightValue->Clone(semanter));
		clone->AddChild(clone->RightValue);
	}

	return clone;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CComparisonExpressionASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CComparisonExpressionASTNode");

	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Semant expressions.
	LeftValue  = ReplaceChild(LeftValue,   LeftValue->Semant(semanter));
	RightValue = ReplaceChild(RightValue, RightValue->Semant(semanter)); 

	// Get expression references.
	CExpressionBaseASTNode* leftValueBase  = dynamic_cast<CExpressionBaseASTNode*>(LeftValue);
	CExpressionBaseASTNode* rightValueBase = dynamic_cast<CExpressionBaseASTNode*>(RightValue);

	// Balance types.
	ExpressionResultType = semanter->BalanceDataTypes(leftValueBase->ExpressionResultType, 
														rightValueBase->ExpressionResultType);
	
	// Objects only permit equality operations.
	if (dynamic_cast<CObjectDataType*>(ExpressionResultType) != NULL &&
		Token.Type != TokenIdentifier::OP_EQUAL &&
		Token.Type != TokenIdentifier::OP_NOT_EQUAL)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("%s operator cannot be used on objects.", Token.Literal), Token);
	}

	// Cast to resulting expression.
	LeftValue  = ReplaceChild(LeftValue,  leftValueBase->CastTo(semanter, ExpressionResultType, Token));
	RightValue = ReplaceChild(RightValue, rightValueBase->CastTo(semanter, ExpressionResultType, Token)); 

	CompareResultType = ExpressionResultType;
	ExpressionResultType = new CBoolDataType(Token);

	return this;
}

// =================================================================
//	Evalulates the constant value of this node.
// =================================================================
EvaluationResult CComparisonExpressionASTNode::Evaluate(CTranslationUnit* unit)
{
	EvaluationResult leftResult  = LeftValue->Evaluate(unit);
	EvaluationResult rightResult = RightValue->Evaluate(unit);

	if (dynamic_cast<CBoolDataType*>(CompareResultType) != NULL)
	{
	}
	else if (dynamic_cast<CIntDataType*>(CompareResultType) != NULL)
	{
		switch (Token.Type)
		{		
			case TokenIdentifier::OP_EQUAL:			return EvaluationResult(leftResult.GetInt() == rightResult.GetInt()); 
			case TokenIdentifier::OP_NOT_EQUAL:		return EvaluationResult(leftResult.GetInt() != rightResult.GetInt());  
			case TokenIdentifier::OP_GREATER:		return EvaluationResult(leftResult.GetInt() >  rightResult.GetInt());
			case TokenIdentifier::OP_LESS:			return EvaluationResult(leftResult.GetInt() <  rightResult.GetInt());   
			case TokenIdentifier::OP_GREATER_EQUAL:	return EvaluationResult(leftResult.GetInt() >= rightResult.GetInt()); 
			case TokenIdentifier::OP_LESS_EQUAL:	return EvaluationResult(leftResult.GetInt() <= rightResult.GetInt());  
		}
	}
	else if (dynamic_cast<CFloatDataType*>(CompareResultType) != NULL)
	{
		switch (Token.Type)
		{		
			case TokenIdentifier::OP_EQUAL:			return EvaluationResult(leftResult.GetFloat() == rightResult.GetFloat()); 
			case TokenIdentifier::OP_NOT_EQUAL:		return EvaluationResult(leftResult.GetFloat() != rightResult.GetFloat());  
			case TokenIdentifier::OP_GREATER:		return EvaluationResult(leftResult.GetFloat() >  rightResult.GetFloat());
			case TokenIdentifier::OP_LESS:			return EvaluationResult(leftResult.GetFloat() <  rightResult.GetFloat());   
			case TokenIdentifier::OP_GREATER_EQUAL:	return EvaluationResult(leftResult.GetFloat() >= rightResult.GetFloat()); 
			case TokenIdentifier::OP_LESS_EQUAL:	return EvaluationResult(leftResult.GetFloat() <= rightResult.GetFloat());  
		}
	}
	else if (dynamic_cast<CStringDataType*>(CompareResultType) != NULL)
	{
		switch (Token.Type)
		{		
			case TokenIdentifier::OP_EQUAL:			return EvaluationResult(leftResult.GetString() == rightResult.GetString()); 
			case TokenIdentifier::OP_NOT_EQUAL:		return EvaluationResult(leftResult.GetString() != rightResult.GetString());  
			case TokenIdentifier::OP_GREATER:		return EvaluationResult(leftResult.GetString() >  rightResult.GetString());
			case TokenIdentifier::OP_LESS:			return EvaluationResult(leftResult.GetString() <  rightResult.GetString());   
			case TokenIdentifier::OP_GREATER_EQUAL:	return EvaluationResult(leftResult.GetString() >= rightResult.GetString()); 
			case TokenIdentifier::OP_LESS_EQUAL:	return EvaluationResult(leftResult.GetString() <= rightResult.GetString());  
		}
	}
	
	unit->FatalError("Invalid constant operation.", Token);
	return EvaluationResult(false);
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CComparisonExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateComparisonExpression(this);
}