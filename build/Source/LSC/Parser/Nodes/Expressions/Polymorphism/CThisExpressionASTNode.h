/* *****************************************************************

		CThisExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CTHISEXPRESSIONASTNODE_H_
#define _CTHISEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CThisExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CThisExpressionASTNode		(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif