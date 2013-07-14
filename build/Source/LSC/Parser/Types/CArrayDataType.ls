// -----------------------------------------------------------------------------
// 	CArrayDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CArrayDataType : CObjectDataType
{
	public CDataType ElementType;
	
	public CArrayDataType(CToken token, CDataType type)
	{
		Token = token;
		ElementType = type;
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
		List<CDataType> args = new List<CDataType>();
		args.AddLast(ElementType);

		CDataType type = semanter.GetContext().GetASTRoot().FindDataType(semanter, "array", args, true);
		return (type.GetClass(semanter) as CClassASTNode);
	}
	
	public virtual override CClassASTNode GetBoxClass(CSemanter semanter)
	{
		return null;
	}
	
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		CArrayDataType dt = (type as CArrayDataType);
		CNullDataType otherNull = (type as CNullDataType);
		if (otherNull != null)
		{
			return true;
		}
		return	dt != null && 
				dt.ElementType.IsEqualTo(semanter, ElementType);
	}
	
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
		CObjectDataType obj = (type as CObjectDataType);
		CArrayDataType arr = (type as CArrayDataType);

		if (IsEqualTo(semanter, type) == true)
		{
			return true;
		}

		if (obj != null && obj.GetClass(semanter).Identifier == "object")
		{
			return true;
		}

		return false;
	}
	
	public virtual override string ToString()
	{
		return ElementType.ToString() + "[]";
	}
	
	public virtual override CArrayDataType ArrayOf()
	{
		if (m_array_of_datatype == null)
		{
			m_array_of_datatype = new CArrayDataType(Token, this);
		}
		return m_array_of_datatype;
	}
	
	public virtual override CDataType Semant(CSemanter semanter, CASTNode node)
	{
		CDataType dt = ElementType.Semant(semanter, node).ArrayOf();
		dt.GetClass(semanter); // Initialises generic instances if neccessary.
		return dt;
	}
}

