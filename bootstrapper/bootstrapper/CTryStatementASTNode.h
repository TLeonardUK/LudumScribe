/* *****************************************************************

		CTryStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTRYSTATEMENTASTNODE_H_
#define _CTRYSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CTryStatementASTNode : public CASTNode
{
protected:	

public:
	CASTNode* BodyStatement;

	CTryStatementASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual void Translate(CTranslator* translator);

};

#endif