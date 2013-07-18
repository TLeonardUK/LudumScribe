/* *****************************************************************

		CObjectDataType.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CObjectDataType.h"
#include "CArrayDataType.h"

#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"

#include "CBoolDataType.h"
#include "CIntDataType.h"
#include "CFloatDataType.h"
#include "CStringDataType.h"
#include "CNullDataType.h"

#include "CTranslationUnit.h"

#include "CSemanter.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CObjectDataType::CObjectDataType(CToken& token, CClassASTNode* classNode) :
	CDataType(token),
	m_class(classNode)
{
}

// =================================================================
//	Checks if this data type is equal to another.
// =================================================================
bool CObjectDataType::IsEqualTo(CSemanter* semanter, CDataType* type)
{
	CObjectDataType* other = dynamic_cast<CObjectDataType*>(type);
	CNullDataType* otherNull = dynamic_cast<CNullDataType*>(type);
	if (otherNull != NULL)
	{
		return true;
	}
	return other != NULL && other->GetClass(semanter) == GetClass(semanter);
}

// =================================================================
//	Checks if this data type extends another.
// =================================================================
bool CObjectDataType::CanCastTo(CSemanter* semanter, CDataType* type)
{
	CObjectDataType* obj = dynamic_cast<CObjectDataType*>(type);
	
	if (obj != NULL)
	{
		return m_class->InheritsFromClass(semanter, obj->GetClass(semanter));
	}
	else
	{
		// Check to see if the type could have been boxed, and if its boxed class
		// allows us to convert to whatever we are converting to.
		// Object can be upcast to anything that its boxed class allows.
		if (m_class->Identifier == "object" &&
			type->GetBoxClass(semanter) != NULL)
		{
			// Look to see if our box-class contains an argument that accepts us.
			CClassASTNode*			node	= type->GetBoxClass(semanter);
			CClassMemberASTNode*	field 	= node == NULL ? NULL : node->FindClassField(semanter, "Value", NULL, NULL); 

			return field != NULL && field->ReturnType->IsEqualTo(semanter, type);
		}
	}

	return false;
}

// =================================================================
//	Converts data type to string.
// =================================================================
std::string	CObjectDataType::ToString()
{
	return m_class->ToString();
}

// =================================================================
//	Gets the class this data type is based on.
// =================================================================
CClassASTNode* CObjectDataType::GetClass(CSemanter* semanter)
{
	return m_class;
}

// =================================================================
//	Semants this data type and returns its output type.
// =================================================================
CDataType* CObjectDataType::Semant(CSemanter* semanter, CASTNode* node)
{
	SEMANT_TRACE("CObjectDataType");

	if (m_class->IsEnum == true)
	{
		return new CIntDataType(Token);
	}
	else
	{
		return this;
	}
}

// =================================================================
//	Semants this data type and returns a class reference.
// =================================================================
CClassASTNode* CObjectDataType::SemantAsClass(CSemanter* semanter, CASTNode* node)
{
	CObjectDataType* type = dynamic_cast<CObjectDataType*>(Semant(semanter, node));
	if (type != NULL)
	{
		return type->GetClass(semanter);
	}
	else
	{
		semanter->GetContext()->FatalError("Identifier does not reference a class or interface.", Token);
	}
	return NULL;
}