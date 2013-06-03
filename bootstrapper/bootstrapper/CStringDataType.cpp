/* *****************************************************************

		CStringDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CStringDataType.h"
#include "CArrayDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"
#include "CClassASTNode.h"

#include "CObjectDataType.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CStringDataType::CStringDataType(CToken& token) :
	CDataType(token)
{
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CStringDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	return dynamic_cast<CStringDataType*>(type) != NULL;
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CStringDataType::CanCastTo(CSemanter* semanter, CDataType* type)
{
	CObjectDataType* obj = dynamic_cast<CObjectDataType*>(type);

	if (obj != NULL)
	{
		// Can be upcast to anything that its boxed class allows.
		if (type->GetClass(semanter)->Identifier == "object" &&
			GetBoxClass(semanter) != NULL)
		{
			// Look to see if our box-class contains an argument that accepts us.
			CClassASTNode*			node	= GetBoxClass(semanter);
			CClassMemberASTNode*	field 	= node == NULL ? NULL : node->FindClassField(semanter, "Value", NULL, NULL); 
			
			return field != NULL && field->ReturnType->IsEqualTo(semanter, this);
		}
	}
	else
	{
		return IsEqualTo(semanter, type);
	}

	return false;
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CStringDataType::ToString()
{
	return "string";
}

// =================================================================
//	Gets the class this data type is based on.
// =================================================================
CClassASTNode* CStringDataType::GetClass(CSemanter* semanter)
{
	return dynamic_cast<CClassASTNode*>(semanter->GetContext()->GetASTRoot()->FindDeclaration(semanter, "string")->Semant(semanter));
}
