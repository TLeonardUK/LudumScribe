// -----------------------------------------------------------------------------
// 	CForEachStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CForEachStatementASTNode : CASTNode
{
	public CASTNode VariableStatement;
	public CExpressionBaseASTNode ExpressionStatement;
	public CASTNode BodyStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CForEachStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CForEachStatementASTNode clone = new CForEachStatementASTNode(null, Token);
		
		if (VariableStatement != null)
		{
			clone.VariableStatement = <CASTNode>(VariableStatement.Clone(semanter));
			clone.AddChild(clone.VariableStatement);
		}
		if (ExpressionStatement != null)
		{
			clone.ExpressionStatement = <CExpressionASTNode>(ExpressionStatement.Clone(semanter));
			clone.AddChild(clone.ExpressionStatement);
		}
		if (BodyStatement != null)
		{
			clone.BodyStatement = <CASTNode>(BodyStatement.Clone(semanter));
			clone.AddChild(clone.BodyStatement);
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
		
		// Find enumerable base.
		CDataType enumerable_base = FindDataType(semanter, "IEnumerable", new List<CDataType>());
		if (enumerable_base == null ||
			enumerable_base.GetClass(semanter) == null)
		{
			semanter.GetContext().FatalError("Internal error, could not find base 'IEnumerable' class.");
		}

		// Check expression is valid.
		if (ExpressionStatement != null)
		{
			ExpressionStatement = (ExpressionStatement.Semant(semanter)) as CExpressionBaseASTNode;

			CDataType dataType = ExpressionStatement.ExpressionResultType.GetClass(semanter).ObjectDataType;

			if (!dataType.CanCastTo(semanter, enumerable_base))
			{
				semanter.GetContext().FatalError("ForEach expressions must implement 'IEnumerable' interface.", Token);	
			}
		}

		// Check variable declaration is a valid l-value.
		VariableStatement = VariableStatement.Semant(semanter);
		CExpressionASTNode varExpr = (VariableStatement) as CExpressionASTNode;
		if (varExpr != null)
		{
			// Try and find field the l-value is refering to.
			CClassMemberASTNode		   		field_node		 	= null;
			CVariableStatementASTNode	   	var_node			= null;
			CFieldAccessExpressionASTNode 	field_access_node 	= (varExpr.LeftValue) as CFieldAccessExpressionASTNode;
			CIdentifierExpressionASTNode  	identifier_node   	= (varExpr.LeftValue) as CIdentifierExpressionASTNode;
			CIndexExpressionASTNode	  		index_node		 	= (varExpr.LeftValue) as CIndexExpressionASTNode;

			if (index_node != null)
			{
				// Should call CanAssignIndex or something
				CExpressionBaseASTNode leftLeftValueBase  = (index_node.LeftValue) as CExpressionBaseASTNode;

				List<CDataType> args = new List<CDataType>();
				args.AddLast(new CIntDataType(Token));
				args.AddLast(varExpr.ExpressionResultType);
				args.AddLast(new CBoolDataType(Token));

				CClassASTNode arrayClass = leftLeftValueBase.ExpressionResultType.GetClass(semanter);
				CClassMemberASTNode memberNode = arrayClass.FindClassMethod(semanter, "SetIndex", args, true, null, null);
			
				if (memberNode == null || ((leftLeftValueBase.ExpressionResultType is CStringDataType) == false && (leftLeftValueBase.ExpressionResultType is CArrayDataType) == false))
				{
					index_node = null;
				}
			}
			else if (field_access_node != null)
			{
				field_node = field_access_node.ExpressionResultClassMember;
			}
			else if (identifier_node != null)
			{
				field_node = identifier_node.ExpressionResultClassMember;
				var_node = identifier_node.ExpressionResultVariable;
			}

			// Is the l-value a valid assignment target?
			if (field_node == null && var_node == null && index_node == null)
			{		
				semanter.GetContext().FatalError("Illegal l-value for assignment expression.", Token);
			}
			if (field_node != null && field_node.IsConst == true)
			{		
				semanter.GetContext().FatalError("Illegal l-value for assignment expression, l-value was declared constant.", Token);
			}
		}

		// Right nows the fun bit! We're going to construct part of the AST tree in-place. The result should be
		// the AST equivilent of this;
		//
		//	ls_IEnumerator internal = (expr).GetEnumerator();
		//	while (internal.Next())
		//	{
		//		object value = internal.Current();
		//		(body)
		//	}
		//
		CBlockStatementASTNode			new_body									= new CBlockStatementASTNode(this, Token.Copy());
		CVariableStatementASTNode		enumerator_var								= new CVariableStatementASTNode(new_body, Token.Copy());
		CMethodCallExpressionASTNode	get_enum_method_call_expr					= new CMethodCallExpressionASTNode(enumerator_var, Token.Copy());
		CIdentifierExpressionASTNode	get_enum_identifier_expr					= new CIdentifierExpressionASTNode(get_enum_method_call_expr, Token.Copy());
		CWhileStatementASTNode			while_loop									= new CWhileStatementASTNode(new_body, Token.Copy());
		CMethodCallExpressionASTNode	while_loop_method_call_expr					= new CMethodCallExpressionASTNode(while_loop, Token.Copy());
		CIdentifierExpressionASTNode	while_loop_identifier_expr					= new CIdentifierExpressionASTNode(while_loop_method_call_expr, Token.Copy());
		CIdentifierExpressionASTNode	while_loop_var_ref_expr						= new CIdentifierExpressionASTNode(while_loop_method_call_expr, Token.Copy());
		CBlockStatementASTNode			while_body									= new CBlockStatementASTNode(while_loop, Token);

		//	CVariableStatementASTNode		value_var				= new CVariableStatementASTNode(while_body, Token);

		RemoveChild(VariableStatement);
		RemoveChild(ExpressionStatement);
		RemoveChild(BodyStatement);
	//	AddChild(new_body);
	//	new_body.AddChild(enumerator_var);
	//	new_body.AddChild(while_loop);

	//	enumerator_var.AddChild(get_enum_method_call_expr);
		get_enum_method_call_expr.AddChild(ExpressionStatement);
	//	get_enum_method_call_expr.AddChild(get_enum_identifier_expr);
	//	while_loop.AddChild(while_body);
	//	while_loop.AddChild(while_loop_method_call_expr);
	//	while_loop_method_call_expr.AddChild(while_loop_identifier_expr);
	//	while_loop_method_call_expr.AddChild(while_loop_var_ref_expr);

		// ls_IEnumerator internal = (expr).GetEnumerator();
		get_enum_identifier_expr.Token.Literal = "GetEnumerator"; 

		get_enum_method_call_expr.LeftValue = ExpressionStatement;
		get_enum_method_call_expr.RightValue = get_enum_identifier_expr;

		enumerator_var.Type = FindDataType(semanter, "IEnumerator", new List<CDataType>());
		enumerator_var.AssignmentExpression = get_enum_method_call_expr;
		enumerator_var.Identifier = semanter.NewInternalVariableName();
		enumerator_var.MangledIdentifier = enumerator_var.Identifier;

		// while (internal.Next())
		while_loop_var_ref_expr.Token.Literal		= enumerator_var.Identifier; 
		while_loop_identifier_expr.Token.Literal	= "Next"; 

		while_loop_method_call_expr.LeftValue = while_loop_var_ref_expr;
		while_loop_method_call_expr.RightValue = while_loop_identifier_expr;

		while_loop.BodyStatement = while_body;
		while_loop.ExpressionStatement = while_loop_method_call_expr;

		// object value = internal.Current();
		if (varExpr != null)
		{	
			CExpressionASTNode				value_assign_expr						= new CExpressionASTNode(while_body, Token.Copy());
			CAssignmentExpressionASTNode	value_assign							= new CAssignmentExpressionASTNode(value_assign_expr, Token.Copy());
			CMethodCallExpressionASTNode	value_assign_method_call_expr			= new CMethodCallExpressionASTNode(value_assign, Token.Copy());
			CIdentifierExpressionASTNode	value_assign_method_call_lvalue_expr	= new CIdentifierExpressionASTNode(value_assign_method_call_expr, Token.Copy());
			CIdentifierExpressionASTNode	value_assign_method_call_rvalue_expr	= new CIdentifierExpressionASTNode(value_assign_method_call_expr, Token.Copy());

			value_assign_expr.LeftValue = value_assign;

			value_assign_method_call_lvalue_expr.Token.Literal	= enumerator_var.Identifier; 
			value_assign_method_call_rvalue_expr.Token.Literal	= "Current"; 

			value_assign_method_call_expr.LeftValue = value_assign_method_call_lvalue_expr;
			value_assign_method_call_expr.RightValue = value_assign_method_call_rvalue_expr;

			value_assign.LeftValue = varExpr.LeftValue;
			value_assign.RightValue = value_assign_method_call_expr;
			value_assign.Token.Type = TokenIdentifier.OP_ASSIGN;

			value_assign.AddChild(varExpr.LeftValue);

			CExpressionBaseASTNode left_base = (value_assign.LeftValue) as CExpressionBaseASTNode;
			CExpressionBaseASTNode right_base = (value_assign.RightValue) as CExpressionBaseASTNode;
			left_base.Semant(semanter);
			right_base.Semant(semanter);
			value_assign.RightValue = value_assign.ReplaceChild(value_assign.RightValue, right_base.CastTo(semanter, left_base.ExpressionResultType, Token, true, true));
		}
		else
		{		
			CVariableStatementASTNode var_node = (VariableStatement) as CVariableStatementASTNode;

			CMethodCallExpressionASTNode	value_assign_method_call_expr			= new CMethodCallExpressionASTNode(VariableStatement, Token.Copy());
			CIdentifierExpressionASTNode	value_assign_method_call_lvalue_expr	= new CIdentifierExpressionASTNode(value_assign_method_call_expr, Token.Copy());
			CIdentifierExpressionASTNode	value_assign_method_call_rvalue_expr	= new CIdentifierExpressionASTNode(value_assign_method_call_expr, Token.Copy());

			value_assign_method_call_lvalue_expr.Token.Literal	= enumerator_var.Identifier; 
			value_assign_method_call_rvalue_expr.Token.Literal	= "Current"; 

			value_assign_method_call_expr.LeftValue = value_assign_method_call_lvalue_expr;
			value_assign_method_call_expr.RightValue = value_assign_method_call_rvalue_expr;

			var_node.RemoveChild(var_node.AssignmentExpression);
			while_body.AddChild(var_node);

			var_node.AssignmentExpression = value_assign_method_call_expr;

			value_assign_method_call_expr.Semant(semanter);
			CASTNode casted_node = value_assign_method_call_expr.CastTo(semanter, var_node.Type, Token, true, true);
			VariableStatement.ReplaceChild(value_assign_method_call_expr, casted_node);
			var_node.AssignmentExpression = <CExpressionBaseASTNode>(casted_node);
		}

		while_body.AddChild(BodyStatement);

		// Replace body statement.
		BodyStatement = new_body;

		// Parse dat body.
		if (BodyStatement != null)
		{
			BodyStatement = BodyStatement.Semant(semanter);
		}

		return this;
	}
		
	// =================================================================
	//	Finds the scope the looping statement this node is contained by.
	// =================================================================
	public virtual override CASTNode FindLoopScope(CSemanter semanter)
	{
		return this;
	}
		
	// =================================================================
	//	Returns true if this node can accept break statements inside
	//	of it.
	// =================================================================
	public virtual override bool AcceptBreakStatement()
	{
		return true;
	}
	
	// =================================================================
	//	Returns true if this node can accept continue statements inside
	//	of it.
	// =================================================================
	public virtual override bool AcceptContinueStatement()
	{
		return true;
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateForEachStatement(this);
	}
}

