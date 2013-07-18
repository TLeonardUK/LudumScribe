// -----------------------------------------------------------------------------
// 	CTernaryExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CTernaryExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode Expression;
	public CASTNode LeftValue;
	public CASTNode RightValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CTernaryExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CTernaryExpressionASTNode clone = new CTernaryExpressionASTNode(null, Token);

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

		if (Expression != null)
		{
			clone.Expression = <CASTNode>(Expression.Clone(semanter));
			clone.AddChild(clone.Expression);
		}

		return clone;
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CTernaryExpressionASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Get expression representations.
		CExpressionBaseASTNode left_hand_expr	 = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode right_hand_expr  = <CExpressionBaseASTNode>(RightValue);
		CExpressionBaseASTNode expr_expr		 = <CExpressionBaseASTNode>(Expression);

		// Semant left hand node.
		LeftValue  = ReplaceChild(LeftValue,   LeftValue.Semant(semanter));

		// Semant right hand node.
		RightValue = ReplaceChild(RightValue, RightValue.Semant(semanter)); 

		// Semant expression node.
		Expression = ReplaceChild(Expression, Expression.Semant(semanter)); 

		// Make sure both l and r value are same DT.
		if (!left_hand_expr.ExpressionResultType.IsEqualTo(semanter, right_hand_expr.ExpressionResultType))
		{
			semanter.GetContext().FatalError("Both expressions of a ternary operator must result in the same data type.", Token);			
		}

		// Cast expression to bool.
		ExpressionResultType = new CBoolDataType(Token);
		Expression			 = ReplaceChild(Expression,  expr_expr.CastTo(semanter, ExpressionResultType, Token, true));

		// Resulting type is our left hand type.
		ExpressionResultType = left_hand_expr.ExpressionResultType;

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateTernaryExpression(this);
	}
	
}

