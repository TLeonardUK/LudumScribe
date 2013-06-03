/* *****************************************************************

		CMSBuildBuilder.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CMSBUILDBUILDER_H_
#define _CMSBUILDBUILDER_H_

#include "CToken.h"
#include "CBuilder.h"

class CTranslationUnit;

// =================================================================
//	Responsible for compiling translated source code into a final
//	binary executable using MSBuild.
// =================================================================
class CMSBuildBuilder : public CBuilder
{
protected:
		
	virtual bool Build();

public:

};

#endif

