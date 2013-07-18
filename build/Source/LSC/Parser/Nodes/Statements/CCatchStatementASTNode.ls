// -----------------------------------------------------------------------------
// 	CCatchStatementASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on an block statement.
// =================================================================
public class CCatchStatementASTNode : CASTNode
{
	public CVariableStatementASTNode VariableStatement;
	public CASTNode BodyStatement;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CCatchStatementASTNode(CASTNode parent, CToken token)
	{
		CASTNode(parent, token);
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CCatchStatementASTNode clone = new CCatchStatementASTNode(null, Token);
		
		if (VariableStatement != null)
		{
			clone.VariableStatement = <CVariableStatementASTNode>(VariableStatement.Clone(semanter));
			clone.AddChild(clone.VariableStatement);
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
		Trace.Write("CCatchStatementASTNode");
		
		if (BodyStatement != null)
		{
			BodyStatement = BodyStatement.Semant(semanter);
		}

		// Semant variable.
		VariableStatement.Semant(semanter);

		CDataType exception_base = FindDataType(semanter, "Exception", new List<CDataType>());
		if (exception_base == null ||
			exception_base.GetClass(semanter) == null)
		{
			semanter.GetContext().FatalError("Internal error, could not find base 'Exception' class.");
		}

		CDataType catch_type = VariableStatement.Type;
		if (catch_type == null ||
			catch_type.GetClass(semanter).InheritsFromClass(semanter, exception_base.GetClass(semanter)) == false)
		{
			semanter.GetContext().FatalError("Caught exceptions must inherit from 'Exception' class.", Token);
		}

		return this;
	}
}

