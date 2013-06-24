/* *****************************************************************

		CComparisonExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCOMPARISONEXPRESSIONASTNODE_H_
#define _CCOMPARISONEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CComparisonExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* RightValue;
	CDataType* CompareResultType;

	CComparisonExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate(CTranslationUnit* unit);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif