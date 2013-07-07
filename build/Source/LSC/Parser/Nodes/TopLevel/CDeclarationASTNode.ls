// -----------------------------------------------------------------------------
// 	CDeclarationASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all declarations.
// =================================================================
public class CDeclarationASTNode : CASTNode
{
	public string Identifier;
	
	public string MangledIdentifier;
	public bool IsNative;
	
	public CDeclarationASTNode(CASTNode parent, CToken token)
	{
		Identifier			= "";
		MangledIdentifier	= "";
		IsNative			= false;
	}
	
	// Semanting.
	public virtual void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
		semanter.GetContext().FatalError("Internal error. Invalid access validation.", Token);
	}
}

