/* *****************************************************************

		CLiteralExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CLITERALEXPRESSIONASTNODE_H_
#define _CLITERALEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CDataType;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CLiteralExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CDataType*			  Type;
	std::string			  Literal;
	
	CLiteralExpressionASTNode(CASTNode* parent, CToken token, CDataType* type, std::string lit);
	
	virtual CASTNode* Clone					(CSemanter* semanter);
	virtual CASTNode* Semant				(CSemanter* semanter);
	
	virtual	EvaluationResult Evaluate(CTranslationUnit* unit);
	
	virtual std::string TranslateExpr(CTranslator* translator);
};

#endif