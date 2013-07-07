// -----------------------------------------------------------------------------
// 	exceptions.hpp
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of exception handling code.
//	This should never be modified as the compiler relies on the correct content 
//  and ordering of this file.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_EXCEPTIONS__
#define __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_EXCEPTIONS__

#include "Packages/Native/Win32/Compiler/Support/Types.hpp"

// -----------------------------------------------------------------------------
//	Used as a base for all objects which can be thrown.
// -----------------------------------------------------------------------------
class lsException : public lsObject
{
private:
	lsString m_message;

public:
	lsException() :
		m_message("Exception")
	{	
	}
	
	lsException(lsString message) :
		m_message(message)
	{
	}
	
	virtual lsString ToString()
	{
		return m_message;
	}

};

// -----------------------------------------------------------------------------
//	Throw when the user attempts to read out of bounds of a finite 
//	block of memory.
// -----------------------------------------------------------------------------
class lsOutOfBoundsException : public lsException
{
public:
	lsOutOfBoundsException() : 
		lsException("Attempt to read outside boundry.")
	{
	}
};

// -----------------------------------------------------------------------------
//	Throw when the user attempts to cast an object to an invalid type.
// -----------------------------------------------------------------------------
class lsInvalidCastException : public lsException
{
public:
	lsInvalidCastException() : 
		lsException("Attempt to cast object to incompatible type.")
	{
	}
};

// -----------------------------------------------------------------------------
//	Throw when an internal error occurs inside the GC. This is kinda serious ;_;
// -----------------------------------------------------------------------------
class lsInternalGCException : public lsException
{
public:
	lsInternalGCException() : 
		lsException("GC encountered an internal error.")
	{
	}
};

// -----------------------------------------------------------------------------
//	Throw when we run out of memory to allocate.
// -----------------------------------------------------------------------------
class lsOutOfMemoryException : public lsException
{
public:
	lsOutOfMemoryException() : 
		lsException("Ran out of memory during object allocation.")
	{
	}
};

// -----------------------------------------------------------------------------
//	Generic fail exception.
// -----------------------------------------------------------------------------
class lsOperationFailedException : public lsException
{
public:
	lsOperationFailedException() : 
		lsException("Operation failed to complete.")
	{
	}
};

#endif // __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_EXCEPTIONS__

