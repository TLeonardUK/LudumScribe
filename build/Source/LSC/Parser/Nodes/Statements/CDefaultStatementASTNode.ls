// -----------------------------------------------------------------------------
// 	CDefaultStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CDefaultStatementASTNode : CASTNode
{
	public CASTNode BodyStatement;
	
	public CDefaultStatementASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override CASTNode FindLoopScope(CSemanter semanter)
	{
	}
	
	public virtual override bool AcceptBreakStatement()
	{
	}	
}

