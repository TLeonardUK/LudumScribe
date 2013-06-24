/* *****************************************************************

		CArrayInitializerASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CARRAYINITIALIZERASTNODE_H_
#define _CARRAYINITIALIZERASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CExpressionBaseASTNode.h"

class CDataType;

// =================================================================
//	Stores information on an expression.
// =================================================================
class CArrayInitializerASTNode : public CExpressionBaseASTNode
{
protected:	

public:
	std::vector<CASTNode*> Expressions;

	CArrayInitializerASTNode				(CASTNode* parent, CToken token);

	virtual CASTNode*		Clone			(CSemanter* semanter);
	virtual CASTNode*		Semant			(CSemanter* semanter);	
	
	virtual std::string		TranslateExpr	(CTranslator* translator);

};

#endif