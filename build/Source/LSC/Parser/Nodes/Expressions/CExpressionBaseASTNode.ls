// -----------------------------------------------------------------------------
// 	CExpressionBaseASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all expression operators.
// =================================================================
public class CExpressionBaseASTNode : CASTNode
{

	public CDataType ExpressionResultType;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CExpressionBaseASTNode(CASTNode parent, CToken token)
	{	
		CASTNode(parent, token);
	}
		
	// =================================================================
	//	Returns a node that casts this expression's result to the correct
	//  data type. If already of the correct type this node is returned.
	// =================================================================
	public CASTNode CastTo(CSemanter semanter, CDataType type, CToken castToken, bool explicit_cast=false, bool exception_on_fail=true)
	{
		// If we are already of this type, just return this.
		if (ExpressionResultType.IsEqualTo(semanter, type))
		{
			return this;
		}

		// Create a cast.
		CCastExpressionASTNode node = new CCastExpressionASTNode(null, castToken, false);
		node.Parent = Parent;
		node.Type = type;
		node.RightValue = this;
		node.AddChild(this);
		node.Explicit = explicit_cast;
		node.ExceptionOnFail = exception_on_fail;

		CASTNode ret = node.Semant(semanter);
		node.Parent = null;

		return ret;
	}
	
	// =================================================================
	//	Translates this expression.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.GetContext().FatalError("Internal error. Attempt to directly translate expression base node.", Token);
	}
	
	public abstract string TranslateExpr(CTranslator translator);
	
}

