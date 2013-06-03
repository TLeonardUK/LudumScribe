/* *****************************************************************

		CMethodCallExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CMethodCallExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CClassASTNode.h"
#include "CIdentifierExpressionASTNode.h"
#include "CExpressionASTNode.h"

#include "CDataType.h"
#include "CClassReferenceDataType.h"

#include "CVariableStatementASTNode.h"
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
CMethodCallExpressionASTNode::CMethodCallExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token),
	LeftValue(NULL),
	RightValue(NULL),
	ResolvedDeclaration(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CMethodCallExpressionASTNode::Semant(CSemanter* semanter)
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

	// Semant arguments.
	std::vector<CDataType*> argument_types;
	std::string argument_types_string;
	for (auto iter = ArgumentExpressions.begin(); iter < ArgumentExpressions.end(); iter++)
	{
		CExpressionBaseASTNode* node = dynamic_cast<CExpressionBaseASTNode*>((*iter)->Semant(semanter));
		argument_types.push_back(node->ExpressionResultType);

		if (iter != ArgumentExpressions.begin())
		{
			argument_types_string += ", ";
		}
		argument_types_string += node->ExpressionResultType->ToString();

		(*iter) = node;
	}

	// Make sure the identifier represents a valid field.
	CClassMemberASTNode* declaration = accessClass->FindClassMethod(semanter, identNode->Token.Literal, argument_types, false, NULL, this);
	if (declaration == NULL)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("Undefined method '%s(%s)' in class '%s'.", identNode->Token.Literal.c_str(), argument_types_string.c_str(), accessClass->ToString().c_str()), Token);		
	}
	if (declaration->IsAbstract == true)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot call method '%s(%s)' in class '%s', method is abstract.", identNode->Token.Literal.c_str(), argument_types_string.c_str(), accessClass->ToString().c_str()), Token);		
	}
	
	ResolvedDeclaration = declaration;

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

	// Add default arguments if we do not have enough args to call.
	if (declaration->Arguments.size() > ArgumentExpressions.size())
	{
		for (unsigned int i = ArgumentExpressions.size(); i < declaration->Arguments.size() ; i++)
		{
			CASTNode* expr = declaration->Arguments.at(i)->AssignmentExpression->Clone(semanter);
			AddChild(expr);
			ArgumentExpressions.push_back(expr);

			expr->Semant(semanter);
		}
	}
	
	// Cast all arguments to correct data types.
	int index = 0;
	for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
	{
		CDataType* dataType = declaration->Arguments.at(index++)->Type;

		CExpressionBaseASTNode* subnode = dynamic_cast<CExpressionBaseASTNode*>(*iter);
		subnode = dynamic_cast<CExpressionBaseASTNode*>(subnode->CastTo(semanter, dataType, Token));
		(*iter) = subnode;
	}

	// If we are a class reference, we can only access static fields.
	bool isClassReference = (dynamic_cast<CClassReferenceDataType*>(left_hand_expr->ExpressionResultType) != NULL);
	if (isClassReference == true)
	{
		if (declaration->IsStatic == false)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot access instance method '%s' through class reference '%s'.", declaration->Identifier.c_str(), accessClass->ToString().c_str()), Token);	
		}
	}

	// If this is a constructor we are calling, make sure we are in a constructors scope, or its illegal!
	else
	{
		CClassMemberASTNode* methodScope = FindClassMethodScope(semanter);

		if (methodScope == NULL ||
			methodScope->IsConstructor == false)
		{
			if (declaration->IsConstructor == true)
			{
				semanter->GetContext()->FatalError("Calling constructors manually is only valid inside another constructors scope.", Token);	
			}
		}
	}

	// Resulting type is always our right hand type.
	ExpressionResultType = declaration->ReturnType;

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CMethodCallExpressionASTNode::Clone(CSemanter* semanter)
{
	CMethodCallExpressionASTNode* clone = new CMethodCallExpressionASTNode(NULL, Token);

	for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
	{
		CASTNode* node = (*iter)->Clone(semanter);
		clone->ArgumentExpressions.push_back(node);
		clone->AddChild(node);
	}
	
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
std::string CMethodCallExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateMethodCallExpression(this);
}