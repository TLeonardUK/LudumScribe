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
	public List<CASTNode> Children;
	
	public bool Semanted;
	
	// General management.
	public override string ToString()
	{
	}
	
	// Child management.
	public void AddChild(CASTNode node, bool atStart=false)
	{
	}
	public void RemoveChild(CASTNode node)
	{
	}
	public CASTNode ReplaceChild(CASTNode replace, CASTNode with)
	{
	}
	
	// Semantic analysis.
	public void SemantChildren(CSemanter semanter)
	{
	}
	public virtual CASTNode Semant(CSemanter semanter)
	{
	}
	
	public CExpressionBaseASTNode SemantAsExpression(CSemanter semanter)
	{
	}
	
	public void FinalizeChildren(CSemanter semanter)
	{
	}
	public virtual CASTNode Finalize(CSemanter semanter)
	{
	}
	
	public abstract CASTNode Clone(CSemanter semanter);
	
	public virtual void CloneChildren(CSemanter semanter, CASTNode parent)
	{
	}
	
	public virtual void Translate(CTranslator translator)
	{
	}
	public virtual void TranslateChildren(CTranslator translator)
	{
	}
	
	// Finding things.
	public virtual CAliasASTNode FindAlias(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
	}
	public virtual CDeclarationASTNode FindDeclaration(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
	}
	public virtual CDeclarationASTNode FindDataTypeDeclaration(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
	}
	public virtual CDataType FindDataType(CSemanter semanter, string identifier, List<CDataType> generic_arguments, bool ignore_access = false)
	{
	}
	public virtual CPackageASTNode FindNodePackageScope(CSemanter semanter)
	{
	}
	public virtual CClassASTNode FindClassScope(CSemanter semanter)
	{
	}
	public virtual CClassMemberASTNode FindClassMethodScope(CSemanter semanter)
	{
	}
	public virtual CClassMemberASTNode FindClassMethod(CSemanter semanter, string identifier, List<CDataType> arguments, bool explicit_arguments, CASTNode ignoreNode=null, CASTNode referenceNode=null)
	{
	}
	public virtual CClassMemberASTNode FindClassField(CSemanter semanter, string identifier, CASTNode ignoreNode, CASTNode referenceNode=null)
	{
	}
	public virtual CASTNode FindLoopScope(CSemanter semanter)
	{
	}
	
	public virtual CASTNode GetParentSearchScope(CSemanter semanter)
	{
	}
	public virtual List<CASTNode> GetSearchScopeChildren(CSemanter semanter)
	{
	}
	
	public virtual void CheckForDuplicateIdentifier(CSemanter semanter, string identifier, CASTNode ignoreNode=null)
	{
	}
	public virtual void CheckForDuplicateMethodIdentifier(CSemanter semanter, string identifier, List<CDataType> arguments, CClassMemberASTNode ignoreNode=null)
	{
	}
	
	public virtual EvaluationResult Evaluate(CTranslationUnit unit)
	{
	}
	
	public virtual bool AcceptBreakStatement()
	{
	}
	public virtual bool AcceptContinueStatement()
	{
	}
	
	// Constructing.
	public CASTNode()
	{
	}
	public CASTNode(CASTNode parent, CToken token)
	{
	}
	
}

