/* *****************************************************************

		CASTNode.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CASTNODE_H_
#define _CASTNODE_H_

#include <string>
#include <vector>

#include "CToken.h"
#include "EvaluationResult.h"

class CSemanter;
class CTranslationUnit;
class CExpressionBaseASTNode;
class CDataType;

class CAliasASTNode;
class CDeclarationASTNode;
class CPackageASTNode;
class CClassASTNode;
class CClassMemberASTNode;

class CTranslator;

// =================================================================
//	Access level type.
// =================================================================
namespace AccessLevel
{
	enum Type
	{
		PUBLIC,
		PRIVATE,
		PROTECTED
	};
};

// =================================================================
//	Base class used to store a representation of individual nodes
//	in an Abstract Syntax Tree.
// =================================================================
class CASTNode
{
private:
	static int g_create_index_tracker;
	int m_create_index;

protected:

public:
	CToken					Token;
	CASTNode*				Parent;
	std::vector<CASTNode*>	Children;

	bool					Semanted;

	// General management.
	virtual std::string ToString();
	
	// Child management.
	void	  AddChild		(CASTNode* node, bool atStart=false);
	void	  RemoveChild	(CASTNode* node);
	CASTNode* ReplaceChild	(CASTNode* replace, CASTNode* with);

	// Semantic analysis.
	//void					PrepareChildren		(CSemanter* semanter);
	//virtual CASTNode*		Prepare				(CSemanter* semanter);

	void					SemantChildren		(CSemanter* semanter);
	virtual CASTNode*		Semant				(CSemanter* semanter);

	CExpressionBaseASTNode* SemantAsExpression	(CSemanter* semanter);	

	void					FinalizeChildren	(CSemanter* semanter);
	virtual CASTNode*		Finalize			(CSemanter* semanter);

	virtual CASTNode*		Clone				(CSemanter* semanter) = 0;
	virtual void			CloneChildren		(CSemanter* semanter, CASTNode* parent);

	virtual void			Translate			(CTranslator* translator);
	virtual void			TranslateChildren	(CTranslator* translator);
		
	// Finding things.	
	virtual CAliasASTNode*			FindAlias							(CSemanter* semanter, std::string identifier, CASTNode* ignoreNode=NULL);
	virtual CDeclarationASTNode*	FindDeclaration						(CSemanter* semanter, std::string identifier, CASTNode* ignoreNode=NULL);
	virtual CDeclarationASTNode*	FindDataTypeDeclaration				(CSemanter* semanter, std::string identifier, CASTNode* ignoreNode=NULL);
	virtual CDataType*				FindDataType						(CSemanter* semanter, std::string identifier, std::vector<CDataType*> generic_arguments, bool ignore_access = false, bool do_not_semant = false);
	virtual CPackageASTNode* 		FindNodePackageScope				(CSemanter* semanter);
	virtual CClassASTNode*	 		FindClassScope						(CSemanter* semanter);
	virtual CClassMemberASTNode*	FindClassMethodScope				(CSemanter* semanter);
	virtual CClassMemberASTNode*	FindClassMethod						(CSemanter* semanter, std::string identifier, std::vector<CDataType*> arguments, bool explicit_arguments, CASTNode* ignoreNode=NULL, CASTNode* referenceNode=NULL);
	virtual CClassMemberASTNode*	FindClassField						(CSemanter* semanter, std::string identifier, CASTNode*	ignoreNode, CASTNode* referenceNode=NULL);
	virtual CASTNode*				FindLoopScope						(CSemanter* semanter);

	virtual	CASTNode*				GetParentSearchScope				(CSemanter* semanter);
	virtual std::vector<CASTNode*>& GetSearchScopeChildren				(CSemanter* semanter);

	virtual void					CheckForDuplicateIdentifier			(CSemanter* semanter, std::string identifier, CASTNode*	ignoreNode=NULL);
	virtual void					CheckForDuplicateMethodIdentifier	(CSemanter* semanter, std::string identifier, std::vector<CDataType*> arguments, CClassMemberASTNode*	ignoreNode=NULL);

	virtual	EvaluationResult		Evaluate							(CTranslationUnit* unit);

	virtual bool					AcceptBreakStatement				();
	virtual bool					AcceptContinueStatement				();

	// Constructing.
	CASTNode();
	CASTNode(CASTNode* parent, CToken token);
	~CASTNode();

};

#endif