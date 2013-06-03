/* *****************************************************************

		CNullDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CNullDataType.h"
#include "CArrayDataType.h"

#include "CObjectDataType.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CNullDataType::CNullDataType(CToken& token) :
	CDataType(token)
{
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CNullDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	return dynamic_cast<CNullDataType*>(type)	!= NULL ||
		   dynamic_cast<CObjectDataType*>(type) != NULL ||
		   dynamic_cast<CArrayDataType*>(type) != NULL;
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CNullDataType::CanCastTo(CSemanter* semanter, CDataType* type)
{
	return IsEqualTo(semanter, type);
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CNullDataType::ToString()
{
	return "null";
}
