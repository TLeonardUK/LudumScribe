// -----------------------------------------------------------------------------
// 	CVariableStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CVariableStatementASTNode : CDeclarationASTNode
{
	public bool IsParameter;
	public CDataType Type;
	public CExpressionBaseASTNode AssignmentExpression;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CVariableStatementASTNode(CASTNode parent, CToken token)
	{
		CDeclarationASTNode(parent, token);
	}
	
	// =================================================================
	//	Converts this node to a string representation.
	// =================================================================
	public virtual override string ToString()
	{
		if (Type == null)
		{
			return Identifier;
		}
	
		string val = Type.ToString();

		val += " " + Identifier;

		return val;
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CVariableStatementASTNode clone = new CVariableStatementASTNode(null, Token);
		clone.Type = this.Type;
		clone.Identifier = this.Identifier;
		clone.IsNative = this.IsNative;
		clone.MangledIdentifier = this.MangledIdentifier;
		clone.IsParameter = this.IsParameter;

		if (AssignmentExpression != null)
		{
			clone.AssignmentExpression = <CExpressionASTNode>(AssignmentExpression.Clone(semanter));
			clone.AddChild(clone.AssignmentExpression);
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
		
		// Work out mangled identifier.
		if (MangledIdentifier == "")
		{
			MangledIdentifier = semanter.GetMangled("ls_local_" + Identifier);
		}

		// Semant the type/return type of this member.
		Type = Type.Semant(semanter, this);

		// Default assignment?
		if (AssignmentExpression == null && IsParameter == false)
		{
			AssignmentExpression = semanter.ConstructDefaultAssignmentExpr(this, Token, Type);
		}

		// Check for duplicate identifiers.
		CheckForDuplicateIdentifier(semanter, Identifier);

		// Semant the assignment.
		if (AssignmentExpression != null)
		{
			AssignmentExpression = <CExpressionBaseASTNode>(ReplaceChild(AssignmentExpression, AssignmentExpression.Semant(semanter)));
			AssignmentExpression = <CExpressionBaseASTNode>(ReplaceChild(AssignmentExpression, AssignmentExpression.CastTo(semanter, Type, Token)));
		}

		return this;
	}
	
	// =================================================================
	//	Checks if we can access this declaration from the given node.
	// =================================================================
	public virtual override void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
		// Find which statement reference belongs to on the same level as variable declaration.
		CASTNode referenceParent = referenceBy;
		while (referenceParent != null &&
			   referenceParent.Parent != Parent)
		{
			referenceParent = referenceParent.Parent;
		}

		// Check we have accessed variable after its defined.
		if (referenceParent != null)
		{
			int define_index    = Parent.Children.IndexOf(this);
			int reference_index = Parent.Children.IndexOf(referenceParent);
			
			if (reference_index <= define_index)
			{
				semanter.GetContext().FatalError("Attempt to access variable '" + Identifier + "' before it is declared.", referenceBy.Token);	
			}
		}
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateVariableStatement(this);
	}
}

