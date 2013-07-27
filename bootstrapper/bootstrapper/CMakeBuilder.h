/* *****************************************************************

		CMakeBuilder.h

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */
#pragma once
#ifndef _CMAKEBUILDER_H_
#define _CMAKEBUILDER_H_

#include "CToken.h"
#include "CBuilder.h"

class CTranslationUnit;

// =================================================================
//	Responsible for compiling translated source code into a final
//	binary executable using Make.
// =================================================================
class CMakeBuilder : public CBuilder
{
protected:
		
	virtual bool Build();

public:

};

#endif

