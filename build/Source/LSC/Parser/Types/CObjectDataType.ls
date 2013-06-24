// -----------------------------------------------------------------------------
// 	CObjectDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CObjectDataType : CDataType
{
	protected CClassASTNode m_class;
	
	public CObjectDataType(CToken token, CClassASTNode classNode)
	{
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
	}
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
	}
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
	}
	public virtual override string ToString()
	{
	}
}

