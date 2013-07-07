// -----------------------------------------------------------------------------
// 	CClassReferenceDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CClassReferenceDataType : CDataType
{
	protected CClassASTNode m_class;
	
	public CClassReferenceDataType(CToken token, CClassASTNode classNode)
	{
		Token = Token;
		m_class = classNode;
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
		return m_class;
	}
	
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		CClassReferenceDataType classRef = type as CClassReferenceDataType;
		return (classRef != null && classRef.m_class == m_class);
	}
	
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
		return IsEqualTo(semanter, type);
	}
	
	public virtual override string ToString()
	{
		return m_class.ToString();
	}
}

