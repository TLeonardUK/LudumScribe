// -----------------------------------------------------------------------------
// 	CIdentifierDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CIdentifierDataType : CDataType
{
	public string Identifier;
	public List<CDataType> GenericTypes;
	
	public CIdentifierDataType(CToken token, string identifier, List<CDataType> genericTypes)
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
	
	public virtual override CDataType Semant(CSemanter semanter, CASTNode node)
	{
	}
	public virtual CClassASTNode SemantAsClass(CSemanter semanter, CASTNode node)
	{
	}
}

