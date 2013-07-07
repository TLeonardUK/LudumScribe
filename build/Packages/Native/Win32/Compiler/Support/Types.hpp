// -----------------------------------------------------------------------------
// 	types.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of all default types used by the
//	language. This should never be modified as the compiler relies on the 
//	correct content and ordering of this file.
// -----------------------------------------------------------------------------

#ifndef __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_TYPES__
#define __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_TYPES__

#define _CRT_SECURE_NO_WARNINGS // GTFO windows secure functions.

#include <assert.h>
#include <stdio.h>
#include <cstring>
#include <cstdlib>
#include <cstdarg>

// Forward declarations.
class lsString;
template<typename T> class lsArray;

// -----------------------------------------------------------------------------
//	All objects that derive from this class are garbage collected.
// -----------------------------------------------------------------------------
class lsGCObject 
{
private:

public:
	virtual ~lsGCObject					();

	void* operator new					(size_t size);	
	void  operator delete				(void* ptr);		
	
	static lsGCObject* 	GCAllocate		(int size);
	static void 		GCCollect		(bool full);	
	
};

// -----------------------------------------------------------------------------
//	All objects derive from the base object class.
// -----------------------------------------------------------------------------
class lsObject : public virtual lsGCObject
{
public:
	virtual lsString ToString();
	
};

// -----------------------------------------------------------------------------
//	This function is responsible for determening if an object can be cast
//	to another type of object at runtime. Invoked when either upcasting or 
//	casting to an interface.
// -----------------------------------------------------------------------------
template<typename ToType, typename FromType>
ToType lsCast(FromType val, bool throw_error_on_fail)
{
	ToType result = dynamic_cast<ToType>(val);
	if (result == NULL && throw_error_on_fail == true)
	{
		throw new lsInvalidCastException();
	}	
	return result;
}

// -----------------------------------------------------------------------------
//	Used as an internal reference-counted representation of a strings character
//	buffer.
// -----------------------------------------------------------------------------
class lsStringBuffer
{
private:
	int m_ref_count;

public:
	char*			Buffer;
	int				Length;

	lsStringBuffer();
	
	void Release();
	void Retain();
	
	static lsStringBuffer* Allocate(int size);

};

// -----------------------------------------------------------------------------
//	The string class holds a single string of characters. Strings are 
//	immutable, all operations produce a new string object.
//
//	Strings internally hold an instance to lsStringBuffer which contains
//	the actual character buffer and uses reference counting to determine its
//	lifecycle. This has significant performance benefits over cluttering up
//	the GC with string instances.
// -----------------------------------------------------------------------------
class lsString
{
private:
	lsStringBuffer* m_buffer;
	
public:

	// -------------------------------------------------------------------------
	//	Constructors.
	// -------------------------------------------------------------------------
	~lsString();
	lsString();
	lsString(const lsString& string);
	lsString(lsStringBuffer* buffer);
	lsString(const char* buffer);
	lsString(const char* buffer, int length);
	lsString(char chr);
	lsString(lsArray<int>* chrs);
	lsString(int value);
	lsString(float value);
	
	// -------------------------------------------------------------------------
	//	Properties.
	// -------------------------------------------------------------------------
	int Length() const;
	lsString GetIndex(int index) const;
	lsString GetSlice(int start_pos) const;
	lsString GetSlice(int start_pos, int end_pos) const;
	
	// -------------------------------------------------------------------------
	//	Conversions.
	// -------------------------------------------------------------------------
	const char* ToCString() const;
	float ToFloat() const;
	int ToInt() const;
	int ToChar() const;
	int HexToInt() const;

	static lsString FromIntToHex(int value);
	static lsString FromChar(int chr);
	static lsString FromChars(lsArray<int>* chr);
	
	// -------------------------------------------------------------------------
	//	Comparisons.
	// -------------------------------------------------------------------------
	int Compare(const lsString& other) const;
	lsString& operator =(const lsString& other);
	lsString operator +(const lsString& other) const;
	lsString& operator +=(const lsString& other);
	char operator [](int index) const;
	bool operator ==(const lsString& other) const;
	bool operator !=(const lsString& other) const;
	bool operator <(const lsString& other) const;
	bool operator >(const lsString& other) const;
	bool operator <=(const lsString& other) const;
	bool operator >=(const lsString& other) const;

};

