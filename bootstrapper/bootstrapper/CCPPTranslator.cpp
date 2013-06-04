/* *****************************************************************

		CCPPTranslator.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#pragma warning(disable:4996) // Remove Microsofts obsession with their proprietary _s postfixed functions.

#include "CCPPTranslator.h"

#include "CTranslationUnit.h"
#include "CCompiler.h"

#include "CCollectionHelper.h"
#include "CPathHelper.h"
#include "CStringHelper.h"

#include "CASTNode.h"
#include "CPackageASTNode.h"
#include "CClassASTNode.h"
#include "CClassBodyASTNode.h"
#include "CClassMemberASTNode.h"
#include "CVariableStatementASTNode.h"
#include "CExpressionBaseASTNode.h"
#include "CMethodBodyASTNode.h"
#include "CExpressionASTNode.h"
#include "CExpressionBaseASTNode.h"

#include "CCaseStatementASTNode.h"
#include "CDefaultStatementASTNode.h"
#include "CCatchStatementASTNode.h"
#include "CBlockStatementASTNode.h"
#include "CBreakStatementASTNode.h"
#include "CContinueStatementASTNode.h"
#include "CDoStatementASTNode.h"
#include "CForEachStatementASTNode.h"
#include "CForStatementASTNode.h"
#include "CIfStatementASTNode.h"
#include "CReturnStatementASTNode.h"
#include "CSwitchStatementASTNode.h"
#include "CThrowStatementASTNode.h"
#include "CTryStatementASTNode.h"
#include "CWhileStatementASTNode.h"

#include "CAssignmentExpressionASTNode.h"
#include "CBaseExpressionASTNode.h"
#include "CBinaryMathExpressionASTNode.h"
#include "CCastExpressionASTNode.h"
#include "CClassRefExpressionASTNode.h"
#include "CCommaExpressionASTNode.h"
#include "CComparisonExpressionASTNode.h"
#include "CFieldAccessExpressionASTNode.h"
#include "CIdentifierExpressionASTNode.h"
#include "CIndexExpressionASTNode.h"
#include "CLiteralExpressionASTNode.h"
#include "CLogicalExpressionASTNode.h"
#include "CMethodCallExpressionASTNode.h"
#include "CNewExpressionASTNode.h"
#include "CPostFixExpressionASTNode.h"
#include "CPreFixExpressionASTNode.h"
#include "CSliceExpressionASTNode.h"
#include "CTernaryExpressionASTNode.h"
#include "CThisExpressionASTNode.h"
#include "CTypeExpressionASTNode.h"

#include "CDataType.h"
#include "CArrayDataType.h"
#include "CBoolDataType.h"
#include "CFloatDataType.h"
#include "CIntDataType.h"
#include "CObjectDataType.h"
#include "CStringDataType.h"
#include "CVoidDataType.h"
#include "CNullDataType.h"
#include "CClassReferenceDataType.h"

#include <stdarg.h> 

// =================================================================
//	Closes the source file.
// =================================================================
CCPPTranslator::CCPPTranslator() :
	m_source_indent_level(0),
	m_header_indent_level(0),
	m_include_guard(""),
	m_last_source_was_newline(false),
	m_last_header_was_newline(false),
	m_internal_var_counter(0),
	m_source_source(""),
	m_header_source(""),
	m_switchBreakJumpLabel(""),
	m_last_gc_collect_emit(0),
	m_emit_source_counter(0)
{
}

// =================================================================
//	Get a list of files that have been translated and need building.
// =================================================================
std::vector<std::string> CCPPTranslator::GetTranslatedFiles() 
{ 
	return m_created_files;
}

// =================================================================
//	Closes the source file.
// =================================================================
void CCPPTranslator::OpenSourceFile(std::string path)
{
	m_source_file_handle = fopen((path + ".cpp").c_str(), "w");

	EmitSourceFile("/* *****************************************************************\n"); 
	EmitSourceFile("          LudumScribe Compiler\n"); 
	EmitSourceFile("          Generated at %s\n", CStringHelper::GetDateTimeStamp().c_str()); 
	EmitSourceFile("   ***************************************************************** */\n"); 
	EmitSourceFile("\n");	
	
	// Emit include declarations.
	std::string relative = CPathHelper::GetRelativePath(path, m_source_directory);
	EmitSourceFile("#include \"%s.hpp\"\n", relative.c_str());
	
	// Emit include declarations.
//	for (unsigned int i = 0; i < m_file_paths.size(); i++)
//	{
//		std::string file_path = m_file_paths.at(i);
//		if (file_path != path)
//		{
//			//std::string relative = CPathHelper::GetRelativePath(file_path, path);
//			std::string relative = CPathHelper::GetRelativePath(file_path, m_file_paths.at(0));
//			EmitSourceFile("#include \"%s.hpp\"\n", relative.c_str());
//		}
//	}

//	EmitSourceFile("\n");

	m_created_files.push_back(path + ".cpp");
}

// =================================================================
//	Opens the header file.
// =================================================================
void CCPPTranslator::OpenHeaderFile(std::string path)
{	
	m_header_file_handle = fopen((path + ".hpp").c_str(), "w");

	std::string relative = CPathHelper::GetRelativePath(path, m_source_directory);
	m_include_guard = CStringHelper::ToUpper("__" + CStringHelper::CleanExceptAlphaNum(relative, '_') + "__");
	
	EmitHeaderFile("/* *****************************************************************\n"); 
	EmitHeaderFile("          LudumScribe Compiler\n"); 
	EmitHeaderFile("          Generated at %s\n", CStringHelper::GetDateTimeStamp().c_str()); 
	EmitHeaderFile("   ***************************************************************** */\n"); 
	EmitHeaderFile("\n");
	EmitHeaderFile("#ifndef %s\n", m_include_guard.c_str());
	EmitHeaderFile("#define %s\n", m_include_guard.c_str());
	EmitHeaderFile("\n");
	
	// Emit native include declarations.
//	for (unsigned int i = 0; i < m_native_file_paths.size(); i++)
//	{
//		std::string file_path = m_native_file_paths.at(i);
//		if (file_path != path)
//		{
//			//std::string relative = CPathHelper::GetRelativePath(file_path, path);
//			std::string relative = CPathHelper::GetRelativePath(file_path, m_file_paths.at(0));
//			EmitHeaderFile("#include \"%s.hpp\"\n", relative.c_str());
//		}
//	}

//	EmitHeaderFile("\n");

	m_created_files.push_back(path + ".hpp");
}

// =================================================================
//	Closes the source file.
// =================================================================
void CCPPTranslator::CloseSourceFile()
{
	fwrite(m_source_source.c_str(), 1, m_source_source.size(), m_source_file_handle);
	m_source_source = "";

	fclose(m_source_file_handle);
}

// =================================================================
//	Closes the header file.
// =================================================================
void CCPPTranslator::CloseHeaderFile()
{
	EmitHeaderFile("#endif // %s\n", m_include_guard.c_str());
	EmitHeaderFile("\n");
	
	fwrite(m_header_source.c_str(), 1, m_header_source.size(), m_header_file_handle);
	m_header_source = "";

	fclose(m_header_file_handle);
}

// =================================================================
//	Writes a piece of text to the given source file.
// =================================================================
void CCPPTranslator::EmitSourceFile(std::string text, ...)
{
	if (text[0] == '{')
	{	
		if (m_last_source_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_source_indent_level) + text;
		}
		m_source_indent_level++;
	}
	else if (text[0] == '}')
	{
		m_source_indent_level--;
		if (m_last_source_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_source_indent_level) + text;
		}
	}
	else
	{
		if (m_last_source_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_source_indent_level) + text;
		}
	}
	
	m_last_source_was_newline = false;
	if (text[text.size() - 1] == '\n')
	{
		m_last_source_was_newline = true;
	}

	va_list vl;
	va_start(vl, text);
	text = CStringHelper::FormatStringVarArgs(text, vl);
	va_end(vl);

	m_source_source += text;
	m_emit_source_counter++;
}

// =================================================================
//	Writes a piece of text to the given header file.
// =================================================================
void CCPPTranslator::EmitHeaderFile(std::string text, ...)
{	
	if (text[0] == '{')
	{
		if (m_last_header_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_header_indent_level) + text;
		}
		m_header_indent_level++;
	}
	else if (text[0] == '}')
	{
		m_header_indent_level--;
		if (m_last_header_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_header_indent_level) + text;
		}
	}
	else
	{
		if (m_last_header_was_newline == true)
		{
			text = CStringHelper::MultiplyString("\t", m_header_indent_level) + text;
		}
	}
	
	m_last_header_was_newline = false;
	if (text != "" && text[text.size() - 1] == '\n')
	{
		m_last_header_was_newline = true;
	}

	va_list vl;
	va_start(vl, text);
	text = CStringHelper::FormatStringVarArgs(text, vl);
	va_end(vl);
	
	m_header_source += text;
}

