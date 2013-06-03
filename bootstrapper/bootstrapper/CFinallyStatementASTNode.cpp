/* *****************************************************************

		CFinallyStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CFinallyStatementASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CFinallyStatementASTNode::CFinallyStatementASTNode(CASTNode* parent, CToken token) :
	CASTNode(parent, token),
	BodyStatement(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CFinallyStatementASTNode::Semant(CSemanter* semanter)
{ 
	if (BodyStatement != NULL)
	{
		BodyStatement = BodyStatement->Semant(semanter);
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CFinallyStatementASTNode::Clone(CSemanter* semanter)
{
	CFinallyStatementASTNode* clone = new CFinallyStatementASTNode(NULL, Token);
	
	if (BodyStatement != NULL)
	{
		clone->BodyStatement = dynamic_cast<CASTNode*>(BodyStatement->Clone(semanter));
		clone->AddChild(clone->BodyStatement);
	}

	return clone;
}
