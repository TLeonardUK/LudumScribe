// -----------------------------------------------------------------------------
// 	CThrowStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CThrowStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode Expression;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CThrowStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CThrowStatementASTNode clone = new CThrowStatementASTNode(null, Token);

		if (Expression != null)
		{
			clone.Expression = <CExpressionASTNode>(Expression.Clone(semanter));
			clone.AddChild(clone.Expression);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Expression = <CExpressionBaseASTNode>(ReplaceChild(Expression, Expression.Semant(semanter)));

		CDataType exception_base = FindDataType(semanter, "Exception", new List<CDataType>());
		if (exception_base == null ||
			exception_base.GetClass(semanter) == null)
		{
			semanter.GetContext().FatalError("Internal error, could not find base 'Exception' class.");
		}

		CDataType catch_type = Expression.ExpressionResultType;
		if (catch_type == null ||
			catch_type.GetClass(semanter).InheritsFromClass(semanter, exception_base.GetClass(semanter)) == false)
		{
			semanter.GetContext().FatalError("Thrown exceptions must inherit from 'Exception' class.", Token);
		}

		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateThrowStatement(this);
	}
}

