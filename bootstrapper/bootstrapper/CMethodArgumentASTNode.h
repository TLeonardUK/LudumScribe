/* *****************************************************************

		CMethodArgumentASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CMETHODARGUMENTASTNODE_H_
#define _CMETHODARGUMENTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

#include "CDataType.h"

#include "CDeclarationASTNode.h"

// =================================================================
//	Stores information on a single argument in a method.
// =================================================================
class CMethodArgumentASTNode : public CDeclarationASTNode
{
protected:	

public:
	CDataType*	Type;

	CMethodArgumentASTNode(CASTNode* parent, CToken token);
		
	virtual std::string ToString	();
	
	virtual CASTNode*	Semant		(CSemanter* semanter);
	virtual CASTNode*	Clone		(CSemanter* semanter);

};

#endif