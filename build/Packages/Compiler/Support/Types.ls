// -----------------------------------------------------------------------------
// 	types.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of all default types used by the
//	language. This should never be modified as the compiler relies on the 
//	correct content and ordering of this file.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.Types;

// =============================================================================
//	Values Types
// =============================================================================

// -----------------------------------------------------------------------------
//	The boolean type allows basic boolean operations. The reason you will see
//	it as a class here when its technically a primitive is to allow the user
//	to access general properties and methods relating to it.
//		eg. bool.MinValue
// -----------------------------------------------------------------------------
public sealed native("bool") box("BoolBox") class @bool : null
{
}

// -----------------------------------------------------------------------------
//	The integer type works in the same way as the boolean one above. The size
//	of this data type depends on if the result is compiled as 64 or 32 bit. In
//	which case its 4 and 8 bytes long respectively.
// -----------------------------------------------------------------------------
public sealed native("int") box("IntBox") class @int : null
{
}

// -----------------------------------------------------------------------------
//	The integer type works in the same way as the other primitive types. 
//	Floating point numbers are always single precision.
// -----------------------------------------------------------------------------
public sealed native("float") box("FloatBox") class @float : null
{
}

// -----------------------------------------------------------------------------
//	The string class holds a single string of characters. Strings are 
//	immutable, all operations produce a new string object.
// -----------------------------------------------------------------------------
public sealed native("lsString") box("StringBox") class @string : null, IEnumerable
{
	public native("ToInt")		int 	ToInt		();
	public native("ToFloat")	float 	ToFloat		();
	public native("Length")		int 	Length		();
	public native("GetIndex")	int 	GetIndex	(int index);
	public native("GetSlice")	string 	GetSlice	(int start_index);
	public native("GetSlice")	string 	GetSlice	(int start_index, int end_index);
	
	public IEnumerator GetEnumerator()
	{
		return (new StringEnumerator(this));
	}
}

/// -----------------------------------------------------------------------------
///  String enumerators are used to provide support for foreach actions against
//	 the string data type.
/// -----------------------------------------------------------------------------
public sealed class StringEnumerator : IEnumerator
{
	private string m_value;
	private int m_index;

	public StringEnumerator(string value)
	{
		m_value = value;
		m_index = 0;
	}

	public object Current()
	{
		return m_value[m_index - 1];
	}
	
	public bool	Next()
	{
		m_index++;
		return (m_index <= m_value.Length());
	}
	
	public void Reset()
	{
		m_index = 0;
	}	
}

// =============================================================================
//	Reference Types
// =============================================================================

// -----------------------------------------------------------------------------
//	All objects derive from the base object class.
// -----------------------------------------------------------------------------
public native("lsObject") class @object : null
{
	public native("ToString") virtual string ToString();
}

/// -----------------------------------------------------------------------------
///	The array is a special class that all arrays are derived from. This class 
///	should never be instantiated or used directly, instead you should access it
//	by declaring data types in typical array syntax, eg. string[]
/// -----------------------------------------------------------------------------
public sealed native("lsArray") class @array<T> : @object, IEnumerable
{
	public native("ToString") override 	string 		ToString	();
	public native("Length")				int 		Length		();
	public native("SetIndex")			void	 	SetIndex	(int index, T value);
	public native("GetIndex")			T		 	GetIndex	(int index);
	public native("GetSlice")			T[]			GetSlice	(int start_index);
	public native("GetSlice")			T[]	 		GetSlice	(int start_index, int end_index);
	
	public IEnumerator GetEnumerator()
	{
		return (new ArrayEnumerator<T[]>(this));
	}
}

/// -----------------------------------------------------------------------------
///  Array enumerators are used to provide support for foreach actions against
//	 array data types.
/// -----------------------------------------------------------------------------
public sealed class ArrayEnumerator<T> : IEnumerator
{
	private T 	m_value;
	private int m_index;

	public ArrayEnumerator(T value)
	{
		m_value = value;
		m_index = 0;
	}

	public object Current()
	{
		return m_value[m_index - 1];
	}
	
	public bool	Next()
	{
		m_index++;
		return (m_index <= m_value.Length());
	}
	
	public void Reset()
	{
		m_index = 0;
	}	
}
