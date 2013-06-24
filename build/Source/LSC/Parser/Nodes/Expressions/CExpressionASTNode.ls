// -----------------------------------------------------------------------------
// 	CExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CExpressionASTNode : CExpressionBaseASTNode
{
	public bool IsConstant;
	public CASTNode LeftValue;
	
	public CExpressionASTNode(CASTNode parent, CToken token)
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
	
	public virtual override void Translate(CTranslator translator)
	{
	}
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}
}