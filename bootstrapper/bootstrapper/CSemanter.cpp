/* *****************************************************************

		CSemanter.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <string>
#include <stdio.h>
#include <assert.h>

#include "CCompiler.h"
#include "CSemanter.h"
#include "CStringHelper.h"
#include "CPathHelper.h"

#include "CASTNode.h"
#include "CDeclarationASTNode.h"
#include "CTranslationUnit.h"
#include "CClassASTNode.h"
#include "CPackageASTNode.h"
#include "CAliasASTNode.h"
#include "CClassMemberASTNode.h"
#include "CLiteralExpressionASTNode.h"
#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CDataType.h"
#include "CObjectDataType.h"
#include "CStringDataType.h"
#include "CIntDataType.h"
#include "CFloatDataType.h"
#include "CNullDataType.h"
#include "CBoolDataType.h"

// =================================================================
//	Processes input and performs the actions requested.
// =================================================================
bool CSemanter::Process(CTranslationUnit* context)
{	
	m_context = context;
	m_internal_var_counter = 0;
	
	//context->Info("Semantic Analysis ...");
//	context->GetASTRoot()->Prepare(this);

	//context->Info("Semantic Analysis ...");
	context->GetASTRoot()->Semant(this);

	//context->Info("Semantic Finalization ...");
	context->GetASTRoot()->Finalize(this);

	return true;
}

// =================================================================
//	Gets a new internal variable name.
// =================================================================
std::string CSemanter::NewInternalVariableName()
{
	return "lsInternal_s__" + CStringHelper::ToString(m_internal_var_counter++);
}

// =================================================================
//	Constructs a default assignment expression that can be applyed
//	to a variable to initialize it if an initialization expression
//	is not provided.
// =================================================================	
CExpressionASTNode*	CSemanter::ConstructDefaultAssignmentExpr(CASTNode* parent, CToken& token, CDataType* type)
{
	CLiteralExpressionASTNode* lit = NULL;
	if (dynamic_cast<CBoolDataType*>(type) != NULL)
	{
		lit =  new CLiteralExpressionASTNode(NULL, token, type, "false");
	}
	else if (dynamic_cast<CIntDataType*>(type) != NULL)
	{
		lit =  new CLiteralExpressionASTNode(NULL, token, type, "0");
	}
	else if (dynamic_cast<CFloatDataType*>(type) != NULL)
	{
		lit =  new CLiteralExpressionASTNode(NULL, token, type, "0.0");
	}
	else if (dynamic_cast<CStringDataType*>(type) != NULL)
	{
		lit =  new CLiteralExpressionASTNode(NULL, token, type, "");
	}
	else
	{
		lit =  new CLiteralExpressionASTNode(NULL, token, new CNullDataType(token), "");
	}

	CExpressionASTNode* expr = new CExpressionASTNode(parent, token);
	expr->LeftValue = lit;
	expr->AddChild(lit);

	return expr;
}

// =================================================================
//	Gets a unique mangled identifier.
// =================================================================
std::string	CSemanter::GetMangled(std::string mangled)
{
	std::string originalMangled = mangled;

	int index = 1;
	while (true)
	{
		bool found = false;

		for (auto iter = m_mangled.begin(); iter != m_mangled.end(); iter++)
		{
			if (*iter == mangled)
			{
				mangled = originalMangled + "_" + CStringHelper::ToString(index++);
				found = true;
				break;
			}
		}

		if (found == false)
		{
			break;
		}
	}
	m_mangled.push_back(mangled);
	
	return mangled;
}

// =================================================================
//	Gets the context we are semanting for.
// =================================================================
CTranslationUnit* CSemanter::GetContext()
{
	return m_context;
}

// =================================================================
//	Check for duplicate identifiers.
// =================================================================
CDataType* CSemanter::BalanceDataTypes(CDataType* lvalue, CDataType* rvalue)
{
	// If either are string result is string.
	if (dynamic_cast<CStringDataType*>(lvalue) != NULL) 
	{
		return lvalue;	
	}
	if (dynamic_cast<CStringDataType*>(rvalue) != NULL) 
	{
		return rvalue;	
	}

	// If either are float result is float.
	if (dynamic_cast<CFloatDataType*>(lvalue) != NULL) 
	{
		return lvalue;	
	}
	if (dynamic_cast<CFloatDataType*>(rvalue) != NULL) 
	{
		return rvalue;	
	}

	// If either are int result is int.
	if (dynamic_cast<CIntDataType*>(lvalue) != NULL) 
	{
		return lvalue;	
	}
	if (dynamic_cast<CIntDataType*>(rvalue) != NULL) 
	{
		return rvalue;	
	}

//	LVALUE = CASTNode
//	RVALUE = CAliasASTNode

	// Check which values we can cast too.
	if (rvalue->CanCastTo(this, lvalue))
	{
		return lvalue;
	}
	if (lvalue->CanCastTo(this, rvalue))
	{
		return rvalue;
	}

	// o_o
	m_context->FatalError(CStringHelper::FormatString("Unable to implicitly convert between data-types '%s' and '%s'", lvalue->ToString().c_str(), rvalue->ToString().c_str()), lvalue->Token);

	return NULL;
}