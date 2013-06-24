// -----------------------------------------------------------------------------
// 	CCPPTranslator.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for translating a parsed AST tree into a
//	C++ representation.
// =================================================================
public class CCPPTranslator : CTranslator
{
	private List<string> m_native_file_paths;
	private List<string> m_library_file_paths;
	
	private string m_base_directory;
	private string m_dst_directory;
	private string m_package_directory;
	private string m_source_directory;
	private string m_source_package_directory;
	
	private CPackageASTNode m_package;
	
	//private FILE m_header_file_handle;
	//private FILE m_source_file_handle;
	
	private int m_header_indent_level;
	private int m_source_indent_level;
	
	private bool m_last_source_was_newline;
	private bool m_last_header_was_newline;
	
	private string m_source_source;
	private string m_header_source;
	
	private string m_include_guard;
	
	private int m_internal_var_counter;
	private string m_switchBreakJumpLabel;
	
	private int m_last_gc_collect_emit;
	private int m_emit_source_counter;
	
	private List<string> m_created_files;
	
	public CCPPTranslator()
	{
	}
	
	public virtual override List<string> GetTranslatedFiles()
	{
	}
	
	public void OpenSourceFile(string format)
	{
	}
	public void OpenHeaderFile(string format)
	{
	}
	public void CloseSourceFile()
	{
	}
	public void CloseHeaderFile()
	{
	}
	
	public void GenerateEntryPoint(CPackageASTNode node)
	{
	}
	
	public void EmitSourceFile(string text, object[] args)
	{
	}
	public void EmitHeaderFile(string text, object[] args)
	{
	}
	
	public void EmitGCCollect()
	{
	}
	
	public string NewInternalVariableName()
	{
	}
	public string EscapeCString(string val)
	{
	}
	public string Enclose(string val)
	{
	}
	
	public bool IsKeyword(string value)
	{
	}
	
	public string FindIncludePath(string path)
	{
	}
	public void EmitRequiredClassIncludes(CClassASTNode node)
	{
	}
	
	public List<CClassASTNode> FindReferencedClasses(CASTNode node)
	{
	}
	
	public virtual override string TranslateDataType(CDataType dt)
	{
	}
	
	public virtual override void TranslatePackage(CPackageASTNode node)
	{
	}
	public virtual override void TranslateClass(CClassASTNode node)
	{
	}
	public virtual override void TranslateClassMember(CClassMemberASTNode node)
	{
	}
	public virtual override void TranslateVariableStatement(CVariableStatementASTNode node)
	{
	}
	public virtual override void TranslateBlockStatement(CBlockStatementASTNode node)
	{
	}
	public virtual override void TranslateBreakStatement(CBreakStatementASTNode node)
	{
	}
	public virtual override void TranslateContinueStatement(CContinueStatementASTNode node)
	{
	}
	public virtual override void TranslateDoStatement(CDoStatementASTNode node)
	{
	}
	public virtual override void TranslateForEachStatement(CForEachStatementASTNode node)
	{
	}
	public virtual override void TranslateForStatement(CForStatementASTNode node)
	{
	}
	public virtual override void TranslateIfStatement(CIfStatementASTNode node)
	{
	}
	public virtual override void TranslateReturnStatement(CReturnStatementASTNode node)
	{
	}
	public virtual override void TranslateSwitchStatement(CSwitchStatementASTNode node)
	{
	}
	public virtual override void TranslateThrowStatement(CThrowStatementASTNode node)
	{
	}
	public virtual override void TranslateTryStatement(CTryStatementASTNode node)
	{
	}
	public virtual override void TranslateWhileStatement(CWhileStatementASTNode node)
	{
	}
	public virtual override void TranslateExpressionStatement(CExpressionASTNode node)
	{
	}
	
	public virtual override string TranslateExpression(CExpressionASTNode node)
	{
	}
	public virtual override string TranslateAssignmentExpression(CAssignmentExpressionASTNode node)
	{
	}
	public virtual override string TranslateBaseExpression(CBaseExpressionASTNode node)
	{
	}
	public virtual override string TranslateBinaryMathExpression(CBinaryMathExpressionASTNode node)
	{
	}
	public virtual override string TranslateCastExpression(CCastExpressionASTNode node)
	{
	}
	public virtual override string TranslateClassRefExpression(CClassRefExpressionASTNode node)
	{
	}
	public virtual override string TranslateCommaExpression(CCommaExpressionASTNode node)
	{
	}
	public virtual override string TranslateComparisonExpression(CComparisonExpressionASTNode node)
	{
	}
	public virtual override string TranslateFieldAccessExpression(CFieldAccessExpressionASTNode node)
	{
	}
	public virtual override string TranslateIdentifierExpression(CIdentifierExpressionASTNode node)
	{
	}
	public virtual override string TranslateIndexExpression(CIndexExpressionASTNode node, bool set = false, string set_expr = "", bool postfix = false)
	{
	}
	public virtual override string TranslateLiteralExpression(CLiteralExpressionASTNode node)
	{
	}
	public virtual override string TranslateLogicalExpression(CLogicalExpressionASTNode node)
	{
	}
	public virtual override string TranslateMethodCallExpression(CMethodCallExpressionASTNode node)
	{
	}
	public virtual override string TranslateNewExpression(CNewExpressionASTNode node)
	{
	}
	public virtual override string TranslatePostFixExpression(CPostFixExpressionASTNode node)
	{
	}
	public virtual override string TranslatePreFixExpression(CPreFixExpressionASTNode node)
	{
	}
	public virtual override string TranslateSliceExpression(CSliceExpressionASTNode node)
	{
	}
	public virtual override string TranslateTernaryExpression(CTernaryExpressionASTNode node)
	{
	}
	public virtual override string TranslateThisExpression(CThisExpressionASTNode node)
	{
	}
	public virtual override string TranslateTypeExpression(CTypeExpressionASTNode node)
	{
	}
	public virtual override string TranslateArrayInitializerExpression(CArrayInitializerASTNode node)
	{
	}
	
}



