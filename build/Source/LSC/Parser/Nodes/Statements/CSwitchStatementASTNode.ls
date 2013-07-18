// -----------------------------------------------------------------------------
// 	CSwitchStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CSwitchStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode ExpressionStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CSwitchStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CSwitchStatementASTNode clone = new CSwitchStatementASTNode(null, Token);

		if (ExpressionStatement != null)
		{
			clone.ExpressionStatement = <CExpressionASTNode>(ExpressionStatement.Clone(semanter));
			clone.AddChild(clone.ExpressionStatement);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CSwitchStatementASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Semant the expression.
		ExpressionStatement = <CExpressionBaseASTNode>(ReplaceChild(ExpressionStatement, ExpressionStatement.Semant(semanter)));

		// Semant all case/default statements.
		SemantChildren(semanter);

		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateSwitchStatement(this);
	}
}

