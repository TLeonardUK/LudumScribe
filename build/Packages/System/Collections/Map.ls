// -----------------------------------------------------------------------------
// 	list.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package provids an implementation of a doubly linked list.
// -----------------------------------------------------------------------------
using List;

// -----------------------------------------------------------------------------
//	Implements a key-value pair collection.
// -----------------------------------------------------------------------------
public class Map<KeyType, ValueType> : IEnumerable
{
	private List<MapPair<KeyType, ValueType>> m_list;

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public Map()
	{
		m_list = new List<MapPair<KeyType, ValueType>>();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ValueType[] GetValues()
	{	
		ValueType[] values = new ValueType[m_list.Count()];
		int index = 0;
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			values[index++] = pair.Value;
		}
		return values;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public KeyType[] GetKeys()
	{	
		KeyType[] values = new KeyType[m_list.Count()];
		int index = 0;
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			values[index++] = pair.Key;
		}
		return values;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public MapPair<KeyType, ValueType>[] GetPairs()
	{	
		MapPair<KeyType, ValueType>[] values = new MapPair<KeyType, ValueType>[m_list.Count()];
		int index = 0;
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			values[index++] = pair;
		}
		return values;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ValueType GetValue(KeyType key)
	{	
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			if (pair.Key == key)
			{
				return pair.Value;
			}
		}
		throw new NonExistantKeyException();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Insert(KeyType key, ValueType value)
	{	
		if (ContainsKey(key))
		{
			throw new DuplicateKeyException();
		}
		
		MapPair<KeyType, ValueType> pair = new MapPair<KeyType, ValueType>();
		pair.Key = key;
		pair.Value = value;		
		m_list.AddLast(pair);		
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void RemoveKey(KeyType key)
	{	
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			if (pair.Key == key)
			{
				m_list.Remove(pair);
				return;
			}
		}
		throw new NonExistantKeyException();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void RemoveValue(ValueType value)
	{	
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			if (pair.Value == value)
			{
				m_list.Remove(pair);
				return;
			}
		}
		throw new NonExistantValueException();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Clear()
	{
		m_list.Clear();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int Count()
	{
		return m_list.Count();
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool ContainsKey(KeyType key)
	{	
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			if (pair.Key == key)
			{
				return true;
			}
		}
		return false;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool ContainsValue(ValueType value)
	{	
		foreach (MapPair<KeyType, ValueType> pair in m_list)
		{
			if (pair.Value = value)
			{
				return true;
			}
		}
		return false;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public IEnumerator GetEnumerator()
	{
		return m_list.GetEnumerator();
	}
}

/// -----------------------------------------------------------------------------
//	Holds a single value in a linked list.
/// -----------------------------------------------------------------------------
public class MapPair<KeyType, ValueType>
{
	public KeyType Key;
	public ValueType Value;

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public MapPair(KeyType k, ValueType v)
	{
		Key = k;
		Value = v;
	}
}
