/* *****************************************************************

		CIfStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CIFSTATEMENTASTNODE_H_
#define _CIFSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionBaseASTNode;

// =================================================================
//	Stores information on an if statement.
// =================================================================
class CIfStatementASTNode : public CASTNode
{
protected:	

public:
	CExpressionBaseASTNode* ExpressionStatement;
	CASTNode* BodyStatement;
	CASTNode* ElseStatement;

	CIfStatementASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual void Translate(CTranslator* translator);

};

#endif