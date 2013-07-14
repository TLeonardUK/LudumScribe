// -----------------------------------------------------------------------------
// 	CIfStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an if statement.
// =================================================================
public class CIfStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode ExpressionStatement;
	public CASTNode BodyStatement;
	public CASTNode ElseStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CIfStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CIfStatementASTNode clone = new CIfStatementASTNode(null, Token);
		
		if (ExpressionStatement != null)
		{
			clone.ExpressionStatement = <CExpressionASTNode>(ExpressionStatement.Clone(semanter));
			clone.AddChild(clone.ExpressionStatement);
		}
		if (BodyStatement != null)
		{
			clone.BodyStatement = BodyStatement.Clone(semanter);
			clone.AddChild(clone.BodyStatement);
		}
		if (ElseStatement != null)
		{
			clone.ElseStatement = ElseStatement.Clone(semanter);
			clone.AddChild(clone.ElseStatement);
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

		// Semant the expression.
		ExpressionStatement = <CExpressionBaseASTNode>(ReplaceChild(ExpressionStatement, ExpressionStatement.Semant(semanter)));
		ExpressionStatement = <CExpressionBaseASTNode>(ReplaceChild(ExpressionStatement, ExpressionStatement.CastTo(semanter, new CBoolDataType(Token), Token)));

		// Semant Body statement.
		if (BodyStatement != null)
		{
			BodyStatement = ReplaceChild(BodyStatement, BodyStatement.Semant(semanter));
		}

		// Semant else statement.
		if (ElseStatement != null)
		{
			ElseStatement = ReplaceChild(ElseStatement, ElseStatement.Semant(semanter));
		}

		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateIfStatement(this);
	}
}

