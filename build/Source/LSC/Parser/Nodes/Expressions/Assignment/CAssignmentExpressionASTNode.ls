// -----------------------------------------------------------------------------
// 	CAssignmentExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CAssignmentExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode RightValue;
	public bool IgnoreConst;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CAssignmentExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CAssignmentExpressionASTNode clone = new CAssignmentExpressionASTNode(null, Token);

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
		
		// Semant expressions.
		LeftValue  = ReplaceChild(LeftValue,   LeftValue.Semant(semanter));
		RightValue = ReplaceChild(RightValue, RightValue.Semant(semanter)); 
		
		// Get expression references.
		CExpressionBaseASTNode leftValueBase  = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode rightValueBase = <CExpressionBaseASTNode>(RightValue);

		// Try and find field the l-value is refering to.
		CClassMemberASTNode		   	   field_node		 = null;
		CVariableStatementASTNode	   var_node			 = null;
		CFieldAccessExpressionASTNode  field_access_node = <CFieldAccessExpressionASTNode>(LeftValue);
		CIdentifierExpressionASTNode   identifier_node   = <CIdentifierExpressionASTNode>(LeftValue);
		CIndexExpressionASTNode		   index_node		 = <CIndexExpressionASTNode>(LeftValue);

		if (index_node != null)
		{
			// Should call CanAssignIndex or something
			CExpressionBaseASTNode leftLeftValueBase  = <CExpressionBaseASTNode>(index_node.LeftValue);

			List<CDataType> args = new List<CDataType>();
			args.AddLast(new CIntDataType(Token));
			args.AddLast(rightValueBase.ExpressionResultType);
			args.AddLast(new CBoolDataType(Token));

			CClassASTNode arrayClass = leftLeftValueBase.ExpressionResultType.GetClass(semanter);
			CClassMemberASTNode memberNode = arrayClass.FindClassMethod(semanter, "SetIndex", args, true, null, null);
			
			if (memberNode == null || ((leftLeftValueBase.ExpressionResultType is CStringDataType) == false && (leftLeftValueBase.ExpressionResultType is CArrayDataType) == false))
			{
				index_node = null;
			}
		}
		else if (field_access_node != null)
		{
			field_node = field_access_node.ExpressionResultClassMember;
		}
		else if (identifier_node != null)
		{
			field_node = identifier_node.ExpressionResultClassMember;
			var_node = identifier_node.ExpressionResultVariable;
		}

		// Is the l-value a valid assignment target?
		if (field_node == null && var_node == null && index_node == null)
		{		
			semanter.GetContext().FatalError("Illegal l-value for assignment expression.", Token);
		}
		if (field_node != null && field_node.IsConst == true && IgnoreConst == false)
		{		
			semanter.GetContext().FatalError("Illegal l-value for assignment expression, l-value was declared constant.", Token);
		}

		// Balance types.
		ExpressionResultType = leftValueBase.ExpressionResultType;
					
		switch (Token.Type)
		{
			// Anything goes :3
			case TokenIdentifier.OP_ASSIGN:
			{
				break;
			}

			// Integer only operators.		
			case  TokenIdentifier.OP_ASSIGN_AND
				, TokenIdentifier.OP_ASSIGN_OR
				, TokenIdentifier.OP_ASSIGN_XOR
				, TokenIdentifier.OP_ASSIGN_SHL
				, TokenIdentifier.OP_ASSIGN_SHR
				, TokenIdentifier.OP_ASSIGN_MOD:
			{
				if ((leftValueBase.ExpressionResultType is CIntDataType) == false)
				{	
					semanter.GetContext().FatalError("Assignment operator '" + Token.Literal + "' cannot be used on types '" + leftValueBase.ExpressionResultType.ToString() + "' and '" + rightValueBase.ExpressionResultType.ToString() + "'.", Token);							
				}
				break;
			}

			// Applicable to any type operators.
			case  TokenIdentifier.OP_ASSIGN_ADD
				, TokenIdentifier.OP_ASSIGN_SUB
				, TokenIdentifier.OP_ASSIGN_MUL
				, TokenIdentifier.OP_ASSIGN_DIV:
				{
					if (ExpressionResultType is CStringDataType)
					{
						if (Token.Type != TokenIdentifier.OP_ASSIGN_ADD)
						{
							semanter.GetContext().FatalError("Invalid operator, strings only supports concatination.", Token);			
						}
					}
					else if ((ExpressionResultType is CNumericDataType) == false)
					{
						semanter.GetContext().FatalError("Assignment operator '" + Token.Literal + "' cannot be used on types '" + leftValueBase.ExpressionResultType.ToString() + "' and '" + rightValueBase.ExpressionResultType.ToString() + "'.", Token);			
					}

					break;
				}

			// dafuq
			default:
			{
				semanter.GetContext().FatalError("Internal error. Invalid assignment operator.", Token);
				break;
			}
		}

		// Cast R-Value to correct type.
		RightValue = ReplaceChild(RightValue, rightValueBase.CastTo(semanter, ExpressionResultType, Token)); 

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateAssignmentExpression(this);
	}
	
}

