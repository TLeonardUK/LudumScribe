/* *****************************************************************

		CFinallyStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CFINALLYSTATEMENTASTNODE_H_
#define _CFINALLYSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CFinallyStatementASTNode : public CASTNode
{
protected:	

public:
	CASTNode* BodyStatement;

	CFinallyStatementASTNode(CASTNode* parent, CToken token);
	
	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);


};

#endif