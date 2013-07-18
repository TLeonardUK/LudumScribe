// -----------------------------------------------------------------------------
// 	CBlockStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CBlockStatementASTNode : CASTNode
{
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CBlockStatementASTNode(CASTNode parent, CToken token)
	{	
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CBlockStatementASTNode clone = new CBlockStatementASTNode(null, Token);

		CloneChildren(semanter, clone);

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CBlockStatementASTNode");
		
		SemantChildren(semanter);
		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateBlockStatement(this);
	}
}

