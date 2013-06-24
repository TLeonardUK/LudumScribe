/* *****************************************************************

		CAliasASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CALIASASTNODE_H_
#define _CALIASASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"
#include "CDataType.h"

#include "CDeclarationASTNode.h"

class CClassBodyASTNode;
class CIdentifierDataType;
class CObjectDataType;
class CDataType;
class CASTNode;

// =================================================================
//	Stores information on a alias declaration.
// =================================================================
class CAliasASTNode : public CDeclarationASTNode
{
protected:	

public:
	CDeclarationASTNode* AliasedDeclaration;
	CDataType*			 AliasedDataType;

	// General management.
	virtual std::string ToString();

	CAliasASTNode(CASTNode* parent, CToken token);
	CAliasASTNode(CASTNode* parent, CToken token, std::string identifier, CDeclarationASTNode* decl);
	CAliasASTNode(CASTNode* parent, CToken token, std::string identifier, CDataType* decl);
	
	// Semantic analysis.
	virtual CASTNode* Semant				(CSemanter* semanter);	
	virtual CASTNode* Clone					(CSemanter* semanter);

	virtual void	  Translate				(CTranslator* translator);
};

#endif