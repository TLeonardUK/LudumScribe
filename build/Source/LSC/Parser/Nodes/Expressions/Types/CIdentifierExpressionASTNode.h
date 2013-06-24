/* *****************************************************************

		CIdentifierExpressionASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CIDENTIFIEREXPRESSIONASTNODE_H_
#define _CIDENTIFIEREXPRESSIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

#include "CVariableStatementASTNode.h"

// =================================================================
//	Stores information on an expression.
// =================================================================
class CIdentifierExpressionASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	CClassMemberASTNode*		ExpressionResultClassMember;
	CVariableStatementASTNode*	ExpressionResultVariable;
	CDeclarationASTNode*		ResolvedDeclaration;
	std::vector<CDataType*>		GenericTypes;

	CIdentifierExpressionASTNode(CASTNode* parent, CToken token);
	
	virtual CASTNode* Clone	(CSemanter* semanter);
	virtual CASTNode* Semant(CSemanter* semanter);
	
	virtual std::string TranslateExpr(CTranslator* translator);
};

#endif