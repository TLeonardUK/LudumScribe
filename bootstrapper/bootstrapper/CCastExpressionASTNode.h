/* *****************************************************************

		CCastExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCASTEXPRESSIONASTNODE_H_
#define _CCASTEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CDataType;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CCastExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	bool		Explicit;	
	bool		ExceptionOnFail;
	CDataType*	Type;
	CASTNode*	RightValue;

	CCastExpressionASTNode(CASTNode* parent, CToken token, bool explicitCast);

	virtual CASTNode* Clone				(CSemanter* semanter);
	virtual CASTNode* Semant			(CSemanter* semanter);	
	
	virtual	EvaluationResult Evaluate	(CTranslationUnit* unit);

	static bool IsValidCast				(CSemanter* semanter, CDataType* from, CDataType* to, bool explicit_cast);	
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif