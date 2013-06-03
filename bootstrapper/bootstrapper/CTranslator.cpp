/* *****************************************************************

		CTranslator.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CTranslator.h"

#include "CASTNode.h"
#include "CPackageASTNode.h"

#include "CSemanter.h"

#include "CTranslationUnit.h"

// =================================================================
//	Processes input and performs the actions requested.
// =================================================================
bool CTranslator::Process(CTranslationUnit* context)
{	
	m_context = context;
	m_semanter = context->GetSemanter();

	CPackageASTNode* package = dynamic_cast<CPackageASTNode*>(m_context->GetASTRoot());
	TranslatePackage(package);

	return true;
}

// =================================================================
//	Returns the context being translated.
// =================================================================
CTranslationUnit* CTranslator::GetContext()
{
	return m_context;
}
