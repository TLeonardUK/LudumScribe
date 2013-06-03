/* *****************************************************************

		CVoidDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CVoidDataType.h"
#include "CArrayDataType.h"

#include "CObjectDataType.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CVoidDataType::CVoidDataType(CToken& token) :
	CDataType(token)
{
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CVoidDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	return dynamic_cast<CVoidDataType*>(type) != NULL;
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CVoidDataType::CanCastTo(CSemanter* semanter, CDataType* type)
{
	return IsEqualTo(semanter, type);
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CVoidDataType::ToString()
{
	return "void";
}
