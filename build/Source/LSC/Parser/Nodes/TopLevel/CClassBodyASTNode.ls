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
		this.CASTNode(parent, token);
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
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
		CClassBodyASTNode clone = new CClassBodyASTNode(null, Token);
		
		CloneChildren(semanter, clone);

		return clone;
	}
}

