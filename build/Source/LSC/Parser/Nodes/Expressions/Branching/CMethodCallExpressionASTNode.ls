// -----------------------------------------------------------------------------
// 	CMethodCallExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CMethodCallExpressionASTNode : CExpressionBaseASTNode
{
	public List<CASTNode> ArgumentExpressions = new List<CASTNode>();
	public CASTNode RightValue;
	public CASTNode LeftValue;
	public CDeclarationASTNode ResolvedDeclaration;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CMethodCallExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CMethodCallExpressionASTNode clone = new CMethodCallExpressionASTNode(null, Token);

		foreach (CASTNode iter in ArgumentExpressions)
		{
			CASTNode node = iter.Clone(semanter);
			clone.ArgumentExpressions.AddLast(node);
			clone.AddChild(node);
		}
		
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

		// Semant arguments.
		List<CDataType> argument_types = new List<CDataType>();
		string argument_types_string;
		int index = 0;
		foreach (CASTNode iter in ArgumentExpressions)
		{
			CExpressionBaseASTNode node = <CExpressionBaseASTNode>(iter.Semant(semanter));
			argument_types.AddLast(node.ExpressionResultType);

			if ((index++) != 0)
			{
				argument_types_string += ", ";
			}
			argument_types_string += node.ExpressionResultType.ToString();

			ArgumentExpressions.SetIndex(index - 1, node);
		}

		// Make sure the identifier represents a valid field.
		CClassMemberASTNode declaration = accessClass.FindClassMethod(semanter, identNode.Token.Literal, argument_types, false, null, this);
		if (declaration == null)
		{
			semanter.GetContext().FatalError("Undefined method '" + identNode.Token.Literal + "(" + argument_types_string + ")' in class '" + accessClass.ToString() + "'.", Token);		
		}

	// UPDATE: Abstract method calling is fine. Remember we won't be able to instantiate classes that do not override all abstract methods.
	//	if (declaration.IsAbstract == true)
	//	{
	//		semanter.GetContext().FatalError(CStringHelper::FormatString("Cannot call method '%s(%s)' in class '%s', method is abstract.", identNode.Token.Literal.c_str(), argument_types_string.c_str(), accessClass.ToString().c_str()), Token);		
	//	}
		
		ResolvedDeclaration = declaration;

		// Check we can access this field from here.
		declaration.CheckAccess(semanter, this);

		// HACK: This is really hackish and needs fixing!
		if (LeftValue is CThisExpressionASTNode &&
			declaration.IsStatic == true)
		{		
			LeftValue = ReplaceChild(LeftValue, new CClassRefExpressionASTNode(null, Token));
			LeftValue.Token.Literal = declaration.FindClassScope(semanter).Identifier;
			LeftValue.Semant(semanter);

			left_hand_expr	 = <CExpressionBaseASTNode>(LeftValue);
		}

		// Add default arguments if we do not have enough args to call.
		if (declaration.Arguments.Count() > ArgumentExpressions.Count())
		{
			for (int i = ArgumentExpressions.Count(); i < declaration.Arguments.Count(); i++)
			{
				CASTNode expr = declaration.Arguments.GetIndex(i).AssignmentExpression.Clone(semanter);
				AddChild(expr);
				ArgumentExpressions.AddLast(expr);

				expr.Semant(semanter);
			}
		}
		
		// Cast all arguments to correct data types.
		index = 0;
		foreach (CASTNode iter in ArgumentExpressions)
		{
			CDataType dataType = declaration.Arguments.GetIndex(index++).Type;

			CExpressionBaseASTNode subnode = <CExpressionBaseASTNode>(iter);
			subnode = <CExpressionBaseASTNode>(ReplaceChild(subnode, subnode.CastTo(semanter, dataType, Token)));
			
			ArgumentExpressions.SetIndex(index - 1, subnode);			
		}

		// If we are a class reference, we can only access static fields.
		bool isClassReference = (left_hand_expr.ExpressionResultType is CClassReferenceDataType);
		if (isClassReference == true)
		{
			if (declaration.IsStatic == false)
			{
				semanter.GetContext().FatalError("Cannot access instance method '" + declaration.Identifier + "' through class reference '" + accessClass.ToString() + "'.", Token);	
			}
		}

		// If this is a constructor we are calling, make sure we are in a constructors scope, or its illegal!
		else
		{
			CClassMemberASTNode methodScope = FindClassMethodScope(semanter);

			if (methodScope == null ||
				methodScope.IsConstructor == false)
			{
				if (declaration.IsConstructor == true)
				{
					semanter.GetContext().FatalError("Calling constructors manually is only valid inside another constructors scope.", Token);	
				}
			}
		}

		// Resulting type is always our right hand type.
		ExpressionResultType = declaration.ReturnType;

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateMethodCallExpression(this);
	}	
}

