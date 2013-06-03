/* *****************************************************************

		CArrayDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CArrayDataType.h"
#include "CStringHelper.h"
#include "CObjectDataType.h"
#include "CNullDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"
#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CArrayDataType::CArrayDataType(CToken& token, CDataType* type) :
	CObjectDataType(token, NULL)
{
	ElementType	   = type;
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CArrayDataType::CanCastTo(CSemanter* semanter, CDataType* type)
{
	CObjectDataType* obj = dynamic_cast<CObjectDataType*>(type);
	CArrayDataType* arr = dynamic_cast<CArrayDataType*>(type);

	if (IsEqualTo(semanter, type) == true)
	{
		return true;
	}

	if (obj != NULL && obj->GetClass(semanter)->Identifier == "object")
	{
		return true;
	}

	return false;
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CArrayDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{	
	CArrayDataType* dt = dynamic_cast<CArrayDataType*>(type);
	CNullDataType* otherNull = dynamic_cast<CNullDataType*>(type);
	if (otherNull != NULL)
	{
		return true;
	}
	return	dt != NULL && 
			dt->ElementType->IsEqualTo(semanter, ElementType);
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CArrayDataType::ToString()
{
	return ElementType->ToString() + "[]";
}

// =================================================================
//	Returns data type thats an array of this data type.
// =================================================================
CArrayDataType* CArrayDataType::ArrayOf()
{
	if (m_array_of_datatype == NULL)
	{
		m_array_of_datatype = new CArrayDataType(Token, this);
	}
	return m_array_of_datatype;
}

// =================================================================
//	Gets the class this data type is based on.
// =================================================================
CClassASTNode* CArrayDataType::GetClass(CSemanter* semanter)
{
	std::vector<CDataType*> args;
	args.push_back(ElementType);

	CDataType* type = semanter->GetContext()->GetASTRoot()->FindDataType(semanter, "array", args, true);
	return dynamic_cast<CClassASTNode*>(type->GetClass(semanter));
}

// =================================================================
//	Gets the class that this data type can be boxed into.
// =================================================================
CClassASTNode* CArrayDataType::GetBoxClass(CSemanter* semanter)
{	
	return NULL;
}

// =================================================================
//	Performs semantic analysis of this data type.
// =================================================================
CDataType* CArrayDataType::Semant(CSemanter* semanter, CASTNode* node)
{	
	CDataType* dt = ElementType->Semant(semanter, node)->ArrayOf();
	dt->GetClass(semanter); // Initialises generic instances if neccessary.
	return dt;
}
