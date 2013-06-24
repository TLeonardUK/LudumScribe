/* *****************************************************************

		CIntDataType.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CINTDATATYPE_H_
#define _CINTDATATYPE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CDataType.h"
#include "CNumericDataType.h"

class CSemanter;
class CTranslationUnit;
class CArrayDataType;
class CDataType;

// =================================================================
//	Base class for all data types.
// =================================================================
class CIntDataType : public CNumericDataType
{
protected:

public:
	CIntDataType(CToken& token);
	
	virtual CClassASTNode*	GetClass	(CSemanter* semanter);
	virtual bool			IsEqualTo	(CSemanter* semanter, CDataType* type);
	virtual bool			CanCastTo	(CSemanter* semanter, CDataType* type);
	virtual std::string		ToString	();

};

#endif