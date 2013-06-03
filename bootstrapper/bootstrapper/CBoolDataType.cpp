/* *****************************************************************

		CBoolDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CBoolDataType.h"
#include "CArrayDataType.h"
#include "CIntDataType.h"
#include "CObjectDataType.h"

#include "CClassASTNode.h"

#include "CTranslationUnit.h"

#include "CSemanter.h"

#include "CClassMemberASTNode.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CBoolDataType::CBoolDataType(CToken& token) :
	CDataType(token)
{
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CBoolDataType::CanCastTo(CSemanter* semanter, CDataType* type)
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
			dynamic_cast<CIntDataType*>(type) != NULL)
		{
			return true;
		}
	}

	return false;
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CBoolDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	return dynamic_cast<CBoolDataType*>(type) != NULL;
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CBoolDataType::ToString()
{
	return "bool";
}

// =================================================================
//	Gets the class this data type is based on.
// =================================================================
CClassASTNode* CBoolDataType::GetClass(CSemanter* semanter)
{
	return dynamic_cast<CClassASTNode*>(semanter->GetContext()->GetASTRoot()->FindDeclaration(semanter, "bool")->Semant(semanter));
}
