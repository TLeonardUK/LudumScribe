/* *****************************************************************

		CIndexExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CIndexExpressionASTNode.h"

#include "CArrayDataType.h"
#include "CStringDataType.h"
#include "CIntDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CTranslator.h"

#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CIndexExpressionASTNode::CIndexExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token),
	IndexExpression(NULL),
	LeftValue(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CIndexExpressionASTNode::Semant(CSemanter* semanter)
{ 
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;
	
	// Semant expressions.
	LeftValue		= ReplaceChild(LeftValue, LeftValue->Semant(semanter));
	IndexExpression = ReplaceChild(IndexExpression, IndexExpression->Semant(semanter));

	// Get expression references.
	CExpressionBaseASTNode* lValueBase    = dynamic_cast<CExpressionBaseASTNode*>(LeftValue);
	CExpressionBaseASTNode* indexExprBase = dynamic_cast<CExpressionBaseASTNode*>(IndexExpression);

	// Cast index to integer.
	IndexExpression = ReplaceChild(indexExprBase, indexExprBase->CastTo(semanter, new CIntDataType(Token), Token));

	// Valid object to index?
	std::vector<CDataType*> argumentTypes;
	argumentTypes.push_back(new CIntDataType(Token));

	CClassASTNode* classNode = lValueBase->ExpressionResultType->GetClass(semanter);
	CClassMemberASTNode* memberNode = classNode->FindClassMethod(semanter, "GetIndex", argumentTypes, true, NULL, NULL);

	if (memberNode == NULL)
	{
		semanter->GetContext()->FatalError("Data type does not support indexing, no GetIndex method defined.", Token);
	}
	// TODO: Remove this restriction.
	else if (memberNode->MangledIdentifier != "GetIndex")
	{
		semanter->GetContext()->FatalError("Indexing using the GetIndex method is only supported on native members.", Token);
	}
	else
	{
		ExpressionResultType = memberNode->ReturnType;
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CIndexExpressionASTNode::Clone(CSemanter* semanter)
{
	CIndexExpressionASTNode* clone = new CIndexExpressionASTNode(NULL, Token);
	
	if (LeftValue != NULL)
	{
		clone->LeftValue = dynamic_cast<CASTNode*>(LeftValue->Clone(semanter));
		clone->AddChild(clone->LeftValue);
	}

	if (IndexExpression != NULL)
	{
		clone->IndexExpression = dynamic_cast<CASTNode*>(IndexExpression->Clone(semanter));
		clone->AddChild(clone->IndexExpression);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CIndexExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateIndexExpression(this);
}