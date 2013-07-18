/* *****************************************************************

		CCatchStatementASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CCatchStatementASTNode.h"

#include "CVariableStatementASTNode.h"
#include "CDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CClassASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CCatchStatementASTNode::CCatchStatementASTNode(CASTNode* parent, CToken token) :
	CASTNode(parent, token),
	VariableStatement(NULL),
	BodyStatement(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CCatchStatementASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CCatchStatementASTNode");

	if (BodyStatement != NULL)
	{
		BodyStatement = BodyStatement->Semant(semanter);
	}

	// Semant variable.
	VariableStatement->Semant(semanter);

	CDataType* exception_base = FindDataType(semanter, "Exception", std::vector<CDataType*>());
	if (exception_base == NULL ||
		exception_base->GetClass(semanter) == NULL)
	{
		semanter->GetContext()->FatalError("Internal error, could not find base 'Exception' class.");
	}

	CDataType* catch_type = VariableStatement->Type;
	if (catch_type == NULL ||
		catch_type->GetClass(semanter)->InheritsFromClass(semanter, exception_base->GetClass(semanter)) == false)
	{
		semanter->GetContext()->FatalError("Caught exceptions must inherit from 'Exception' class.", Token);
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CCatchStatementASTNode::Clone(CSemanter* semanter)
{
	CCatchStatementASTNode* clone = new CCatchStatementASTNode(NULL, Token);
	
	if (VariableStatement != NULL)
	{
		clone->VariableStatement = dynamic_cast<CVariableStatementASTNode*>(VariableStatement->Clone(semanter));
		clone->AddChild(clone->VariableStatement);
	}
	if (BodyStatement != NULL)
	{
		clone->BodyStatement = dynamic_cast<CASTNode*>(BodyStatement->Clone(semanter));
		clone->AddChild(clone->BodyStatement);
	}

	return clone;
}
