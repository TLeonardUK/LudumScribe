// -----------------------------------------------------------------------------
// 	CClassRefExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CClassRefExpressionASTNode : CExpressionBaseASTNode
{
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CClassRefExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CClassRefExpressionASTNode clone = new CClassRefExpressionASTNode(null, Token);
		
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
		CClassASTNode class_scope = this.FindClassScope(semanter);
		ExpressionResultType = new CClassReferenceDataType(Token, class_scope);

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateClassRefExpression(this);
	}
}

