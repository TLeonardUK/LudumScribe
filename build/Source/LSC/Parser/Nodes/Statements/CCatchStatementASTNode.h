/* *****************************************************************

		CCatchStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCATCHSTATEMENTASTNODE_H_
#define _CCATCHSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionASTNode;
class CVariableStatementASTNode;

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CCatchStatementASTNode : public CASTNode
{
protected:	

public:
	CVariableStatementASTNode* VariableStatement;
	CASTNode* BodyStatement;

	CCatchStatementASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

};

#endif