// =================================================================
//	Writes a garbage collection call out.
// =================================================================
void CCPPTranslator::EmitGCCollect()
{	
	if (m_emit_source_counter > m_last_gc_collect_emit)
	{
		EmitSourceFile("lsGCObject::GCCollect(false);\n");
	}
	m_last_gc_collect_emit = m_emit_source_counter;
}

// =================================================================
//	Gets a new internal variable name.
// =================================================================
std::string CCPPTranslator::NewInternalVariableName()
{
	return "lsInternal_t__" + CStringHelper::ToString(m_internal_var_counter++);
}

// =================================================================
//	Escapes a string so it can be inserted into a C literal.
// =================================================================
std::string CCPPTranslator::EscapeCString(std::string val)
{
	std::string result = "";
	for (unsigned int i = 0; i < val.size(); i++)
	{
		char chr = val.at(i);
		if (chr == '\\')
		{
			result += chr;
			result += chr;
		}
		else if (chr == '"')
		{
			result += "\\" + chr;
		}
		else if (chr == '\a')
		{
			result += "\\a";
		}
		else if (chr == '\b')
		{
			result += "\\b";
		}
		else if (chr == '\f')
		{
			result += "\\f";
		}
		else if (chr == '\n')
		{
			result += "\\n";
		}
		else if (chr == '\r')
		{
			result += "\\r";
		}
		else if (chr == '\v')
		{
			result += "\\v";
		}
		else if (chr == '\?')
		{
			result += "\\?";
		}
		else if (chr == '\0')
		{
			result += "\\0";
		}
		else if (chr == '\t')
		{
			result += "\\t";
		}
		else if (chr == '\'')
		{
			result += "\'";
		}
		else if (chr == '\"')
		{
			result += "\"";
		}
		else if (chr >= 32 && chr <= 126)
		{
			result += chr;
		}
		else
		{
			result += "\\x" + CStringHelper::ToHexString((int)chr);
		}
	}
	return result;
}

// =================================================================
//	Encloses an expression string with parenthesis if they are 
//	required.
// =================================================================
std::string CCPPTranslator::Enclose(std::string val)
{
	if (val[0] == '(' && val[val.size() - 1] == ')')
	{
		return val;
	}

	return "(" + val + ")";
}

// =================================================================
//	Returns true if the given string is a keyword. This is used to
//	ignore trying to forward-declare classes that are keywords.
// =================================================================
bool CCPPTranslator::IsKeyword(std::string value)
{
	if (value == "bool" ||
		value == "int" ||
		value == "float")
	{
		return true;
	}

	return false;
}

// =================================================================
//	Emits all includes required for a class declaration.
// =================================================================
void CCPPTranslator::EmitRequiredClassIncludes(CClassASTNode* node)
{
	if (node->SuperClass != NULL)
	{
		if (node->SuperClass->IsNative == false)
		{		
			std::string path = node->SuperClass->MangledIdentifier;
			EmitHeaderFile("#include \"%s.hpp\"\n", path.c_str());
		}
	}

	for (auto iter = node->Interfaces.begin(); iter != node->Interfaces.end(); iter++)
	{
		CClassASTNode* interfaceNode = *iter;
		if (interfaceNode->IsNative == false)
		{		
			std::string path = interfaceNode->MangledIdentifier;
			EmitHeaderFile("#include \"%s.hpp\"\n", path.c_str());
		}
	}

	EmitHeaderFile("\n");
}

// =================================================================
//	Finds all class referenced by a given node and its children.
// =================================================================
std::vector<CClassASTNode*> CCPPTranslator::FindReferencedClasses(CASTNode* node)
{
	std::vector<CClassASTNode*> references;

	// Class references?
	CClassASTNode* classNode = dynamic_cast<CClassASTNode*>(node);
	if (classNode != NULL)
	{
		if (classNode->SuperClass != NULL)
		{
			CCollectionHelper::VectorAddIfNotExists(references, classNode->SuperClass);
		}
		for (auto iter = classNode->Interfaces.begin(); iter != classNode->Interfaces.end(); iter++)
		{
			CCollectionHelper::VectorAddIfNotExists(references, *iter);
		}
	}

	// Expression result types.
	CBaseExpressionASTNode* exprNode = dynamic_cast<CBaseExpressionASTNode*>(node);
	if (exprNode != NULL)
	{
		CCollectionHelper::VectorAddIfNotExists(references, exprNode->ExpressionResultType->GetClass(NULL));
	}

	// Grab references made by children.
	for (auto iter = node->Children.begin(); iter != node->Children.end(); iter++)
	{
		std::vector<CClassASTNode*> child_refs = FindReferencedClasses(*iter);		
		for (auto ref_iter = child_refs.begin(); ref_iter != child_refs.end(); ref_iter++)
		{
			CCollectionHelper::VectorAddIfNotExists(references, *ref_iter);	
		}
	}

	return references;
}

// =================================================================
//	Converts an actual untranslated path into the path we 
//	want to include.
// =================================================================
std::string CCPPTranslator::FindIncludePath(std::string path)
{
	std::string file     = path;
	std::string dst_file = file;
	
	// Is it relative to base directory?
	if (dst_file.size() > m_base_directory.size() &&
		dst_file.substr(0, m_base_directory.size()) == m_base_directory)
	{
		dst_file = m_source_directory + dst_file.substr(m_base_directory.size() + 1);
	}

	// Is it relative to package directory?
	else if (dst_file.size() > m_package_directory.size() &&
				dst_file.substr(0, m_package_directory.size()) == m_package_directory)
	{
		dst_file = m_source_package_directory + dst_file.substr(m_package_directory.size() + 1);
	}

	// Strip extension.
	dst_file = CPathHelper::StripExtension(dst_file);

	return dst_file;
}

// =================================================================
//	Generates the "main" function stub.
// =================================================================
void CCPPTranslator::GenerateEntryPoint(CPackageASTNode* node)
{
	EmitHeaderFile("int main(int argc, const char* argv[]);\n\n");
	EmitSourceFile("int main(int argc, const char* argv[])\n");
	EmitSourceFile("{\n");

	// Call runtime initialization.
	EmitSourceFile("lsRuntimeInit();\n");
	EmitSourceFile("\n");

	// Call class constructors.
	for (auto iter = node->Children.begin(); iter != node->Children.end(); iter++)
	{
		CClassASTNode* classNode = dynamic_cast<CClassASTNode*>(*iter);
		if (classNode != NULL &&
			classNode->ClassConstructor != NULL)
		{
			if (classNode->ClassConstructor->IsExtension == true)
			{
				EmitSourceFile(classNode->ClassConstructor->MangledIdentifier + "();\n");
			}
			else
			{
				EmitSourceFile(classNode->MangledIdentifier + "::" + classNode->ClassConstructor->MangledIdentifier + "();\n");
			}
		}
	}
	EmitSourceFile("\n");

	// Call user-define entry point.
	CClassMemberASTNode* entryPoint = m_context->GetEntryPoint();
	CClassASTNode* entryPointScope = entryPoint->FindClassScope(m_context->GetSemanter());
	EmitSourceFile(entryPointScope->MangledIdentifier + "::" + entryPoint->MangledIdentifier + "();\n");
	EmitSourceFile("\n");

	// Call runtime deinitialization.
	EmitSourceFile("lsRuntimeDeInit();\n");

	EmitSourceFile("}\n");
	EmitSourceFile("\n");
}

