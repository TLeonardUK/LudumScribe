// -----------------------------------------------------------------------------
// 	sorting.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of base classes used for implementing
//	sorting behaviour for collections.
// -----------------------------------------------------------------------------

/// -----------------------------------------------------------------------------
///  Base class for all comparison classes used to compare objects for 
//	 algorithms like sorting.
/// -----------------------------------------------------------------------------
public class Comparer<T>
{
	public abstract int Compare(T lvalue, T rvalue);
}
