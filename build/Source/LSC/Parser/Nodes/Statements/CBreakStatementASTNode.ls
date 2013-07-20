// -----------------------------------------------------------------------------
// 	CBreakStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CBreakStatementASTNode : CASTNode
{
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CBreakStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CBreakStatementASTNode clone = new CBreakStatementASTNode(null, Token);

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		CASTNode node = FindLoopScope(semanter);
		if (node == null || node.AcceptBreakStatement() == false)
		{
			semanter.GetContext().FatalError("Break statements can only be used inside loops and switch statements.", Token);
		}
		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateBreakStatement(this);
	}	
}

