/* *****************************************************************

		CFieldAccessExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CFieldAccessExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CClassASTNode.h"
#include "CIdentifierExpressionASTNode.h"

#include "CDataType.h"
#include "CClassReferenceDataType.h"

#include "CClassMemberASTNode.h"

#include "CThisExpressionASTNode.h"
#include "CClassRefExpressionASTNode.h"

#include "CTranslationUnit.h"
#include "CSemanter.h"

#include "CStringHelper.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CFieldAccessExpressionASTNode::CFieldAccessExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token),
	LeftValue(NULL),
	RightValue(NULL),
	ExpressionResultClassMember(NULL),
	m_isSemantingRightValue(false)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CFieldAccessExpressionASTNode::Semant(CSemanter* semanter)
{ 
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Get expression representations.
	CExpressionBaseASTNode* left_hand_expr	 = dynamic_cast<CExpressionBaseASTNode*>(LeftValue);
	CExpressionBaseASTNode* right_hand_expr  = dynamic_cast<CExpressionBaseASTNode*>(RightValue);

	// Semant left hand node.
	LeftValue  = ReplaceChild(LeftValue,   LeftValue->Semant(semanter));
	
	// Make sure we can access class.
	CClassASTNode* accessClass = left_hand_expr->ExpressionResultType->GetClass(semanter);
	if (accessClass == NULL)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("Invalid use of scoping operator."), Token);		
	}

	// Check we can access this class from here.
	accessClass->CheckAccess(semanter, this);

	// NOTE: Do not r-value semant identifier, we want to process that ourselves.
	CIdentifierExpressionASTNode* identNode = dynamic_cast<CIdentifierExpressionASTNode*>(RightValue);

	// Make sure the identifier represents a valid field.
	CClassMemberASTNode* declaration = accessClass->FindClassField(semanter, identNode->Token.Literal, NULL, this);
	if (declaration == NULL)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("Undefined field '%s' in class '%s'.", identNode->Token.Literal.c_str(), accessClass->ToString().c_str()), Token);		
	}
	identNode->ResolvedDeclaration = declaration;
	
	// Check we can access this field from here.
	declaration->CheckAccess(semanter, this);
	
	// HACK: This is really hackish and needs fixing!
	if (dynamic_cast<CThisExpressionASTNode*>(LeftValue) != NULL &&
		declaration->IsStatic == true)
	{		
		LeftValue = ReplaceChild(LeftValue, new CClassRefExpressionASTNode(NULL, Token));
		LeftValue->Token.Literal = declaration->FindClassScope(semanter)->Identifier;
		LeftValue->Semant(semanter);

		left_hand_expr	 = dynamic_cast<CExpressionBaseASTNode*>(LeftValue);
	}

	// If we are a class reference, we can only access static fields.
	bool isClassReference = (dynamic_cast<CClassReferenceDataType*>(left_hand_expr->ExpressionResultType) != NULL);
	if (isClassReference == true)
	{
		if (declaration->IsStatic == false)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot access instance field '%s' through class reference '%s'.", declaration->Identifier.c_str(), accessClass->ToString().c_str()), Token);	
		}
	}

	// Resulting type is always our right hand type.
	ExpressionResultClassMember	 = declaration;
	ExpressionResultType		 = declaration->ReturnType;
	
	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CFieldAccessExpressionASTNode::Clone(CSemanter* semanter)
{
	CFieldAccessExpressionASTNode* clone = new CFieldAccessExpressionASTNode(NULL, Token);

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
//	Causes this node to be translated.
// =================================================================
std::string CFieldAccessExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateFieldAccessExpression(this);
}