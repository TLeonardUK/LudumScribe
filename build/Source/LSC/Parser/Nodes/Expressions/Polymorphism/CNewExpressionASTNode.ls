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
	public List<CASTNode> ArgumentExpressions = new List<CASTNode>();
	public CArrayInitializerASTNode ArrayInitializer;
		
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CNewExpressionASTNode(CASTNode parent, CToken token)
	{
		CExpressionBaseASTNode(parent, token);
	}
		
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CNewExpressionASTNode clone = new CNewExpressionASTNode(null, Token);
		clone.DataType = DataType;
		clone.IsArray = IsArray;

		foreach (CASTNode iter in ArgumentExpressions)
		{
			CASTNode node = iter.Clone(semanter);
			clone.ArgumentExpressions.AddLast(node);
			clone.AddChild(node);
		}

		return clone;
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		// Semant data types.
		DataType = DataType.Semant(semanter, this);

		// Semant arguments.
		List<CDataType> argument_datatypes = new List<CDataType>();
		int index = 0;
		foreach (CASTNode iter in ArgumentExpressions)
		{
			CExpressionBaseASTNode node = <CExpressionBaseASTNode>(iter);
			node = <CExpressionBaseASTNode>(node.Semant(semanter));
			argument_datatypes.AddLast(node.ExpressionResultType);
			ArgumentExpressions.SetIndex(index++, node);
		}

		// Semant array initializer.
		if (ArrayInitializer != null)
		{
			ArrayInitializer.Semant(semanter);
		}

		// Create new array of objects.
		if (IsArray == true)
		{
			// Cast all arguments to correct data types.
			index = 0;
			foreach (CASTNode iter in ArgumentExpressions)
			{
				CExpressionBaseASTNode subnode = <CExpressionBaseASTNode>(iter);
				subnode.Parent.ReplaceChild(subnode, subnode = <CExpressionBaseASTNode>(subnode.CastTo(semanter, new CIntDataType(Token), Token)));
				ArgumentExpressions.SetIndex(index++, subnode);
			}

			ExpressionResultType = DataType;
		}

		// Create a new object!
		else
		{		
			// Make sure DT is a class.
			if ((DataType is CObjectDataType) == false)
			{
				semanter.GetContext().FatalError("Cannot instantiate primitive data type '" + DataType.ToString() + "'.", Token);
			}

			// Check class is valid.
			CClassASTNode classNode = DataType.GetClass(semanter);
			if (classNode.IsInterface == true)
			{
				semanter.GetContext().FatalError("Cannot instantiate interface '" + DataType.ToString() + "'.", Token);
			}
			if (classNode.IsAbstract == true)
			{
				semanter.GetContext().FatalError("Cannot instantiate abstract class '" + DataType.ToString() + "'.", Token);
			}
			if (classNode.IsStatic == true)
			{
				semanter.GetContext().FatalError("Cannot instantiate static class '" + DataType.ToString() + "'.", Token);
			}
			if (classNode.IsNative == true)
			{
				semanter.GetContext().FatalError("Cannot instantiate native class '" + DataType.ToString() + "'.", Token);
			}

			classNode.IsInstanced = true;
			classNode.InstancedBy = this;

			// Check we can find a constructor.
			CClassMemberASTNode node = classNode.FindClassMethod(semanter, classNode.Identifier, argument_datatypes, false);
			if (node == null)
			{
				semanter.GetContext().FatalError("No suitable constructor to instantiate class '" + DataType.ToString() + "'.", Token);
			}

		//	if (classNode.Identifier == "MapPair")
		//	{
		//		printf("WUT");
		//	}

			ResolvedConstructor = node;

			// Cast all arguments to correct data types.
			index = 0;
			foreach (CASTNode iter in ArgumentExpressions)
			{
				CDataType dataType = node.Arguments.GetIndex(index++).Type;

				CExpressionBaseASTNode subnode = <CExpressionBaseASTNode>(iter);
				CExpressionBaseASTNode subnode_casted = <CExpressionBaseASTNode>(subnode.CastTo(semanter, dataType, Token));
				this.ReplaceChild(subnode, subnode_casted);

				ArgumentExpressions.SetIndex(index - 1, subnode_casted);
			}

			ExpressionResultType = DataType;
		}

		// Check we can create new object.
		if ((DataType is CArrayDataType) == false)
		{		
			// Check class is valid.
			CClassASTNode classNode = DataType.GetClass(semanter);

			// Check we can find a constructor.
			CClassMemberASTNode node = classNode.FindClassMethod(semanter, classNode.Identifier, argument_datatypes, false);
			if (node == null)
			{
				semanter.GetContext().FatalError("Could not find suitable constructor to instantiate class '" + DataType.ToString() + "'.", Token);
			}
		}

		return this;
	}
		
	// =================================================================
	//	Performs finalization on this node.
	//
	//	TODO: Move this into semant, we only have it in here because
	//		  if we do a checkAccess in semant we will get a null
	//		  reference exception if we are still assinging this
	//		  nodes parents (in the case of implicit boxing)
	//
	// =================================================================
	public virtual override CASTNode Finalize(CSemanter semanter)
	{
		// Grab arguments.
		List<CDataType> argument_datatypes = new List<CDataType>();
		foreach (CASTNode iter in ArgumentExpressions)
		{
			CExpressionBaseASTNode node = <CExpressionBaseASTNode>(iter);
			argument_datatypes.AddLast(node.ExpressionResultType);
		}

		// Create new object.
		if ((DataType is CArrayDataType) == false)
		{		
			// Check class is valid.
			CClassASTNode classNode = DataType.GetClass(semanter);

			// Check we can find a constructor.
			CClassMemberASTNode node = classNode.FindClassMethod(semanter, classNode.Identifier, argument_datatypes, false);
			if (node == null)
			{
				semanter.GetContext().FatalError("Could not find suitable constructor to instantiate class '" + DataType.ToString() + "'.", Token);
			}

			// Now to do the actual finalization - checking if access is valid!
			node.CheckAccess(semanter, this);
		}

		return this;
	}
		
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override string TranslateExpr(CTranslator translator)
	{
		return translator.TranslateNewExpression(this);
	}
}

