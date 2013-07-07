// -----------------------------------------------------------------------------
// 	CTranslator.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for translating a parsed AST tree into a
//	native language.
// =================================================================
public class CTranslator
{
	protected CTranslationUnit m_context;
	protected CSemanter m_semanter;
		
	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		m_context = context;
		m_semanter = context.GetSemanter();

		CPackageASTNode pkg = <CPackageASTNode>(m_context.GetASTRoot());
		TranslatePackage(pkg);

		return true;
	}
		
	// =================================================================
	//	Returns the context being translated.
	// =================================================================
	public CTranslationUnit GetContext()
	{
		return m_context;
	}

	public abstract List<string> GetTranslatedFiles();
	
	public abstract string TranslateDataType(CDataType dt);
	
	public abstract void TranslatePackage(CPackageASTNode node);
	public abstract void TranslateClass(CClassASTNode node);
	public abstract void TranslateClassMember(CClassMemberASTNode node);
	public abstract void TranslateVariableStatement(CVariableStatementASTNode node);
	
	public abstract void TranslateBlockStatement(CBlockStatementASTNode node);
	public abstract void TranslateBreakStatement(CBreakStatementASTNode node);
	public abstract void TranslateContinueStatement(CContinueStatementASTNode node);
	public abstract void TranslateDoStatement(CDoStatementASTNode node);
	public abstract void TranslateForEachStatement(CForEachStatementASTNode node);
	public abstract void TranslateForStatement(CForStatementASTNode node);
	public abstract void TranslateIfStatement(CIfStatementASTNode node);
	public abstract void TranslateReturnStatement(CReturnStatementASTNode node);
	public abstract void TranslateSwitchStatement(CSwitchStatementASTNode node);
	public abstract void TranslateThrowStatement(CThrowStatementASTNode node);
	public abstract void TranslateTryStatement(CTryStatementASTNode node);
	public abstract void TranslateWhileStatement(CWhileStatementASTNode node);
	public abstract void TranslateExpressionStatement(CExpressionASTNode node);
	
	public abstract string TranslateExpression(CExpressionASTNode node);
	public abstract string TranslateAssignmentExpression(CAssignmentExpressionASTNode node);
	public abstract string TranslateBaseExpression(CBaseExpressionASTNode node);
	public abstract string TranslateBinaryMathExpression(CBinaryMathExpressionASTNode node);
	public abstract string TranslateCastExpression(CCastExpressionASTNode node);
	public abstract string TranslateClassRefExpression(CClassRefExpressionASTNode node);
	public abstract string TranslateCommaExpression(CCommaExpressionASTNode node);
	public abstract string TranslateComparisonExpression(CComparisonExpressionASTNode node);
	public abstract string TranslateFieldAccessExpression(CFieldAccessExpressionASTNode node);
	public abstract string TranslateIdentifierExpression(CIdentifierExpressionASTNode node);
	public abstract string TranslateIndexExpression(CIndexExpressionASTNode node, bool set = false, string set_expr = "", bool postfix = false);
	public abstract string TranslateLiteralExpression(CLiteralExpressionASTNode node);
	public abstract string TranslateLogicalExpression(CLogicalExpressionASTNode node);
	public abstract string TranslateMethodCallExpression(CMethodCallExpressionASTNode node);
	public abstract string TranslateNewExpression(CNewExpressionASTNode node);
	public abstract string TranslatePostFixExpression(CPostFixExpressionASTNode node);
	public abstract string TranslatePreFixExpression(CPreFixExpressionASTNode node);
	public abstract string TranslateSliceExpression(CSliceExpressionASTNode node);
	public abstract string TranslateTernaryExpression(CTernaryExpressionASTNode node);
	public abstract string TranslateThisExpression(CThisExpressionASTNode node);
	public abstract string TranslateTypeExpression(CTypeExpressionASTNode node);
	public abstract string TranslateArrayInitializerExpression(CArrayInitializerASTNode node);
}