/* *****************************************************************

		CVariableStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CVariableStatementASTNode.h"
#include "CDataType.h"
#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CCollectionHelper.h"
#include "CStringHelper.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CVariableStatementASTNode::CVariableStatementASTNode(CASTNode* parent, CToken token) :
	CDeclarationASTNode(parent, token),
	AssignmentExpression(NULL),
	Type(NULL)
{
}

// =================================================================
//	Converts this node to a string representation.
// =================================================================
std::string CVariableStatementASTNode::ToString()
{
	std::string val = Type->ToString();

	val += " " + Identifier;

	return val;
}

// =================================================================
//	Checks if we can access this declaration from the given node.
// =================================================================
void CVariableStatementASTNode::CheckAccess(CSemanter* semanter, CASTNode* referenceBy)
{
	// Find which statement reference belongs to on the same level as variable declaration.
	CASTNode* referenceParent = referenceBy;
	while (referenceParent != NULL &&
		   referenceParent->Parent != Parent)
	{
		referenceParent = referenceParent->Parent;
	}

	// Check we have accessed variable after its defined.
	if (referenceParent != NULL)
	{
		int define_index    = CCollectionHelper::VectorIndexOf<CASTNode*>(Parent->Children, this);
		int reference_index = CCollectionHelper::VectorIndexOf<CASTNode*>(Parent->Children, referenceParent);
		
		if (reference_index <= define_index)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Attempt to access variable '%s' before it is declared.", Identifier.c_str()), referenceBy->Token);	
		}
	}
}

// =================================================================
// Performs semantic analysis of this node.
// =================================================================
CASTNode* CVariableStatementASTNode::Semant(CSemanter* semanter)
{	
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;
	
	// Work out mangled identifier.
	if (MangledIdentifier == "")
	{
		MangledIdentifier = semanter->GetMangled("ls_local_" + Identifier);
	}

	// Semant the type/return type of this member.
	Type = Type->Semant(semanter, this);

	// Default assignment?
	if (AssignmentExpression == NULL)
	{
		AssignmentExpression = semanter->ConstructDefaultAssignmentExpr(this, Token, Type);
	}

	// Check for duplicate identifiers.
	CheckForDuplicateIdentifier(semanter, Identifier);

	// Semant the assignment.
	if (AssignmentExpression != NULL)
	{
		AssignmentExpression = dynamic_cast<CExpressionBaseASTNode*>(ReplaceChild(AssignmentExpression, AssignmentExpression->Semant(semanter)));
		AssignmentExpression = dynamic_cast<CExpressionBaseASTNode*>(ReplaceChild(AssignmentExpression, AssignmentExpression->CastTo(semanter, Type, Token)));
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CVariableStatementASTNode::Clone(CSemanter* semanter)
{
	CVariableStatementASTNode* clone = new CVariableStatementASTNode(NULL, Token);
	clone->Type = this->Type;
	clone->Identifier = this->Identifier;
	clone->IsNative = this->IsNative;
	clone->MangledIdentifier = this->MangledIdentifier;

	if (AssignmentExpression != NULL)
	{
		clone->AssignmentExpression = dynamic_cast<CExpressionASTNode*>(AssignmentExpression->Clone(semanter));
		clone->AddChild(clone->AssignmentExpression);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CVariableStatementASTNode::Translate(CTranslator* translator)
{
	translator->TranslateVariableStatement(this);
}