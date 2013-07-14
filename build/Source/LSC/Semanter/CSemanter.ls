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
	private List<CASTNode> m_scope_stack = new List<CASTNode>();
	private List<string> m_mangled = new List<string>();
	
	private int m_internal_var_counter;
		
	// =================================================================
	//	Gets a new internal variable name.
	// =================================================================
	public string NewInternalVariableName()
	{
		return "lsInternal_s__" + (m_internal_var_counter++);
	}
		
	// =================================================================
	//	Constructs a default assignment expression that can be applyed
	//	to a variable to initialize it if an initialization expression
	//	is not provided.
	// =================================================================	
	public CExpressionASTNode ConstructDefaultAssignmentExpr(CASTNode parent, CToken token, CDataType type)
	{
		CLiteralExpressionASTNode lit = null;
		if (type is CBoolDataType)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "false");
		}
		else if (type is CIntDataType)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "0");
		}
		else if (type is CFloatDataType)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "0.0");
		}
		else if (type is CStringDataType)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "");
		}
		else
		{
			lit =  new CLiteralExpressionASTNode(null, token, new CNullDataType(token), "");
		}

		CExpressionASTNode expr = new CExpressionASTNode(parent, token);
		expr.LeftValue = lit;
		expr.AddChild(lit);

		return expr;
	}

	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		m_context = context;
		m_internal_var_counter = 0;

		context.GetASTRoot().Semant(this);
		context.GetASTRoot().Finalize(this);

		return true;
	}
		
	// =================================================================
	//	Gets the context we are semanting for.
	// =================================================================
	public CTranslationUnit GetContext()
	{
		return m_context;
	}
		
	// =================================================================
	//	Gets a unique mangled identifier.
	// =================================================================
	public string GetMangled(string mangled)
	{
		string originalMangled = mangled;

		int index = 1;
		while (true)
		{
			bool found = false;

			foreach (string iter in m_mangled)
			{
				if (iter == mangled)
				{
					mangled = originalMangled + "_" + (index++);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				break;
			}
		}
		m_mangled.AddLast(mangled);
		
		return mangled;
	}
		
	// =================================================================
	//	Check for duplicate identifiers.
	// =================================================================
	public CDataType BalanceDataTypes(CDataType lvalue, CDataType rvalue)
	{
		// If either are string result is string.
		if (lvalue is CStringDataType) 
		{
			return lvalue;	
		}
		if (rvalue is CStringDataType) 
		{
			return rvalue;	
		}

		// If either are float result is float.
		if (lvalue is CFloatDataType) 
		{
			return lvalue;	
		}
		if (rvalue is CFloatDataType) 
		{
			return rvalue;	
		}

		// If either are int result is int.
		if (lvalue is CIntDataType) 
		{
			return lvalue;	
		}
		if (rvalue is CIntDataType) 
		{
			return rvalue;	
		}
		
		// Check which values we can cast too.
		if (rvalue.CanCastTo(this, lvalue))
		{
			return lvalue;
		}
		if (lvalue.CanCastTo(this, rvalue))
		{
			return rvalue;
		}

		// o_o
		m_context.FatalError("Unable to implicitly convert between data-types '" + lvalue.ToString() + "' and '" + rvalue.ToString() + "'", lvalue.Token);

		return null;
	}	
}