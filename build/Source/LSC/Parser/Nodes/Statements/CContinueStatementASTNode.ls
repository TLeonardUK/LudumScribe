// -----------------------------------------------------------------------------
// 	CContinueStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CContinueStatementASTNode : CASTNode
{
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CContinueStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CContinueStatementASTNode clone = new CContinueStatementASTNode(null, Token);

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CContinueStatementASTNode");
		
		CASTNode node = FindLoopScope(semanter);
		if (node == null || node.AcceptContinueStatement() == false)
		{
			semanter.GetContext().FatalError("Continue statements can only be used inside loops.", Token);
		}
		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateContinueStatement(this);
	}
}

