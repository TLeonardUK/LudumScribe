// -----------------------------------------------------------------------------
// 	CClassASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a class declaration.
// =================================================================
public class CClassASTNode : CDeclarationASTNode
{
	protected bool m_semanting;
	
	// Parsing infered data.
	public AccessLevel ClassAccessLevel;
	public bool IsStatic;
	public bool IsAbstract;
	public bool IsInterface;
	public bool IsSealed;
	public bool IsGeneric;
	public bool InheritsNull;
	public bool IsInstanced;
	public bool IsEnum;
	public CASTNode InstancedBy;
	
	public bool HasBoxClass;
	public string BoxClassIdentifier;
	
	public List<CToken> GenericTypeTokens;
	public List<CIdentifierDataType> InheritedTypes;
	
	public CClassBodyASTNode Body;
	
	public CObjectDataType ObjectDataType;
	public CClassReferenceDataType ClassReferenceDataType;
	
	public CClassMemberASTNode ClassConstructor;
	public CClassMemberASTNode InstanceConstructor;
	
	// Semanting infered data.
	public List<CClassASTNode> GenericInstances;
	public CClassASTNode GenericInstanceOf;
	public List<CDataType> GenericInstanceTypes;
	
	public CClassASTNode SuperClass;
	public List<CClassASTNode> Interfaces;
	
	// General management.
	public virtual override string ToString()
	{
	}
	
	// Initialization.
	public CClassASTNode(CASTNode parent, CToken token)
	{
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	public virtual override CASTNode Finalize(CSemanter semanter)
	{
	}
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	
	public virtual override void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
	}
	public bool InheritsFromClass(CSemanter semanter, CClassASTNode node)
	{
	}
	
	public virtual override CASTNode GetParentSearchScope(CSemanter semanter)
	{
	}
	public virtual override List<CASTNode> GetSearchScopeChildren(CSemanter semanter)
	{
	}
	
	public CClassASTNode GenerateClassInstance(CSemanter semanter, CASTNode referenceNode, List<CDataType> generic_arguments)
	{
	}
	
	public virtual override CClassMemberASTNode FindClassMethod(CSemanter semanter, string identifier, List<CDataType> arguments, bool explicit_arguments, CASTNode ignoreNode=null, CASTNode referenceNode=null)
	{
	}
	public virtual override CClassMemberASTNode FindClassField(CSemanter semanter, string identifier, CASTNode ignoreNode, CASTNode referenceNode)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}	
}

