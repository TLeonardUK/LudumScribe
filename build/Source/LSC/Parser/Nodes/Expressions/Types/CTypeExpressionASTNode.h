/* *****************************************************************

		CTypeExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTYPEEXPRESSIONASTNODE_H_
#define _CTYPEEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CDataType.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CTypeExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CDataType* Type;
	CASTNode* LeftValue;

	CTypeExpressionASTNode(CASTNode* parent, CToken token);
	
	virtual CASTNode* Clone (CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);
};

#endif