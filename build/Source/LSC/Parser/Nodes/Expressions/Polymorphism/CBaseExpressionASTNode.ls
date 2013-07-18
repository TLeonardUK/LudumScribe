// -----------------------------------------------------------------------------
// 	CBaseExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CBaseExpressionASTNode : CExpressionBaseASTNode
{
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CBaseExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CBaseExpressionASTNode clone = new CBaseExpressionASTNode(null, Token);

		return clone;
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CBaseExpressionASTNode");
		
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
			semanter.GetContext().FatalError("base keyword can only be used in class methods.", Token);		
		}
		if (method_scope.IsStatic == true)
		{
			semanter.GetContext().FatalError("base keyword cannot be used in static methods.", Token);
		}
		if (class_scope.SuperClass == null)
		{
			semanter.GetContext().FatalError("base keyword cannot be used in class without super class.", Token);
		}

		ExpressionResultType = class_scope.SuperClass.ObjectDataType;

		return this;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateBaseExpression(this);
	}
	
}

