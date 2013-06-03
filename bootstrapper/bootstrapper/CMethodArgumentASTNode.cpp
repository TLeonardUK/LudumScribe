/* *****************************************************************

		CMethodArgumentASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CMethodArgumentASTNode.h"

#include "CSemanter.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CMethodArgumentASTNode::CMethodArgumentASTNode(CASTNode* parent, CToken token) :
	CDeclarationASTNode(parent, token),
	Type(NULL)
{
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CMethodArgumentASTNode::Clone(CSemanter* semanter)
{
	CMethodArgumentASTNode* clone = new CMethodArgumentASTNode(NULL, Token);
	clone->Identifier = this->Identifier;
	clone->IsNative	  = this->IsNative;
	clone->Type		  = this->Type;

	return clone;
}

// =================================================================
//	Converts this node to a string representation.
// =================================================================
std::string CMethodArgumentASTNode::ToString()
{
	return Type->ToString() + " " + Identifier;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CMethodArgumentASTNode::Semant(CSemanter* semanter)
{
	// Only semant once.
	if (Semanted == true)
	{
		return this;
	}
	Semanted = true;

	// Semant the return type.
	Type = Type->Semant(semanter, this);

	// Check for duplicate identifiers.	
	CheckForDuplicateIdentifier(semanter, Identifier);

	return this;
}
