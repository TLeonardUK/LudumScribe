// -----------------------------------------------------------------------------
// 	CBinaryMathExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CBinaryMathExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode RightValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CBinaryMathExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CBinaryMathExpressionASTNode clone = new CBinaryMathExpressionASTNode(null, Token);

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
		switch (Token.Type)
		{
			// Integer only operators.		
			case TokenIdentifier.OP_AND
				 , TokenIdentifier.OP_OR
				 , TokenIdentifier.OP_XOR
				 , TokenIdentifier.OP_SHL
				 , TokenIdentifier.OP_SHR
				 , TokenIdentifier.OP_MOD:
			{
				ExpressionResultType = new CIntDataType(Token);
				break;
			}

			// Applicable to any type operators.
			case TokenIdentifier.OP_ADD
				 , TokenIdentifier.OP_SUB
				 , TokenIdentifier.OP_MUL
				 , TokenIdentifier.OP_DIV:
				{
					ExpressionResultType = semanter.BalanceDataTypes(leftValueBase.ExpressionResultType, rightValueBase.ExpressionResultType);
					
					if (ExpressionResultType is CStringDataType)
					{
						if (Token.Type != TokenIdentifier.OP_ADD)
						{
							semanter.GetContext().FatalError("Invalid operator, strings only supports concatination.", Token);			
						}
					}
					else if ((ExpressionResultType is CNumericDataType) == false)
					{
						semanter.GetContext().FatalError("Invalid expression. Operator '" + Token.Literal + "' cannot be used on types '" + leftValueBase.ExpressionResultType.ToString() + "' and '" + rightValueBase.ExpressionResultType.ToString() + "'.", Token);			
					}

					break;
				}
			default:
			{
				semanter.GetContext().FatalError("Internal error. Invalid binary math operator.", Token);
				break;
			}
		}

		// Cast to resulting expression.
		LeftValue  = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token));
		RightValue = ReplaceChild(RightValue, rightValueBase.CastTo(semanter, ExpressionResultType, Token)); 

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult  = LeftValue.Evaluate(unit);
		EvaluationResult rightResult = RightValue.Evaluate(unit);

		if (ExpressionResultType is CBoolDataType)
		{
		}
		else if (ExpressionResultType is CIntDataType)
		{
			switch (Token.Type)
			{		
				case TokenIdentifier.OP_AND:	return new EvaluationResult(leftResult.GetInt() & rightResult.GetInt()); 
				case TokenIdentifier.OP_OR:		return new EvaluationResult(leftResult.GetInt() | rightResult.GetInt());  
				case TokenIdentifier.OP_XOR:	return new EvaluationResult(leftResult.GetInt() ^ rightResult.GetInt());
				case TokenIdentifier.OP_SHL:	return new EvaluationResult(leftResult.GetInt() << rightResult.GetInt());  
				case TokenIdentifier.OP_SHR:	return new EvaluationResult(leftResult.GetInt() >> rightResult.GetInt());  
				case TokenIdentifier.OP_MOD:	return new EvaluationResult(leftResult.GetInt() % rightResult.GetInt());  
				case TokenIdentifier.OP_ADD:	return new EvaluationResult(leftResult.GetInt() + rightResult.GetInt());
				case TokenIdentifier.OP_SUB:	return new EvaluationResult(leftResult.GetInt() - rightResult.GetInt());  
				case TokenIdentifier.OP_MUL:	return new EvaluationResult(leftResult.GetInt() * rightResult.GetInt()); 
				case TokenIdentifier.OP_DIV:	
					{
						if (rightResult.GetInt() == 0)
						{
							unit.FatalError("Attempt to divide by zero.", Token);
						}
						return new EvaluationResult(leftResult.GetInt() / rightResult.GetInt()); 
					}
			}
		}
		else if (ExpressionResultType is CFloatDataType)
		{
			switch (Token.Type)
			{		 
				case TokenIdentifier.OP_ADD:	return new EvaluationResult(leftResult.GetFloat() + rightResult.GetFloat());
				case TokenIdentifier.OP_SUB:	return new EvaluationResult(leftResult.GetFloat() - rightResult.GetFloat());  
				case TokenIdentifier.OP_MUL:	return new EvaluationResult(leftResult.GetFloat() * rightResult.GetFloat()); 
				case TokenIdentifier.OP_DIV:	
					{
						if (rightResult.GetFloat() == 0)
						{
							unit.FatalError("Attempt to divide by zero.", Token);
						}
						return new EvaluationResult(leftResult.GetFloat() / rightResult.GetFloat()); 
					}
			}
		}
		else if (ExpressionResultType is CStringDataType)
		{
			switch (Token.Type)
			{		 
				case TokenIdentifier.OP_ADD:	return new EvaluationResult(leftResult.GetString() + rightResult.GetString());
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
		return translator.TranslateBinaryMathExpression(this);
	}	
}