// =================================================================
//	Translate a package node.
// =================================================================
void CCPPTranslator::TranslatePackage(CPackageASTNode* node)
{
	// Work out base directories.
	m_base_directory			= CPathHelper::StripFilename(m_context->GetFilePath());
	m_dst_directory				= m_context->GetCompiler()->GetBuildDirectory();
	m_package_directory			= m_context->GetCompiler()->GetPackageDirectory();
	m_source_directory			= m_dst_directory + "Source/";
	m_source_package_directory	= m_dst_directory + "Source/Packages/";
	m_package					= node;
	m_created_files.clear();

	// Make directories.
	CPathHelper::MakeDirectory(m_dst_directory);
	CPathHelper::MakeDirectory(m_source_directory);
	CPathHelper::MakeDirectory(m_package_directory);

	// Work out and create all unique native files.
	std::vector<std::string> native_files = m_context->GetNativeFileList();
	m_native_file_paths.clear();
	for (auto iter = native_files.begin(); iter != native_files.end(); iter++)
	{
		std::string file     = *iter;
		std::string dst_file = file;

		// Is it relative to base directory?
		if (dst_file.size() > m_base_directory.size() &&
			dst_file.substr(0, m_base_directory.size()) == m_base_directory)
		{
			dst_file = m_source_directory + dst_file.substr(m_base_directory.size() + 1);
		}

		// Is it relative to package directory?
		else if (dst_file.size() > m_package_directory.size() &&
				 dst_file.substr(0, m_package_directory.size()) == m_package_directory)
		{
			dst_file = m_source_package_directory + dst_file.substr(m_package_directory.size() + 1);
		}

		// Create directory.
		std::string dir = CPathHelper::StripFilename(dst_file) + "/";
		CPathHelper::MakeDirectory(dir);

		// Work out base file without an extension.
		std::string file_no_extension = CPathHelper::StripExtension(file);
		std::string dst_file_no_extension = CPathHelper::StripExtension(dst_file);
		
		// Copy native file over.
		if (CPathHelper::IsFile(file_no_extension + ".hpp"))
		{
			m_created_files.push_back(dst_file_no_extension + ".hpp");
			CPathHelper::CopyFileTo(file_no_extension + ".hpp", dst_file_no_extension + ".hpp");
			m_native_file_paths.push_back(dst_file_no_extension);
		}
		if (CPathHelper::IsFile(file_no_extension + ".h"))
		{
			m_created_files.push_back(dst_file_no_extension + ".h");
			CPathHelper::CopyFileTo(file_no_extension + ".h", dst_file_no_extension + ".h");
		}
		if (CPathHelper::IsFile(file_no_extension + ".cpp"))
		{
			m_created_files.push_back(dst_file_no_extension + ".cpp");
			CPathHelper::CopyFileTo(file_no_extension + ".cpp", dst_file_no_extension + ".cpp");
		}
		if (CPathHelper::IsFile(file_no_extension + ".c"))
		{
			m_created_files.push_back(dst_file_no_extension + ".c");
			CPathHelper::CopyFileTo(file_no_extension + ".c", dst_file_no_extension + ".c");
		}
		if (CPathHelper::IsFile(file_no_extension + ".cc"))
		{
			m_created_files.push_back(dst_file_no_extension + ".cc");
			CPathHelper::CopyFileTo(file_no_extension + ".cc", dst_file_no_extension + ".cc");
		}
		if (CPathHelper::IsFile(file_no_extension + ".cxx"))
		{
			m_created_files.push_back(dst_file_no_extension + ".cxx");
			CPathHelper::CopyFileTo(file_no_extension + ".cxx", dst_file_no_extension + ".cxx");
		}
	}
	
	// Emit a source file for each class.
	for (auto iter = node->Children.begin(); iter != node->Children.end(); iter++)
	{
		CClassASTNode* child = dynamic_cast<CClassASTNode*>(*iter);
		if (child == NULL)
		{
			continue;
		}
		if (child->IsGeneric == true)
		{
			for (unsigned int i = 0; i < child->GenericInstances.size(); i++)
			{
				TranslateClass(child->GenericInstances.at(i));
			}
		}
		else
		{
			TranslateClass(child);
		}
	}

	// Emit the "main" file.
	OpenSourceFile(m_source_directory + "main");
	OpenHeaderFile(m_source_directory + "main");
	
	// Emit native include declarations.
	for (unsigned int i = 0; i < m_native_file_paths.size(); i++)
	{
		std::string file_path = m_native_file_paths.at(i);
		std::string relative = CPathHelper::GetRelativePath(file_path, m_source_directory);
		EmitHeaderFile("#include \"%s.hpp\"\n", relative.c_str());
	}
	EmitHeaderFile("\n");

	// Emit all forward declarations.
	std::vector<CASTNode*> referenced_classes = m_package->Children;//FindReferencedClasses(node);
	for (auto iter = referenced_classes.begin(); iter != referenced_classes.end(); iter++)
	{
		CClassASTNode* child = dynamic_cast<CClassASTNode*>(*iter);
		if (child == NULL)
		{
			continue;
		}
		if (child->IsGeneric == true)
		{
			for (auto iter2 = child->GenericInstances.begin(); iter2 != child->GenericInstances.end(); iter2++)
			{
				if (!IsKeyword((*iter2)->MangledIdentifier))
				{
					EmitHeaderFile("class %s;\n", (*iter2)->MangledIdentifier.c_str());
				}

				std::string path = (*iter2)->MangledIdentifier;
				EmitSourceFile("#include \"%s.hpp\"\n", path.c_str());
			}
		}
		else
		{
			if (!IsKeyword(child->MangledIdentifier))
			{
				EmitHeaderFile("class %s;\n", child->MangledIdentifier.c_str());
			}

			std::string path = child->MangledIdentifier;
			EmitSourceFile("#include \"%s.hpp\"\n", path.c_str());
		}
	}
	EmitHeaderFile("\n");
	EmitSourceFile("\n");

	// Generate entry point.
	GenerateEntryPoint(node);

	CloseHeaderFile();
	CloseSourceFile();
}

// =================================================================
//	Translate a class node.
// =================================================================
void CCPPTranslator::TranslateClass(CClassASTNode* node)
{
	// Open source file for this class.
	OpenSourceFile(m_source_directory + node->MangledIdentifier);
	OpenHeaderFile(m_source_directory + node->MangledIdentifier);

	// Emit native include declarations.
	for (unsigned int i = 0; i < m_native_file_paths.size(); i++)
	{
		std::string file_path = m_native_file_paths.at(i);
		std::string relative = CPathHelper::GetRelativePath(file_path, m_source_directory);

		EmitHeaderFile("#include \"%s.hpp\"\n", relative.c_str());
	}
	EmitHeaderFile("\n");
	
	// Emit all translated includes we need.
	EmitRequiredClassIncludes(node);
	
	// Emit all forward declarations.
	std::vector<CASTNode*> referenced_classes = m_package->Children;//FindReferencedClasses(node);
	for (auto iter = referenced_classes.begin(); iter != referenced_classes.end(); iter++)
	{
		CClassASTNode* child = dynamic_cast<CClassASTNode*>(*iter);
		if (child == NULL || 
			child == node)
		{
			continue;
		}
		if (child->IsGeneric == true)
		{
			for (auto iter2 = child->GenericInstances.begin(); iter2 != child->GenericInstances.end(); iter2++)
			{
				if (!IsKeyword((*iter2)->MangledIdentifier))
				{
					EmitHeaderFile("class %s;\n", (*iter2)->MangledIdentifier.c_str());
				}

				std::string path = (*iter2)->MangledIdentifier;
				EmitSourceFile("#include \"%s.hpp\"\n", path.c_str());
			}
		}
		else
		{
			if (!IsKeyword(child->MangledIdentifier))
			{
				EmitHeaderFile("class %s;\n", child->MangledIdentifier.c_str());
			}
				
			std::string path = child->MangledIdentifier;
			EmitSourceFile("#include \"%s.hpp\"\n", path.c_str());
		}
	}
	EmitHeaderFile("\n");
	EmitSourceFile("\n");

	// Native class? Abort abort.
	if ((node->IsGeneric == false || node->GenericInstanceOf != NULL))
	{
		if (node->IsNative == false)
		{
			// Work out inheritance code.
			std::string inherit = "";
			if (node->IsInterface == false)
			{
				if (node->SuperClass != NULL)
				{
					inherit += "public " + node->SuperClass->MangledIdentifier;
				}

				for (auto iter = node->Interfaces.begin(); iter != node->Interfaces.end(); iter++)
				{
					CClassASTNode* inheritNode = *iter;
					if (inherit != " ")
					{
						inherit += ", ";
					}
					inherit += "public virtual " + inheritNode->MangledIdentifier;
				}
			}

			// Emit header class.
			EmitHeaderFile("class %s%s\n", node->MangledIdentifier.c_str(), (inherit != "" ? " : " + inherit : "").c_str());	
			EmitHeaderFile("{\npublic:\n");	
		}

		for (auto iter = node->Body->Children.begin(); iter != node->Body->Children.end(); iter++)
		{
			(*iter)->Translate(this);
		}
		
		if (node->IsNative == false)
		{
			EmitHeaderFile("};\n");		
			EmitHeaderFile("\n");	
		}
	}

	CloseHeaderFile();
	CloseSourceFile();
}

// =================================================================
//	Translate a class member node.
// =================================================================
void CCPPTranslator::TranslateClassMember(CClassMemberASTNode* node)
{		
	CClassASTNode* classNode = dynamic_cast<CClassASTNode*>(node->Parent->Parent);

	// Emit a method declaration.
	if (node->MemberType == MemberType::Method)
	{
		if (classNode->IsNative == true)
		{
			if (node->IsNative == true)
			{
				return;
			}
		}

		// Attributes
		if (node->IsExtension == false)
		{
			if (node->IsStatic == true)
			{
				EmitHeaderFile("static ");
			}
			if (node->IsVirtual == true || classNode->IsInterface == true)
			{
				EmitHeaderFile("virtual ");
			}
		}

		// Data type.
		EmitHeaderFile("%s ", TranslateDataType(node->ReturnType).c_str());

		// Identifier			
		//if (node->IsExtension == false)
		//{
		//	EmitSourceFile(classNode->MangledIdentifier + "::");			
		//}
		EmitHeaderFile(node->MangledIdentifier);

		// Arguments.
		EmitHeaderFile("(");
		if (node->IsExtension == true && node->IsStatic == false)
		{
			EmitHeaderFile(TranslateDataType(classNode->ObjectDataType) + " ext_this");
			if (node->Arguments.size() > 0)
			{
				EmitHeaderFile(", ");
			}
		}
		for (auto iter = node->Arguments.begin(); iter != node->Arguments.end(); iter++)
		{
			CVariableStatementASTNode* arg = *iter;
			
			EmitHeaderFile("%s ", TranslateDataType(arg->Type).c_str());
			EmitHeaderFile(arg->MangledIdentifier);
			
			if (iter + 1 != node->Arguments.end())
			{
				EmitHeaderFile(", ");
			}
		}
		EmitHeaderFile(")");

		// Body
		if (node->IsAbstract == true || classNode->IsInterface == true)
		{
			EmitHeaderFile(" = 0;");
		}
		else if (classNode->IsInterface == false && node->Body != NULL)
		{
			EmitHeaderFile(";");
			
			// Data type.
			EmitSourceFile("%s ", TranslateDataType(node->ReturnType).c_str());
			
			// Class Identifier				
			if (node->IsExtension == false)
			{
				EmitSourceFile(classNode->MangledIdentifier + "::");			
			}
			EmitSourceFile(node->MangledIdentifier);

			// Arguments.
			EmitSourceFile("(");
			if (node->IsExtension == true && node->IsStatic == false)
			{
				EmitSourceFile(TranslateDataType(classNode->ObjectDataType) + " ext_this");
				if (node->Arguments.size() > 0)
				{
					EmitSourceFile(", ");
				}
			}
			for (auto iter = node->Arguments.begin(); iter != node->Arguments.end(); iter++)
			{
				CVariableStatementASTNode* arg = *iter;
			
				EmitSourceFile("%s ", TranslateDataType(arg->Type).c_str());
				EmitSourceFile(arg->MangledIdentifier);
			
				if (iter + 1 != node->Arguments.end())
				{
					EmitSourceFile(", ");
				}
			}
			EmitSourceFile(")\n");	
			EmitSourceFile("{\n");	
			EmitGCCollect();
			
			// Translate body.
			node->Body->TranslateChildren(this);
			
			EmitGCCollect();
			EmitSourceFile("}\n");
			EmitSourceFile("\n");				
		}		
		else
		{			
			EmitHeaderFile(";");			
		}
	}

	// Emit a field declaration.
	else
	{
		// Emit external declaration in source file.
		if (node->IsStatic == true)
		{
			if (node->IsExtension == true)
			{
				EmitSourceFile("%s %s;\n", TranslateDataType(node->ReturnType).c_str(), 
												node->MangledIdentifier.c_str());
			}
			else
			{
				EmitSourceFile("%s %s::%s;\n", TranslateDataType(node->ReturnType).c_str(), 
												classNode->MangledIdentifier.c_str(), 
												node->MangledIdentifier.c_str());
			}
		}

		// Attributes
		if (classNode->IsNative == false)
		{
			if (node->IsStatic == true)
			{
				EmitHeaderFile("static ");
			}
			if (node->IsConst == true)
			{
				EmitHeaderFile("const ");
			}
		}
		else
		{
			if (node->IsNative == true)
			{
				return;
			}
		}

		// Data type.
		if (node->IsExtension == true)
		{
			EmitHeaderFile("extern ");
		}
		EmitHeaderFile("%s ", TranslateDataType(node->ReturnType).c_str());

		// Identifier
		EmitHeaderFile(node->MangledIdentifier);

		// Semicolon.		
		EmitHeaderFile(";");
	}

	EmitHeaderFile("\n");
}

// =================================================================
//	Translate a data type.
// =================================================================
std::string CCPPTranslator::TranslateDataType(CDataType* type)
{
	if (dynamic_cast<CArrayDataType*>(type) != NULL)
	{
		CArrayDataType* arrayDT = dynamic_cast<CArrayDataType*>(type);
		return "lsArray<" + TranslateDataType(arrayDT->ElementType) + ">*";
	}
	else if (dynamic_cast<CBoolDataType*>(type) != NULL)
	{
		return "bool";
	}
	else if (dynamic_cast<CFloatDataType*>(type) != NULL)
	{
		return "float";
	}
	else if (dynamic_cast<CIntDataType*>(type) != NULL)
	{
		return "int";
	}
	else if (dynamic_cast<CStringDataType*>(type) != NULL)
	{
		return "lsString";
	}
	else if (dynamic_cast<CVoidDataType*>(type) != NULL)
	{
		return "void";
	}
	else if (dynamic_cast<CObjectDataType*>(type) != NULL)
	{
		CObjectDataType* objectDT = dynamic_cast<CObjectDataType*>(type);
		CClassASTNode* classDT = objectDT->GetClass(m_semanter);
		if (classDT->Identifier == "bool"	||
			classDT->Identifier == "float"	||
			classDT->Identifier == "int"	||
			classDT->Identifier == "string")
		{
			return classDT->MangledIdentifier;
		}
		else if (classDT->Identifier == "array")
		{
			return "lsArray<" + TranslateDataType(classDT->GenericInstanceTypes.at(0)) + ">*";
		}

		return classDT->MangledIdentifier + "*";
	}
	else
	{
		GetContext()->FatalError("Attempt to translate invalid or unknown data type.", type->Token);
	}

	return "";
}
	
// =================================================================
//	Translates a local variable statement.
// =================================================================
void CCPPTranslator::TranslateVariableStatement(CVariableStatementASTNode* node)
{
	CClassASTNode* classNode = dynamic_cast<CClassASTNode*>(node->Parent->Parent);
	
	// Data type.
	EmitSourceFile("%s ", TranslateDataType(node->Type).c_str());

	// Identifier
	EmitSourceFile(node->MangledIdentifier);

	// Assignment?
	if (node->AssignmentExpression != NULL)
	{
		EmitSourceFile(" = %s", dynamic_cast<CExpressionBaseASTNode*>(node->AssignmentExpression)->TranslateExpr(this).c_str());
	}

	// Semicolon!
	EmitSourceFile(";\n");
}

// =================================================================
//	Translates a block statement.
// =================================================================	
void CCPPTranslator::TranslateBlockStatement(CBlockStatementASTNode* node)
{
	EmitGCCollect();
	node->TranslateChildren(this);
	EmitGCCollect();	
}

// =================================================================
//	Translates a break statement.
// =================================================================	
void CCPPTranslator::TranslateBreakStatement(CBreakStatementASTNode* node)
{
	if (m_switchBreakJumpLabel != "")
	{
		EmitSourceFile("goto " + m_switchBreakJumpLabel + ";\n");
	}
	else
	{
		EmitSourceFile("break;\n");
	}
}

// =================================================================
//	Translates a continue statement.
// =================================================================	
void CCPPTranslator::TranslateContinueStatement(CContinueStatementASTNode* node)
{
	EmitSourceFile("continue;\n");
}

// =================================================================
//	Translates a do statement.
// =================================================================	
void CCPPTranslator::TranslateDoStatement(CDoStatementASTNode* node)
{
	EmitSourceFile("do\n");
	EmitSourceFile("{\n");
	node->BodyStatement->Translate(this);
	EmitSourceFile("}\n");
	EmitSourceFile("while (%s);\n", dynamic_cast<CExpressionBaseASTNode*>(node->ExpressionStatement)->TranslateExpr(this).c_str());
}

// =================================================================
//	Translates a foreach statement.
// =================================================================	
void CCPPTranslator::TranslateForEachStatement(CForEachStatementASTNode* node)
{
	node->BodyStatement->Translate(this);

	// Foreach is a placeholder. It should get replaced in-code.
	return;

	/*
	// Get an internal var to use for iteration.
	std::string internal_var_name = NewInternalVariableName();

	CExpressionBaseASTNode* base_expr = dynamic_cast<CExpressionBaseASTNode*>(node->ExpressionStatement);	
	CClassMemberASTNode* get_enum = base_expr->ExpressionResultType->GetClass(m_semanter)->FindClassMethod(m_semanter, "GetEnumerator", std::vector<CDataType*>(), true);
	CClassASTNode* enumerator_class = get_enum->ReturnType->GetClass(m_semanter);
	CClassMemberASTNode* enum_next = enumerator_class->FindClassMethod(m_semanter, "Next", std::vector<CDataType*>(), true);
	CClassMemberASTNode* enum_current = enumerator_class->FindClassMethod(m_semanter, "Current", std::vector<CDataType*>(), true);

	if (get_enum->IsExtension == true)
	{
		EmitSourceFile("%s %s = %s(%s);\n", 
							TranslateDataType(get_enum->ReturnType).c_str(),
							internal_var_name.c_str(),							
							get_enum->MangledIdentifier.c_str(),
							base_expr->TranslateExpr(this).c_str());
	}
	else
	{
		EmitSourceFile("%s %s = (%s)->%s();\n", 
							TranslateDataType(get_enum->ReturnType).c_str(),
							internal_var_name.c_str(),
							base_expr->TranslateExpr(this).c_str(),
							get_enum->MangledIdentifier.c_str());
	}
	EmitSourceFile("while (%s->%s())\n",
						internal_var_name.c_str(),
						enum_next->MangledIdentifier.c_str());
	EmitSourceFile("{\n");

	// Variable definition.
	CVariableStatementASTNode* var = dynamic_cast<CVariableStatementASTNode*>(node->VariableStatement);
	if (var != NULL)
	{
		TranslateVariableStatement(var);
		EmitSourceFile("%s = (%s->%s());\n",
						var->MangledIdentifier.c_str(),
						internal_var_name.c_str(),
						enum_current->MangledIdentifier.c_str());
	}

	// Pre-defined variable.
	else
	{
		std::string expr = dynamic_cast<CExpressionBaseASTNode*>(node->VariableStatement)->TranslateExpr(this).c_str();
		EmitSourceFile("%s = (%s->%s());\n",
						expr.c_str(),
						internal_var_name.c_str(),
						enum_current->MangledIdentifier.c_str());
	}

	// Emit the main block.
	node->BodyStatement->Translate(this);

	EmitSourceFile("}\n");
	return;
	*/
}

