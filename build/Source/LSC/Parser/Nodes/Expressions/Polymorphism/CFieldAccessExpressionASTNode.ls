// -----------------------------------------------------------------------------
// 	CFieldAccessExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CFieldAccessExpressionASTNode : CExpressionBaseASTNode
{
	protected bool m_isSemantingRightValue;
	
	public CASTNode LeftValue;
	public CASTNode RightValue;
	public CClassMemberASTNode ExpressionResultClassMember;

	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CFieldAccessExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CFieldAccessExpressionASTNode clone = new CFieldAccessExpressionASTNode(null, Token);

		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
		}

		if (RightValue != null)
		{
			clone.RightValue = <CASTNode>(RightValue.Clone(semanter));
			clone.AddChild(clone.RightValue);
		}

		return clone;
	}

	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CFieldAccessExpressionASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Get expression representations.
		CExpressionBaseASTNode left_hand_expr	 = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode right_hand_expr  = <CExpressionBaseASTNode>(RightValue);

		// Semant left hand node.
		LeftValue  = ReplaceChild(LeftValue,   LeftValue.Semant(semanter));
		
		// Make sure we can access class.
		CClassASTNode accessClass = left_hand_expr.ExpressionResultType.GetClass(semanter);
		if (accessClass == null)
		{
			semanter.GetContext().FatalError("Invalid use of scoping operator.", Token);		
		}

		// Check we can access this class from here.
		accessClass.CheckAccess(semanter, this);

		// NOTE: Do not r-value semant identifier, we want to process that ourselves.
		CIdentifierExpressionASTNode identNode = <CIdentifierExpressionASTNode>(RightValue);

		// Make sure the identifier represents a valid field.
		CClassMemberASTNode declaration = accessClass.FindClassField(semanter, identNode.Token.Literal, null, this);
		if (declaration == null)
		{
			semanter.GetContext().FatalError("Undefined field '" + identNode.Token.Literal + "' in class '" + accessClass.ToString() + "'.", Token);		
		}
		identNode.ResolvedDeclaration = declaration;
		
		// Check we can access this field from here.
		declaration.CheckAccess(semanter, this);
		
		// HACK: This is really hackish and needs fixing!
		if (LeftValue is CThisExpressionASTNode &&
			declaration.IsStatic == true)
		{		
			LeftValue = ReplaceChild(LeftValue, new CClassRefExpressionASTNode(null, Token.Copy()));
			LeftValue.Token.Literal = declaration.FindClassScope(semanter).Identifier;
			LeftValue.Semant(semanter);

			left_hand_expr	 = <CExpressionBaseASTNode>(LeftValue);
		}

		// If we are a class reference, we can only access static fields.
		bool isClassReference = (left_hand_expr.ExpressionResultType is CClassReferenceDataType);
		if (isClassReference == true)
		{
			if (declaration.IsStatic == false)
			{
				semanter.GetContext().FatalError("Cannot access instance field '" + declaration.Identifier + "' through class reference '" + accessClass.ToString() + "'.", Token);	
			}
		}

		// Resulting type is always our right hand type.
		ExpressionResultClassMember	 = declaration;
		ExpressionResultType		 = declaration.ReturnType;

		ExpressionResultType		 = ExpressionResultType.Semant(semanter, this);
		
		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateFieldAccessExpression(this);
	}
}

