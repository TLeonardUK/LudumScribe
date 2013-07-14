// -----------------------------------------------------------------------------
// 	CPostFixExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CPostFixExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CPostFixExpressionASTNode(CASTNode parent, CToken token)
	{	
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CPostFixExpressionASTNode clone = new CPostFixExpressionASTNode(null, Token);

		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
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
		
		// Get expression references.
		CExpressionBaseASTNode leftValueBase  = LeftValue as CExpressionBaseASTNode;

		// Try and find field the l-value is refering to.
		CClassMemberASTNode		   		field_node		 	= null;
		CVariableStatementASTNode	   	var_node			= null;
		CFieldAccessExpressionASTNode 	field_access_node 	= LeftValue as CFieldAccessExpressionASTNode;
		CIdentifierExpressionASTNode  	identifier_node   	= LeftValue as CIdentifierExpressionASTNode;
		CIndexExpressionASTNode	   		index_node			= LeftValue as CIndexExpressionASTNode;

		if (index_node != null)
		{
			// Should call CanAssignIndex or something
			CExpressionBaseASTNode leftLeftValueBase  = index_node.LeftValue as CExpressionBaseASTNode;

			List<CDataType> args = new List<CDataType>();
			args.AddLast(new CIntDataType(Token));
			args.AddLast(leftValueBase.ExpressionResultType);
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
		if (field_node != null && field_node.IsConst == true)
		{		
			semanter.GetContext().FatalError("Illegal l-value for assignment expression, l-value was declared constant.", Token);
		}

		// Work out result!
		ExpressionResultType = leftValueBase.ExpressionResultType;

		// Balance types.
		switch (Token.Type)
		{	
			case TokenIdentifier.OP_INCREMENT
			   , TokenIdentifier.OP_DECREMENT:	
			{
				if ((ExpressionResultType is CIntDataType) == false)
				{
					semanter.GetContext().FatalError("Postfix operator '" + Token.Literal + "' only supports integer l-value's.", Token);
				}
				break;
			}
			default:
			{
				semanter.GetContext().FatalError("Internal error. Invalid postfix operator.", Token);
				break;
			}
		}

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult  = LeftValue.Evaluate(unit);

		switch (Token.Type)
		{	
			case TokenIdentifier.OP_INCREMENT
			   , TokenIdentifier.OP_DECREMENT:	
			{
				break;
			}
		}

		unit.FatalError("Invalid postfix operation, increment and decrement operators cannot be evaluated.", Token);
		return new EvaluationResult(false);
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslatePostFixExpression(this);
	}	
}

