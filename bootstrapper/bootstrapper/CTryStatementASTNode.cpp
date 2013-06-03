/* *****************************************************************

		CTryStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CTryStatementASTNode.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CTryStatementASTNode::CTryStatementASTNode(CASTNode* parent, CToken token) :
	CASTNode(parent, token),
	BodyStatement(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CTryStatementASTNode::Semant(CSemanter* semanter)
{ 
	SemantChildren(semanter);
	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CTryStatementASTNode::Clone(CSemanter* semanter)
{
	CTryStatementASTNode* clone = new CTryStatementASTNode(NULL, Token);
	
	if (BodyStatement != NULL)
	{
		clone->BodyStatement = dynamic_cast<CASTNode*>(BodyStatement->Clone(semanter));
		clone->AddChild(clone->BodyStatement);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CTryStatementASTNode::Translate(CTranslator* translator)
{
	translator->TranslateTryStatement(this);
}