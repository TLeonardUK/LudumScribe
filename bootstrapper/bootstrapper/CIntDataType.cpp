/* *****************************************************************

		CIntDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CIntDataType.h"
#include "CArrayDataType.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"
#include "CClassASTNode.h"

#include "CObjectDataType.h"
#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CIntDataType::CIntDataType(CToken& token) :
	CNumericDataType(token)
{
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CIntDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	return dynamic_cast<CIntDataType*>(type) != NULL;
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CIntDataType::CanCastTo(CSemanter* semanter, CDataType* type)
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
		if (IsEqualTo(semanter, type) ||
			dynamic_cast<CNumericDataType*>(type) != NULL)
		{
			return true;
		}
	}

	return false;
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CIntDataType::ToString()
{
	return "int";
}

// =================================================================
//	Gets the class this data type is based on.
// =================================================================
CClassASTNode* CIntDataType::GetClass(CSemanter* semanter)
{
	return dynamic_cast<CClassASTNode*>(semanter->GetContext()->GetASTRoot()->FindDeclaration(semanter, "int")->Semant(semanter));
}

