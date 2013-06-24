// -----------------------------------------------------------------------------
// 	CClassMemberASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Member type type.
// =================================================================
public enum MemberType
{
	Method,
	Field
}

// =================================================================
//	Stores information on a class member declaration.
// =================================================================
public class CClassMemberASTNode : CDeclarationASTNode
{
	public AccessLevel MemberAccessLevel;
	public bool IsStatic;
	public bool IsAbstract;
	public bool IsVirtual;
	public bool IsConst;
	public bool IsOverride;
	public bool IsConstructor;
	public bool IsExtension;
	
	public MemberType MemberMemberType;
	
	public CMethodBodyASTNode Body;
	public CExpressionASTNode Assignment;
	public List<CVariableStatementASTNode> Arguments;
	public CDataType ReturnType;
	
	// Constructors.
	public CClassMemberASTNode(CASTNode parent, CToken token)
	{
	}
	
	// General management.
	public virtual override string ToString()
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
	
	public void AddClassConstructorStub(CSemanter semanter)
	{
	}
	public void AddInstanceConstructorStub(CSemanter semanter)
	{
	}
	public void AddInstanceConstructorPostfix(CSemanter semanter)
	{
	}
	public void AddInstanceConstructorPrefix(CSemanter semanter)
	{
	}
	public void AddDefaultReturnExpression(CSemanter semanter)
	{
	}
	
	public void AddMethodConstructorStub(CSemanter semanter)
	{
	}
	
	public bool EqualToMember(CSemanter semanter, CClassMemberASTNode other)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}	
}

