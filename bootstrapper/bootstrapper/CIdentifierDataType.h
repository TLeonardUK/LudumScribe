/* *****************************************************************

		CIdentifierDataType.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CIDENTIFIERDATATYPE_H_
#define _CIDENTIFIERDATATYPE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CDataType.h"

class CSemanter;
class CTranslationUnit;
class CArrayDataType;
class CDataType;
class CClassASTNode;
class CASTNode;

// =================================================================
//	Base class for all data types.
// =================================================================
class CIdentifierDataType : public CDataType
{
protected:
	bool m_do_not_semant_dt;

public:
	std::string				Identifier;
	std::vector<CDataType*>	GenericTypes;

	CIdentifierDataType(CToken& token, std::string identifier, std::vector<CDataType*> genericTypes);
	
	virtual CClassASTNode*	GetClass		(CSemanter* semanter);
	virtual bool			IsEqualTo		(CSemanter* semanter, CDataType* type);
	virtual bool			CanCastTo		(CSemanter* semanter, CDataType* type);
	virtual std::string		ToString		();
	
	virtual CDataType*		Semant			(CSemanter* semanter, CASTNode* node);
	virtual CClassASTNode*	SemantAsClass	(CSemanter* semanter, CASTNode* node, bool do_not_semant = false);

};

#endif