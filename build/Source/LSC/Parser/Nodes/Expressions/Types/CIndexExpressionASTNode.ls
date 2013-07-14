// -----------------------------------------------------------------------------
// 	CIndexExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CIndexExpressionASTNode : CExpressionBaseASTNode
{
	public CASTNode LeftValue;
	public CASTNode IndexExpression;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CIndexExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CIndexExpressionASTNode clone = new CIndexExpressionASTNode(null, Token);
		
		if (LeftValue != null)
		{
			clone.LeftValue = <CASTNode>(LeftValue.Clone(semanter));
			clone.AddChild(clone.LeftValue);
		}

		if (IndexExpression != null)
		{
			clone.IndexExpression = <CASTNode>(IndexExpression.Clone(semanter));
			clone.AddChild(clone.IndexExpression);
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
		LeftValue		= ReplaceChild(LeftValue, LeftValue.Semant(semanter));
		IndexExpression = ReplaceChild(IndexExpression, IndexExpression.Semant(semanter));

		// Get expression references.
		CExpressionBaseASTNode lValueBase    = <CExpressionBaseASTNode>(LeftValue);
		CExpressionBaseASTNode indexExprBase = <CExpressionBaseASTNode>(IndexExpression);

		// Cast index to integer.
		IndexExpression = ReplaceChild(indexExprBase, indexExprBase.CastTo(semanter, new CIntDataType(Token), Token));

		// Valid object to index?
		List<CDataType> argumentTypes = new List<CDataType>();
		argumentTypes.AddLast(new CIntDataType(Token));

		CClassASTNode classNode = lValueBase.ExpressionResultType.GetClass(semanter);
		CClassMemberASTNode memberNode = classNode.FindClassMethod(semanter, "GetIndex", argumentTypes, true, null, null);

		if (memberNode == null)
		{
			semanter.GetContext().FatalError("Data type does not support indexing, no GetIndex method defined.", Token);
		}
		// TODO: Remove this restriction.
		else if (memberNode.MangledIdentifier != "GetIndex")
		{
			semanter.GetContext().FatalError("Indexing using the GetIndex method is only supported on native members.", Token);
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
		return translator.TranslateIndexExpression(this);	
	}
	
}

