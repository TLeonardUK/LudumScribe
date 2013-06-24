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
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
	}
	public virtual override CClassASTNode GetBoxClass(CSemanter semanter)
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
	public virtual override CArrayDataType ArrayOf()
	{
	}
	public virtual override CDataType Semant(CSemanter semanter, CASTNode node)
	{
	}
}

