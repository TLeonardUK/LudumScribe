/* *****************************************************************

		CMethodCallExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CMETHODCALLEXPRESSIONASTNODE_H_
#define _CMETHODCALLEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CMethodCallExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	std::vector<CASTNode*> ArgumentExpressions;
	CASTNode* RightValue;
	CASTNode* LeftValue;
	CDeclarationASTNode* ResolvedDeclaration;

	CMethodCallExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone		(CSemanter* semanter);
	virtual CASTNode* Semant	(CSemanter* semanter);	
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif