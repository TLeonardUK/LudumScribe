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
		if (<CBoolDataType>(type) != null)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "false");
		}
		else if (<CIntDataType>(type) != null)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "0");
		}
		else if (<CFloatDataType>(type) != null)
		{
			lit =  new CLiteralExpressionASTNode(null, token, type, "0.0");
		}
		else if (<CStringDataType>(type) != null)
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
		if (<CStringDataType>(lvalue) != null) 
		{
			return lvalue;	
		}
		if (<CStringDataType>(rvalue) != null) 
		{
			return rvalue;	
		}

		// If either are float result is float.
		if (<CFloatDataType>(lvalue) != null) 
		{
			return lvalue;	
		}
		if (<CFloatDataType>(rvalue) != null) 
		{
			return rvalue;	
		}

		// If either are int result is int.
		if (<CIntDataType>(lvalue) != null) 
		{
			return lvalue;	
		}
		if (<CIntDataType>(rvalue) != null) 
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