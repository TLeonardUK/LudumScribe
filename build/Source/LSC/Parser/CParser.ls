// -----------------------------------------------------------------------------
// 	CParser.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Class deals with taken a stream of tokens and converting in
//	into a AST representation.
// =================================================================
public class CParser
{
	private CTranslationUnit m_context;
	private int m_token_offset;
	private CToken m_eof_token;
	private CToken m_sof_token;
	
	private CASTNode m_root;
	private CASTNode m_scope;
	
	private List<CASTNode> m_scope_stack;
	
	// Token stream manipulation.
	private bool EndOfTokens(int offset = 0)
	{
	}
	private CToken NextToken()
	{
	}
	private CToken LookAheadToken(int offset = 1)
	{
	}
	private CToken CurrentToken()
	{
	}
	private CToken PreviousToken()
	{
	}
	private CToken ExpectToken(TokenIdentifier type)
	{
	}
	private void RewindStream(int offset = 1)
	{
	}
	
	// Scope manipulation.
	private void PushScope(CASTNode node)
	{
	}
	private void PopScope()
	{
	}
	private CASTNode CurrentScope()
	{
	}
	
	private bool IsGenericTypeListFollowing(int final_token_offset)
	{
	}
	
	private CClassASTNode CurrentClassScope()
	{
	}
	private CClassMemberASTNode CurrentClassMemberScope()
	{
	}
	
	// Parse statements.
	private void ParseTopLevelStatement()
	{
	}
	
	private void ParseUsingStatement()
	{
	}
	
	private CDataType ParseDataType(bool acceptArrays = true)
	{
	}
	private CIdentifierDataType ParseIdentifierDataType()
	{
	}
	
	private CClassASTNode ParseClassStatement()
	{
	}
	private CClassBodyASTNode ParseClassBody()
	{
	}
	private CASTNode ParseClassBodyStatement()
	{
	}
	private CClassMemberASTNode ParseClassMemberStatement()
	{
	}
	
	private void ParseMethodArguments(CClassMemberASTNode method)
	{
	}
	private CMethodBodyASTNode ParseMethodBody()
	{
	}
	private CASTNode ParseMethodBodyStatement()
	{
	}
	
	private CIfStatementASTNode ParseIfStatement()
	{
	}
	private CBlockStatementASTNode ParseBlockStatement()
	{
	}
	private CWhileStatementASTNode ParseWhileStatement()
	{
	}
	private CBreakStatementASTNode ParseBreakStatement()
	{
	}
	private CReturnStatementASTNode ParseReturnStatement()
	{
	}
	private CContinueStatementASTNode ParseContinueStatement()
	{
	}
	private CDoStatementASTNode ParseDoStatement()
	{
	}
	private CSwitchStatementASTNode ParseSwitchStatement()
	{
	}
	private CForStatementASTNode ParseForStatement()
	{
	}
	private CForEachStatementASTNode ParseForEachStatement()
	{
	}
	private CVariableStatementASTNode ParseLocalVariableStatement(bool acceptMultiple = true, bool acceptAssignment = true, bool acceptNonConstAssignment = true)
	{
	}
	private CTryStatementASTNode ParseTryStatement()
	{
	}
	private CThrowStatementASTNode ParseThrowStatement()
	{
	}
	
	private CArrayInitializerASTNode ParseArrayInitializer()
	{
	}
	
	private CExpressionASTNode ParseExpr(bool useNullScope, bool noSequencePoints = false)
	{
	}
	private CExpressionASTNode ParseConstExpr(bool useNullScope, bool noSequencePoints = false)
	{
	}
	private CASTNode ParseExprComma()
	{
	}
	private CASTNode ParseExprIsAs()
	{
	}
	private CASTNode ParseExprAssignment()
	{
	}
	private CASTNode ParseExprTernary()
	{
	}
	private CASTNode ParseExprLogical()
	{
	}
	private CASTNode ParseExprBitwise()
	{
	}
	private CASTNode ParseExprCompare()
	{
	}
	private CASTNode ParseExprAddSub()
	{
	}
	private CASTNode ParseExprMulDiv()
	{
	}
	private CASTNode ParseExprTypeCast()
	{
	}
	private CASTNode ParseExprPrefix()
	{
	}
	private CASTNode ParseExprPostfix()
	{
	}
	private CASTNode ParseExprFactor()
	{
	}
	
	public CParser()
	{
	}
	
	public CASTNode GetASTRoot()
	{
	}
	
	public bool Process(CTranslationUnit context)
	{
	}
	public bool Evaluate(CTranslationUnit context)
	{
	}
}



