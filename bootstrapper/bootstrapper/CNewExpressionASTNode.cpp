/* *****************************************************************

		CNewExpressionASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CNewExpressionASTNode.h"

#include "CDataType.h"
#include "CArrayDataType.h"
#include "CObjectDataType.h"
#include "CIntDataType.h"

#include "CClassASTNode.h"
#include "CClassMemberASTNode.h"
#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"
#include "CVariableStatementASTNode.h"
#include "CArrayInitializerASTNode.h"

#include "CSemanter.h"
#include "CTranslationUnit.h"

#include "CStringHelper.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CNewExpressionASTNode::CNewExpressionASTNode(CASTNode* parent, CToken token) :
	CExpressionBaseASTNode(parent, token),
	DataType(NULL),
	IsArray(false),
	ResolvedConstructor(NULL),
	ArrayInitializer(NULL)
{
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CNewExpressionASTNode::Semant(CSemanter* semanter)
{
	SEMANT_TRACE("CNewExpressionASTNode");

	// Semant data types.
	DataType = DataType->Semant(semanter, this);

	// Semant arguments.
	std::vector<CDataType*> argument_datatypes;
	for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
	{
		CExpressionBaseASTNode* node = dynamic_cast<CExpressionBaseASTNode*>(*iter);
		node = dynamic_cast<CExpressionBaseASTNode*>(node->Semant(semanter));
		argument_datatypes.push_back(node->ExpressionResultType);
		(*iter) = node;
	}

	// Semant array initializer.
	if (ArrayInitializer != NULL)
	{
		ArrayInitializer->Semant(semanter);
	}

	// Create new array of objects.
	if (IsArray == true)
	{
		// Cast all arguments to correct data types.
		int index = 0;
		for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
		{
			CExpressionBaseASTNode* subnode = dynamic_cast<CExpressionBaseASTNode*>(*iter);
			subnode->Parent->ReplaceChild(subnode, subnode = dynamic_cast<CExpressionBaseASTNode*>(subnode->CastTo(semanter, new CIntDataType(Token), Token)));
			(*iter) = subnode;
		}

		ExpressionResultType = DataType;
	}

	// Create a new object!
	else
	{		
		// Make sure DT is a class.
		if (dynamic_cast<CObjectDataType*>(DataType) == NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate primitive data type '%s'.", DataType->ToString().c_str()), Token);
		}

		// Check class is valid.
		CClassASTNode* classNode = DataType->GetClass(semanter);
		if (classNode->IsInterface == true)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate interface '%s'.", DataType->ToString().c_str()), Token);
		}
		if (classNode->IsAbstract == true)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate abstract class '%s'.", DataType->ToString().c_str()), Token);
		}
		if (classNode->IsStatic == true)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate static class '%s'.", DataType->ToString().c_str()), Token);
		}
		if (classNode->IsNative == true)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate native class '%s'.", DataType->ToString().c_str()), Token);
		}

		classNode->IsInstanced = true;
		classNode->InstancedBy = this;

		// Check we can find a constructor.
		CClassMemberASTNode* node = classNode->FindClassMethod(semanter, classNode->Identifier, argument_datatypes, false);
		if (node == NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("No suitable constructor to instantiate class '%s'.", DataType->ToString().c_str()), Token);
		}

	//	if (classNode->Identifier == "MapPair")
	//	{
	//		printf("WUT");
	//	}

		ResolvedConstructor = node;

		// Cast all arguments to correct data types.
		int index = 0;
		for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
		{
			CDataType* dataType = node->Arguments.at(index++)->Type;

			CExpressionBaseASTNode* subnode = dynamic_cast<CExpressionBaseASTNode*>(*iter);
			CExpressionBaseASTNode* subnode_casted = dynamic_cast<CExpressionBaseASTNode*>(subnode->CastTo(semanter, dataType, Token));
			this->ReplaceChild(subnode, subnode_casted);

			(*iter) = subnode_casted;
		}

		ExpressionResultType = DataType;
	}

	// Check we can create new object.
	if (dynamic_cast<CArrayDataType*>(DataType) == NULL)
	{		
		// Check class is valid.
		CClassASTNode* classNode = DataType->GetClass(semanter);

		// Check we can find a constructor.
		CClassMemberASTNode* node = classNode->FindClassMethod(semanter, classNode->Identifier, argument_datatypes, false);
		if (node == NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Could not find suitable constructor to instantiate class '%s'.", DataType->ToString().c_str()), Token);
		}
	}

	return this;
}

// =================================================================
//	Performs finalization on this node.
//
//	TODO: Move this into semant, we only have it in here because
//		  if we do a checkAccess in semant we will get a null
//		  reference exception if we are still assinging this
//		  nodes parents (in the case of implicit boxing)
//
// =================================================================
CASTNode* CNewExpressionASTNode::Finalize(CSemanter* semanter)
{
	// Grab arguments.
	std::vector<CDataType*> argument_datatypes;
	for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
	{
		CExpressionBaseASTNode* node = dynamic_cast<CExpressionBaseASTNode*>(*iter);
		argument_datatypes.push_back(node->ExpressionResultType);
	}

	// Create new object.
	if (dynamic_cast<CArrayDataType*>(DataType) == NULL)
	{		
		// Check class is valid.
		CClassASTNode* classNode = DataType->GetClass(semanter);

		// Check we can find a constructor.
		CClassMemberASTNode* node = classNode->FindClassMethod(semanter, classNode->Identifier, argument_datatypes, false);
		if (node == NULL)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Could not find suitable constructor to instantiate class '%s'.", DataType->ToString().c_str()), Token);
		}

		// Now to do the actual finalization - checking if access is valid!
		node->CheckAccess(semanter, this);
	}

	return this;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CNewExpressionASTNode::Clone(CSemanter* semanter)
{
	CNewExpressionASTNode* clone = new CNewExpressionASTNode(NULL, Token);
	clone->DataType = DataType;
	clone->IsArray = IsArray;

	for (auto iter = ArgumentExpressions.begin(); iter != ArgumentExpressions.end(); iter++)
	{
		CASTNode* node = (*iter)->Clone(semanter);
		clone->ArgumentExpressions.push_back(node);
		clone->AddChild(node);
	}

	return clone;
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
std::string CNewExpressionASTNode::TranslateExpr(CTranslator* translator)
{
	return translator->TranslateNewExpression(this);
}