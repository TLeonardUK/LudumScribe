// -----------------------------------------------------------------------------
// 	console.cpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains code required to interact with the console.
// -----------------------------------------------------------------------------

#include "Packages/Native/CPP/Default/System/Console.hpp"

// -----------------------------------------------------------------------------
//	Writes a string of text to the console.
// -----------------------------------------------------------------------------
void lsConsole::Write(lsString output)
{
	printf("%s", output.ToCString());
}

// -----------------------------------------------------------------------------
//	Writes a string of text to the console and appends a new line.
// -----------------------------------------------------------------------------
void lsConsole::WriteLine(lsString output)
{
	printf("%s\n", output.ToCString());
}

// -----------------------------------------------------------------------------
//	Reads next character from console. Blocks until character available.
// -----------------------------------------------------------------------------
int lsConsole::ReadChar()
{
	return getchar();
}

