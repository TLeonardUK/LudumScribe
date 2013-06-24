/* *****************************************************************

		CClassASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CCLASSASTNODE_H_
#define _CCLASSASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "CASTNode.h"
#include "CDataType.h"

#include "CDeclarationASTNode.h"

class CClassBodyASTNode;
class CIdentifierDataType;
class CObjectDataType;
class CClassReferenceDataType;

// =================================================================
//	Stores information on a class declaration.
// =================================================================
class CClassASTNode : public CDeclarationASTNode
{
protected:	
	bool								m_semanting;

public:

	// Parsing infered data.
	AccessLevel::Type					AccessLevel;
	bool								IsStatic;
	bool								IsAbstract;
	bool								IsInterface;
	bool								IsSealed;
	bool								IsGeneric;
	bool								InheritsNull;
	bool								IsInstanced;
	bool								IsEnum;
	CASTNode*							InstancedBy;

	bool								HasBoxClass;
	std::string							BoxClassIdentifier;

	std::vector<CToken>					GenericTypeTokens;
	std::vector<CIdentifierDataType*>	InheritedTypes;		

	CClassBodyASTNode*					Body;	

	CObjectDataType*					ObjectDataType;
	CClassReferenceDataType*			ClassReferenceDataType;

	CClassMemberASTNode*				ClassConstructor;
	CClassMemberASTNode*				InstanceConstructor;

	// Semanting infered data.
	std::vector<CClassASTNode*>			GenericInstances;
	CClassASTNode*						GenericInstanceOf;
	std::vector<CDataType*>				GenericInstanceTypes;
	
	CClassASTNode*						SuperClass;
	std::vector<CClassASTNode*>			Interfaces;	
	
	// General management.
	virtual std::string ToString();

	// Initialization.
	CClassASTNode(CASTNode* parent, CToken token);
	~CClassASTNode();
	
	// Semantic analysis.
	virtual CASTNode*				Semant					(CSemanter* semanter);
	virtual CASTNode*				Finalize				(CSemanter* semanter);	
	virtual CASTNode*				Clone					(CSemanter* semanter);

	virtual void					CheckAccess				(CSemanter* semanter, CASTNode* referenceBy);
	bool							InheritsFromClass		(CSemanter* semanter, CClassASTNode* node);

	virtual	CASTNode*				GetParentSearchScope	(CSemanter* semanter);
	virtual std::vector<CASTNode*>& GetSearchScopeChildren	(CSemanter* semanter);

	CClassASTNode*					GenerateClassInstance	(CSemanter* semanter, CASTNode* referenceNode, std::vector<CDataType*> generic_arguments);
	
	virtual CClassMemberASTNode*	FindClassMethod			(CSemanter* semanter, std::string identifier, std::vector<CDataType*> arguments, bool explicit_arguments, CASTNode* ignoreNode=NULL, CASTNode* referenceNode=NULL);
	virtual CClassMemberASTNode*	FindClassField			(CSemanter* semanter, std::string identifier, CASTNode*	ignoreNode, CASTNode* referenceNode);

	virtual void					Translate				(CTranslator* translator);

};

#endif