// =================================================================
//	Translates a for statement.
// =================================================================	
void CCPPTranslator::TranslateForStatement(CForStatementASTNode* node)
{
	EmitSourceFile("for (");

	if (node->InitialStatement != NULL)
	{
		node->InitialStatement->Translate(this);
		EmitSourceFile(" ");
	}
	else
	{
		EmitSourceFile("; ");
	}
	
	if (node->ConditionExpression != NULL)
	{
		EmitSourceFile("%s; ",
			dynamic_cast<CExpressionBaseASTNode*>(node->ConditionExpression)->TranslateExpr(this).c_str());
	}
	else
	{
		EmitSourceFile("; ");
	}
	
	if (node->IncrementExpression != NULL)
	{
		EmitSourceFile("%s)\n",
						dynamic_cast<CExpressionBaseASTNode*>(node->IncrementExpression)->TranslateExpr(this).c_str());
	}
	else
	{
		EmitSourceFile(")\n");
	}

	EmitSourceFile("{\n");
	node->BodyStatement->Translate(this);
	EmitSourceFile("}\n");
}

// =================================================================
//	Translates a if statement.
// =================================================================	
void CCPPTranslator::TranslateIfStatement(CIfStatementASTNode* node)
{
	EmitSourceFile("if (%s)\n", dynamic_cast<CExpressionBaseASTNode*>(node->ExpressionStatement)->TranslateExpr(this).c_str());
	EmitSourceFile("{\n");
	node->BodyStatement->Translate(this);
	EmitSourceFile("}\n");
	if (node->ElseStatement != NULL)
	{
		CIfStatementASTNode* elseIf =  dynamic_cast<CIfStatementASTNode*>(node->ElseStatement);
		if (elseIf != NULL)
		{
			EmitSourceFile("else ");
			node->ElseStatement->Translate(this);
		}
		else
		{
			EmitSourceFile("else\n");
			EmitSourceFile("{\n");
			node->ElseStatement->Translate(this);
			EmitSourceFile("}\n");
		}
	}
}

// =================================================================
//	Translates a return statement.
// =================================================================	
void CCPPTranslator::TranslateReturnStatement(CReturnStatementASTNode* node)
{
	EmitSourceFile("{\n");
	EmitGCCollect();
	EmitSourceFile("return (%s);\n", dynamic_cast<CExpressionBaseASTNode*>(node->ReturnExpression)->TranslateExpr(this).c_str());
	EmitSourceFile("}\n");
}

// =================================================================
//	Translates a switch statement.
// =================================================================	
void CCPPTranslator::TranslateSwitchStatement(CSwitchStatementASTNode* node)
{
	std::string internal_var_name				 = NewInternalVariableName();
	std::string internal_var_name_jump_statement = "jmp_" + NewInternalVariableName();
	
	// Store expression in a temp variable.
	EmitSourceFile("%s %s = %s;\n", 
					TranslateDataType(node->ExpressionStatement->ExpressionResultType).c_str(),
					internal_var_name.c_str(),
					dynamic_cast<CExpressionBaseASTNode*>(node->ExpressionStatement)->TranslateExpr(this).c_str());

	// Skip first child, thats the expression.
	auto iterBegin = node->Children.begin() + 1;

	for (auto iter = iterBegin; iter != node->Children.end(); iter++)
	{
		CCaseStatementASTNode* caseStmt = dynamic_cast<CCaseStatementASTNode*>(*iter);
		CDefaultStatementASTNode* defaultStmt = dynamic_cast<CDefaultStatementASTNode*>(*iter);

		if (caseStmt != NULL)
		{
			if (iter != iterBegin)
			{
				EmitSourceFile("else ");
			}
			EmitSourceFile("if (");

			for (auto exprIter = caseStmt->Expressions.begin(); exprIter != caseStmt->Expressions.end(); exprIter++)
			{
				if (exprIter != caseStmt->Expressions.begin())
				{
					EmitSourceFile(" || ");
				}
				CExpressionBaseASTNode* expr = dynamic_cast<CExpressionBaseASTNode*>(*exprIter);
				EmitSourceFile("%s == %s", internal_var_name.c_str(), expr->TranslateExpr(this).c_str());
			}

			EmitSourceFile(")\n");
			EmitSourceFile("{\n");
			
			std::string previousLabel = m_switchBreakJumpLabel;
			m_switchBreakJumpLabel = internal_var_name_jump_statement;

			caseStmt->BodyStatement->Translate(this);

			m_switchBreakJumpLabel = previousLabel;

			EmitSourceFile("}\n");			
		}
		else if (defaultStmt != NULL)
		{
			if (iter != iterBegin)
			{
				EmitSourceFile("else\n");
				EmitSourceFile("{\n");
			}
		
			std::string previousLabel = m_switchBreakJumpLabel;
			m_switchBreakJumpLabel = internal_var_name_jump_statement;

			defaultStmt->BodyStatement->Translate(this);
			
			m_switchBreakJumpLabel = previousLabel;

			if (iter != iterBegin)
			{
				EmitSourceFile("}\n");	
			}
			break;
		}
		else
		{
			GetContext()->FatalError("Internal error. Unknown switch statement child node.", node->Token);
		}
	}

	// Emit the break label.
	EmitSourceFile(internal_var_name_jump_statement + ":\n");

	return;
}

// =================================================================
//	Translates a throw statement.
// =================================================================	
void CCPPTranslator::TranslateThrowStatement(CThrowStatementASTNode* node)
{
	EmitSourceFile("throw (%s);\n", dynamic_cast<CExpressionBaseASTNode*>(node->Expression)->TranslateExpr(this).c_str());
	return;
}

// =================================================================
//	Translates a try statement.
// =================================================================	
void CCPPTranslator::TranslateTryStatement(CTryStatementASTNode* node)
{
	EmitSourceFile("try\n");
	EmitSourceFile("{\n");	
	node->BodyStatement->Translate(this);
	EmitSourceFile("}\n");

	for (auto iter = node->Children.begin(); iter != node->Children.end(); iter++)
	{
		CCatchStatementASTNode* catchStmt = dynamic_cast<CCatchStatementASTNode*>(*iter);
		if (catchStmt != NULL)
		{
			EmitSourceFile("catch (%s %s)\n", TranslateDataType(catchStmt->VariableStatement->Type).c_str(), catchStmt->VariableStatement->MangledIdentifier.c_str());
			EmitSourceFile("{\n");	
			node->BodyStatement->Translate(this);
			EmitSourceFile("}\n");
		}		
	}

	return;
}

// =================================================================
//	Translates a while statement.
// =================================================================	
void CCPPTranslator::TranslateWhileStatement(CWhileStatementASTNode* node)
{
	EmitSourceFile("while (%s)\n", dynamic_cast<CExpressionBaseASTNode*>(node->ExpressionStatement)->TranslateExpr(this).c_str());
	EmitSourceFile("{\n");
	node->BodyStatement->Translate(this);
	EmitSourceFile("}\n");
	return;
}

// =================================================================
//	Translates an expression statement.
// =================================================================
void CCPPTranslator::TranslateExpressionStatement(CExpressionASTNode* node)
{
	EmitSourceFile("%s;\n", dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue)->TranslateExpr(this).c_str());
}

// =================================================================
//	Translates an expression.
// =================================================================
std::string	CCPPTranslator::TranslateExpression(CExpressionASTNode* node)
{
	return Enclose(dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue)->TranslateExpr(this));
}

