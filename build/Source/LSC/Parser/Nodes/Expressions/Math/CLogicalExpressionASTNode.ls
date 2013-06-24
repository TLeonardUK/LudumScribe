// -----------------------------------------------------------------------------
// 	CLogicalExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CLogicalExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode RightValue;
	
	public CLogicalExpressionASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
	}
	
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}	
}

