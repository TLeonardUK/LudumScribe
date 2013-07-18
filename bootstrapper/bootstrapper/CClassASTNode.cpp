/* *****************************************************************

		CClassASTNode.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <Windows.h>

#include "CStringHelper.h"

#include "CClassASTNode.h"
#include "CIdentifierDataType.h"
#include "CTranslationUnit.h"
#include "CDeclarationASTNode.h"
#include "CObjectDataType.h"
#include "CPackageASTNode.h"
#include "CAliasASTNode.h"
#include "CClassReferenceDataType.h"
#include "CMethodBodyASTNode.h"
#include "CVoidDataType.h"

#include "CClassMemberASTNode.h"
#include "CVariableStatementASTNode.h"
#include "CClassBodyASTNode.h"

#include "CCastExpressionASTNode.h"

#include "CTranslator.h"

// =================================================================
//	Constructs a new instance of this class.
// =================================================================
CClassASTNode::CClassASTNode(CASTNode* parent, CToken token) :
	CDeclarationASTNode(parent, token)
{
	Identifier				= "";
	AccessLevel				= AccessLevel::PUBLIC;
	IsStatic				= false;
	IsAbstract				= false;
	IsInterface				= false;
	IsGeneric				= false;
	Body					= NULL;
	SuperClass				= NULL;
	InheritsNull			= false;
	ObjectDataType			= new CObjectDataType(token, this);
	ClassReferenceDataType	= new CClassReferenceDataType(token, this);
	m_semanting				= false;
	GenericInstanceOf		= NULL;
	ClassConstructor		= NULL;
	InstanceConstructor		= NULL;
	IsInstanced				= false;
	InstancedBy				= NULL;
	HasBoxClass				= false;
	BoxClassIdentifier		= "";
	IsEnum					= false;
}

// =================================================================
//	Destructor.
// =================================================================
CClassASTNode::~CClassASTNode()
{
	for (auto iter = GenericInstances.begin(); iter != GenericInstances.end(); iter++)
	{
		delete (*iter);
	}
	GenericInstances.clear();
	
	delete ObjectDataType;
}

// =================================================================
//	Creates a clone of this node.
// =================================================================
CASTNode* CClassASTNode::Clone(CSemanter* semanter)
{
	CClassASTNode* clone = new CClassASTNode(NULL, Token);
	
	//clone->MangledIdentifier = this->MangledIdentifier;
	clone->IsNative			  = this->IsNative;
	clone->Identifier		 = this->Identifier;
	clone->AccessLevel		 = this->AccessLevel;
	clone->IsStatic			 = this->IsStatic;
	clone->IsAbstract		 = this->IsAbstract;
	clone->IsInterface		 = this->IsInterface;
	clone->IsSealed			 = this->IsSealed;
	clone->IsGeneric		 = this->IsGeneric;
	clone->InheritsNull		 = this->InheritsNull;
	clone->GenericTypeTokens = this->GenericTypeTokens;
	clone->InheritedTypes	 = this->InheritedTypes;	
	clone->HasBoxClass		 = this->HasBoxClass;
	clone->BoxClassIdentifier = this->BoxClassIdentifier;
	clone->IsEnum			 = this->IsEnum;
	clone->Body				 = dynamic_cast<CClassBodyASTNode*>(this->Body->Clone(semanter));
	clone->ObjectDataType	 = new CObjectDataType(Token, clone);
	clone->AddChild(clone->Body);

	if (ClassConstructor != NULL)
	{
		for (auto iter = clone->Body->Children.begin(); iter != clone->Body->Children.end(); iter++)
		{
			CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(*iter);
			if (member != NULL)
			{
				if (member->Identifier == ClassConstructor->Identifier)
				{
					clone->ClassConstructor = member;
					break;
				}
			}
		}
	}
	
	if (InstanceConstructor != NULL)
	{
		for (auto iter = clone->Body->Children.begin(); iter != clone->Body->Children.end(); iter++)
		{
			CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(*iter);
			if (member != NULL)
			{
				if (member->Identifier == InstanceConstructor->Identifier)
				{
					clone->InstanceConstructor = member;
					break;
				}
			}
		}
	}
	
	return clone;
}

// =================================================================
//	Converts this node to a string representation.
// =================================================================
std::string CClassASTNode::ToString()
{
	std::string result = Identifier;

	if (IsGeneric == true)
	{
		result += "<";
		if (GenericInstanceOf != NULL)
		{
			for (auto iter = GenericInstanceTypes.begin(); iter != GenericInstanceTypes.end(); iter++)
			{
				if (iter != GenericInstanceTypes.begin())
				{
					result += ",";
				}
				result += (*iter)->ToString();
			}
		}
		else
		{
			for (auto iter = GenericTypeTokens.begin(); iter != GenericTypeTokens.end(); iter++)
			{
				if (iter != GenericTypeTokens.begin())
				{
					result += ",";
				}
				result += (*iter).Literal;
			}
		}
		result += ">";
	}

	return result;
}

// =================================================================
//	Performs semantic analysis on this node.
// =================================================================
CASTNode* CClassASTNode::Semant(CSemanter* semanter)
{ 
	SEMANT_TRACE("CClassASTNode=%s", Identifier.c_str());

	// Only semant once.
	if (Semanted == true)
	{
		//m_semanting = false;
		return this;
	}
	Semanted = true;
	
	// Check for duplicate identifiers (only if we are not an instanced class).
	if (GenericInstanceOf == NULL)
	{
		Parent->CheckForDuplicateIdentifier(semanter, Identifier, this);
	}
	
	if (IsGeneric		  == false ||
		GenericInstanceOf != NULL)
	{
	
		// Work out mangled identifier.
		if (MangledIdentifier == "")
		{
			MangledIdentifier = semanter->GetMangled("ls_" + Identifier);
		}

		// Interface cannot use inheritance.
		if (InheritedTypes.size() > 0 && IsInterface == true)
		{
			semanter->GetContext()->FatalError("Interfaces cannot inherit from other interfaces or classes.", Token);
		}		
		if (InheritedTypes.size() > 0 && IsStatic == true)
		{
			semanter->GetContext()->FatalError("Static classes cannot inherit from interfaces.", Token);
		}
		
		// Flag this class as semanting - we do this so we can detect
		// inheritance loops.
		if (m_semanting == true)
		{
			semanter->GetContext()->FatalError("Detected illegal cyclic inheritance of '" + Identifier + "'.", Token);
		}
		m_semanting = true;
	
		// Semant inherited types.
		bool foundSuper = false;
		for (auto iter = InheritedTypes.begin(); iter != InheritedTypes.end(); iter++)
		{
			CIdentifierDataType* type = *iter;
			CClassASTNode* node = type->SemantAsClass(semanter, this, true);

			if (type->Identifier == Identifier)
			{
				semanter->GetContext()->FatalError("Attempt to inherit class from itself.", Token);
			}

			if (node->IsInterface == true)
			{
				Interfaces.push_back(node);
			}
			else
			{
				if (foundSuper == true)
				{
					semanter->GetContext()->FatalError("Multiple inheritance is not supported. Use interfaces instead.", Token);
				}
				SuperClass = node;
				foundSuper = true;
			}
		}

		// Native classes are not allowed to implement interfaces.
		//if (IsNative == true && Interfaces.size() > 0)
		//{
		//	semanter->GetContext()->FatalError("Native classes cannot implement interfaces.", Token);
		//}

		// If no inherited types the we inherit from object.
		if (SuperClass == NULL && IsNative == false)
		{
			SuperClass = dynamic_cast<CClassASTNode*>(FindDeclaration(semanter, "object"));

			if (SuperClass == NULL)
			{
				semanter->GetContext()->FatalError("Could not find base class to inherit from.", Token);
			}
		}
		else if (SuperClass != NULL)
		{
			// Check super class is valid.
			if (SuperClass->IsSealed == true)
			{
				semanter->GetContext()->FatalError("Classes cannot inherit from sealed class.", Token);
			}
		
			// Cannot inherit in static classes.
			if (IsStatic == true)
			{
				semanter->GetContext()->FatalError("Static classes cannot inherit from other classes.", Token);
			}
		}
		
		// Semant inherited classes.
		if (SuperClass != NULL)
		{
			SuperClass->Semant(semanter);
		}
		for (auto iter = Interfaces.begin(); iter != Interfaces.end(); iter++)
		{
			CClassASTNode* interfaceClass = *iter;
			interfaceClass->Semant(semanter);
		}
	
		// Look for interface in parent classes.
		if (SuperClass != NULL)
		{
			for (auto iter = Interfaces.begin(); iter != Interfaces.end(); iter++)
			{
				CClassASTNode* interfaceClass = *iter;
				if (SuperClass->InheritsFromClass(semanter, interfaceClass) != NULL)
				{
					semanter->GetContext()->FatalError(CStringHelper::FormatString("Attempt to implement interface '%s' that is already implemented by a parent class.", interfaceClass->Identifier.c_str()), Token);
				}
			}
		}

		// Remove semanting flag.
		m_semanting = false;		
	}

	// If we are generic we only semant children of instanced classes.
	if (IsGeneric		  == false ||
		GenericInstanceOf != NULL)
	{
		// Create static class constructor.
		if (IsInterface == false)
		{
			CClassMemberASTNode* defaultCtor = FindClassMethod(semanter, "__"+Identifier+"_ClassConstructor", std::vector<CDataType*>(), false);
			if (defaultCtor == NULL)
			{
				CClassMemberASTNode* member		= new CClassMemberASTNode(NULL, Token);
				member->MemberType				= MemberType::Method;
				member->Identifier				= "__"+Identifier+"_ClassConstructor";
				member->AccessLevel				= AccessLevel::PUBLIC;
				member->Body					= new CMethodBodyASTNode(member, Token);
				member->IsConstructor			= true;
				member->IsStatic				= true;
				member->ReturnType				= new CVoidDataType(Token);
				member->IsExtension				= IsNative;
				Body->AddChild(member);

				ClassConstructor				= member; 
			}

			if (IsNative == false && IsEnum == false)
			{
				// Create instance constructor.
				CClassMemberASTNode* instanceCtor = FindClassMethod(semanter, "__"+Identifier+"_InstanceConstructor", std::vector<CDataType*>(), false);
				if (instanceCtor == NULL)
				{
					CClassMemberASTNode* member		= new CClassMemberASTNode(NULL, Token);
					member->MemberType				= MemberType::Method;
					member->Identifier				= "__"+Identifier+"_InstanceConstructor";
					member->AccessLevel				= AccessLevel::PUBLIC;
					member->Body					= new CMethodBodyASTNode(member, Token);
					member->IsConstructor			= true;
					member->IsStatic				= false;
					member->ReturnType				= new CVoidDataType(Token);
					Body->AddChild(member);

					InstanceConstructor				= member; 
				}
			}

			// If no argument-less constructor has been provided, lets create a default one.
			if (IsStatic == false && IsAbstract == false && IsInterface == false && IsNative == false && IsEnum == false)
			{
				CClassMemberASTNode* defaultCtor = FindClassMethod(semanter, Identifier, std::vector<CDataType*>(), false);
				if (defaultCtor == NULL)
				{
					CClassMemberASTNode* member = new CClassMemberASTNode(NULL, Token);
					member->MemberType			= MemberType::Method;
					member->Identifier			= Identifier;
					member->AccessLevel			= AccessLevel::PUBLIC;
					member->Body				= new CMethodBodyASTNode(member, Token);
					member->IsConstructor		= true;
					member->ReturnType			= new CVoidDataType(Token);
					Body->AddChild(member);
				}
			}
	
		}
		
		// Semant all members.
		SemantChildren(semanter);
	}

	return this;
}

// =================================================================
//	Performs finalization on this class.
// =================================================================
CASTNode* CClassASTNode::Finalize(CSemanter* semanter)
{
	// If we are generic, only finalize instances.
	if (IsGeneric == false || GenericInstanceOf != NULL)
	{
		// Check for hiding variables and methods.
		for (auto iter = Body->Children.begin(); iter != Body->Children.end(); iter++)
		{
			CClassMemberASTNode* node = dynamic_cast<CClassMemberASTNode*>(*iter);
			if (node != NULL)
			{
				CClassASTNode* scope = SuperClass;
				while (scope != NULL)
				{
					for (auto iter2 = scope->Body->Children.begin(); iter2 != scope->Body->Children.end(); iter2++)
					{
						CClassMemberASTNode* node2 = dynamic_cast<CClassMemberASTNode*>(*iter2);
						if (node2 != NULL &&
							node->Identifier == node2->Identifier &&
							(
								(node->IsOverride == false && node2->IsVirtual == true) ||
								(node->MemberType == MemberType::Field || node2->MemberType == MemberType::Field) 
							))
						{
							if (node->MemberType  == MemberType::Method ||
								node2->MemberType == MemberType::Method)
							{
								semanter->GetContext()->FatalError(CStringHelper::FormatString("Method '%s' in class '%s' hides existing declaration in class '%s'.", node->Identifier.c_str(), ToString().c_str(), scope->ToString().c_str()), node->Token);
							}
							else
							{
								semanter->GetContext()->FatalError(CStringHelper::FormatString("Member '%s' in class '%s' hides existing declaration in class '%s'.", node->Identifier.c_str(), ToString().c_str(), scope->ToString().c_str()), node->Token);
							}
						}
					}
					scope = scope->SuperClass;
				}			
			}
		}

		// Flag us as abstract if we have any abstract methods in our inheritance tree.	
		if (IsAbstract == false)
		{
			CClassASTNode* scope = this;
			std::vector<CClassMemberASTNode*> members;
			while (scope != NULL && IsAbstract == false)
			{
				// Look for abstract methods in this scope.		
				for (auto iter = scope->Body->Children.begin(); iter != scope->Body->Children.end() && IsAbstract == false; iter++)
				{
					CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(*iter);
					if (member != NULL && member->MemberType == MemberType::Method)
					{
						// If member is abstract, check it is implemented in the members we have 
						// see higher in the inheritance tree so far.
						if (member->IsAbstract == true)
						{
							bool found = false;
							for (auto iter2 = members.begin(); iter2 != members.end(); iter2++)
							{
								CClassMemberASTNode* sub_member = *iter2;
								
								if (sub_member->EqualToMember(semanter, member))
								{
									found = true;
									break;
								}
							}

							// If not found, this class is abstract!
							if (found == false)
							{
								if (IsInstanced == true)
								{
									semanter->GetContext()->FatalError(CStringHelper::FormatString("Cannot instantiate abstract class '%s'.", ToString().c_str()), InstancedBy->Token);
								}
								IsAbstract = true;
							}
						}
						else
						{
							members.push_back(member);
						}
					}
				}

				// Move up the inheritance tree.
				scope = scope->SuperClass;
			}
		}

		// Throw errors if we do not implement all interface functions.	
		for (auto iter = Interfaces.begin(); iter != Interfaces.end(); iter++)
		{
			CClassASTNode* interfaceClass = *iter;
			for (auto iter2 = interfaceClass->Body->Children.begin(); iter2 != interfaceClass->Body->Children.end(); iter2++)
			{
				CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(*iter2);
				if (member != NULL &&
					member->MemberType == MemberType::Method)
				{
					std::vector<CDataType*> argument_data_types;
					for (auto iter3 = member->Arguments.begin(); iter3 != member->Arguments.end(); iter3++)
					{
						CVariableStatementASTNode* arg = *iter3;
						argument_data_types.push_back(arg->Type);
					}

					if (FindClassMethod(semanter, member->Identifier, argument_data_types, true, NULL, this) == NULL)
					{
						semanter->GetContext()->FatalError(CStringHelper::FormatString("Class does not implement method '%s' of interface '%s'.", member->Identifier.c_str(), interfaceClass->Identifier.c_str()), Token);
					}
				}
			}
		}

		// Finalize children.
		FinalizeChildren(semanter);
	}

	// Finalize generic instances.
	else if (IsGeneric == true)
	{
		for (auto iter = GenericInstances.begin(); iter != GenericInstances.end(); iter++)
		{
			(*iter)->Finalize(semanter);
		}
	}

	return this;
}

// =================================================================
//	Check for duplicate identifier.
// =================================================================
CClassMemberASTNode* CClassASTNode::FindClassMethod(CSemanter*					semanter, 
													std::string					identifier, 
													std::vector<CDataType*>		arguments, 
													bool						explicit_arguments,
													CASTNode*					ignoreNode, 
													CASTNode*					referenceNode)
{
	// Make sure this class is semanted.
	if (!Semanted)
	{
		Semant(semanter);
	}

	// Find all possible methods with the name.
	std::vector<CClassMemberASTNode*> nodes;

	CClassASTNode* scope = this;
	while (scope != NULL)
	{
		if (scope->Body != NULL)
		{
			for (auto iter = scope->Body->Children.begin(); iter != scope->Body->Children.end(); iter++)
			{
				CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(*iter);
				if (member				!= NULL &&
					member->MemberType	== MemberType::Method && 
					member->Identifier	== identifier &&
					member				!= ignoreNode &&
					arguments.size()	<= member->Arguments.size())
				{

					// Has one of the other members overridcen this method already?
					bool alreadyExists = false;
					for (auto iter2 = nodes.begin(); iter2 != nodes.end(); iter2++)
					{
						CClassMemberASTNode* member2 = *iter2;
						if (member->Identifier == member2->Identifier &&
							member->Arguments.size() == member2->Arguments.size() &&
							member->IsVirtual == true && member2->IsOverride == true)
						{
							bool argsSame = true;

							for (unsigned int i = 0; i < member->Arguments.size(); i++)
							{
								CVariableStatementASTNode* arg = member->Arguments.at(i);
								CVariableStatementASTNode* arg2 = member2->Arguments.at(i);
								if (!arg->Type->IsEqualTo(semanter, arg2->Type))
								{
									argsSame = false;
									break;
								}
							}

							if (argsSame == true)
							{
								alreadyExists = true;
								break;
							}
						}
					}

					if (alreadyExists == false)
					{
						member->Semant(semanter);
						nodes.push_back(member);
					}
				}
			}
		}
		scope = scope->SuperClass;
	}

	// Try and find amatch!
	CClassMemberASTNode* match			= NULL;
	bool				 isExactMatch	= false;
	std::string			 errorMessage	= "";

	// Look for valid nodes.		
	for (auto iter = nodes.begin(); iter != nodes.end(); iter++)
	{
		CClassMemberASTNode* member = *iter;

		bool exact		= true;
		bool possible	= true;

		for (unsigned int i = 0; i < member->Arguments.size(); i++)
		{
			CVariableStatementASTNode* arg = member->Arguments.at(i);

			if (arguments.size() > member->Arguments.size())
			{
				continue;
			}

			if (i < arguments.size())
			{
				if (arguments.at(i)->IsEqualTo(semanter, arg->Type))
				{
					continue;
				}
				exact = false;

				if (!explicit_arguments && CCastExpressionASTNode::IsValidCast(semanter, arguments.at(i), arg->Type, false))// arguments.at(i)->CanCastTo(semanter, arg->Type))
				{
					continue;
				}
			}
			else if (arg->AssignmentExpression != NULL)
			{
				exact = false;
				if (!explicit_arguments)
				{
					continue;
				}
			}

			possible = false;
			break;
		}

		if (!possible)
		{
			continue;
		}

		if (exact == true)
		{
			if (isExactMatch == true)
			{
				semanter->GetContext()->FatalError(CStringHelper::FormatString("Found ambiguous reference to method of class '%s'. Reference could mean either '%s' or '%s'.", Identifier.c_str(), match->ToString().c_str(), member->ToString().c_str()),
													referenceNode == NULL ? Token : referenceNode->Token);
			}
			else
			{
				errorMessage	= "";
				match			= member;
				isExactMatch	= true;
			}
		}
		else
		{
			if (!isExactMatch)
			{
				if (match != NULL)
				{
					errorMessage = CStringHelper::FormatString("Found ambiguous reference to method of class '%s'. Reference could mean either '%s' or '%s'.", Identifier.c_str(), match->ToString().c_str(), member->ToString().c_str());
				}
				else
				{
					match = member;
				}
			}
		}
	}

	// Return?
	if (!isExactMatch)
	{
		if (errorMessage != "")
		{
			semanter->GetContext()->FatalError(errorMessage, referenceNode == NULL ? Token : referenceNode->Token);
		}
		if (explicit_arguments == true)
		{
			return NULL;
		}
	}

	// No match available? :S
	if (match == NULL)
	{
		return NULL;
	}

	// Return matched class.
	return match;
}

// =================================================================
//	Check for duplicate identifier.
// =================================================================
CClassMemberASTNode* CClassASTNode::FindClassField(CSemanter*					semanter, 
													std::string					identifier, 
													CASTNode*					ignoreNode, 
													CASTNode*					referenceNode)
{
	// Make sure this class is semanted.
	if (!Semanted)
	{
		Semant(semanter);
	}

	// Look for some sweet sweet methods.
	if (Body != NULL)
	{
		CClassMemberASTNode* result = NULL;

		// Look for explicit member matchs.
		for (auto iter = Body->Children.begin(); iter != Body->Children.end(); iter++)
		{
			CClassMemberASTNode* classNode = dynamic_cast<CClassMemberASTNode*>(*iter);
			if (classNode					!= NULL &&
				classNode					!= ignoreNode &&
				classNode->Identifier		== identifier &&
				classNode->MemberType		== MemberType::Field)
			{
				
				result = classNode; 
			}
		}

		// Return result!
		if (result != NULL)
		{
			return result;
		}
	}

	// Look up the inheritance tree.
	if (SuperClass != NULL)
	{
		return SuperClass->FindClassField(semanter, identifier, ignoreNode, referenceNode);
	}
	else
	{
		return NULL;
	}
}

// =================================================================
//	Gets the next scope up the tree to check when looking for
//	declarations.
// =================================================================
CASTNode* CClassASTNode::GetParentSearchScope(CSemanter* semanter)
{
	return Parent;
}

// =================================================================
//	Gets the list of children to be searched when looking for
//	declarations.
// =================================================================
std::vector<CASTNode*>& CClassASTNode::GetSearchScopeChildren(CSemanter* semanter)
{
	return Body->Children;
}

// =================================================================
//	Checks if we can access this declaration from the given node.
// =================================================================
void CClassASTNode::CheckAccess(CSemanter* semanter, CASTNode* referenceBy)
{
	// If we are in a different package and not public, then refuse access.
	if (Token.SourceFile != referenceBy->Token.SourceFile && this->AccessLevel != AccessLevel::PUBLIC)
	{
		semanter->GetContext()->FatalError(CStringHelper::FormatString("Class '%s' is not accessible from this package.", ToString().c_str()), referenceBy->Token);
	}
}

// =================================================================
//	Returns true if the given class is in the inheritance 
//  or implementation tree for this class.
// =================================================================
bool CClassASTNode::InheritsFromClass(CSemanter* semanter, CClassASTNode* node)
{
	if (node == this)
	{
		return true;
	}

	Semant(semanter);
	node->Semant(semanter);

	CClassASTNode* check = this;
	while (check != NULL)
	{
		// Check for direct class inheriting.
		if (check == node)
		{
			return true;
		}

		// Check for interface inheriting.
		for (auto iter = check->Interfaces.begin(); iter != check->Interfaces.end(); iter++)
		{
			if ((*iter) == node)
			{
				return true;
			}
		}

		check = check->SuperClass;
	}

	return false;
}

// =================================================================
//	Instantiates a copy of this class if its a generic, or just
//	returns the class if its not generic.
// =================================================================
CClassASTNode* CClassASTNode::GenerateClassInstance(CSemanter* semanter, CASTNode* referenceNode, std::vector<CDataType*> generic_arguments)
{
	if (IsGeneric == true)
	{
		if (generic_arguments.size() != GenericTypeTokens.size())
		{
			if (generic_arguments.size() == 0)
			{
				semanter->GetContext()->FatalError(CStringHelper::FormatString("Class '%s' is generic and expects generic arguments.", Token.Literal.c_str()), referenceNode->Token);
			}
			else
			{
				semanter->GetContext()->FatalError(CStringHelper::FormatString("Incorrect number of generic arguments given to class '%s' during instantiation.", Token.Literal.c_str()), referenceNode->Token);
			}
		}

		// Instance with these data types already exists?
		for (auto iter = GenericInstances.begin(); iter != GenericInstances.end(); iter++)
		{
			CClassASTNode* instance = *iter;
			bool argumentsMatch = true;
			
			for (unsigned int i = 0; i < instance->GenericInstanceTypes.size(); i++)
			{
				if (!instance->GenericInstanceTypes.at(i)->IsEqualTo(semanter, generic_arguments.at(i)))
				{
					argumentsMatch = false;
					break;
				}
			}

			if (argumentsMatch == true)
			{
				return instance;
			}
		}

		// Nope, time to create it.
		CClassASTNode* astNode			= dynamic_cast<CClassASTNode*>(this->Clone(semanter));
		astNode->Parent					= Parent; // We set the derived node to our parent so it can correctly find things in its scope, but so that it can't be found by others.
		astNode->GenericInstanceOf		= this;
		astNode->GenericInstanceTypes	= generic_arguments;
		GenericInstances.push_back(astNode);

		// Create alias's for all generic type tokens.		
		for (unsigned int i = 0; i < generic_arguments.size(); i++)
		{
			CToken&		token	= GenericTypeTokens.at(i);
			CDataType*	type	= generic_arguments.at(i);
			
			CAliasASTNode* alias = new CAliasASTNode(astNode->Body, this->Token, token.Literal, type);
			astNode->Body->AddChild(alias);
			alias->Semant(semanter);
		}

		// Semant our new instance.
		astNode->Semant(semanter);

		return astNode;
	}
	else
	{
		if (generic_arguments.size() > 0)
		{
			semanter->GetContext()->FatalError(CStringHelper::FormatString("Class '%s' is not generic and cannot be instantiated.", Token.Literal.c_str()), referenceNode->Token);
		}
		return this;
	}
}

// =================================================================
//	Causes this node to be translated.
// =================================================================
void CClassASTNode::Translate(CTranslator* translator)
{
	if (IsGeneric == true)
	{		
		for (auto iter = GenericInstances.begin(); iter != GenericInstances.end(); iter++)
		{
			CClassASTNode* instance = *iter;
			translator->TranslateClass(instance);
		}
	}
	else
	{
		translator->TranslateClass(this);
	}
}