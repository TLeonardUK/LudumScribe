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
		return Identifier;
	}
	
	public CAliasASTNode(CASTNode parent, CToken token)
	{
		base.CDeclarationASTNode(parent, token);
		
		AliasedDeclaration = null;
		AliasedDataType = null;
	}
	public CAliasASTNode(CASTNode parent, CToken token, string identifier, CDeclarationASTNode decl)
	{
		base.CDeclarationASTNode(parent, token);

		Identifier  = identifier;
		AliasedDeclaration = decl;
		AliasedDataType = null;
	}
	public CAliasASTNode(CASTNode parent, CToken token, string identifier, CDataType decl)
	{
		base.CDeclarationASTNode(parent, token);

		Identifier  = identifier;
		AliasedDeclaration = null;
		AliasedDataType = decl;
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CAliasASTNode");
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		// Check alias identifier is unique.	
		CheckForDuplicateIdentifier(semanter, Identifier);

		// Semant the aliased node.
		if (AliasedDeclaration != null)
		{
			AliasedDeclaration.Semant(semanter);
		}	
		if (AliasedDataType != null)
		{
			AliasedDataType.Semant(semanter, this);
		}

		return this;
	}
	
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CAliasASTNode clone = new CAliasASTNode(null, Token);
		
		clone.Identifier		  = this.Identifier;
		clone.IsNative			  = this.IsNative;

		clone.AliasedDataType	  = this.AliasedDataType;

		if (clone.AliasedDeclaration != null)
		{
			clone.AliasedDeclaration = <CDeclarationASTNode>(this.AliasedDeclaration.Clone(semanter));
			clone.AddChild(clone.AliasedDeclaration);
		}	

		return clone;
	}
	
	public virtual override void Translate(CTranslator translator)
	{
		// Alias is purely semantic, we can ignore it for translations.
	}
}

