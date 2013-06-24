/* *****************************************************************

		CBinaryMathExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CBINARYMATHEXPRESSIONASTNODE_H_
#define _CBINARYMATHEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CBinaryMathExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* RightValue;

	CBinaryMathExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate(CTranslationUnit* unit);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif