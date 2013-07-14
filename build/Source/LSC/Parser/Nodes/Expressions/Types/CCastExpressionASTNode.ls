// -----------------------------------------------------------------------------
// 	CCastExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CCastExpressionASTNode : CExpressionBaseASTNode
{
	public bool Explicit;
	public bool ExceptionOnFail;
	public CDataType Type;
	public CASTNode RightValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CCastExpressionASTNode(CASTNode parent, CToken token, bool explicitCast)
	{
		CExpressionBaseASTNode(parent, token);
		Explicit = explicitCast;
		ExceptionOnFail = true;
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CCastExpressionASTNode clone = new CCastExpressionASTNode(null, Token, Explicit);
		clone.Type = Type;

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
		
		// Semant everything!
		Type		= Type.Semant(semanter, this);
		RightValue  = ReplaceChild(RightValue, RightValue.Semant(semanter));
		
		// Get expression references.
		CExpressionBaseASTNode rightValueBase = <CExpressionBaseASTNode>(RightValue);
		CDataType rightValueDataType = rightValueBase.ExpressionResultType;

		ExpressionResultType = null;

		// Already correct type?
		if (rightValueDataType.IsEqualTo(semanter, Type))
		{
			return RightValue;
		}

		// Can cast?
		else if (rightValueDataType.CanCastTo(semanter, Type))
		{
			// Box
			if ((Type is CObjectDataType) == true &&
				(rightValueDataType is CObjectDataType) == false)
			{
				// Create new boxed object.
				CNewExpressionASTNode astNode	= new CNewExpressionASTNode(null, Token);
				astNode.DataType				= rightValueDataType.GetBoxClass(semanter).ObjectDataType;
				astNode.ArgumentExpressions.AddLast(RightValue);
				astNode.AddChild(RightValue);
				astNode.Semant(semanter);

				ExpressionResultType = Type;

				return astNode; // TODO: Memory leak.
			}

			// Unbox
			else if ((rightValueDataType is CObjectDataType) == true &&
					 (Type is CObjectDataType) == false &&
					 (Type is CStringDataType) == false) // String is an exception as we use ToString for that
			{
				if (Explicit == true)
				{
					// Get the boxed value and return it.
					CMethodCallExpressionASTNode astNode   = new CMethodCallExpressionASTNode(Parent, Token);
					astNode.LeftValue					   = this;
					astNode.RightValue					   = new CIdentifierExpressionASTNode(null, new CToken());
					astNode.RightValue.Token.Literal	   = "GetValue";
					astNode.AddChild(astNode.LeftValue);
					astNode.AddChild(astNode.RightValue);

					//ExceptionOnFail = true;
					Type = Type.GetBoxClass(semanter).ObjectDataType;
					ExpressionResultType = Type;

					astNode.Semant(semanter);
					
					return astNode; // TODO: Memory leak.

					// Unbox the object.
				//	CNewExpressionASTNode* astNode = new CNewExpressionASTNode(NULL, Token);
				//	astNode->DataType = Type;		
				//	astNode->ArgumentExpressions.push_back(RightValue);
				//	astNode->AddChild(RightValue);
				//	RightValue = ReplaceChild(RightValue, astNode);
				//	astNode->Semant(semanter);
				}
			}

			// Normal cast?
			else
			{
				ExpressionResultType = Type;
			}		
		}
		
		if (ExpressionResultType == null)
		{

			// Implicitly cast to bool.
			if (Type is CBoolDataType)
			{
				if ((rightValueDataType is CVoidDataType) == false)// &&
	//				Explicit == true)
				{
					ExpressionResultType = Type;
				}
			}

			// Implicitly cast to string.
			else if (Type is CStringDataType)
			{
				if (rightValueDataType is CNumericDataType || Explicit == true)
				{
					ExpressionResultType = Type;
				}
			}
		
			// Explicitly cast objects.
			else if (Type.CanCastTo(semanter, rightValueDataType))
			{
				if (Explicit == true)
				{
					if (Type is CObjectDataType &&
						rightValueDataType is CObjectDataType)
					{
						ExpressionResultType = Type;
					}
				}
			}

		}

		// Invalid cast :S
		if (ExpressionResultType == null)
		{
			if (Explicit == false)
			{
				semanter.GetContext().FatalError("Cannot implicitly cast value from '" + rightValueDataType.ToString() + "' to '" + Type.ToString() + "'.", Token);
			}
			else
			{
				semanter.GetContext().FatalError("Cannot cast value from '" + rightValueDataType.ToString() + "' to '" + Type.ToString() + "'.", Token);
			}
		}

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult  = RightValue.Evaluate(unit);

		if (ExpressionResultType is CBoolDataType)
		{
			leftResult.SetType(EvaluationDataType.Bool);
		}
		else if (ExpressionResultType is CIntDataType)
		{
			leftResult.SetType(EvaluationDataType.Int);
		}
		else if (ExpressionResultType is CFloatDataType)
		{
			leftResult.SetType(EvaluationDataType.Float);
		}
		else if (ExpressionResultType is CStringDataType)
		{
			leftResult.SetType(EvaluationDataType.String);
		}

		return leftResult;
	}
		
	// =================================================================
	//	Returns true if the conversion between two data types is a valid
	//  cast.
	// =================================================================
	public static bool IsValidCast(CSemanter semanter, CDataType from, CDataType to, bool explicit_cast)
	{
		// Already correct type?
		if (from.IsEqualTo(semanter, to))
		{
			return true;
		}

		// Can cast?
		else if (from.CanCastTo(semanter, to))
		{
			// Box
			if (to is CObjectDataType &&
				!(from is CObjectDataType))
			{
				return true;
			}

			// Unbox
			else if (from is CObjectDataType &&
					 !(to is CObjectDataType))
			{
				if (explicit_cast == true)
				{
					return true;
				}
			}

			// Normal cast?
			else
			{
				return true;
			}
		}
		
		// Implicitly cast to bool.
		if (to is CBoolDataType)
		{
			if (!(from is CVoidDataType))
			{			
				return true;
			}
		}

		// Implicitly cast to string.
		else if (to is CStringDataType)
		{
			if (from is CNumericDataType || explicit_cast == true)
			{
				return true;
			}
		}
		
		// Explicitly cast objects.
		else if (to.CanCastTo(semanter, from))
		{
			if (explicit_cast == true)
			{
				if (to is CObjectDataType &&
					from is CObjectDataType)
				{
					return true;
				}
			}
		}

		return false;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateCastExpression(this);
	}
	
}

