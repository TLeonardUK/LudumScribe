/* *****************************************************************

		CFieldAccessExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CFIELDACCESSEXPRESSIONASTNODE_H_
#define _CFIELDACCESSEXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CClassMemberASTNode;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CFieldAccessExpressionASTNode : public CExpressionBaseASTNode
{
protected:	
	bool m_isSemantingRightValue;

public:
	CASTNode*				LeftValue;
	CASTNode*				RightValue;
	CClassMemberASTNode*	ExpressionResultClassMember;

	CFieldAccessExpressionASTNode(CASTNode* parent, CToken token);

	virtual CASTNode* Clone									(CSemanter* semanter);
	virtual CASTNode* Semant								(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);

};

#endif