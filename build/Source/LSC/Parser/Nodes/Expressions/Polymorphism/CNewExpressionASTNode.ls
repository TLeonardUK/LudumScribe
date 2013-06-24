// -----------------------------------------------------------------------------
// 	CNewExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CNewExpressionASTNode : CExpressionBaseASTNode
{
	public CDataType DataType;
	public bool IsArray;
	public CClassMemberASTNode ResolvedConstructor;
	public List<CASTNode> ArgumentExpressions;
	public CArrayInitializerASTNode ArrayInitializer;
	
	public CNewExpressionASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override CASTNode Finalize(CSemanter semanter)
	{
	}
	
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}
}

