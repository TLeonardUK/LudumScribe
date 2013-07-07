// -----------------------------------------------------------------------------
// 	CMethodBodyASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a method body.
// =================================================================
public class CMethodBodyASTNode : CASTNode
{
	public CMethodBodyASTNode(CASTNode parent, CToken token)
	{
		this.CASTNode(parent, token);
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CMethodBodyASTNode clone = new CMethodBodyASTNode(null, Token);

		CloneChildren(semanter, clone);

		return clone;
	}
	
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
}

