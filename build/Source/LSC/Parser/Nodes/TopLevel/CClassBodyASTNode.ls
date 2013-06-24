// -----------------------------------------------------------------------------
// 	CClassBodyASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a class body.
// =================================================================
public class CClassBodyASTNode : CASTNode
{
	public CClassBodyASTNode(CASTNode parent, CToken token)
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

