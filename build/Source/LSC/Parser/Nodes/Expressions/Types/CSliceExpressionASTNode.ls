// -----------------------------------------------------------------------------
// 	CSliceExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CSliceExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode StartExpression;
	public CASTNode EndExpression;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CSliceExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CSliceExpressionASTNode clone = new CSliceExpressionASTNode(null, Token);
		
		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
		}

		if (StartExpression != null)
		{
			clone.StartExpression = <CASTNode>(StartExpression.Clone(semanter));
			clone.AddChild(clone.StartExpression);
		}

		if (EndExpression != null)
		{
			clone.EndExpression = <CASTNode>(EndExpression.Clone(semanter));
			clone.AddChild(clone.EndExpression);
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
		LeftValue = ReplaceChild(LeftValue, LeftValue.Semant(semanter));
		if (StartExpression != null)
		{
			StartExpression  = ReplaceChild(StartExpression, StartExpression.Semant(semanter));
		}
		if (EndExpression != null)
		{
			EndExpression    = ReplaceChild(EndExpression, EndExpression.Semant(semanter));
		}

		// Get expression references.
		CExpressionBaseASTNode lValueBase    = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode startExprBase = <CExpressionBaseASTNode>(StartExpression);
		CExpressionBaseASTNode endExprBase   = <CExpressionBaseASTNode>(EndExpression);
		
		// Cast index to integer.
		if (startExprBase != null)
		{
			StartExpression = ReplaceChild(startExprBase, startExprBase.CastTo(semanter, new CIntDataType(Token), Token));
		}
		if (endExprBase != null)
		{
			EndExpression   = ReplaceChild(endExprBase,   endExprBase.CastTo  (semanter, new CIntDataType(Token), Token));
		}

		// Valid object to slice?
		List<CDataType> argumentTypes = new List<CDataType>();
		argumentTypes.AddLast(new CIntDataType(Token));
		argumentTypes.AddLast(new CIntDataType(Token));

		CClassASTNode classNode = lValueBase.ExpressionResultType.GetClass(semanter);
		CClassMemberASTNode memberNode = classNode.FindClassMethod(semanter, "GetSlice", argumentTypes, true, null, null);

		if (memberNode == null)
		{
			semanter.GetContext().FatalError("Data type does not support slicing, no GetSlice method defined.", Token);
		}
		else
		{
			ExpressionResultType = memberNode.ReturnType;
		}

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateSliceExpression(this);
	}
	
}

