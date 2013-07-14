// -----------------------------------------------------------------------------
// 	CCommaExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CCommaExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode RightValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CCommaExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CCommaExpressionASTNode clone = new CCommaExpressionASTNode(null, Token);

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

		// Resulting type is always our right hand type.
		ExpressionResultType = (<CExpressionBaseASTNode>RightValue).ExpressionResultType;

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateCommaExpression(this);
	}
	
}

