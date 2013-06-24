// -----------------------------------------------------------------------------
// 	CIndexExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CIndexExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode IndexExpression;
	
	public CIndexExpressionASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}
}

