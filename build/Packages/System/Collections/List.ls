// -----------------------------------------------------------------------------
// 	list.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package provids an implementation of a doubly linked list.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//	Implements a simple singly linked list
// -----------------------------------------------------------------------------
public class List<T> : IEnumerable
{
	protected ListNode<T> m_head;
	protected int m_size;

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public List()
	{
		m_head = new ListNode<T>();
		m_head.Next = m_head;
		m_head.Prev = m_head;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Replace(T other, T replacement)
	{	
		ListNode<T> node = m_head.Next;
		while (node != m_head)
		{
			if (node.Value == other) 
			{
				node.Value = replacement;
			}
			node = node.Next;
		}
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Insert(int offset, T other)
	{	
		int index = 0;
		ListNode<T> node = m_head.Next;
		while (node != m_head)
		{
			if (index == offset)
			{				
				new ListNode<T>(other, node, node.Prev);
				m_size++;
				return;
			}
			node = node.Next;
			index++;
		}	
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void SetIndex(int offset, T other)
	{	
		ListNode<T> node = m_head.Next;
		int index = 0;
		while (node != m_head)
		{
			if (index == offset) 
			{
				node.Value = other;
			}
			node = node.Next;
			index++;
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddLast(List<T> other)
	{	
		ListNode<T> node = other.m_head.Next;
		while (node != other.m_head)
		{
			AddLast(node.Value);
			node = node.Next;
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddLast(T value)
	{	
		new ListNode<T>(value, m_head, m_head.Prev);
		m_size++;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddFirst(List<T> other)
	{	
		ListNode<T> node = other.m_head.Next;
		while (node != other.m_head)
		{
			AddFirst(node.Value);
			node = node.Next;
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void AddFirst(T value)
	{	
		new ListNode<T>(value, m_head.Next, m_head);
		m_size++;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Remove(T value)
	{	
		ListNode<T> node = m_head.Next;
		while (node != m_head)
		{
			if (node.Value == value)
			{
				node.Remove();
				m_size--;
			}
			node = node.Next;
		}
	}
		
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T RemoveFirst()
	{	
		T data = m_head.Next.Value;
		m_head.Next.Remove();
		m_size--;
		return data;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T RemoveLast()
	{	
		T data = m_head.Prev.Value;
		m_head.Prev.Remove();
		m_size--;
		return data;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Clear()
	{
		m_head.Next = m_head;
		m_head.Prev = m_head;
		m_size = 0;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int Count()
	{
		return m_size;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool Contains(T value)
	{	
		return (IndexOf(value) >= 0);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public int IndexOf(T value)
	{	
		int index = 0;
		ListNode<T> node = m_head.Next;
		while (node != m_head)
		{
			if (node.Value == value)
			{
				return index;
			}
			node = node.Next;
			index++;
		}
		return -1;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public T GetIndex(int index)
	{	
		int i = 0;
		ListNode<T> node = m_head.Next;
		while (node != m_head)
		{
			if (i == index)
			{
				return node.Value;
			}
			node = node.Next;
			i++;
		}
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public IEnumerator GetEnumerator()
	{
		return (new ListEnumerator<T>(this, m_head));
	}
}

/// -----------------------------------------------------------------------------
//	Holds a single value in a linked list.
/// -----------------------------------------------------------------------------
private class ListNode<T>
{
	public T Value;
	public ListNode<T> Next;
	public ListNode<T> Prev;

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ListNode()
	{
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ListNode(T value, ListNode<T> next, ListNode<T> prev)
	{
		Value = value;
		Next = next;
		Prev = prev;
		Next.Prev = this;
		Prev.Next = this;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Remove()
	{
		Next.Prev = Prev;
		Prev.Next = Next;
	}
}

/// -----------------------------------------------------------------------------
///  List enumerators are used to provide support for foreach actions against
//	 list classes.
/// -----------------------------------------------------------------------------
public sealed class ListEnumerator<T> : IEnumerator
{
	private List<T>	 		m_list;
	private ListNode<T> 	m_head;
	private ListNode<T> 	m_current;

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public ListEnumerator(List<T> list, ListNode<T> head)
	{
		m_list = list;
		m_head = head;
		m_current = m_head;
	}

	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public object Current()
	{
		return m_current.Value;
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public bool	Next()
	{
		m_current = m_current.Next;
		return (m_current != m_head);
	}
	
	// -------------------------------------------------------------------------
	//
	// -------------------------------------------------------------------------
	public void Reset()
	{
		m_current = m_head;
	}	
}
