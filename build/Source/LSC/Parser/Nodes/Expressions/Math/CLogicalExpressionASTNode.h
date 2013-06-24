/* *****************************************************************

		CLogicalExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CLOGICALEXPRESSIONASTNODE_H_
#define _CLOGICALEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CLogicalExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* RightValue;

	CLogicalExpressionASTNode(CASTNode* parent, CToken token);
	
	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate(CTranslationUnit* unit);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif