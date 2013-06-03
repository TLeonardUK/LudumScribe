 // -----------------------------------------------------------------------------
// 	enumerators.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations o any objects used for 
//	exception handling.
//	This should never be modified as the compiler relies on the correct content 
//	and ordering of this file.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//	Used as a base for objects that can be enumerated over.
// -----------------------------------------------------------------------------
public interface IEnumerable
{
	public IEnumerator GetEnumerator();
}

// -----------------------------------------------------------------------------
//	Used as a base for objects that enumerate over collections.
// -----------------------------------------------------------------------------
public interface IEnumerator
{
	public object	Current();
	public bool		Next();
	public void   	Reset();
}