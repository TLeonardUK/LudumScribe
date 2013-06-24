/* *****************************************************************

		CReturnStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CRETURNSTATEMENTASTNODE_H_
#define _CRETURNSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CReturnStatementASTNode : public CASTNode
{
protected:	

public:
	CExpressionBaseASTNode*	ReturnExpression;

	CReturnStatementASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual void Translate(CTranslator* translator);

};

#endif