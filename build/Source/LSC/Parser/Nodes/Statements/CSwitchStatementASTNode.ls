// -----------------------------------------------------------------------------
// 	CSwitchStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CSwitchStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode ExpressionStatement;
	
	public CSwitchStatementASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}
}
