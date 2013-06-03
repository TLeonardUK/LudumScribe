/* *****************************************************************

		CExpressionBaseASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CEXPRESSIONBASEASTNODE_H_
#define _CEXPRESSIONBASEASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

class CDataType;

// =================================================================
//	Base class for all expression operators.
// =================================================================
class CExpressionBaseASTNode : public CASTNode
{
protected:	

public:
	CDataType* ExpressionResultType;

	CExpressionBaseASTNode					(CASTNode* parent, CToken token);

	CASTNode* CastTo						(CSemanter* semanter, CDataType* type, CToken& castToken, bool explicit_cast=false, bool exception_on_fail=true);	
	
	virtual void		Translate			(CTranslator* translator);
	virtual std::string TranslateExpr		(CTranslator* translator) = 0;

};

#endif