// -----------------------------------------------------------------------------
// 	CCatchStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CCatchStatementASTNode : CASTNode
{
	public CVariableStatementASTNode VariableStatement;
	public CASTNode BodyStatement;
	
	public CCatchStatementASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
}

