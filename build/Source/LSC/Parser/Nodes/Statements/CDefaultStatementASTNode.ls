// -----------------------------------------------------------------------------
// 	CDefaultStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CDefaultStatementASTNode : CASTNode
{
	public CASTNode BodyStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CDefaultStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CDefaultStatementASTNode clone = new CDefaultStatementASTNode(null, Token);
		
		if (BodyStatement != null)
		{
			clone.BodyStatement = <CASTNode>(BodyStatement.Clone(semanter));
			clone.AddChild(clone.BodyStatement);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CDefaultStatementASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;
		
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

