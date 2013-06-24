/* *****************************************************************

		CExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CEXPRESSIONASTNODE_H_
#define _CEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	bool		IsConstant;
	CASTNode*	LeftValue;

	CExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone					(CSemanter* semanter);
	virtual CASTNode* Semant				(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate		(CTranslationUnit* unit);
	
	virtual void			Translate		(CTranslator* translator);
	virtual std::string TranslateExpr		(CTranslator* translator);

};

#endif