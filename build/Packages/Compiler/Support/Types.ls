// -----------------------------------------------------------------------------
// 	types.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of all default types used by the
//	language. This should never be modified as the compiler relies on the 
//	correct content and ordering of this file.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.Compiler.Support.Types;
using System.Collections.*;

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
	public native("ToInt")			int 			ToInt		();
	public native("ToFloat")		float 			ToFloat		();
	public native("ToChar")			int 			ToChar		();
	public native("Length")			int 			Length		();
	public native("GetIndex")		string 			GetIndex	(int index);
	public native("GetSlice")		string 			GetSlice	(int start_index);
	public native("GetSlice")		string 			GetSlice	(int start_index, int end_index);
	public native("FromIntToHex")	static string 	FromIntToHex(int chr);
	public native("FromChar")		static string 	FromChar	(int chr);
	public native("FromChars")		static string 	FromChars	(int[] chr);
	public native("HexToInt")		int 			HexToInt	();
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string TrimStart(string chars = " ") 
	{	
		int start_index = 0;
		bool found = true;
		
		for (int i = 0; i < Length() && found == true; i++, start_index++)
		{
			found = false;
			
			for (int k = 0; k < chars.Length(); k++)
			{
				if (this[i] == chars[k])
				{
					found = true;
					break;
				}
			}		
		}
		
		return this[(start_index - 1) : ];
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------	
	public string TrimEnd(string chars = " ")
	{	
		int end_index = Length();
		bool found = true;
		
		for (int i = Length() - 1; i >= 0 && found == true; i--, end_index--)
		{
			found = false;
			
			for (int k = 0; k < chars.Length(); k++)
			{
				if (this[i] == chars[k])
				{
					found = true;
					break;
				}
			}		
		}
		
		return this[ : (end_index + 1)];
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------	
	public string Trim(string chars = " ")
	{	
		return TrimStart(chars).TrimEnd(chars);
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string SubString(int offset, int count = -1)
	{	
		if (count == -1)
		{
			count = Length() - offset;
		}
		return this[offset : offset + count];
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string PadRight(int length, string padding = " ")
	{	
		string result = this;
		int offset = 0;
		while (result.Length() < length)
		{
			result += padding[(offset++) % padding.Length()];
		}		
		return result;
	}	
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string PadLeft(int length, string padding = " ")
	{	
		string result = this;
		int offset = 0;
		while (result.Length() < length)
		{
			result = padding[(offset++) % padding.Length()] + result;
		}		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string LimitEnd(int length, string postfix = " ...")
	{
		if (length <= postfix.Length())
		{
			return postfix[:length];
		}
		else
		{
			return this[:length - postfix.Length()] + postfix;
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string LimitStart(int length, string postfix = " ...")
	{
		if (length <= postfix.Length())
		{
			return postfix[:length];
		}
		else
		{
			int cutLength = (Length() - length) + postfix.Length();
			return postfix + this[cutLength:];
		}
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Reverse()
	{
		string result = "";
		
		for (int i = Length() - 1; i >= 0; i--)
		{
			result += this[i];
		}
		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string ToLower()
	{
		string result = "";
		
		int lower_bound = 65;//"A"[0];
		int higher_bound = 90;//"Z"[0];
		
		foreach (string chr in this)
		{
			int asc = chr.ToChar();
			if (asc >= lower_bound && asc <= higher_bound)
			{
				asc += 32;
			}
			result += string.FromChar(asc);
		}
		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string ToUpper()
	{
		string result = "";
		
		int lower_bound = 97;//"a"[0];
		int higher_bound = 122;//"z"[0];
		
		foreach (string chr in this)
		{
			int asc = chr.ToChar();
			if (asc >= lower_bound && asc <= higher_bound)
			{
				asc -= 32;
			}
			result += string.FromChar(asc);
		}
		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------	
	public bool EndsWith(string postfix)
	{
		return (this[-postfix.Length():] == postfix);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool StartsWith(string prefix)
	{
		return (this[:prefix.Length()] == prefix);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Remove(int start, int length)
	{
		return this[0:start] + this[start+length:];
	}	
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Insert(string value, int index)
	{
		return this[0:index] + value + this[index:];
	}	
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Replace(string what, string with)
	{
		string result = "";
	
		if (what == "")
		{
			return this;
		}
		
		for (int i = 0; i < Length(); i++)
		{
			string res = this[i : i + 1];
			if (i <= Length() - what.Length())
			{
				res = this[i : i + what.Length()];
			}
			
			if (res == what)
			{
				result += with;
				i += (what.Length() - 1);
				continue;
			}
			else
			{
				result += this[i : i+1];
			}		
		}
		
		return result;		
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Replace(int start, int length, string mid)
	{
		return this[0:start] + mid + this[start+length:];
	}	
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool Contains(string text)
	{
		return (IndexOf(text) >= 0);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool ContainsAny(string[] text)
	{
		return (IndexOfAny(text) >= 0);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int IndexOf(string needle, int start_index = 0)
	{
		string result = "";	
		if (needle == "")
		{
			return -1;
		}
		
		for (int i = start_index; i < Length() - needle.Length(); i++)
		{
			string res = this[i : i + needle.Length()];			
			if (res == needle)
			{
				return i;
			}
		}
		
		return -1;		
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int IndexOfAny(string[] needles, int start_index = 0)
	{
		string result = "";	
		if (needles.Length() == 0)
		{
			return -1;
		}
		
		for (int i = start_index; i < Length(); i++)
		{
			foreach (string needle in needles)
			{
				string res = this[i : i + needle.Length()];			
				if (res == needle)
				{
					return i;
				}
			}
		}
		
		return -1;	
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int LastIndexOf(string needle, int end_index = -1)
	{
		string result = "";	
		if (needle == "")
		{
			return -1;
		}
		
		if (end_index == -1)
		{
			end_index = Length() - 1;
		}
		
		for (int i = end_index; i >= 0; i--)
		{
			string res = this[i : i + needle.Length()];			
			if (res == needle)
			{
				return i;
			}
		}
		
		return -1;	
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int LastIndexOfAny(string[] needles, int end_index = -1)
	{
		string result = "";	
		if (needles.Length() == 0)
		{
			return -1;
		}
		
		if (end_index == -1)
		{
			end_index = Length() - 1;
		}
		
		for (int i = end_index; i >= 0; i--)
		{
			foreach (string needle in needles)
			{
				string res = this[i : i + needle.Length()];			
				if (res == needle)
				{
					return i;
				}
			}
		}
		
		return -1;	
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Filter(string allowed_chars, string replacement_char = "")
	{
		string result = "";
		for (int i = 0; i < Length(); i++)
		{
			string chr = GetIndex(i);
			bool found = false;
			
			for (int j = 0; j < allowed_chars.Length(); j++)
			{
				string chr2 = allowed_chars.GetIndex(j);
				if (chr == chr2)
				{
					found = true;
					break;
				}
			}
			
			if (found == true)
			{
				result += chr;
			}
			else
			{
				result += replacement_char;
			}
		}
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool IsHex()
	{
		for (int i = 0; i < Length(); i++)
		{
			int chr = GetIndex(i).ToChar();
			if (!(chr >= '0'.ToChar() && chr <= '9'.ToChar()) ||
				(chr >= 'A'.ToChar() && chr <= 'F'.ToChar()) ||
				(chr >= 'a'.ToChar() && chr <= 'f'.ToChar()))
			{
				return false;
			}
		}
		return true;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool IsNumeric()
	{
		for (int i = 0; i < Length(); i++)
		{
			int chr = GetIndex(i).ToChar();
			if (!(chr >= '0'.ToChar() && chr <= '9'.ToChar()))
			{
				return false;
			}
		}
		return true;
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Join(string[] haystack)
	{
		string result = "";
		foreach (string s in haystack)
		{
			if (result != "")
			{
				result += this;
			}
			result += s;
		}
		return result;
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Join(List<string> haystack)
	{
		string result = "";
		foreach (string s in haystack)
		{
			if (result != "")
			{
				result += this;
			}
			result += s;
		}
		return result;
	}
	
	// -------------------------------------------------------------------------
	//	TODO: Move into another class, this is to specialized for the
	//		  string class.
	// -------------------------------------------------------------------------
	public string GetLine(int lineIndex)
	{
		string line;
		int lineOffset = 0;
		int startIndex = 0;

		while (true)
		{
			int offset = this.IndexOf('\n', startIndex);
			if (offset <= 0)
			{
				break;
			}
		
			line = this.SubString(startIndex, offset - startIndex);
			if (lineOffset == lineIndex)
			{
				return line;
			}
			lineOffset++;

			startIndex = offset + 1;
		}

		line = this.SubString(startIndex, this.Length() - startIndex);

		if (lineOffset == lineIndex)
		{
			return line;
		}
		else
		{
			return "";
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string[] Split(string seperator, int max_splits = -1, bool remove_duplicates = false)
	{		
		string[] result = new string[0];
		string split = "";
		
		if (seperator == "")
		{
			return { this };
		}
		
		for (int i = 0; i < Length(); i++)
		{
			string res = this[i : i + 1];
			if (i <= Length() - seperator.Length())
			{
				res = this[i : i + seperator.Length()];
			}
			
			if (res == seperator && (result.Length() < max_splits || max_splits <= 0))
			{
				if (split != "" || remove_duplicates == false)
				{
					result.AddLast(split);
					split = "";
				}
				i += (seperator.Length() - 1);
				continue;
			}
			else
			{
				split += this[i : i+1];
			}		
		}
		
		if (split != "" || remove_duplicates == false)
		{
			result.AddLast(split);
			split = "";
		}
		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Format(object[] args)
	{		
		int arg_index = 0;
		
		string result = "";
		for (int i = 0; i < this.Length(); i++)
		{
			string chr = this[i];
			if (chr == "%" && i < this.Length() - 1)
			{
				string next = this[++i];
				switch (next)
				{
					case "i":
					{
						result += <int>args[arg_index++];
						break;
					}
					case "f":
					{
						result += <float>args[arg_index++];
						break;
					}
					case "s":
					{
						result += <string>args[arg_index++];
						break;
					}
					case "x":
					{
						result += string.FromIntToHex(<int>args[arg_index++]).ToLower();
						break;
					}
					case "X":
					{
						result += string.FromIntToHex(<int>args[arg_index++]).ToUpper();
						break;
					}
					case "f":
					{
						result += <float>args[arg_index++];
						break;
					}
					case "%":
					{
						result += "%";
						break;
					}					
					default:
					{
						i--;
						result += "%";
						break;
					}
				}		
			}
			else
			{
				result += chr;
			}
		}		
		return result;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
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
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public StringEnumerator(string value)
	{
		m_value = value;
		m_index = 0;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public object Current()
	{
		return m_value[m_index - 1];
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool	Next()
	{
		m_index++;
		return (m_index <= m_value.Length());
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
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
//	GetType();
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
	public native("Resize")				void		Resize		(int size);
	
	public native("SetIndex")			void	 	SetIndex	(int index, T value, bool postfix = false);
	public native("GetIndex")			T		 	GetIndex	(int index);
	public native("ClearIndex")			void		ClearIndex	(int index);
	
	public native("GetSlice")			T[]			GetSlice	(int start_index);
	public native("GetSlice")			T[]	 		GetSlice	(int start_index, int end_index);
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Shift(int offset)
	{
		// Shift to the left.
		if (offset < 0)
		{
			for (int i = 0; i < Length(); i++)
			{
				int new_index = i + offset;
				if (new_index >= 0)
				{
					SetIndex(new_index, GetIndex(i));
				}
				if (i >= Length() + offset)
				{
					ClearIndex(i);
				}
			}		
		}
		
		// Shift to the right.
		else if (offset > 0)
		{
			for (int i = Length() - 1; i >= 0; i--)
			{
				int new_index = i + offset;
				if (new_index < Length())
				{
					SetIndex(new_index, GetIndex(i));
				}
				if (i <= offset)
				{
					ClearIndex(i);
				}
			}		
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddFirst(T value)
	{
		Resize(Length() + 1);
		Shift(1);
		SetIndex(0, value);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddFirst(T[] value)
	{
		Resize(Length() + value.Length());
		Shift(value.Length());
		for (int i = 0; i < value.Length(); i++)
		{
			SetIndex(i, value.GetIndex(i));
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddLast(T value)
	{
		Resize(Length() + 1);
		SetIndex(Length() - 1, value);	
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddLast(T[] value)
	{
		Resize(Length() + value.Length());
		for (int i = 0; i < value.Length(); i++)
		{
			SetIndex((Length() - value.Length()) + i, value.GetIndex(i));
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int Clear()
	{
		for (int i = 0; i < Length(); i++)
		{
			ClearIndex(i);
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T[] Clone()
	{
		T[] newArray = new T[Length()];
		for (int i = 0; i < Length(); i++)
		{
			newArray[i] = GetIndex(i);
		}
		return newArray;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void CopyTo(T[] other)
	{
		for (int i = 0; i < Length(); i++)
		{
			other[i] = GetIndex(i);
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool Contains(T needle)
	{
		for (int i = 0; i < Length(); i++)
		{
			if (GetIndex(i) == needle)
			{
				return true;
			}
		}		
		return false;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Replace(T needle, T other)
	{
		for (int i = 0; i < Length(); i++)
		{
			if (GetIndex(i) == needle)
			{
				SetIndex(i, other);
			}
		}
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Reverse()
	{
		for (int i = 0; i < Length() / 2; i++)
		{
			SetIndex(i, GetIndex(Length() - (i + 1)));
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Remove(T needle)
	{
		for (int i = 0; i < Length(); i++)
		{
			if (GetIndex(i) == needle)
			{
				for (int j = i; j < Length() - 1; j++)
				{
					SetIndex(j, GetIndex(j + 1));
				}			
				Resize(Length() - 1);
			}
		}			
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T RemoveFirst()
	{
		T val = GetIndex(0);
		Shift(-1);
		Resize(Length() - 1);
		return val;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T RemoveLast()
	{
		T val = GetIndex(Length() - 1);
		Resize(Length() - 1);
		return val;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string Insert(T value, int index)
	{
		Resize(Length() + 1);
		SetIndex(index, value);
		for (int j = index; j < Length() - 1; j++)
		{
			SetIndex(j, GetIndex(j + 1));
		}			
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T[] SubArray(int start, int len = -1)
	{
		if (len <= -1)
		{
			len = Length() - start;
		}
		return GetSlice(start, start + len);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void TrimStart(T needle)
	{
		for (int start_index = 0; start_index < Length(); start_index++)
		{
			if (GetIndex(start_index) != needle)
			{
				if (start_index > 0)
				{
					Shift(-(start_index - 1));
					Resize(start_index);
				}
				return;
			}
		}
		Resize(0);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void TrimEnd(T needle)
	{
		for (int start_index = Length() - 1; start_index >= 0; start_index--)
		{
			if (GetIndex(start_index) != needle)
			{
				Resize(start_index + 1);
				return;
			}
		}
		Resize(0);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Trim(T needle)
	{
		TrimStart(needle);
		TrimEnd(needle);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string PadLeft(int len, T padding)
	{	
		if (Length() < len)
		{
			int old_len = Length();
			Resize(len);
			Shift(len - old_len);

			for (int i = 0; i < len - old_len; i++)
			{
				SetIndex(i, padding);
			}
		}
	}	
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public string PadRight(int len, T padding)
	{	
		if (Length() < len)
		{
			int old_len = Length();
			Resize(len);

			for (int i = old_len - 1; i < len; i++)
			{
				SetIndex(i, padding);
			}
		}
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int IndexOf(T value, int start_index = -1)
	{
		for (int i = start_index; i < Length(); i++)
		{
			if (GetIndex(i) == value)
			{
				return i;
			}
		}
		return -1;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int IndexOfAny(T[] value, int start_index = -1)
	{
		foreach (T needle in value)
		{
			for (int i = start_index; i < Length(); i++)
			{
				if (GetIndex(i) == needle)
				{
					return i;
				}
			}
		}
		return -1;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int LastIndexOf(T value, int end_index = -1)
	{
		for (int i = end_index; i >= 0; i--)
		{
			if (GetIndex(i) == value)
			{
				return i;
			}
		}
		return -1;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int LastIndexOfAny(T[] value, int end_index = -1)
	{
		foreach (T needle in value)
		{
			for (int i = end_index; i >= 0; i--)
			{
				if (GetIndex(i) == needle)
				{
					return i;
				}
			}
		}
		return -1;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	// TODO: Got to change this to use a list or something, using T[][] causes this
	//		 generic class to keep being instanced recursively.
	/*
	public T[][] Split(T seperator, int max_splits = 0, bool remove_duplicates = false)
	{
		T[][] result = new T[0];
		T[]   split = new T[0];
		
		for (int i = 0; i < Length(); i++)
		{
			T res = GetIndex(i);
			
			if (res == seperator && (result.Length() < max_splits || max_splits <= 0))
			{
				if (split.Length() > 0 || remove_duplicates == false)
				{
					result.AddLast(split);
					split = new T[0];
				}
				continue;
			}
			else
			{
				split.AddLast(res);
			}		
		}

		if (split.Length() > 0 || remove_duplicates == false)
		{
			result.AddLast(split);
		}
		
		return result;
	}
	*/
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Sort(Comparer<T> comparer)
	{
		QuickSort(comparer, 0, Length() - 1);
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------	
	private void QuickSort(Comparer<T> comparer, int left, int right)
	{
		if (left < right)
		{
			int pivot = left + (right - left) / 2;
			pivot = QuickSortPartition(comparer, left, right, pivot);
			QuickSort(comparer, left, pivot - 1);
			QuickSort(comparer, pivot + 1, right);
		}	
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------		
	private int QuickSortPartition(Comparer<T> comparer, int left, int right, int pivot)
	{
		T pivot_value = GetIndex(pivot);
		
		SetIndex(pivot, GetIndex(right));
		SetIndex(right, pivot_value);
		
		int store_index = left;
		
		for (int i = left; i < right; i++)
		{
			T i_value = GetIndex(i);
			
			if (comparer.Compare(i_value, pivot_value) <= 0)
			{
				SetIndex(i, GetIndex(store_index));
				SetIndex(store_index, i_value);
				store_index++;
			}
		}
		
		T store_value = GetIndex(store_index);
		
		SetIndex(store_index, GetIndex(right));
		SetIndex(right, store_value);
		
		return store_index;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
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

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ArrayEnumerator(T value)
	{
		m_value = value;
		m_index = 0;
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public object Current()
	{
		return m_value[m_index - 1];
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool	Next()
	{
		m_index++;
		return (m_index <= m_value.Length());
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Reset()
	{
		m_index = 0;
	}	
}
