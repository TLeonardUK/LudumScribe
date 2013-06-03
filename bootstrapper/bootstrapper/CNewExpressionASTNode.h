/* *****************************************************************

		CNewExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CNEWEXPRESSIONASTNODE_H_
#define _CNEWEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CDataType;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CNewExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CDataType*				DataType;
	bool					IsArray;
	CClassMemberASTNode*	ResolvedConstructor;
	std::vector<CASTNode*>	ArgumentExpressions;

	CNewExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);

	virtual CASTNode* Finalize(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif