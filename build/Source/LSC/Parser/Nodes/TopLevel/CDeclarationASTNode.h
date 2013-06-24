/* *****************************************************************

		CDeclarationASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CDECLARATIONASTNODE_H_
#define _CDECLARATIONASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"

// =================================================================
//	Base class for all declarations.
// =================================================================
class CDeclarationASTNode : public CASTNode 
{
protected:	

public:
	std::string Identifier;

	std::string MangledIdentifier;
	bool		IsNative;

	CDeclarationASTNode(CASTNode* parent, CToken token);

	// Semanting.
	virtual void CheckAccess(CSemanter* semanter, CASTNode* referenceBy);

};

#endif