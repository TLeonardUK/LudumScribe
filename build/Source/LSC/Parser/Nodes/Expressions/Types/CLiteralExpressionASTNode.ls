// -----------------------------------------------------------------------------
// 	CLiteralExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CLiteralExpressionASTNode : CExpressionBaseASTNode
{
	public CDataType Type;
	public string Literal;
	
	public CLiteralExpressionASTNode(CASTNode parent, CToken token, CDataType type, string lit)
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

