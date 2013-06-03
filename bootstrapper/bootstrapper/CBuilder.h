/* *****************************************************************

		CBuilder.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CBUILDER_H_
#define _CBUILDER_H_

#include "CToken.h"

class CTranslationUnit;

// =================================================================
//	Responsible for compiling translated source code into a final
//	binary executable.
// =================================================================
class CBuilder
{
protected:
	CTranslationUnit* m_context;

	virtual bool Build() = 0;

public:
	bool				Process							(CTranslationUnit* context);
	CTranslationUnit*	GetContext						();

};

#endif

