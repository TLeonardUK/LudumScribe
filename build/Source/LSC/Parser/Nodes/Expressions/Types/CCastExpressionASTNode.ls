// -----------------------------------------------------------------------------
// 	CCastExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CCastExpressionASTNode : CExpressionBaseASTNode
{
	public bool Explicit;
	public bool ExceptionOnFail;
	public CDataType Type;
	public CASTNode RightValue;
	
	public CCastExpressionASTNode(CASTNode parent, CToken token, bool explicitCast)
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
	
	public static bool IsValidCast(CSemanter semanter, CDataType from, CDataType to, bool explicit_cast)
	{
	}
	
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}
}

