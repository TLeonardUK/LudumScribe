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
		Token = token;
	}
	
	public virtual CClassASTNode GetClass(CSemanter semanter)
	{
		return null;
	}
	
	public virtual CClassASTNode GetBoxClass(CSemanter semanter)
	{	
		CClassASTNode node = GetClass(semanter);
		if (node.HasBoxClass == true)
		{
			return semanter.GetContext().GetASTRoot().FindDeclaration(semanter, node.BoxClassIdentifier).Semant(semanter) as CClassASTNode;
		}
		else
		{
			return null;
		}
	}
	
	public virtual bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		return false;
	}
	
	public virtual bool CanCastTo(CSemanter semanter, CDataType type)
	{
		return IsEqualTo(semanter, type);
	}
	
	public virtual override string ToString()
	{
		return "Unknown DataType";
	}
	
	public virtual CArrayDataType ArrayOf()
	{
		if (m_array_of_datatype == null)
		{
			m_array_of_datatype = new CArrayDataType(Token, this);
		}
		return m_array_of_datatype;
	}
	
	public virtual CDataType Semant(CSemanter semanter, CASTNode node)
	{
		Trace.Write("CDataType");
		
		return this;
	}	
}

