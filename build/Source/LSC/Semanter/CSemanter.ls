// -----------------------------------------------------------------------------
// 	CSemanter.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for semantic analysis of a parsed AST.
// =================================================================
public class CSemanter
{
	private CTranslationUnit m_context;
	private List<CASTNode> m_scope_stack;
	private List<string> m_mangled;
	
	private int m_internal_var_counter;
	
	public string NewInternalVariableName()
	{
	}
	
	public CExpressionASTNode ConstructDefaultAssignmentExpr(CASTNode parent, CToken token, CDataType type)
	{
	}
	
	public bool Process(CTranslationUnit context)
	{
	}
	
	public CTranslationUnit GetContext()
	{
	}
	
	public string GetMangled(string mangled)
	{
	}
	
	public CDataType BalanceDataTypes(CDataType lvalue, CDataType rvalue)
	{
	}	
}



