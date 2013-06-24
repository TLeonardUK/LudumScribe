/* *****************************************************************

		CIndexExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CINDEXEXPRESSIONASTNODE_H_
#define _CINDEXEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CIndexExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* IndexExpression;

	CIndexExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);
};

#endif