// -----------------------------------------------------------------------------
// 	CThisExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CThisExpressionASTNode : CExpressionBaseASTNode
{

	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CThisExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CThisExpressionASTNode clone = new CThisExpressionASTNode(null, Token);

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

		// Make sure we are inside a method and 
		CClassASTNode		 class_scope = this.FindClassScope(semanter);
		CClassMemberASTNode method_scope = this.FindClassMethodScope(semanter);

		if (method_scope == null ||
			class_scope  == null)
		{
			semanter.GetContext().FatalError("this keyword can only be used in class methods.", Token);		
		}
		if (method_scope.IsStatic == true)
		{
			semanter.GetContext().FatalError("this keyword cannot be used in static methods.", Token);
		}

		if (class_scope.Identifier == "string")
		{
			ExpressionResultType = new CStringDataType(Token);
		}
		else
		{
			ExpressionResultType = class_scope.ObjectDataType;
		}

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateThisExpression(this);
	}
	
}

