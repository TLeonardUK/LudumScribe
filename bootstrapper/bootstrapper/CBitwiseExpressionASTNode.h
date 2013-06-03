/* *****************************************************************

		CBitwiseExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CBITWISEEXPRESSIONASTNODE_H_
#define _CBITWISEEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CBitwiseExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* RightValue;

	CBitwiseExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone					(CSemanter* semanter);

};

#endif