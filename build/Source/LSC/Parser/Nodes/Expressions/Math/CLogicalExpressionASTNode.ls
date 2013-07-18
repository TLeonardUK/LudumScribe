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
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CLogicalExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}	

	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CLogicalExpressionASTNode clone = new CLogicalExpressionASTNode(null, Token);

		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
		}
		if (RightValue != null)
		{
			clone.RightValue = <CASTNode>(RightValue.Clone(semanter));
			clone.AddChild(clone.RightValue);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CLogicalExpressionASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Semant expressions.
		LeftValue  = ReplaceChild(LeftValue,   LeftValue.Semant(semanter));
		RightValue = ReplaceChild(RightValue, RightValue.Semant(semanter)); 

		// Get expression references.
		CExpressionBaseASTNode leftValueBase  = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode rightValueBase = <CExpressionBaseASTNode>(RightValue);

		// Cast to resulting expression.
		ExpressionResultType = new CBoolDataType(Token);
		LeftValue  = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token, true));
		RightValue = ReplaceChild(RightValue, rightValueBase.CastTo(semanter, ExpressionResultType, Token, true)); 

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult  = LeftValue.Evaluate(unit);
		EvaluationResult rightResult = RightValue.Evaluate(unit);

		switch (Token.Type)
		{		
			case TokenIdentifier.OP_LOGICAL_AND:	return new EvaluationResult(leftResult.GetBool() && rightResult.GetBool()); 
			case TokenIdentifier.OP_LOGICAL_OR:		return new EvaluationResult(leftResult.GetBool() && rightResult.GetBool());
		}
		
		unit.FatalError("Invalid constant operation.", Token);
		return new EvaluationResult(false);
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateLogicalExpression(this);
	}	
}

