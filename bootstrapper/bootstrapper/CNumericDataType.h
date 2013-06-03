/* *****************************************************************

		CNumericDataType.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CNUMERICDATATYPE_H_
#define _CNUMERICDATATYPE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CDataType.h"

class CSemanter;
class CTranslationUnit;
class CArrayDataType;
class CDataType;

// =================================================================
//	Base class for all numeric data types.
// =================================================================
class CNumericDataType : public CDataType
{
protected:

public:
	CNumericDataType(CToken& token);
	
};

#endif