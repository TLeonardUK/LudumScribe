// -----------------------------------------------------------------------------
// 	CArrayInitializerASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CArrayInitializerASTNode : CExpressionBaseASTNode
{
	public List<CASTNode> Expressions = new List<CASTNode>();
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CArrayInitializerASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CArrayInitializerASTNode clone = new CArrayInitializerASTNode(null, Token);

		foreach (CASTNode iter in Expressions)
		{
			CASTNode node = iter.Clone(semanter);
			clone.Expressions.AddLast(node);
			clone.AddChild(node);
		}

		return clone;
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CArrayInitializerExpressionASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Semant all expressions.
		foreach (CASTNode iter in Expressions)
		{
			CExpressionBaseASTNode node = <CExpressionBaseASTNode>(iter);
			node.Semant(semanter);

			if (ExpressionResultType == null)
			{
				ExpressionResultType = node.ExpressionResultType;
			}
			else
			{
				if (!ExpressionResultType.IsEqualTo(semanter, node.ExpressionResultType))
				{
					semanter.GetContext().FatalError("All expressions in an array initialization list must be of the same type.", node.Token);
				}
			}
		}

		ExpressionResultType = ExpressionResultType.ArrayOf();

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateArrayInitializerExpression(this);
	}
	
}

