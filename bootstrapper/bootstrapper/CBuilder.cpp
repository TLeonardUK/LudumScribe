/* *****************************************************************

		CBuilder.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CBuilder.h"

#include "CASTNode.h"
#include "CPackageASTNode.h"

#include "CSemanter.h"

#include "CTranslationUnit.h"

// =================================================================
//	Processes input and performs the actions requested.
// =================================================================
bool CBuilder::Process(CTranslationUnit* context)
{	
	m_context = context;
	return Build();
}

// =================================================================
//	Returns the context being translated.
// =================================================================
CTranslationUnit* CBuilder::GetContext()
{
	return m_context;
}
