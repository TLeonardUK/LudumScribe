// -----------------------------------------------------------------------------
// 	runtime.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the default runtime functionality.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------
using native {NATIVE_PACKAGE_NAMESPACE}.Compiler.Support.Runtime;

// Nothing is declared directly in this file. All work is performed by the 
// native runtime source code.
//
// The runtime code includes two main functions.
//	void lsRuntimeInit();
//	void lsRuntimeDeInit();
//
// These functions are called before any translated code is executed and
// after all translated code has been executed. They should be used
// for initializing or deinitializing any runtime elements (for example
// installing error handlers, starting up IP stack, etc).