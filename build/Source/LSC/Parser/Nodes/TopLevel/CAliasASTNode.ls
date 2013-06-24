// -----------------------------------------------------------------------------
// 	CAliasASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a alias declaration.
// =================================================================
public class CAliasASTNode : CDeclarationASTNode
{
	
	public CDeclarationASTNode AliasedDeclaration;
	public CDataType AliasedDataType;
	
	// General management.
	public virtual override string ToString()
	{
	}
	
	public CAliasASTNode(CASTNode parent, CToken token)
	{
	}
	public CAliasASTNode(CASTNode parent, CToken token, string identifier, CDeclarationASTNode decl)
	{
	}
	public CAliasASTNode(CASTNode parent, CToken token, string identifier, CDataType decl)
	{
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
	}
	public virtual override CASTNode Clone(CSemanter semanter)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}
}

