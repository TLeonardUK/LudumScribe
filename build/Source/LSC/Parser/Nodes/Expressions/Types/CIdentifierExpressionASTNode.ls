// -----------------------------------------------------------------------------
// 	CIdentifierExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CIdentifierExpressionASTNode : CExpressionBaseASTNode
{
	public CClassMemberASTNode ExpressionResultClassMember;
	public CVariableStatementASTNode ExpressionResultVariable;
	public CDeclarationASTNode ResolvedDeclaration;
	public List<CDataType> GenericTypes = new List<CDataType>();
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CIdentifierExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CIdentifierExpressionASTNode clone = new CIdentifierExpressionASTNode(null, Token);

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

		// Declaration priority:
		//		Field
		//		Method
		//		Class
		//		Last two get swapped if our parent is a field access operator.

		// Find the declaration specified.
		CClassASTNode		 classScope	 = this.FindClassScope(semanter);
		CDeclarationASTNode declaration = null;

		CFieldAccessExpressionASTNode parentFieldAccess = Parent as CFieldAccessExpressionASTNode;
		CMethodCallExpressionASTNode  parentMethodCall  = Parent as CMethodCallExpressionASTNode;

		// Generic class reference?
		if (GenericTypes.Count() > 0)
		{
			CDataType type = this.FindDataType(semanter, Token.Literal, GenericTypes);
			declaration = type.GetClass(semanter);
		}

		// We are the left side of a field access?
		else if ((parentFieldAccess != null && parentFieldAccess.LeftValue == this))
		{
			declaration = this.FindClassField(semanter, Token.Literal, null);
			if (declaration == null)
			{
				declaration = this.FindDataTypeDeclaration(semanter, Token.Literal);
			}
			if (declaration == null)
			{
				declaration = this.FindDeclaration(semanter, Token.Literal);
			}
		}
		
		// We are the left side of a method call?
		else if ((parentMethodCall != null && parentMethodCall.LeftValue == this))
		{
			declaration = this.FindClassField(semanter, Token.Literal, null);
			if (declaration == null)
			{
				declaration = this.FindDataTypeDeclaration(semanter, Token.Literal);
			}
			if (declaration == null)
			{
				declaration = this.FindDeclaration(semanter, Token.Literal);
			}
		}

		// Just a general identifier.
		else
		{
			declaration = this.FindClassField(semanter, Token.Literal, null);
			if (declaration == null)
			{
				declaration = this.FindDeclaration(semanter, Token.Literal);
			}
		}

		ResolvedDeclaration = declaration; 

		if (declaration == null)
		{
			semanter.GetContext().FatalError(("Undefined identifier '" + Token.Literal + "'."), Token);		
		}

		// Check access.
		declaration.CheckAccess(semanter, this);

		// Work out result type.
		CClassASTNode				classNode		= declaration as CClassASTNode;
		CClassMemberASTNode		memberNode			= declaration as CClassMemberASTNode;
		CVariableStatementASTNode	localNode		= declaration as CVariableStatementASTNode;
		
		// Check we are not accessing an instance
		// variable from a static method.	
		if (memberNode != null)
		{
			CClassMemberASTNode methodScope = FindClassMethodScope(semanter);
			if (methodScope.IsStatic == true &&
				memberNode.IsStatic  == false)
			{
				semanter.GetContext().FatalError(("Cannot acccess instance field '" + memberNode.Identifier + "' in static method."), Token);		
			}

			ExpressionResultType = memberNode.ReturnType;
			ExpressionResultClassMember = memberNode;
		}

		// Is this a local variable?
		else if (localNode != null)
		{
			ExpressionResultType	 = localNode.Type;
			ExpressionResultVariable = localNode;
		}

		// If this is a class reference, make sure we are the left-value of a scope expression
		// you should not be able to have a class reference as an r-value.
		else if (classNode != null)
		{
			if (classNode.IsGeneric == true && GenericTypes.Count() <= 0)
			{
				semanter.GetContext().FatalError(("Reference to class '" + classNode.Identifier + "' expects declaration of generic types."), Token);			
			}
			else if (classNode.IsGeneric == false && GenericTypes.Count() > 0)
			{
				semanter.GetContext().FatalError(("Reference to class '" + classNode.Identifier + "' does not expect declaration of generic types."), Token);			
			}
			ExpressionResultType = classNode.ClassReferenceDataType;
		}

		ExpressionResultType = ExpressionResultType.Semant(semanter, this);

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateIdentifierExpression(this);
	}
	
}

