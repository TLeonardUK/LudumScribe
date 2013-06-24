/* *****************************************************************

		CPostFixExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CPOSTFIXEXPRESSIONASTNODE_H_
#define _CPOSTFIXEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CPostFixExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;

	CPostFixExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate(CTranslationUnit* unit);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif