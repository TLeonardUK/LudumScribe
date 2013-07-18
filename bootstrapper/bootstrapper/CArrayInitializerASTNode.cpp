/* *****************************************************************

		CArrayInitializerASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CArrayInitializerASTNode.h"
#include "CDataType.h"
#include "CBoolDataType.h"
#include "CObjectDataType.h"
#include "CVoidDataType.h"
#include "CStringDataType.h"
#include "CIntDataType.h"
#include "CFloatDataType.h"
#include "CArrayDataType.h"

#include "CClassASTNode.h"

#include "CStringHelper.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CNewExpressionASTNode.h"

#include "CMethodCallExpressionASTNode.h"
#include "CFieldAccessExpressionASTNode.h"
#include "CIdentifierExpressionASTNode.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CArrayInitializerASTNode::CArrayInitializerASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token)
{
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CArrayInitializerASTNode::Clone(CSemanter* semanter)
{
	CArrayInitializerASTNode* clone = new CArrayInitializerASTNode(NULL, Token);

	for (auto iter = Expressions.begin(); iter != Expressions.end(); iter++)
	{
		CASTNode* node = (*iter)->Clone(semanter);
		clone->Expressions.push_back(node);
		clone->AddChild(node);
	}

	return clone;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CArrayInitializerASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CArrayInitializerASTNode");

	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Semant all expressions.
	for (auto iter = Expressions.begin(); iter != Expressions.end(); iter++)
	{
		CExpressionBaseASTNode* node = dynamic_cast<CExpressionBaseASTNode*>(*iter);
		node->Semant(semanter);

		if (ExpressionResultType == NULL)
		{
			ExpressionResultType = node->ExpressionResultType;
		}
		else
		{
			if (!ExpressionResultType->IsEqualTo(semanter, node->ExpressionResultType))
			{
				semanter->GetContext()->FatalError("All expressions in an array initialization list must be of the same type.", node->Token);
			}
		}
	}

	ExpressionResultType = ExpressionResultType->ArrayOf();

	return this;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CArrayInitializerASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateArrayInitializerExpression(this);
}