/* *****************************************************************

		Compiler Bootstrapper Implementation

		This project is used as a bootstrap implementation of the
		language. It compiles the initial compiler so that the
		compiler can eventually become self-hosting.

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include <string.h>
#include <stdio.h>
#include "CCompiler.h"

// =================================================================
//	Entry point
// =================================================================
int main(int argc, char* argv[])
{
#ifdef NDEBUG
	try
	{
#endif
		CCompiler compiler;
		return compiler.Process(argc, argv);
#ifdef NDEBUG
	}
	catch (...)
	{
		printf("Compiler threw unhandled exception and aborted unexpectedly.");
		return 1;
	}
#endif
}