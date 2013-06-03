/* *****************************************************************

		CAliasASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CStringHelper.h"

#include "CAliasASTNode.h"
#include "CIdentifierDataType.h"
#include "CTranslationUnit.h"
#include "CDeclarationASTNode.h"
#include "CObjectDataType.h"
#include "CPackageASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CAliasASTNode::CAliasASTNode(CASTNode* parent, CToken token, std::string identifier, CDeclarationASTNode* decl) :
	CDeclarationASTNode(parent, token)
{
	Identifier  = identifier;
	AliasedDeclaration = decl;
	AliasedDataType = NULL;
}

CAliasASTNode::CAliasASTNode(CASTNode* parent, CToken token, std::string identifier, CDataType* decl) :
	CDeclarationASTNode(parent, token)
{
	Identifier  = identifier;
	AliasedDeclaration = NULL;
	AliasedDataType = decl;
}

CAliasASTNode::CAliasASTNode(CASTNode* parent, CToken token) :
	CDeclarationASTNode(parent, token)
{
	AliasedDeclaration = NULL;
	AliasedDataType = NULL;
}

// =================================================================
//	Converts this node to a string representation.
// =================================================================
std::string CAliasASTNode::ToString()
{
	return Identifier;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CAliasASTNode::Semant(CSemanter* semanter)
{ 
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Check alias identifier is unique.	
	CheckForDuplicateIdentifier(semanter, Identifier);

	// Semant the aliased node.
	if (AliasedDeclaration != NULL)
	{
		AliasedDeclaration->Semant(semanter);
	}	
	if (AliasedDataType != NULL)
	{
		AliasedDataType->Semant(semanter, this);
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CAliasASTNode::Clone(CSemanter* semanter)
{
	CAliasASTNode* clone = new CAliasASTNode(NULL, Token);
	
	clone->Identifier		  = this->Identifier;
	clone->IsNative			  = this->IsNative;

	clone->AliasedDataType	  = this->AliasedDataType;

	if (clone->AliasedDeclaration != NULL)
	{
		clone->AliasedDeclaration = dynamic_cast<CDeclarationASTNode*>(this->AliasedDeclaration->Clone(semanter));
		clone->AddChild(clone->AliasedDeclaration);
	}	

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CAliasASTNode::Translate(CTranslator* translator)
{
	// Alias is purely semantic, we can ignore it for translations.
}