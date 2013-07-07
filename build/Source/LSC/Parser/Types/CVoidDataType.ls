// -----------------------------------------------------------------------------
// 	CVoidDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CVoidDataType : CDataType
{
	public CVoidDataType(CToken token)
	{
		Token = token;
	}
	
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		return (type as CVoidDataType) != null;
	}
	
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
		return IsEqualTo(semanter, type);
	}
	
	public virtual override string ToString()
	{
		return "void";
	}
}

