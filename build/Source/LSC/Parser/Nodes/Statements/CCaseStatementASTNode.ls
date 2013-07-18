// -----------------------------------------------------------------------------
// 	CCaseStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CCaseStatementASTNode : CASTNode
{
	public CASTNode BodyStatement;
	public List<CASTNode> Expressions = new List<CASTNode>();
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CCaseStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CCaseStatementASTNode clone = new CCaseStatementASTNode(null, Token);
		
		if (BodyStatement != null)
		{
			clone.BodyStatement = <CASTNode>(BodyStatement.Clone(semanter));
			clone.AddChild(clone.BodyStatement);
		}
		
		foreach (CASTNode iter in Expressions)
		{
			CASTNode node = (iter).Clone(semanter);
			clone.Expressions.AddLast(node);
			clone.AddChild(clone);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CCaseStatementASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Find the switch statement we are part of.
		CASTNode scope = this;
		CSwitchStatementASTNode switchScope = null;

		while (scope != null && switchScope == null)
		{
			switchScope = scope as CSwitchStatementASTNode;
			scope = scope.Parent;
		}

		// Semant the expression.
		int index = 0;
		foreach (CASTNode iter in Expressions)
		{
			CASTNode node = iter;
			node = ReplaceChild(node, node.Semant(semanter));
			node = ReplaceChild(node, (<CExpressionBaseASTNode>node).CastTo(semanter, switchScope.ExpressionStatement.ExpressionResultType, Token));
			Expressions.SetIndex(index++, node);
		}
		
		// Semant Body statement.
		if (BodyStatement != null)
		{
			BodyStatement = ReplaceChild(BodyStatement, BodyStatement.Semant(semanter));
		}

		return this;
	}
	
	// =================================================================
	//	Finds the scope the looping statement this node is contained by.
	// =================================================================
	public virtual override CASTNode FindLoopScope(CSemanter semanter)
	{
		return this;
	}
		
	// =================================================================
	//	Returns true if this node can accept break statements inside
	//	of it.
	// =================================================================
	public virtual override bool AcceptBreakStatement()
	{
		return true;
	}	
}

