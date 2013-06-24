/* *****************************************************************

		CAssignmentExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CASSIGNMENTEXPRESSIONASTNODE_H_
#define _CASSIGNMENTEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CExpressionASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CAssignmentExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CASTNode* LeftValue;
	CASTNode* RightValue;
	bool IgnoreConst;

	CAssignmentExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif