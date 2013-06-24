/* *****************************************************************

		CThrowStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTHROWSTATEMENTASTNODE_H_
#define _CTHROWSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionBaseASTNode;

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CThrowStatementASTNode : public CASTNode
{
protected:	

public:
	CExpressionBaseASTNode* Expression;

	CThrowStatementASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual void Translate(CTranslator* translator);

};

#endif