// -----------------------------------------------------------------------------
//	The array is a special class that all arrays are derived from. Arrays do
//	not derive themselves from object and are handled differently. This class
//	is private as it is used internally and should not be handled directly by the 
//  user.
// -----------------------------------------------------------------------------
template<typename T>
class lsArray : public lsObject
{
private:
	T   m_default;
	T*  m_buffer;
	int m_length;
	
public:

	// -------------------------------------------------------------------------
	//	Constructors.
	// -------------------------------------------------------------------------
	virtual ~lsArray()
	{
		delete[] m_buffer;
		m_buffer = NULL;
	}
	
	lsArray(int size) :
		m_length(size),
		m_buffer(new T[size])
	{
	}
	
	lsArray(lsArray<T>* other, int offset, int length) :
		m_length(length),
		m_buffer(new T[length])
	{
		for (int i = offset; i < offset + length; i++)
		{
			m_buffer[i - offset] = other->m_buffer[i];
		}
	}
	
	lsArray(lsArray<T>* other) :
		m_length(other->m_length),
		m_buffer(new T[other->m_length])
	{	
		for (int i = 0; i < other->m_length; i++)
		{
			m_buffer[i] = other->m_buffer[i];
		}	
	}

	lsArray* Init(T value)
	{
		for (int i = 0; i < m_length; i++)
		{
			m_buffer[i] = value;
		}
		m_default = value;
		return this;
	}

	// -------------------------------------------------------------------------
	//	Properties.
	// -------------------------------------------------------------------------
	int Length() const
	{
		return m_length;
	}
	
	void Resize(int size)
	{
		T* new_buffer = new T[size];
		for (int i = 0; i < size; i++)
		{
			if (i < m_length)
			{
				new_buffer[i] = m_buffer[i];
			}
			else
			{
				new_buffer[i] = m_default;
			}
		}
		
		delete[] m_buffer;
		m_buffer = new_buffer;
		m_length = size;
	}

	T GetIndex(int index) const
	{
#ifdef _DEBUG
		if (index < 0 || index >= m_length)
		{
			throw new lsOutOfBoundsException();		
		}
#endif
		return m_buffer[index];
	}
	
	T SetIndex(int index, T value, bool postfix = false)
	{
#ifdef _DEBUG
		if (index < 0 || index >= m_length)
		{
			throw new lsOutOfBoundsException();		
		}
#endif
		T old_value = m_buffer[index];
		m_buffer[index] = value;
		
		if (postfix == true)
		{
			return old_value;
		}
		else
		{
			return value;
		}
	}
	
	void ClearIndex(int index)
	{
#ifdef _DEBUG
		if (index < 0 || index >= m_length)
		{
			throw new lsOutOfBoundsException();		
		}
#endif
		m_buffer[index] = m_default;
	}
	
	lsArray<T>* GetSlice(int start_pos) 
	{
		return GetSlice(start_pos, m_length);
	}

	lsArray<T>* GetSlice(int start_pos, int end_pos) 
	{
		if (start_pos < 0)
		{
			start_pos += m_length;
			if (start_pos < 0)
			{
				start_pos = 0;
			}		
		}
		else if (start_pos > m_length)
		{
			start_pos = m_length;
		}
		
		if (end_pos < 0)
		{
			end_pos += m_length;
		}
		else if (end_pos > m_length)
		{
			end_pos = m_length;
		}

		if (start_pos >= end_pos)
		{
			return new lsArray<T>(0);
		}
		else if (start_pos == 0 && end_pos == m_length)
		{
			return new lsArray<T>(this);	
		}
		else
		{
			return new lsArray<T>(this, start_pos, end_pos - start_pos);	
		}
	}
	
	virtual lsString ToString() 
	{
		return lsString("array[") + m_length + "]";
	}	

	T operator [](int index) const
	{
		return GetIndex(index);
	}
	
};

// -----------------------------------------------------------------------------
//	Used to construct an array from an initialization list.
// -----------------------------------------------------------------------------
template<typename ElementType>
lsArray<ElementType>* lsConstructArray(int length, ...)
{
	va_list args;
	lsArray<ElementType>* arr = new lsArray<ElementType>(length);

	va_start(args, length);          
	for (int i = 0; i < length; i++) 
	{
		arr->SetIndex(i, va_arg(args, ElementType));
	}
	va_end(args);    

	return arr;
}

#endif // __LS_PACKAGES_NATIVE_WIN32_COMPILER_SUPPORT_TYPES__

