/* *****************************************************************

		CTernaryExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTERNARYEXPRESSIONASTNODE_H_
#define _CTERNARYEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CTernaryExpressionASTNode : public CExpressionBaseASTNode
{
protected:	
public:
	CASTNode* Expression;
	CASTNode* LeftValue;
	CASTNode* RightValue;

	CTernaryExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif