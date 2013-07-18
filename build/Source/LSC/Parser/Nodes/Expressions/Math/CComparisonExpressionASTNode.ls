// -----------------------------------------------------------------------------
// 	CComparisonExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CComparisonExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode RightValue;
	public CDataType CompareResultType;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CComparisonExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CComparisonExpressionASTNode clone = new CComparisonExpressionASTNode(null, Token);

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
		Trace.Write("CComparisonExpressionASTNode");
		
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

		// Balance types.
		ExpressionResultType = semanter.BalanceDataTypes(leftValueBase.ExpressionResultType, 
															rightValueBase.ExpressionResultType);
		
		// Objects only permit equality operations.
		if (ExpressionResultType is CObjectDataType &&
			Token.Type != TokenIdentifier.OP_EQUAL &&
			Token.Type != TokenIdentifier.OP_NOT_EQUAL)
		{
			semanter.GetContext().FatalError(Token.Literal + " operator cannot be used on objects.", Token);
		}

		// Cast to resulting expression.
		LeftValue  = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token));
		RightValue = ReplaceChild(RightValue, rightValueBase.CastTo(semanter, ExpressionResultType, Token)); 

		CompareResultType = ExpressionResultType;
		ExpressionResultType = new CBoolDataType(Token);

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult  = LeftValue.Evaluate(unit);
		EvaluationResult rightResult = RightValue.Evaluate(unit);

		if (CompareResultType is CBoolDataType)
		{
		}
		else if (CompareResultType is CIntDataType)
		{
			switch (Token.Type)
			{		
				case TokenIdentifier.OP_EQUAL:			return new EvaluationResult(leftResult.GetInt() == rightResult.GetInt()); 
				case TokenIdentifier.OP_NOT_EQUAL:		return new EvaluationResult(leftResult.GetInt() != rightResult.GetInt());  
				case TokenIdentifier.OP_GREATER:		return new EvaluationResult(leftResult.GetInt() >  rightResult.GetInt());
				case TokenIdentifier.OP_LESS:			return new EvaluationResult(leftResult.GetInt() <  rightResult.GetInt());   
				case TokenIdentifier.OP_GREATER_EQUAL:	return new EvaluationResult(leftResult.GetInt() >= rightResult.GetInt()); 
				case TokenIdentifier.OP_LESS_EQUAL:		return new EvaluationResult(leftResult.GetInt() <= rightResult.GetInt());  
			}
		}
		else if (CompareResultType is CFloatDataType)
		{
			switch (Token.Type)
			{		
				case TokenIdentifier.OP_EQUAL:			return new EvaluationResult(leftResult.GetFloat() == rightResult.GetFloat()); 
				case TokenIdentifier.OP_NOT_EQUAL:		return new EvaluationResult(leftResult.GetFloat() != rightResult.GetFloat());  
				case TokenIdentifier.OP_GREATER:		return new EvaluationResult(leftResult.GetFloat() >  rightResult.GetFloat());
				case TokenIdentifier.OP_LESS:			return new EvaluationResult(leftResult.GetFloat() <  rightResult.GetFloat());   
				case TokenIdentifier.OP_GREATER_EQUAL:	return new EvaluationResult(leftResult.GetFloat() >= rightResult.GetFloat()); 
				case TokenIdentifier.OP_LESS_EQUAL:		return new EvaluationResult(leftResult.GetFloat() <= rightResult.GetFloat());  
			}
		}
		else if (CompareResultType is CStringDataType)
		{
			switch (Token.Type)
			{		
				case TokenIdentifier.OP_EQUAL:			return new EvaluationResult(leftResult.GetString() == rightResult.GetString()); 
				case TokenIdentifier.OP_NOT_EQUAL:		return new EvaluationResult(leftResult.GetString() != rightResult.GetString());  
				case TokenIdentifier.OP_GREATER:		return new EvaluationResult(leftResult.GetString() >  rightResult.GetString());
				case TokenIdentifier.OP_LESS:			return new EvaluationResult(leftResult.GetString() <  rightResult.GetString());   
				case TokenIdentifier.OP_GREATER_EQUAL:	return new EvaluationResult(leftResult.GetString() >= rightResult.GetString()); 
				case TokenIdentifier.OP_LESS_EQUAL:		return new EvaluationResult(leftResult.GetString() <= rightResult.GetString());  
			}
		}
		
		unit.FatalError("Invalid constant operation.", Token);
		return new EvaluationResult(false);
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateComparisonExpression(this);
	}
}

