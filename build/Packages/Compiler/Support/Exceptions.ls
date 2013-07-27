 // -----------------------------------------------------------------------------
// 	exceptions.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations o any objects used for 
//	exception handling.
//	This should never be modified as the compiler relies on the correct content 
//	and ordering of this file.
// -----------------------------------------------------------------------------
using native {NATIVE_PACKAGE_NAMESPACE}.Compiler.Support.Exceptions;

// -----------------------------------------------------------------------------
//	Used as a base for all objects which can be thrown.
// -----------------------------------------------------------------------------
public native("lsException") class Exception : object
{
	public native("ToString") override string ToString();
}

// -----------------------------------------------------------------------------
//	Throw when the user attempts to read out of bounds of a finite 
//	block of memory.
// -----------------------------------------------------------------------------
public native("lsOutOfBoundsException") class OutOfBoundsException : Exception
{
}

// -----------------------------------------------------------------------------
//	Throw when the user attempts to cast an object to an invalid type.
// -----------------------------------------------------------------------------
public native("lsInvalidCastException") class InvalidCastException : Exception
{
}

// -----------------------------------------------------------------------------
//	Throw when an internal error occurs inside the GC. This is kinda serious ;_;
// -----------------------------------------------------------------------------
public native("lsInternalGCException") class InternalGCException : Exception
{
}

// -----------------------------------------------------------------------------
//	Throw when we run out of memory to allocate.
// -----------------------------------------------------------------------------
public native("lsOutOfMemoryException") class OutOfMemoryException : Exception
{
}

// -----------------------------------------------------------------------------
//	Generic operation failed exception.
// -----------------------------------------------------------------------------
public native("lsOperationFailedException") class OperationFailedException : Exception
{
}

// -----------------------------------------------------------------------------
//	Throw when we attempt to get a non-existant key.
// -----------------------------------------------------------------------------
public class NonExistantKeyException : Exception
{
	public override string ToString()
	{
		return "Key specified does not exist in collection.";
	}	
}

// -----------------------------------------------------------------------------
//	Throw when we attempt to get a non-existant value.
// -----------------------------------------------------------------------------
public class NonExistantValueException : Exception
{
	public override string ToString()
	{
		return "Value specified does not exist in collection.";
	}	
}

// -----------------------------------------------------------------------------
//	Throw when we attempt to insert an already existing key into a collection.
// -----------------------------------------------------------------------------
public class DuplicateKeyException : Exception
{
	public override string ToString()
	{
		return "Attempt to insert duplicate key into collection.";
	}	
}
