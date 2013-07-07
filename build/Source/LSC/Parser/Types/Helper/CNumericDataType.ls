// -----------------------------------------------------------------------------
// 	CNumericDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all numeric data types.
// =================================================================
public class CNumericDataType : CDataType
{
	public CNumericDataType(CToken token)
	{
		Token = token;
	}
}

