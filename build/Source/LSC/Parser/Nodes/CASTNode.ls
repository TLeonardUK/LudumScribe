// -----------------------------------------------------------------------------
// 	CASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Access level type.
// =================================================================
public enum AccessLevel
{
	Public,
	Private,
	Protected
}

// =================================================================
//	Base class used to store a representation of individual nodes
//	in an Abstract Syntax Tree.
// =================================================================
public class CASTNode
{
	private static int g_create_index_tracker;
	private int m_create_index;
		
	public CToken Token;
	public CASTNode Parent;
	public List<CASTNode> Children = new List<CASTNode>();
	
	public bool Semanted;
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CASTNode()
	{
		m_create_index = g_create_index_tracker++;

		Parent = null;
		Children.Clear();
	}
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CASTNode(CASTNode parent, CToken token)
	{
		m_create_index = g_create_index_tracker++;

		Parent = parent;
		Token = token;
		Semanted = false;

		if (parent != null)
		{
			parent.Children.AddLast(this);
		}
	}
	
	// =================================================================
	//	Converts this node to a string representation.
	// =================================================================
	public override string ToString()
	{
		return "untitled-node";
	}
	
	// =================================================================
	//	Adds a child node to this node.
	// =================================================================
	public void AddChild(CASTNode node, bool atStart=false)
	{
		node.Parent = this;

		if (atStart == true)
		{
			Children.AddFirst(node);
		}
		else
		{
			Children.AddLast(node);
		}
	}
		
	// =================================================================
	//	Removes a child node from this node.
	// =================================================================
	public void RemoveChild(CASTNode node)
	{
		node.Parent = null;
		Children.Remove(node);
	}
	
	// =================================================================
	//	Replaces a child with another child and returns it.
	// =================================================================
	public CASTNode ReplaceChild(CASTNode replace, CASTNode with)
	{
		if (replace == with)
		{
			return replace;
		}

		Children.Remove(replace);

		Children.AddLast(with);
		with.Parent = this;
		return with;
	}

	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public void SemantChildren(CSemanter semanter)
	{
		foreach (CASTNode iter in Children)
		{
			iter.Semant(semanter);
		}
	}
		
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual CASTNode Semant(CSemanter semanter)
	{
		semanter.GetContext().FatalError("AST node cannot be semanted.", Token);
		return null;
	}
		
	// =================================================================
	//	Semants an expression and returns the result as an expression
	//	base node.
	// =================================================================
	public CExpressionBaseASTNode SemantAsExpression(CSemanter semanter)
	{
		return <CExpressionBaseASTNode>(Semant(semanter));
	}
		
	// =================================================================
	//	Performs finalization on this nodes children.
	// =================================================================
	public void FinalizeChildren(CSemanter semanter)
	{
		foreach (CASTNode iter in Children)
		{
			iter.Finalize(semanter);
		}
	}
		
	// =================================================================
	//	Performs finalization on this node.
	// =================================================================
	public virtual CASTNode Finalize(CSemanter semanter)
	{
		FinalizeChildren(semanter);
		return null;
	}
	
	public abstract CASTNode Clone(CSemanter semanter);
		
	// =================================================================
	//	Clones this nodes children and adds them to a parent node.
	// =================================================================
	public virtual void CloneChildren(CSemanter semanter, CASTNode parent)
	{
		foreach (CASTNode iter in Children)
		{
			CASTNode node = iter.Clone(semanter);
			parent.AddChild(node);
		}
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual void Translate(CTranslator translator)
	{	
		translator.GetContext().FatalError("AST node cannot be translated.", Token);
	}
	
	// =================================================================
	//	Causes this nodes children to be translated.
	// =================================================================
	public virtual void TranslateChildren(CTranslator translator)
	{
		foreach (CASTNode iter in Children)
		{
			iter.Translate(translator);
		}
	}
		
	// =================================================================
	//	Finds an alias declaration.
	// =================================================================
	public virtual CAliasASTNode FindAlias(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
		// Find normal declarations.
		List<CASTNode> nodes = GetSearchScopeChildren(semanter);
		foreach (CASTNode iter in nodes)
		{
			CAliasASTNode node = iter as CAliasASTNode;
			if (node != null && node != ignoreNode)
			{
				if (node.Identifier == identifier)
				{
					return node;
				}
			}
		}
		
		CASTNode next_scope = GetParentSearchScope(semanter);
		if (next_scope != null)
		{
			return next_scope.FindAlias(semanter, identifier, ignoreNode);
		}
		else
		{
			return null;
		}
	}
		
	// =================================================================
	//	Finds the declaration in the scope stack with the given
	//  identifier.
	// =================================================================
	public virtual CDeclarationASTNode FindDeclaration(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
		CAliasASTNode aliasNode = FindAlias(semanter, identifier, ignoreNode);
		if (aliasNode != null)
		{
			return aliasNode;
		}

		// Find normal declarations.
		List<CASTNode> nodes = GetSearchScopeChildren(semanter);
		foreach (CASTNode iter in nodes)
		{
			CDeclarationASTNode node = iter as CDeclarationASTNode;
			if (node != null && node != ignoreNode)
			{
				if (node.Identifier == identifier)
				{
					return node;
				}
			}
		}

		CASTNode next_scope = GetParentSearchScope(semanter);
		if (next_scope != null)
		{
			return next_scope.FindDeclaration(semanter, identifier, ignoreNode);
		}
		else
		{
			return null;
		}
	}

	// =================================================================
	//	Finds the declaration in the scope stack with the given
	//  identifier.
	// =================================================================
	public virtual CDeclarationASTNode FindDataTypeDeclaration(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
		CAliasASTNode aliasNode = FindAlias(semanter, identifier, ignoreNode);
		if (aliasNode != null)
		{
			return aliasNode;
		}

		// Find normal declarations.
		List<CASTNode> nodes = GetSearchScopeChildren(semanter);
		foreach (CASTNode iter in nodes)
		{
			CClassASTNode node = iter as CClassASTNode;
			if (node != null && node != ignoreNode)
			{
				if (node.Identifier == identifier)
				{
					return node;
				}
			}
		}

		CASTNode next_scope = GetParentSearchScope(semanter);
		if (next_scope != null)
		{
			return next_scope.FindDataTypeDeclaration(semanter, identifier, ignoreNode);
		}
		else
		{
			return null;
		}
	}

	// =================================================================
	//	Finds the given type on the scope stack.
	// =================================================================
	public virtual CDataType FindDataType(CSemanter semanter, string identifier, List<CDataType> generic_arguments, bool ignore_access = false, bool do_not_semant = false)
	{
		CDeclarationASTNode decl = FindDataTypeDeclaration(semanter, identifier);

		CAliasASTNode dt_decl = decl as CAliasASTNode;
		if (dt_decl != null)
		{
			if (dt_decl.AliasedDataType != null)
			{
				return dt_decl.AliasedDataType;
			}
			else
			{
				decl = dt_decl.AliasedDeclaration;
			}
		}

		CClassASTNode class_decl = decl as CClassASTNode;
		if (class_decl != null)
		{
			if (ignore_access == false)
			{
				class_decl.CheckAccess(semanter, this);
			}
			class_decl = class_decl.GenerateClassInstance(semanter, this, generic_arguments);
			if (do_not_semant == false)
			{
				class_decl.Semant(semanter);
			}
			return class_decl.ObjectDataType;
		}

		return null;
	}
	
	// =================================================================
	//	Gets the package the given node is in.
	// =================================================================
	public virtual CPackageASTNode FindNodePackageScope(CSemanter semanter)
	{
		CASTNode node = this;

		while (node != null)
		{
			CPackageASTNode pkg = node as CPackageASTNode;
			if (pkg != null)
			{
				return pkg;
			}
			node = node.Parent;
		}

		return null;
	}
	
	// =================================================================
	//	Finds the class a node is in.
	// =================================================================
	public virtual CClassASTNode FindClassScope(CSemanter semanter)
	{
		CASTNode node = this;

		while (node != null)
		{
			CClassASTNode scope = node as CClassASTNode;
			if (scope != null)
			{
				return scope;
			}
			node = node.GetParentSearchScope(semanter);//node.Parent;
		}

		return null;
	}

	// =================================================================
	//	Finds the class method scope we are in.
	// =================================================================
	public virtual CClassMemberASTNode FindClassMethodScope(CSemanter semanter)
	{
		CASTNode node = this;

		while (node != null)
		{
			CClassMemberASTNode scope = node as CClassMemberASTNode;
			if (scope != null && scope.MemberMemberType == MemberType.Method)
			{
				return scope;
			}
			node = node.Parent;
		}

		return null;
	}
		
	// =================================================================
	//	Finds a class method with the given arguments.
	// =================================================================
	public virtual CClassMemberASTNode FindClassMethod(CSemanter semanter, string identifier, List<CDataType> arguments, bool explicit_arguments, CASTNode ignoreNode=null, CASTNode referenceNode=null)
	{
		// Real work is done inside the derived method in CClassASTNode

		CASTNode next_scope = GetParentSearchScope(semanter);
		if (next_scope != null)
		{
			return next_scope.FindClassMethod(semanter, identifier, arguments, explicit_arguments, ignoreNode, referenceNode);
		}
		else
		{
			return null;
		}
	}
		
	// =================================================================
	//	Finds a class field.
	// =================================================================
	public virtual CClassMemberASTNode FindClassField(CSemanter semanter, string identifier, CASTNode ignoreNode, CASTNode referenceNode=null)
	{
		// Real work is done inside the derived method in CClassASTNode

		CASTNode next_scope = GetParentSearchScope(semanter);
		if (next_scope != null)
		{
			return next_scope.FindClassField(semanter, identifier, ignoreNode, referenceNode);
		}
		else
		{
			return null;
		}
	}
		
	// =================================================================
	//	Finds the scope the looping statement this node is contained by.
	// =================================================================
	public virtual CASTNode FindLoopScope(CSemanter semanter)
	{
		// Overridden in loop statements to return themselves.

		if (Parent != null)
		{
			return Parent.FindLoopScope(semanter);
		}
		else
		{
			return null;
		}
	}

	// =================================================================
	//	Gets the next scope up the tree to check when looking for
	//	declarations.
	// =================================================================
	public virtual CASTNode GetParentSearchScope(CSemanter semanter)
	{
		return Parent;
	}
	
	// =================================================================
	//	Gets the list of children to be searched when looking for
	//	declarations.
	// =================================================================
	public virtual List<CASTNode> GetSearchScopeChildren(CSemanter semanter)
	{
		return Children;
	}
		
	// =================================================================
	//	Check for duplicate identifiers.
	// =================================================================
	public virtual void CheckForDuplicateIdentifier(CSemanter semanter, string identifier, CASTNode ignore_node=null)
	{
		if (ignore_node == null)
		{
			ignore_node = this;
		}

		CASTNode duplicate = FindDeclaration(semanter, identifier, ignore_node);
		if (duplicate != null)
		{
			semanter.GetContext().FatalError("Encountered duplicate identifier '" + identifier + "'.", Token);
		}
	}

	// =================================================================
	//	Check for duplicate identifier.
	// =================================================================
	public virtual void CheckForDuplicateMethodIdentifier(CSemanter semanter, string identifier, List<CDataType> arguments, CClassMemberASTNode ignore_node=null)
	{
		if (ignore_node == null)
		{
			semanter.GetContext().FatalError("Internal error, no method specified when looking for duplicate identifier.", Token);	
		}

		CClassMemberASTNode method = FindClassMethod(semanter, identifier, arguments, true, ignore_node);
		
		// If we are overriding and we haven't found a base method,
		// then wtf are we overriding?
		if (ignore_node.IsOverride == true && method == null)
		{ 
			semanter.GetContext().FatalError("Attempt to override unknown virtual method '" + ignore_node.Identifier + "'.", Token);
		}

		// If we are overriding this method, then a method lower
		// in the inheritance tree with the same name is valid.
		if (method					!= null	&&
			method.IsVirtual		== true &&
			ignore_node.IsVirtual	== true &&
			method.Parent			!= ignore_node.Parent &&
			(ignore_node.IsOverride == true || ignore_node.IsAbstract == true))
		{
			method = null;
		}
		
		if (method != null)
		{
			semanter.GetContext().FatalError("Encountered duplicate method '" + ignore_node.Identifier + "'.", Token);
		}
	}
		
	// =================================================================
	//	Evalulates the constant value of this node.
	// =================================================================
	public virtual EvaluationResult Evaluate(CTranslationUnit unit)
	{
		unit.FatalError("Could not statically analyse node. Expression is not constant.", Token);
		return new EvaluationResult(false);
	}
		
	// =================================================================
	//	Returns true if this node can accept break statements inside
	//	of it.
	// =================================================================
	public virtual bool AcceptBreakStatement()
	{
		// Overridden in loop statements.

		return false;
	}
		
	// =================================================================
	//	Returns true if this node can accept continue statements inside
	//	of it.
	// =================================================================
	public virtual bool AcceptContinueStatement()
	{
		// Overridden in loop statements.

		return false;
	}
	
}

