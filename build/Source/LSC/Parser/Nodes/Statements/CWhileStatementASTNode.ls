// -----------------------------------------------------------------------------
// 	CWhileStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CWhileStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode ExpressionStatement;
	public CASTNode BodyStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CWhileStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CWhileStatementASTNode clone = new CWhileStatementASTNode(null, Token);
		
		if (ExpressionStatement != null)
		{
			clone.ExpressionStatement = <CExpressionASTNode>(ExpressionStatement.Clone(semanter));
			clone.AddChild(clone.ExpressionStatement);
		}	
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
		Trace.Write("CWhileStatementASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Semant the expression.
		ExpressionStatement = <CExpressionBaseASTNode>(ReplaceChild(ExpressionStatement, ExpressionStatement.Semant(semanter)));
		ExpressionStatement = <CExpressionBaseASTNode>(ReplaceChild(ExpressionStatement, ExpressionStatement.CastTo(semanter, new CBoolDataType(Token), Token)));

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
	
	// =================================================================
	//	Returns true if this node can accept continue statements inside
	//	of it.
	// =================================================================
	public virtual override bool AcceptContinueStatement()
	{
		return true;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateWhileStatement(this);
	}
}

