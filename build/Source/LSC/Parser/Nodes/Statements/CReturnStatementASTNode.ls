// -----------------------------------------------------------------------------
// 	CReturnStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CReturnStatementASTNode : CASTNode
{
	public CExpressionBaseASTNode ReturnExpression;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CReturnStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CReturnStatementASTNode clone = new CReturnStatementASTNode(null, Token);

		if (ReturnExpression != null)
		{
			clone.ReturnExpression = <CExpressionASTNode>(ReturnExpression.Clone(semanter));
			clone.AddChild(clone.ReturnExpression);
		}

		return clone;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CReturnStatementASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Find statement we are in.
		CClassMemberASTNode scope = this.FindClassMethodScope(semanter);

		// Check we don't have a manual return expression
		// for constructors.
		if (scope.IsConstructor == true)
		{
			if (ReturnExpression != null)
			{
				semanter.GetContext().FatalError("Constructor '" + scope.Identifier + "' can not return a value.", Token);		
			}

			// Return the class instance.
			ReturnExpression = new CThisExpressionASTNode(null, Token);
			AddChild(ReturnExpression);
		}

		// Semant the expression.
		if (ReturnExpression != null)
		{
			if (scope.ReturnType is CVoidDataType)
			{
				semanter.GetContext().FatalError("Method '" + scope.Identifier + "' does not expect a return value.", Token);
			}

			ReturnExpression = <CExpressionBaseASTNode>(ReplaceChild(ReturnExpression, ReturnExpression.Semant(semanter)));
			ReturnExpression = <CExpressionBaseASTNode>(ReplaceChild(ReturnExpression, ReturnExpression.CastTo(semanter, scope.ReturnType, Token)));
		}
		else
		{
			if ((scope.ReturnType is CVoidDataType) == false)
			{
				semanter.GetContext().FatalError("Method '" + scope.Identifier + "' expects return value of type '" + scope.ReturnType.ToString() + "'.", Token);
			}
		}

		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateReturnStatement(this);
	}
}

