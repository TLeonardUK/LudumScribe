// -----------------------------------------------------------------------------
// 	CForStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CForStatementASTNode : CASTNode
{
	public CASTNode InitialStatement;
	public CExpressionBaseASTNode ConditionExpression;
	public CExpressionBaseASTNode IncrementExpression;
	
	public CASTNode BodyStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CForStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CForStatementASTNode clone = new CForStatementASTNode(null, Token);
		
		if (InitialStatement != null)
		{
			clone.InitialStatement = <CASTNode>(InitialStatement.Clone(semanter));
			clone.AddChild(clone.InitialStatement);
		}
		if (ConditionExpression != null)
		{
			clone.ConditionExpression = <CExpressionASTNode>(ConditionExpression.Clone(semanter));
			clone.AddChild(clone.ConditionExpression);
		}
		if (IncrementExpression != null)
		{
			clone.IncrementExpression = <CExpressionASTNode>(IncrementExpression.Clone(semanter));
			clone.AddChild(clone.IncrementExpression);
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
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		if (InitialStatement != null)
		{		
			InitialStatement = <CASTNode>(InitialStatement.Semant(semanter));
		}

		if (ConditionExpression != null)
		{	
			ConditionExpression = <CExpressionBaseASTNode>(ConditionExpression.Semant(semanter));
			ConditionExpression = <CExpressionBaseASTNode>(ConditionExpression.CastTo(semanter, new CBoolDataType(Token), Token));
		}

		if (IncrementExpression != null)
		{
			IncrementExpression = <CExpressionBaseASTNode>(IncrementExpression.Semant(semanter));
		}

		if (BodyStatement != null)
		{
			BodyStatement = BodyStatement.Semant(semanter);
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
		translator.TranslateForStatement(this);
	}	
}

