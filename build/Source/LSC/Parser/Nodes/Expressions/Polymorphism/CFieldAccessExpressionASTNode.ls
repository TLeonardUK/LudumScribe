// -----------------------------------------------------------------------------
// 	CFieldAccessExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CFieldAccessExpressionASTNode : CExpressionBaseASTNode
{
	protected bool m_isSemantingRightValue;
	
	public CASTNode LeftValue;
	public CASTNode RightValue;
	public CClassMemberASTNode ExpressionResultClassMember;
	
	public CFieldAccessExpressionASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override string TranslateExpr(CTranslator translator)
	{
	}
}

