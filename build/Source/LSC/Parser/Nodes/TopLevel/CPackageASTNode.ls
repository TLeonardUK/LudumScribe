// -----------------------------------------------------------------------------
// 	CPackageASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a package declaration.
// =================================================================
public class CPackageASTNode : CASTNode
{
	public CPackageASTNode(CASTNode parent, CToken token)
	{
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}	
}

