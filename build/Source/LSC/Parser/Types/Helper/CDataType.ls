// -----------------------------------------------------------------------------
// 	CDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CDataType
{
	protected CArrayDataType m_array_of_datatype;
	
	public CToken Token;
	
	public CDataType(CToken token)
	{
	}
	
	public virtual CClassASTNode GetClass(CSemanter semanter)
	{
	}
	public virtual CClassASTNode GetBoxClass(CSemanter semanter)
	{
	}
	public virtual bool IsEqualTo(CSemanter semanter, CDataType type)
	{
	}
	public virtual bool CanCastTo(CSemanter semanter, CDataType type)
	{
	}
	public virtual override string ToString()
	{
	}
	public virtual CArrayDataType ArrayOf()
	{
	}
	public virtual CDataType Semant(CSemanter semanter, CASTNode node)
	{
	}	
}

