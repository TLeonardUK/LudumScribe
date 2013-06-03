/* *****************************************************************

		CClassInheritedClassASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCLASSINHERITEDCLASSASTNODE_H_
#define _CCLASSINHERITEDCLASSASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

// =================================================================
//	Stores information on a class's inherted class type.
// =================================================================
class CClassInheritedClassASTNode : public CASTNode
{
protected:	

public:
	CClassInheritedClassASTNode(CASTNode* parent, CToken token);

};

#endif