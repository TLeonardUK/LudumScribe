/* *****************************************************************

		CMethodArgumentListASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CMETHODARGUMENTLISTASTNODE_H_
#define _CMETHODARGUMENTLISTASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

// =================================================================
//	Stores information on a list of arguments in a method. 
// =================================================================
class CMethodArgumentListASTNode : public CASTNode
{
protected:	

public:
	CMethodArgumentListASTNode(CASTNode* parent, CToken token);

};

#endif