// =================================================================
//	Translates an assignment expression.
// =================================================================
std::string	CCPPTranslator::TranslateAssignmentExpression(CAssignmentExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	// We need to deal with index based assignments slightly differently.
	CIndexExpressionASTNode* left_index_base = dynamic_cast<CIndexExpressionASTNode*>(left_base);
	if (left_index_base != NULL)
	{
		std::string set_expr = dynamic_cast<CExpressionBaseASTNode*>(left_index_base->LeftValue)->TranslateExpr(this);

		switch (node->Token.Type)
		{
			case TokenIdentifier::OP_ASSIGN:		return TranslateIndexExpression(left_index_base, true, right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_AND:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " & " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_OR:		return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " | " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_XOR:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " ^ " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SHL:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " << " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SHR:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " >> " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_MOD:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " % " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_ADD:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " + " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SUB:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " - " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_MUL:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " * " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_DIV:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " / " + right_base->TranslateExpr(this));
			default:
				{
					GetContext()->FatalError("Internal error. Unknown assignment operator.", node->Token);
					return "";
				}
		}
	}
	else
	{
		switch (node->Token.Type)
		{
			case TokenIdentifier::OP_ASSIGN:		
				{
			//		if (dynamic_cast<CObjectDataType*>(left_base->ExpressionResultType) != NULL)
			//		{
			//			return left_base->TranslateExpr(this) + " = dynamic_cast<" + TranslateDataType(left_base->ExpressionResultType) + ">(lsGCObject::GCAssign(" + left_base->TranslateExpr(this) + ", " + right_base->TranslateExpr(this) + "))";
			//		}
			//		else
			//		{
						return (left_base->TranslateExpr(this) + " = " + right_base->TranslateExpr(this));	
			//		}
			//		break;	
				}
			case TokenIdentifier::OP_ASSIGN_AND:	return (left_base->TranslateExpr(this) + " &= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_OR:		return (left_base->TranslateExpr(this) + " |= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_XOR:	return (left_base->TranslateExpr(this) + " ^= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SHL:	return (left_base->TranslateExpr(this) + " <<= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SHR:	return (left_base->TranslateExpr(this) + " >>= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_MOD:	return (left_base->TranslateExpr(this) + " %= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_ADD:	return (left_base->TranslateExpr(this) + " += " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_SUB:	return (left_base->TranslateExpr(this) + " -= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_MUL:	return (left_base->TranslateExpr(this) + " *= " + right_base->TranslateExpr(this));
			case TokenIdentifier::OP_ASSIGN_DIV:	return (left_base->TranslateExpr(this) + " /= " + right_base->TranslateExpr(this));
			default:
				{
					GetContext()->FatalError("Internal error. Unknown assignment operator.", node->Token);
					return "";
				}
		}
	}
}

// =================================================================
//	Translates a base expression.
// =================================================================
std::string	CCPPTranslator::TranslateBaseExpression(CBaseExpressionASTNode* node)
{
	CClassASTNode* scope = node->FindClassScope(m_semanter);
	if (scope != NULL)
	{
		return scope->SuperClass->MangledIdentifier;
	}
	else
	{
		GetContext()->FatalError("Internal error. Attempt to access base class of object with no base class..", node->Token);
	}
	return ""; // Shuts up Warning C4715
}

// =================================================================
//	Translates a binary math expression.
// =================================================================
std::string	CCPPTranslator::TranslateBinaryMathExpression(CBinaryMathExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	switch (node->Token.Type)
	{
		case TokenIdentifier::OP_AND:		return Enclose(left_base->TranslateExpr(this) + " & " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_OR:		return Enclose(left_base->TranslateExpr(this) + " | " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_XOR:		return Enclose(left_base->TranslateExpr(this) + " ^ " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_SHL:		return Enclose(left_base->TranslateExpr(this) + " << " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_SHR:		return Enclose(left_base->TranslateExpr(this) + " >> " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_MOD:		return Enclose(left_base->TranslateExpr(this) + " % " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_ADD:		return Enclose(left_base->TranslateExpr(this) + " + " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_SUB:		return Enclose(left_base->TranslateExpr(this) + " - " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_MUL:		return Enclose(left_base->TranslateExpr(this) + " * " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_DIV:		return Enclose(left_base->TranslateExpr(this) + " / " + right_base->TranslateExpr(this));
		default:
			{
				GetContext()->FatalError("Internal error. Unknown binary math operator.", node->Token);
				return "";
			}
	}
}

// =================================================================
//	Translates a class ref expression.
// =================================================================
std::string	CCPPTranslator::TranslateClassRefExpression(CClassRefExpressionASTNode* node)
{
	return node->ExpressionResultType->GetClass(m_semanter)->MangledIdentifier;
}

// =================================================================
//	Translates a comparison expression.
// =================================================================
std::string	CCPPTranslator::TranslateComparisonExpression(CComparisonExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	switch (node->Token.Type)
	{			
		case TokenIdentifier::OP_EQUAL:			return Enclose(left_base->TranslateExpr(this) + " = " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_NOT_EQUAL:		return Enclose(left_base->TranslateExpr(this) + " != " + right_base->TranslateExpr(this)); 
		case TokenIdentifier::OP_GREATER:		return Enclose(left_base->TranslateExpr(this) + " > " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_LESS:			return Enclose(left_base->TranslateExpr(this) + " < " + right_base->TranslateExpr(this)); 
		case TokenIdentifier::OP_GREATER_EQUAL:	return Enclose(left_base->TranslateExpr(this) + " >= " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_LESS_EQUAL:	return Enclose(left_base->TranslateExpr(this) + " <= " + right_base->TranslateExpr(this)); 
		default:
			{
				GetContext()->FatalError("Internal error. Unknown comparison operator.", node->Token);
				return "";
			}
	}
}

// =================================================================
//	Translates a field access expression.
// =================================================================
std::string	CCPPTranslator::TranslateFieldAccessExpression(CFieldAccessExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	CClassASTNode* left_class = left_base->ExpressionResultType->GetClass(m_semanter);
	
	// Class access.
	if (dynamic_cast<CBaseExpressionASTNode*>(left_base)						!= NULL ||
		dynamic_cast<CFloatDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CIntDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CBoolDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CClassReferenceDataType*>(left_base->ExpressionResultType) != NULL)
	{
		return left_class->MangledIdentifier + "::" + right_base->TranslateExpr(this);
	}

	// Value access.
	else if (dynamic_cast<CStringDataType*>(left_base->ExpressionResultType))
	{
		return left_base->TranslateExpr(this) + "." + right_base->TranslateExpr(this);
	}

	// Pointer access.
	else if (dynamic_cast<CObjectDataType*>(left_base->ExpressionResultType))
	{
		return left_base->TranslateExpr(this) + "->" + right_base->TranslateExpr(this);
	}

	// Wut
	else
	{
		GetContext()->FatalError("Internal error. Unknown field access data type.", node->Token);
		return "";
	}

	return "";
}

// =================================================================
//	Translates a index expression.
// =================================================================
std::string	CCPPTranslator::TranslateIndexExpression(CIndexExpressionASTNode* node, bool set, std::string set_expr, bool postfix)
{
	CExpressionBaseASTNode* index_base = dynamic_cast<CExpressionBaseASTNode*>(node->IndexExpression);
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CClassASTNode* left_class = index_base->ExpressionResultType->GetClass(m_semanter);

	std::string op = ".";
	if (dynamic_cast<CObjectDataType*>(left_base->ExpressionResultType) != NULL)
	{
		op = "->";
	}

	if (set == true)
	{
		//if (dynamic_cast<CObjectDataType*>(node->ExpressionResultType) != NULL)
		//{
		//	CDataType* type = dynamic_cast<CArrayDataType*>(left_base->ExpressionResultType)->ElementType;
		//
		//	set_expr = "dynamic_cast<" + TranslateDataType(type) + ">(lsGCObject::GCAssign(" + (left_base->TranslateExpr(this) + op + "GetIndex(" + index_base->TranslateExpr(this)) + "), " + set_expr + "))";
		//	return left_base->TranslateExpr(this) + op + "SetIndex(" + index_base->TranslateExpr(this) + ", " + set_expr + ", " + (postfix ? "true" : "false") + ")";
		//}
		//else
		//{
			return left_base->TranslateExpr(this) + op + "SetIndex(" + index_base->TranslateExpr(this) + ", " + set_expr + ", " + (postfix ? "true" : "false") + ")";
		//}
	}
	else
	{
		return left_base->TranslateExpr(this) + op + "GetIndex(" + index_base->TranslateExpr(this) + ")";
	}
}

// =================================================================
//	Translates a literal expression.
// =================================================================
std::string	CCPPTranslator::TranslateLiteralExpression(CLiteralExpressionASTNode* node)
{	
	std::string lit = node->Literal;

	if (dynamic_cast<CBoolDataType*>(node->ExpressionResultType) != NULL)
	{
		return lit == "0" || CStringHelper::ToLower(lit) == "false" || lit == "" ? "false" : "true";
	}
	else if (dynamic_cast<CIntDataType*>(node->ExpressionResultType) != NULL)
	{
		return lit;
	}
	else if (dynamic_cast<CFloatDataType*>(node->ExpressionResultType) != NULL)
	{
		return lit + "f";
	}
	else if (dynamic_cast<CStringDataType*>(node->ExpressionResultType) != NULL)
	{
		return "lsString(\"" + EscapeCString(lit) + "\")";
	}
	else if (dynamic_cast<CNullDataType*>(node->ExpressionResultType) != NULL)
	{
		return "NULL";
	}
	else
	{
		GetContext()->FatalError("Internal error. Unknown literal.", node->Token);				
	}

	return ""; // Shuts up Warning C4715
}

// =================================================================
//	Translates a slice expression.
// =================================================================
std::string	CCPPTranslator::TranslateSliceExpression(CSliceExpressionASTNode* node)
{
	CExpressionBaseASTNode* start_base  = dynamic_cast<CExpressionBaseASTNode*>(node->StartExpression);
	CExpressionBaseASTNode* end_base  = dynamic_cast<CExpressionBaseASTNode*>(node->EndExpression);
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);

	std::string op = ".";

	if (dynamic_cast<CObjectDataType*>(left_base->ExpressionResultType) != NULL)
	{
		op = "->";
	}

	if (start_base != NULL && end_base == NULL)
	{
		return left_base->TranslateExpr(this) + op + "GetSlice(" + start_base->TranslateExpr(this) + ")";
	}
	else if (start_base == NULL && end_base != NULL)
	{
		return left_base->TranslateExpr(this) + op + "GetSlice(0, " + end_base->TranslateExpr(this) + ")";
	}
	else if (start_base != NULL && end_base != NULL)
	{
		return left_base->TranslateExpr(this) + op + "GetSlice(" + start_base->TranslateExpr(this) + ", " + end_base->TranslateExpr(this) + ")";
	}
	else
	{
		return left_base->TranslateExpr(this) + op + "GetSlice(0)";
	}
}

// =================================================================
//	Translates a comma expression.
// =================================================================
std::string	CCPPTranslator::TranslateCommaExpression(CCommaExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base  = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);
	return Enclose(left_base->TranslateExpr(this)) + ", " + Enclose(right_base->TranslateExpr(this));
}

// =================================================================
//	Translates a this expression.
// =================================================================
std::string	CCPPTranslator::TranslateThisExpression(CThisExpressionASTNode* node)
{
	if (node->FindClassMethodScope(m_semanter)->IsExtension == true)
	{
		return "ext_this";
	}
	else
	{
		return "this";
	}
}

// =================================================================
//	Translates a logical expression.
// =================================================================
std::string	CCPPTranslator::TranslateLogicalExpression(CLogicalExpressionASTNode* node)
{	
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	switch (node->Token.Type)
	{	
		case TokenIdentifier::OP_LOGICAL_AND:		return Enclose(left_base->TranslateExpr(this) + " && " + right_base->TranslateExpr(this));
		case TokenIdentifier::OP_LOGICAL_OR:		return Enclose(left_base->TranslateExpr(this) + " || " + right_base->TranslateExpr(this));
		default:
			{
				GetContext()->FatalError("Internal error. Unknown logical operator.", node->Token);
				return "";
			}
	}
}

// =================================================================
//	Translates a prefix expression.
// =================================================================
std::string	CCPPTranslator::TranslatePreFixExpression(CPreFixExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);

	switch (node->Token.Type)
	{	
		case TokenIdentifier::OP_ADD:			return Enclose("+" + left_base->TranslateExpr(this));
		case TokenIdentifier::OP_SUB:			return Enclose("-" + left_base->TranslateExpr(this));
		case TokenIdentifier::OP_DECREMENT:		
		case TokenIdentifier::OP_INCREMENT:		
			{
				// We need to deal with index based assignments slightly differently.
				CIndexExpressionASTNode* left_index_base = dynamic_cast<CIndexExpressionASTNode*>(left_base);
				if (left_index_base != NULL)
				{
					std::string set_expr = dynamic_cast<CExpressionBaseASTNode*>(left_index_base->LeftValue)->TranslateExpr(this);

					switch (node->Token.Type)
					{
						case TokenIdentifier::OP_DECREMENT:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " - 1", true);
						case TokenIdentifier::OP_INCREMENT:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " + 1", true);
					}
				}
				else
				{
					switch (node->Token.Type)
					{
						case TokenIdentifier::OP_DECREMENT:		return Enclose("--" + left_base->TranslateExpr(this));
						case TokenIdentifier::OP_INCREMENT:		return Enclose("++" + left_base->TranslateExpr(this));
					}
				}
				
				GetContext()->FatalError("Internal error. Unknown prefix operator.", node->Token);
				return "";
			}
		default:
			{
				GetContext()->FatalError("Internal error. Unknown prefix operator.", node->Token);
				return "";
			}
	}
}

// =================================================================
//	Translates a postfix expression.
// =================================================================
std::string	CCPPTranslator::TranslatePostFixExpression(CPostFixExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);

	switch (node->Token.Type)
	{			
		case TokenIdentifier::OP_DECREMENT:		
		case TokenIdentifier::OP_INCREMENT:		
			{
				// We need to deal with index based assignments slightly differently.
				CIndexExpressionASTNode* left_index_base = dynamic_cast<CIndexExpressionASTNode*>(left_base);
				if (left_index_base != NULL)
				{
					std::string set_expr = dynamic_cast<CExpressionBaseASTNode*>(left_index_base->LeftValue)->TranslateExpr(this);

					switch (node->Token.Type)
					{
						case TokenIdentifier::OP_DECREMENT:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " - 1", false);
						case TokenIdentifier::OP_INCREMENT:	return TranslateIndexExpression(left_index_base, true, left_base->TranslateExpr(this) + " + 1", false);
					}
				}
				else
				{
					switch (node->Token.Type)
					{
						case TokenIdentifier::OP_DECREMENT:		return Enclose(left_base->TranslateExpr(this) + "--");
						case TokenIdentifier::OP_INCREMENT:		return Enclose(left_base->TranslateExpr(this) + "++");
					}
				}
				
				GetContext()->FatalError("Internal error. Unknown prefix operator.", node->Token);
				return "";
			}
		default:
			{
				GetContext()->FatalError("Internal error. Unknown prefix operator.", node->Token);
				return "";
			}
	}
}

// =================================================================
//	Translates a identifier expression.
// =================================================================
std::string	CCPPTranslator::TranslateIdentifierExpression(CIdentifierExpressionASTNode* node)
{
	return node->ResolvedDeclaration->MangledIdentifier;
}

// =================================================================
//	Translates a method call expression.
// =================================================================
std::string	CCPPTranslator::TranslateMethodCallExpression(CMethodCallExpressionASTNode* node)
{
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);

	std::string args = "";

	CClassMemberASTNode* member = dynamic_cast<CClassMemberASTNode*>(node->ResolvedDeclaration);

	if (member != NULL && member->IsExtension == true)
	{
		args += left_base->TranslateExpr(this);
	}

	for (auto iter = node->ArgumentExpressions.begin(); iter != node->ArgumentExpressions.end(); iter++)
	{
		if (args != "")
		{
			args += ", ";
		}
		
		CExpressionBaseASTNode* arg  = dynamic_cast<CExpressionBaseASTNode*>(*iter);
		args += Enclose(arg->TranslateExpr(this));
	}

	CClassASTNode* left_class = left_base->ExpressionResultType->GetClass(m_semanter);
	
	// Extension method.
	if (member != NULL && member->IsExtension == true)
	{
		return node->ResolvedDeclaration->MangledIdentifier  + "(" + args + ")";
	}

	// Class access.
	else if (dynamic_cast<CBaseExpressionASTNode*>(left_base)						!= NULL ||
		dynamic_cast<CFloatDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CIntDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CBoolDataType*>(left_base->ExpressionResultType)			!= NULL ||
		dynamic_cast<CClassReferenceDataType*>(left_base->ExpressionResultType) != NULL)
	{
		return left_base->TranslateExpr(this) + "::" + node->ResolvedDeclaration->MangledIdentifier  + "(" + args + ")";
	}

	// Value access.
	else if (dynamic_cast<CStringDataType*>(left_base->ExpressionResultType))
	{
		return left_base->TranslateExpr(this) + "." + node->ResolvedDeclaration->MangledIdentifier  + "(" + args + ")";
	}

	// Pointer access.
	else if (dynamic_cast<CObjectDataType*>(left_base->ExpressionResultType))
	{
		return left_base->TranslateExpr(this) + "->" + node->ResolvedDeclaration->MangledIdentifier  + "(" + args + ")";
	}

	// Wut
	else
	{
		GetContext()->FatalError("Internal error. Unknown field access data type.", node->Token);
		return "";
	}
}

// =================================================================
//	Translates a ternary expression.
// =================================================================
std::string	CCPPTranslator::TranslateTernaryExpression(CTernaryExpressionASTNode* node)
{	
	CExpressionBaseASTNode* left_base  = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	CExpressionBaseASTNode* right_base = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);
	CExpressionBaseASTNode* expr_base  = dynamic_cast<CExpressionBaseASTNode*>(node->Expression);

	return Enclose(expr_base->TranslateExpr(this) + " ? " + left_base->TranslateExpr(this) + " : " + right_base->TranslateExpr(this));
}

// =================================================================
//	Translates a cast expression.
// =================================================================
std::string	CCPPTranslator::TranslateCastExpression(CCastExpressionASTNode* node)
{
	CExpressionBaseASTNode* expr = dynamic_cast<CExpressionBaseASTNode*>(node->RightValue);

	std::string exprTrans = expr->TranslateExpr(this);

	CDataType* fromType = expr->ExpressionResultType;
	CDataType* toType   = node->Type;

	if (dynamic_cast<CBoolDataType*>(toType) != NULL)
	{
		if (dynamic_cast<CBoolDataType*>(fromType) != NULL)		return exprTrans;
		if (dynamic_cast<CIntDataType*>(fromType) != NULL)		return Enclose(exprTrans + " != 0");
		if (dynamic_cast<CFloatDataType*>(fromType) != NULL)	return Enclose(exprTrans + " != 0");
		if (dynamic_cast<CArrayDataType*>(fromType) != NULL)	return Enclose(exprTrans + "->Length() != 0");
		if (dynamic_cast<CStringDataType*>(fromType) != NULL)	return Enclose(exprTrans + ".Length() != 0");
		if (dynamic_cast<CObjectDataType*>(fromType) != NULL)	return Enclose(exprTrans + " != 0");		
	}
	else if (dynamic_cast<CIntDataType*>(toType) != NULL)
	{
		if (dynamic_cast<CBoolDataType*>(fromType) != NULL)		return Enclose(exprTrans + " ? 1 : 0");
		if (dynamic_cast<CIntDataType*>(fromType) != NULL)		return exprTrans;
		if (dynamic_cast<CFloatDataType*>(fromType) != NULL)	return "int(" + exprTrans + ")";
		if (dynamic_cast<CStringDataType*>(fromType) != NULL)	return exprTrans + ".ToInt()";
		if (dynamic_cast<CArrayDataType*>(fromType) != NULL)	return Enclose(exprTrans + "->Length() != 0 ? 1 : 0");
		if (dynamic_cast<CObjectDataType*>(fromType) != NULL)	return Enclose(exprTrans + " != 0 ? 1 : 0");
	}
	else if (dynamic_cast<CFloatDataType*>(toType) != NULL)
	{
		if (dynamic_cast<CBoolDataType*>(fromType) != NULL)		return Enclose(exprTrans + " ? 1.0f : 0.0f");
		if (dynamic_cast<CIntDataType*>(fromType) != NULL)		return "float(" + exprTrans + ")";
		if (dynamic_cast<CFloatDataType*>(fromType) != NULL)	return exprTrans;
		if (dynamic_cast<CStringDataType*>(fromType) != NULL)	return exprTrans + ".ToFloat()";
		if (dynamic_cast<CArrayDataType*>(fromType) != NULL)	return Enclose(exprTrans + "->Length() != 0 ? 1.0f : 0.0f");
		if (dynamic_cast<CObjectDataType*>(fromType) != NULL)	return Enclose(exprTrans + " != 0 ? 1.0f : 0.0f");
	}
	else if (dynamic_cast<CStringDataType*>(toType) != NULL)
	{
		if (dynamic_cast<CBoolDataType*>(fromType) != NULL)		return Enclose(exprTrans + " ? lsString(\"1\") : lsString(\"0\")");
		if (dynamic_cast<CIntDataType*>(fromType) != NULL)		return "lsString(" + exprTrans + ")";
		if (dynamic_cast<CFloatDataType*>(fromType) != NULL)	return "lsString(" + exprTrans + ")";
		if (dynamic_cast<CStringDataType*>(fromType) != NULL)	return exprTrans;
		if (dynamic_cast<CArrayDataType*>(fromType) != NULL)	return exprTrans + "->ToString()";
		if (dynamic_cast<CObjectDataType*>(fromType) != NULL)	return exprTrans + "->ToString()";
	}
	else if (dynamic_cast<CObjectDataType*>(toType) != NULL &&
			 dynamic_cast<CObjectDataType*>(fromType) != NULL)
	{
		// Converting interface to object.
		if (fromType->GetClass(m_semanter)->IsInterface == true &&
			toType->GetClass(m_semanter)->IsInterface == false)
		{
			return "lsCast<" + TranslateDataType(toType) + ">(" + Enclose(exprTrans) + ", " + (node->ExceptionOnFail ? "true" : "false") + ")";
		}

		// Upcasting (make sure we are not an array, arrays are special cases).
		else if (dynamic_cast<CArrayDataType*>(fromType) == NULL &&
				 dynamic_cast<CArrayDataType*>(toType) == NULL &&
				 fromType->GetClass(m_semanter)->InheritsFromClass(m_semanter, toType->GetClass(m_semanter)))
		{
			return exprTrans;
		}

		// Downcasting
		else
		{
			return "lsCast<" + TranslateDataType(toType) + ">(" + Enclose(exprTrans) + ", " + (node->ExceptionOnFail ? "true" : "false") + ")";
		}
	}

	GetContext()->FatalError(CStringHelper::FormatString("Internal error. Can not cast from '%s' to '%s'.", fromType->ToString(), toType->ToString()), node->Token);
	return "";
}

// =================================================================
//	Translates a new expression.
// =================================================================
std::string	CCPPTranslator::TranslateNewExpression(CNewExpressionASTNode* node)
{
	std::string result = "";

	if (node->IsArray == true)
	{
		CExpressionASTNode* expr = dynamic_cast<CExpressionASTNode*>(node->ArgumentExpressions.at(0));
		CArrayDataType* arrayType = dynamic_cast<CArrayDataType*>(node->DataType);

		std::string defaultValue = "";
		if (dynamic_cast<CBoolDataType*>(arrayType->ElementType) != NULL)
		{
			defaultValue = "false";
		}
		else if (dynamic_cast<CIntDataType*>(arrayType->ElementType) != NULL)
		{
			defaultValue = "0";
		}
		else if (dynamic_cast<CFloatDataType*>(arrayType->ElementType) != NULL)
		{
			defaultValue = "0.0f";
		}
		else if (dynamic_cast<CStringDataType*>(arrayType->ElementType) != NULL)
		{
			defaultValue = "lsString(\"\")";
		}
		else
		{
			defaultValue = "NULL";
		}

		result = "((new lsArray<" + TranslateDataType(arrayType->ElementType) + ">(" + expr->TranslateExpr(this) + "))->Init(" + defaultValue + "))";
	}
	else
	{
		// Create a new object.
		result += "(new " + node->DataType->GetClass(m_semanter)->MangledIdentifier + "())";

		// Invoke the constructor.
		result += "->" + node->ResolvedConstructor->MangledIdentifier + "(";

		for (auto iter = node->ArgumentExpressions.begin(); iter != node->ArgumentExpressions.end(); iter++)
		{
			CExpressionASTNode* expr = dynamic_cast<CExpressionASTNode*>(*iter);
			if (iter != node->ArgumentExpressions.begin())
			{
				result += ", ";
			}
			result += expr->TranslateExpr(this);
		}

		result += ")";
	}

	return Enclose(result);
}

// =================================================================
//	Translates a type expression.
// =================================================================
std::string	CCPPTranslator::TranslateTypeExpression(CTypeExpressionASTNode* node)
{
	CExpressionBaseASTNode* expr = dynamic_cast<CExpressionBaseASTNode*>(node->LeftValue);
	std::string exprTrans = expr->TranslateExpr(this);

	switch (node->Token.Type)
	{
		case TokenIdentifier::KEYWORD_IS:
			{		
				CDataType*		 fromType	= expr->ExpressionResultType;
				CObjectDataType* toType		= NULL;

				if (dynamic_cast<CBoolDataType*>(node->Type)	!= NULL ||	
					dynamic_cast<CIntDataType*>(node->Type)		!= NULL ||		
					dynamic_cast<CFloatDataType*>(node->Type)	!= NULL ||	
					dynamic_cast<CStringDataType*>(node->Type)	!= NULL ||	
					dynamic_cast<CArrayDataType*>(node->Type)	!= NULL)
				{
					toType = node->Type->GetBoxClass(m_semanter)->ObjectDataType;
				}
				else if (dynamic_cast<CObjectDataType*>(node->Type)	!= NULL)	
				{
					toType = node->Type->GetClass(m_semanter)->ObjectDataType;
				}

				// Converting interface to object.
				if (fromType->GetClass(m_semanter)->IsInterface == true &&
					toType->GetClass(m_semanter)->IsInterface == false)
				{
					return Enclose("lsCast<" + TranslateDataType(toType) + ">(" + exprTrans + ", false) != 0");
				}

				// Upcasting
				else if (fromType->GetClass(m_semanter)->InheritsFromClass(m_semanter, toType->GetClass(m_semanter)))
				{
					return Enclose(exprTrans + " != 0");
				}

				// Downcasting
				else
				{
					return Enclose("lsCast<" + TranslateDataType(toType) + ">(" + exprTrans + ", false) != 0");
				}
			}
		case TokenIdentifier::KEYWORD_AS:
			{
				return Enclose(exprTrans);
			}
	}

	GetContext()->FatalError(CStringHelper::FormatString("Internal error. Can not perform '%s' operator.", node->Token.Literal), node->Token);
	return "";
}

