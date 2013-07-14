// -----------------------------------------------------------------------------
// 	CExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CExpressionASTNode : CExpressionBaseASTNode
{
	public bool IsConstant;
	public CASTNode LeftValue;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CExpressionASTNode clone = new CExpressionASTNode(null, Token);

		if (LeftValue != null)
		{
			clone.LeftValue = (<CASTNode>LeftValue).Clone(semanter);
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

		// Semant the expression.
		LeftValue = ReplaceChild(LeftValue, LeftValue.Semant(semanter));
		ExpressionResultType = (<CExpressionBaseASTNode>LeftValue).ExpressionResultType;

		// Check it evaluates correctly.
		if (IsConstant == true)
		{
		//	try
		//	{
				EvaluationResult result = Evaluate(semanter.GetContext());
		//	}
		//	catch (std::runtime_error ex)
		//	{
		//		semanter->GetContext()->FatalError("Illegal constant expression.", Token);
		//	}
		}

		return this;
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual override EvaluationResult Evaluate(CTranslationUnit unit)
	{
		EvaluationResult leftResult = LeftValue.Evaluate(unit);
		return leftResult;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateExpressionStatement(this);
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateExpression(this);
	}
	
}