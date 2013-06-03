/* *****************************************************************

		CObjectDataType.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _COBJECTDATATYPE_H_
#define _COBJECTDATATYPE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CDataType.h"

class CSemanter;
class CTranslationUnit;
class CArrayDataType;
class CDataType;

// =================================================================
//	Base class for all data types.
// =================================================================
class CObjectDataType : public CDataType
{
protected:
	CClassASTNode* m_class;

public:

	CObjectDataType(CToken& token, CClassASTNode* classNode);
	
	virtual CClassASTNode*	GetClass	(CSemanter* semanter);
	virtual bool			IsEqualTo	(CSemanter* semanter, CDataType* type);
	virtual bool			CanCastTo	(CSemanter* semanter, CDataType* type);
	virtual std::string		ToString	();

};

#endif