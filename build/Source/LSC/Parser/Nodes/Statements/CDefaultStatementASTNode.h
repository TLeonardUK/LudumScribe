/* *****************************************************************

		CDefaultStatementASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CDEFAULTSTATEMENTASTNODE_H_
#define _CDEFAULTSTATEMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

// =================================================================
//	Stores information on an block statement.
// =================================================================
class CDefaultStatementASTNode : public CASTNode
{
protected:	

public:	
	CASTNode* BodyStatement;

	CDefaultStatementASTNode(CASTNode* parent, CToken token);
	
	virtual CASTNode* Clone(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual CASTNode* FindLoopScope(CSemanter* semanter);

	virtual bool AcceptBreakStatement();

};

#endif