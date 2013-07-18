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
		this.CASTNode(parent, token);
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CPackageASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		SemantChildren(semanter);
		return this;
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CPackageASTNode clone = new CPackageASTNode(null, Token);

		CloneChildren(semanter, clone);

		return clone;
	}	
}

