// -----------------------------------------------------------------------------
// 	CExpressionBaseASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all expression operators.
// =================================================================
public class CExpressionBaseASTNode : CASTNode
{
	public CDataType ExpressionResultType;
	
	public CExpressionBaseASTNode(CASTNode parent, CToken token)
	{
	}
	
	public CASTNode CastTo(CSemanter semanter, CDataType type, CToken castToken, bool explicit_cast=false, bool exception_on_fail=true)
	{
	}
	
	public virtual override void Translate(CTranslator translator)
	{
	}
	
	public abstract string TranslateExpr(CTranslator translator);
}

