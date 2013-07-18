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
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CLiteralExpressionASTNode(CASTNode parent, CToken token, CDataType type, string lit)
	{	
		CExpressionBaseASTNode(parent, token); 
		Type = type;
		Literal = lit;
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CLiteralExpressionASTNode clone = new CLiteralExpressionASTNode(null, Token, Type, Literal);

		return clone;
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CLiteralExpressionASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		ExpressionResultType = Type.Semant(semanter, this);

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		if (ExpressionResultType is CBoolDataType)
		{
			return new EvaluationResult(Literal == "0" || Literal.ToLower() == "false" || Literal == "" ? false : true);
		}
		else if (ExpressionResultType is CIntDataType)
		{
			return new EvaluationResult(Literal.ToInt());
		}
		else if (ExpressionResultType is CFloatDataType)
		{
			return new EvaluationResult(Literal.ToFloat());
		}
		else if (ExpressionResultType is CStringDataType)
		{
			return new EvaluationResult(Literal);
		}
		else if (ExpressionResultType is CNullDataType)
		{
			return new EvaluationResult(0);
		}
		
		unit.FatalError("Invalid constant operation.", Token);
		return new EvaluationResult(false);
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateLiteralExpression(this);
	}
	
}

