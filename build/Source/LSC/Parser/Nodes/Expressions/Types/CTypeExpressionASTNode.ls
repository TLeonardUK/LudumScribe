// -----------------------------------------------------------------------------
// 	CTypeExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CTypeExpressionASTNode : CExpressionBaseASTNode
{
	public CDataType Type;
	public CASTNode LeftValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CTypeExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CTypeExpressionASTNode clone = new CTypeExpressionASTNode(null, Token);
		clone.Type = Type;
		
		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
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
		LeftValue = ReplaceChild(LeftValue, LeftValue.Semant(semanter));
		Type	  = Type.Semant(semanter, this);

		// Get expression references.
		CExpressionBaseASTNode lValueBase    = <CExpressionBaseASTNode>(LeftValue);
		
		// What operator.
		switch (Token.Type)
		{
			// herp as int
			case TokenIdentifier.KEYWORD_AS:
			{
				LeftValue			 = ReplaceChild(LeftValue, lValueBase.CastTo(semanter, Type, Token, true, false));
				ExpressionResultType = Type;

				return LeftValue;
			}

			// expr is int
			case TokenIdentifier.KEYWORD_IS:
			{
				// Left side must be object.
				if (<CObjectDataType>(lValueBase.ExpressionResultType) == null)
				{
					semanter.GetContext().FatalError("L-Value of is keyword must be of type 'object'.", Token);
				}

				// Is this cast valid?
				if (!CCastExpressionASTNode.IsValidCast(semanter, lValueBase.ExpressionResultType, Type, true))
				{
					semanter.GetContext().FatalError(("Cannot check cast for '" + lValueBase.ExpressionResultType.ToString() + "' to '" + Type.ToString() + "'."), Token);
				}

				ExpressionResultType = new CBoolDataType(Token);
				break;
			}

			// Wut O_o
			default:
			{
				semanter.GetContext().FatalError("Internal error. Invalid type operator.", Token);
				break;
			}
		}

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateTypeExpression(this);
	}
	
}

