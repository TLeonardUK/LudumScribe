// -----------------------------------------------------------------------------
// 	CPreFixExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CPreFixExpressionASTNode : CExpressionBaseASTNode
{	
	public CASTNode LeftValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CPreFixExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CPreFixExpressionASTNode clone = new CPreFixExpressionASTNode(null, Token);

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
		Trace.Write("CPreFixExpressionASTNode");
		
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

		// Balance types.
		switch (Token.Type)
		{	
			case TokenIdentifier.OP_INCREMENT
			   , TokenIdentifier.OP_DECREMENT:
			{
				// Try and find field the l-value is refering to.
				CClassMemberASTNode 		   field_node		 = null;
				CVariableStatementASTNode 	   var_node			 = null;
				CFieldAccessExpressionASTNode  field_access_node = LeftValue as CFieldAccessExpressionASTNode;
				CIdentifierExpressionASTNode   identifier_node   = LeftValue as CIdentifierExpressionASTNode;
				CIndexExpressionASTNode 	   index_node		 = LeftValue as CIndexExpressionASTNode;

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

				// Check expression type is integer.
				if ((ExpressionResultType is CIntDataType) == false)
				{
					semanter.GetContext().FatalError("Prefix operator '" + Token.Literal + "' only supports integer r-value's.", Token);
				}

				break;
			}

			case TokenIdentifier.OP_ADD
			   , TokenIdentifier.OP_SUB:
			{
				if ((leftValueBase.ExpressionResultType is CNumericDataType) == false)
				{
					semanter.GetContext().FatalError("Unary " + Token.Literal + " operator is only supported on numeric types.", Token);
				}

				ExpressionResultType = leftValueBase.ExpressionResultType;
				LeftValue = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token, false));
				break;
			}

			case TokenIdentifier.OP_NOT:
			{
				ExpressionResultType = new CIntDataType(Token);
				LeftValue = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token, false));
				break;
			}

			case TokenIdentifier.OP_LOGICAL_NOT:
			{
				ExpressionResultType = new CBoolDataType(Token);
				LeftValue  = ReplaceChild(LeftValue,  leftValueBase.CastTo(semanter, ExpressionResultType, Token, true));
			
				break;
			}

			default:
			{
				semanter.GetContext().FatalError("Internal error. Invalid prefix math operator.", Token);
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
			case TokenIdentifier.OP_ADD:	
			{
				if (ExpressionResultType is CIntDataType)
				{
					return new EvaluationResult(+leftResult.GetInt());
				}
				else if (ExpressionResultType is CFloatDataType)
				{
					return new EvaluationResult(+leftResult.GetFloat());
				}
				break;
			}
			case TokenIdentifier.OP_SUB:
			{
				if (ExpressionResultType is CIntDataType)
				{
					return new EvaluationResult(-leftResult.GetInt());
				}
				else if (ExpressionResultType is CFloatDataType)
				{
					return new EvaluationResult(-leftResult.GetFloat());
				}
				break;
			}
			case TokenIdentifier.OP_NOT:
			{
				if (ExpressionResultType is CIntDataType)
				{
					return new EvaluationResult(~leftResult.GetInt());
				}
				break;
			}
			case TokenIdentifier.OP_LOGICAL_NOT:
			{
				if (ExpressionResultType is CBoolDataType)
				{
					return new EvaluationResult(!leftResult.GetBool());
				}
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
		return translator.TranslatePreFixExpression(this);
	}	
}

