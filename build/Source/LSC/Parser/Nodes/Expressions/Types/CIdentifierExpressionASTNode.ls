// -----------------------------------------------------------------------------
// 	CIdentifierExpressionASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an expression.
// =================================================================
public class CIdentifierExpressionASTNode : CExpressionBaseASTNode
{
	public CClassMemberASTNode ExpressionResultClassMember;
	public CVariableStatementASTNode ExpressionResultVariable;
	public CDeclarationASTNode ResolvedDeclaration;
	public List<CDataType> GenericTypes;
	
	public CIdentifierExpressionASTNode(CASTNode parent, CToken token)
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

