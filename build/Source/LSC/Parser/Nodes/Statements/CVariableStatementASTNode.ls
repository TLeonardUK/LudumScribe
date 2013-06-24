// -----------------------------------------------------------------------------
// 	CVariableStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CVariableStatementASTNode : CDeclarationASTNode
{
	public bool IsParameter;
	public CDataType Type;
	public CExpressionBaseASTNode AssignmentExpression;
	
	public CVariableStatementASTNode(CASTNode parent, CToken token)
	{
	}
	
	public virtual override string ToString()
	{
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	
	public virtual override void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}
}

