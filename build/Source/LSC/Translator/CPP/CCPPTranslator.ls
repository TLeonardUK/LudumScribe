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
	private List<string> m_native_file_paths = new List<string>();
	private List<string> m_library_file_paths = new List<string>();
	
	private string m_base_directory;
	private string m_dst_directory;
	private string m_package_directory;
	private string m_source_directory;
	private string m_source_package_directory;
	
	private CPackageASTNode m_package;
	
	private string m_header_file_path;
	private string m_source_file_path;
	
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
	
	private List<string> m_created_files = new List<string>();
	
	public CCPPTranslator()
	{
	}
	
	public virtual override List<string> GetTranslatedFiles()
	{
		return m_created_files;
	}
	
	public void OpenSourceFile(string path)
	{
		m_source_file_path = (path + ".cpp");

		EmitSourceFile("/* *****************************************************************\n"); 
		EmitSourceFile("          LudumScribe Compiler\n"); 
		EmitSourceFile("   ***************************************************************** */\n"); 
		EmitSourceFile("\n");	
		
		// Emit include declarations.
		string relative = Path.GetRelative(path, m_source_directory);
		EmitSourceFile("#include \"" + relative + ".hpp\"\n");

		m_created_files.AddLast(path + ".cpp");
	}
	
	public void OpenHeaderFile(string path)
	{
		m_header_file_path = (path + ".hpp");

		string relative = Path.GetRelative(path, m_source_directory);
		m_include_guard = ("__" + relative.Filter("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "_") + "__").ToUpper();
		
		EmitHeaderFile("/* *****************************************************************\n"); 
		EmitHeaderFile("          LudumScribe Compiler\n"); 
		EmitHeaderFile("   ***************************************************************** */\n"); 
		EmitHeaderFile("\n");
		EmitHeaderFile("#ifndef " + m_include_guard + "\n");
		EmitHeaderFile("#define " + m_include_guard + "\n");
		EmitHeaderFile("\n");

		m_created_files.AddLast(path + ".hpp");
	}
	
	public void CloseSourceFile()
	{
		string output;

		try
		{
			output = File.LoadText(m_source_file_path);
			if (output != m_source_source)
			{		
				File.SaveText(m_source_file_path, m_source_source);
			}
		}
		catch (OperationFailedException ex)
		{
			// TODO
		}
		
		m_source_source = "";
	}
	
	public void CloseHeaderFile()
	{
		EmitHeaderFile("#endif // " + m_include_guard + "\n");
		EmitHeaderFile("\n");

		string output;

		try
		{
			output = File.LoadText(m_header_file_path);
			if (output != m_header_source)
			{
				File.SaveText(m_header_file_path, m_header_source);
			}
		}
		catch (OperationFailedException ex)
		{
			// TODO
		}

		m_header_source = "";
	}
	
	public void EmitSourceFile(string text)
	{
		if (text[0] == '{')
		{	
			if (m_last_source_was_newline == true)
			{
				text = "".PadRight(m_source_indent_level, "\t") + text;
			}
			m_source_indent_level++;
		}
		else if (text[0] == '}')
		{
			m_source_indent_level--;
			if (m_last_source_was_newline == true)
			{
				text = "".PadRight(m_source_indent_level, "\t") + text;
			}
		}
		else
		{
			if (m_last_source_was_newline == true)
			{
				text = "".PadRight(m_source_indent_level, "\t") + text;
			}
		}
		
		m_last_source_was_newline = false;
		if (text[text.Length() - 1] == '\n')
		{
			m_last_source_was_newline = true;
		}
		
		m_source_source += text;
		m_emit_source_counter++;
	}
	
	public void EmitHeaderFile(string text)
	{
		if (text[0] == '{')
		{
			if (m_last_header_was_newline == true)
			{
				text = "".PadRight(m_header_indent_level, "\t") + text;
			}
			m_header_indent_level++;
		}
		else if (text[0] == '}')
		{
			m_header_indent_level--;
			if (m_last_header_was_newline == true)
			{
				text = "".PadRight(m_header_indent_level, "\t") + text;
			}
		}
		else
		{
			if (m_last_header_was_newline == true)
			{
				text = "".PadRight(m_header_indent_level, "\t") + text;
			}
		}
		
		m_last_header_was_newline = false;
		if (text != "" && text[text.Length() - 1] == '\n')
		{
			m_last_header_was_newline = true;
		}

		m_header_source += text;
	}
	
	public void EmitGCCollect()
	{
		if (m_emit_source_counter > m_last_gc_collect_emit)
		{
			EmitSourceFile("lsGCObject::GCCollect(false);\n");
		}
		m_last_gc_collect_emit = m_emit_source_counter;
	}
	
	public string NewInternalVariableName()
	{
		return "lsInternal_t__" + (m_internal_var_counter++);
	}
	
	public string EscapeCString(string val)
	{
		string result = "";
		for ( int i = 0; i < val.Length(); i++)
		{
			string chr = val.GetIndex(i);
			if (chr == '\\')
			{
				result += "\\";
				result += "\\";
			}
			else if (chr == '"')
			{
				result += "\\\"";
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
			else if (chr.ToChar() >= 32 && chr.ToChar() <= 126)
			{
				result += chr;
			}
			else
			{
				result += "\\x" + string.FromIntToHex(chr.ToChar());
			}
		}
		return result;
	}
	
	public string Enclose(string val)
	{
		return "(" + val + ")";
	}
	
	public bool IsKeyword(string value)
	{
		if (value == "bool" ||
			value == "int" ||
			value == "float")
		{
			return true;
		}

		return false;
	}
	
	public string FindIncludePath(string path)
	{
		string file     = path;
		string dst_file = file;
		
		// Is it relative to base directory?
		if (dst_file.Length() > m_base_directory.Length() &&
			dst_file.SubString(0, m_base_directory.Length()) == m_base_directory)
		{
			dst_file = m_source_directory + dst_file.SubString(m_base_directory.Length() + 1);
		}

		// Is it relative to package directory?
		else if (dst_file.Length() > m_package_directory.Length() &&
					dst_file.SubString(0, m_package_directory.Length()) == m_package_directory)
		{
			dst_file = m_source_package_directory + dst_file.SubString(m_package_directory.Length() + 1);
		}

		// Strip extension.
		dst_file = Path.StripExtension(dst_file);

		return dst_file;
	}
	
	public void EmitRequiredClassIncludes(CClassASTNode node)
	{
		if (node.SuperClass != null)
		{
			if (node.SuperClass.IsNative == false)
			{		
				string path = node.SuperClass.MangledIdentifier;
				EmitHeaderFile("#include \"" + path + ".hpp\"\n");
			}
		}

		foreach (CClassASTNode interfaceNode in node.Interfaces)
		{
			if (interfaceNode.IsNative == false)
			{		
				string path = interfaceNode.MangledIdentifier;
				EmitHeaderFile("#include \"" + path + ".hpp\"\n");
			}
		}

		EmitHeaderFile("\n");
	}
	
	public List<CClassASTNode> FindReferencedClasses(CASTNode node)
	{
		List<CClassASTNode> references = new List<CClassASTNode>();

		// Class references?
		CClassASTNode classNode = node as CClassASTNode;
		if (classNode != null)
		{
			if (classNode.SuperClass != null)
			{
				if (!references.Contains(classNode.SuperClass))
				{
					references.AddLast(classNode.SuperClass);
				}
			}
			foreach (CClassASTNode subnode in classNode.Interfaces)
			{
				if (!references.Contains(subnode))
				{
					references.AddLast(subnode);
				}
			}
		}

		// Expression result types.
		CBaseExpressionASTNode exprNode = (node as CBaseExpressionASTNode);
		if (exprNode != null)
		{
			CClassASTNode subClassNode = exprNode.ExpressionResultType.GetClass(null);
			if (!references.Contains(subClassNode))
			{
				references.AddLast(subClassNode);
			}
		}

		// Grab references made by children.
		foreach (CASTNode iter in node.Children)
		{
			List<CClassASTNode> child_refs = FindReferencedClasses(iter);		
			foreach (CClassASTNode ref_iter in child_refs)
			{
				if (!references.Contains(ref_iter))
				{
					references.AddLast(ref_iter);
				}			
			}
		}

		return references;
	}
	
	public void GenerateEntryPoint(CPackageASTNode node)
	{
		EmitHeaderFile("int main(int argc, const char* argv[]);\n\n");
		EmitSourceFile("int main(int argc, const char* argv[])\n");
		EmitSourceFile("{\n");

		// Call runtime initialization.
		EmitSourceFile("lsRuntimeInit();\n");
		EmitSourceFile("\n");

		// Call class constructors.
		foreach (CASTNode n in node.Children)
		{
			CClassASTNode classNode = n as CClassASTNode;
			if (classNode != null && classNode.ClassConstructor != null)
			{
				if (classNode.ClassConstructor.IsExtension == true)
				{
					EmitSourceFile(classNode.ClassConstructor.MangledIdentifier + "();\n");
				}
				else
				{
					EmitSourceFile(classNode.MangledIdentifier + "::" + classNode.ClassConstructor.MangledIdentifier + "();\n");
				}
			}
		}
		EmitSourceFile("\n");

		EmitSourceFile("lsArray<lsString>* cmdArgs = new lsArray<lsString>(argc);\n");
		EmitSourceFile("for (int i = 0; i < argc; i++)\n");
		EmitSourceFile("{\n");
		EmitSourceFile("cmdArgs->SetIndex(i, lsString(argv[i]));\n");
		EmitSourceFile("}\n");
		EmitSourceFile("\n");

		// Call user-define entry point.
		CClassMemberASTNode entryPoint = m_context.GetEntryPoint();
		CClassASTNode entryPointScope = entryPoint.FindClassScope(m_context.GetSemanter());
		EmitSourceFile("int exitcode = " + entryPointScope.MangledIdentifier + "::" + entryPoint.MangledIdentifier + "(cmdArgs);\n");
		EmitSourceFile("\n");

		// Call runtime deinitialization.
		EmitSourceFile("lsRuntimeDeInit();\n");
		EmitSourceFile("\n");
		
		// Return to OS.
		EmitSourceFile("return exitcode;\n");

		EmitSourceFile("}\n");
		EmitSourceFile("\n");
	}
	
	public virtual override string TranslateDataType(CDataType type)
	{
		if (type is CArrayDataType)
		{
			CArrayDataType arrayDT = <CArrayDataType>(type);
			return "lsArray<" + TranslateDataType(arrayDT.ElementType) + ">*";
		}
		else if (type is CBoolDataType)
		{
			return "bool";
		}
		else if (type is CFloatDataType)
		{
			return "float";
		}
		else if (type is CIntDataType)
		{
			return "int";
		}
		else if (type is CStringDataType)
		{
			return "lsString";
		}
		else if (type is CVoidDataType)
		{
			return "void";
		}
		else if (type is CObjectDataType)
		{
			CObjectDataType objectDT = <CObjectDataType>(type);
			CClassASTNode classDT = objectDT.GetClass(m_semanter);
			if (classDT.Identifier == "bool"	||
				classDT.Identifier == "float"	||
				classDT.Identifier == "int"	||
				classDT.Identifier == "string")
			{
				return classDT.MangledIdentifier;
			}
			else if (classDT.Identifier == "array")
			{
				return "lsArray<" + TranslateDataType(classDT.GenericInstanceTypes.GetIndex(0)) + ">*";
			}

			return classDT.MangledIdentifier + "*";
		}
		else
		{
			GetContext().FatalError("Attempt to translate invalid or unknown data type.", type.Token);
		}

		return "";
	}
	
	public virtual override void TranslatePackage(CPackageASTNode node)
	{
		// Work out base directories.
		m_base_directory			= Path.StripFilename(m_context.GetFilePath());
		m_dst_directory				= m_context.GetCompiler().GetBuildDirectory();
		m_package_directory			= m_context.GetCompiler().GetPackageDirectory();
		m_source_directory			= m_dst_directory + "Source/";
		m_source_package_directory	= m_dst_directory + "Source/Packages/";
		m_package					= node;
		m_created_files.Clear();

		// Make directories.
		Directory.Create(m_dst_directory);
		Directory.Create(m_source_directory);
		Directory.Create(m_package_directory);

		// Work out and create all unique native files.
		List<string> native_files = m_context.GetNativeFileList();
		m_native_file_paths.Clear();
		foreach (string file in native_files)
		{
			string dst_file = file;

			// Is it relative to base directory?
			if (dst_file.Length() > m_base_directory.Length() &&
				dst_file.SubString(0, m_base_directory.Length()) == m_base_directory)
			{
				dst_file = m_source_directory + dst_file.SubString(m_base_directory.Length() + 1);
			}

			// Is it relative to package directory?
			else if (dst_file.Length() > m_package_directory.Length() &&
					 dst_file.SubString(0, m_package_directory.Length()) == m_package_directory)
			{
				dst_file = m_source_package_directory + dst_file.SubString(m_package_directory.Length() + 1);
			}

			// Create directory.
			string dir = Path.StripFilename(dst_file) + "/";
			Directory.Create(dir);

			// Work out base file without an extension.
			string file_no_extension = Path.StripExtension(file);
			string dst_file_no_extension = Path.StripExtension(dst_file);
			
			// Copy native file over.
			if (File.Exists(file_no_extension + ".hpp"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".hpp");
				File.Copy(file_no_extension + ".hpp", dst_file_no_extension + ".hpp");
				m_native_file_paths.AddLast(dst_file_no_extension);
			}
			if (File.Exists(file_no_extension + ".h"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".h");
				File.Copy(file_no_extension + ".h", dst_file_no_extension + ".h");
			}
			if (File.Exists(file_no_extension + ".cpp"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".cpp");
				File.Copy(file_no_extension + ".cpp", dst_file_no_extension + ".cpp");
			}
			if (File.Exists(file_no_extension + ".c"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".c");
				File.Copy(file_no_extension + ".c", dst_file_no_extension + ".c");
			}
			if (File.Exists(file_no_extension + ".cc"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".cc");
				File.Copy(file_no_extension + ".cc", dst_file_no_extension + ".cc");
			}
			if (File.Exists(file_no_extension + ".cxx"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".cxx");
				File.Copy(file_no_extension + ".cxx", dst_file_no_extension + ".cxx");
			}
		}

		// Work out and create all library files.
		List<string> library_files = m_context.GetLibraryFileList();
		foreach (string file in library_files)
		{
			string dst_file = file;

			// Is it relative to base directory?
			if (dst_file.Length() > m_base_directory.Length() &&
				dst_file.SubString(0, m_base_directory.Length()) == m_base_directory)
			{
				dst_file = m_source_directory + dst_file.SubString(m_base_directory.Length() + 1);
			}

			// Is it relative to package directory?
			else if (dst_file.Length() > m_package_directory.Length() &&
					 dst_file.SubString(0, m_package_directory.Length()) == m_package_directory)
			{
				dst_file = m_source_package_directory + dst_file.SubString(m_package_directory.Length() + 1);
			}

			// Create directory.
			string dir = Path.StripFilename(dst_file) + "/";
			Directory.Create(dir);

			// Work out base file without an extension.
			string file_no_extension = Path.StripExtension(file);
			string dst_file_no_extension = Path.StripExtension(dst_file);
			
			// Copy native file over.
			if (File.Exists(file_no_extension + ".lib"))
			{
				m_created_files.AddLast(dst_file_no_extension + ".lib");
				File.Copy(file_no_extension + ".lib", dst_file_no_extension + ".lib");
			}
		}
		
		// Copy across all copy files.
		List<string> copy_files = m_context.GetCopyFileList();
		foreach (string file in copy_files)
		{
			string dst_file = file;

			// Is it relative to base directory?
			if (dst_file.Length() > m_base_directory.Length() &&
				dst_file.SubString(0, m_base_directory.Length()) == m_base_directory)
			{
				dst_file = m_source_directory + dst_file.SubString(m_base_directory.Length() + 1);
			}

			// Is it relative to package directory?
			else if (dst_file.Length() > m_package_directory.Length() &&
					 dst_file.SubString(0, m_package_directory.Length()) == m_package_directory)
			{
				dst_file = m_source_package_directory + dst_file.SubString(m_package_directory.Length() + 1);
			}

			// Create directory.
			string dir = Path.StripFilename(dst_file) + "/";
			Directory.Create(dir);

			// Copy native file over.
			if (File.Exists(file))
			{
				//m_created_files.AddLast(file);
				File.Copy(file, dst_file);
			}
		}
		
		// Emit a source file for each class.
		foreach (CASTNode iter in node.Children)
		{
			CClassASTNode child = iter as CClassASTNode;
			if (child == null)
			{
				continue;
			}
			if (child.IsGeneric == true)
			{
				for ( int i = 0; i < child.GenericInstances.Count(); i++)
				{
					TranslateClass(child.GenericInstances.GetIndex(i));
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
		for (int i = 0; i < m_native_file_paths.Count(); i++)
		{
			string file_path = m_native_file_paths.GetIndex(i);
			string relative = Path.GetRelative(file_path, m_source_directory);
			EmitHeaderFile("#include \"" + relative + ".hpp\"\n");
		}
		EmitHeaderFile("\n");

		// Emit all forward declarations.
		List<CASTNode> referenced_classes = m_package.Children;
		foreach (CASTNode iter in referenced_classes)
		{
			CClassASTNode child = iter as CClassASTNode;
			if (child == null)
			{
				continue;
			}
			if (child.IsGeneric == true)
			{	
				foreach (CClassASTNode iter2 in child.GenericInstances)
				{
					if (!IsKeyword(iter2.MangledIdentifier))
					{
						EmitHeaderFile("class " + iter2.MangledIdentifier + ";\n");
					}

					string path = iter2.MangledIdentifier;
					EmitSourceFile("#include \"" + path + ".hpp\"\n");
				}
			}
			else
			{
				if (!IsKeyword(child.MangledIdentifier))
				{
					EmitHeaderFile("class " + child.MangledIdentifier + ";\n");
				}

				string path = child.MangledIdentifier;
				EmitSourceFile("#include \"" + path + ".hpp\"\n");
			}
		}
		EmitHeaderFile("\n");
		EmitSourceFile("\n");

		// Generate entry point.
		GenerateEntryPoint(node);

		CloseHeaderFile();
		CloseSourceFile();
	}
	
	public virtual override void TranslateClass(CClassASTNode node)
	{
		// Open source file for this class.
		OpenSourceFile(m_source_directory + node.MangledIdentifier);
		OpenHeaderFile(m_source_directory + node.MangledIdentifier);

		// Emit native include declarations.
		for ( int i = 0; i < m_native_file_paths.Count(); i++)
		{
			string file_path = m_native_file_paths.GetIndex(i);
			string relative = Path.GetRelative(file_path, m_source_directory);

			EmitHeaderFile("#include \"" + relative + ".hpp\"\n");
		}
		EmitHeaderFile("\n");
		
		// Emit all translated includes we need.
		EmitRequiredClassIncludes(node);
		
		// Emit all forward declarations.
		List<CASTNode> referenced_classes = m_package.Children;//FindReferencedClasses(node);
		foreach (CASTNode iter in referenced_classes)
		{
			CClassASTNode child = iter as CClassASTNode;
			if (child == null || 
				child == node)
			{
				continue;
			}
			if (child.IsGeneric == true)
			{
				foreach (CClassASTNode iter2 in child.GenericInstances)
				{
					if (!IsKeyword(iter2.MangledIdentifier))
					{
						EmitHeaderFile("class " + iter2.MangledIdentifier + ";\n");
					}

					string path = iter2.MangledIdentifier;
					EmitSourceFile("#include \"" + path + ".hpp\"\n");
				}
			}
			else
			{
				if (!IsKeyword(child.MangledIdentifier))
				{
					EmitHeaderFile("class " + child.MangledIdentifier + ";\n");
				}
					
				string path = child.MangledIdentifier;
				EmitSourceFile("#include \"" + path + ".hpp\"\n");
			}
		}
		EmitHeaderFile("\n");
		EmitSourceFile("\n");

		// Native class? Abort abort.
		if ((node.IsGeneric == false || node.GenericInstanceOf != null))
		{
			if (node.IsNative == false)
			{
				// Work out inheritance code.
				string inherit = "";
				if (node.IsInterface == false)
				{
					if (node.SuperClass != null)
					{
						inherit += "public " + node.SuperClass.MangledIdentifier;
					}

					foreach (CClassASTNode inheritNode in node.Interfaces)
					{
						if (inherit != " ")
						{
							inherit += ", ";
						}
						inherit += "public virtual " + inheritNode.MangledIdentifier;
					}
				}

				// Emit header class.
				EmitHeaderFile("class " + node.MangledIdentifier + (inherit != "" ? " : " + inherit : "") + "\n");	
				EmitHeaderFile("{\npublic:\n");	
			}

			foreach (CASTNode iter in node.Body.Children)
			{
				iter.Translate(this);
			}
			
			if (node.IsNative == false)
			{
				EmitHeaderFile("};\n");		
				EmitHeaderFile("\n");	
			}
		}

		CloseHeaderFile();
		CloseSourceFile();
	}
	
	public virtual override void TranslateClassMember(CClassMemberASTNode node)
	{
		CClassASTNode classNode = (node.Parent.Parent) as CClassASTNode;

		// Emit a method declaration.
		if (node.MemberMemberType == MemberType.Method)
		{
			if (classNode.IsNative == true)
			{
				if (node.IsNative == true)
				{
					return;
				}
			}

			// Attributes
			if (node.IsExtension == false)
			{
				if (node.IsStatic == true)
				{
					EmitHeaderFile("static ");
				}
				if (node.IsVirtual == true || classNode.IsInterface == true)
				{
					EmitHeaderFile("virtual ");
				}
			}

			// Data type.
			EmitHeaderFile(TranslateDataType(node.ReturnType) + " ");

			// Identifier			
			EmitHeaderFile(node.MangledIdentifier);

			// Arguments.
			EmitHeaderFile("(");
			if (node.IsExtension == true && node.IsStatic == false)
			{
				EmitHeaderFile(TranslateDataType(classNode.ObjectDataType) + " ext_this");
				if (node.Arguments.Count() > 0)
				{
					EmitHeaderFile(", ");
				}
			}
			int index = 0;
			foreach (CVariableStatementASTNode arg in node.Arguments)
			{				
				EmitHeaderFile(TranslateDataType(arg.Type) + " ");
				EmitHeaderFile(arg.MangledIdentifier);
				
				if (index + 1 < node.Arguments.Count())
				{
					EmitHeaderFile(", ");
				}
				
				index++;
			}
			EmitHeaderFile(")");

			// Body
			if (node.IsAbstract == true || classNode.IsInterface == true)
			{
				EmitHeaderFile(" = 0;");
			}
			else if (classNode.IsInterface == false && node.Body != null)
			{
				EmitHeaderFile(";");
				
				// Data type.
				EmitSourceFile(TranslateDataType(node.ReturnType) + " ");
				
				// Class Identifier				
				if (node.IsExtension == false)
				{
					EmitSourceFile(classNode.MangledIdentifier + "::");			
				}
				EmitSourceFile(node.MangledIdentifier);

				// Arguments.
				EmitSourceFile("(");
				if (node.IsExtension == true && node.IsStatic == false)
				{
					EmitSourceFile(TranslateDataType(classNode.ObjectDataType) + " ext_this");
					if (node.Arguments.Count() > 0)
					{
						EmitSourceFile(", ");
					}
				}
				index = 0;
				foreach (CVariableStatementASTNode arg in node.Arguments)
				{				
					EmitSourceFile(TranslateDataType(arg.Type) + " ");
					EmitSourceFile(arg.MangledIdentifier);
				
					if (index + 1 < node.Arguments.Count())
					{
						EmitSourceFile(", ");
					}
					
					index++;
				}
				EmitSourceFile(")\n");	
				EmitSourceFile("{\n");	
				//EmitGCCollect();
				
				// Translate body.
				node.Body.TranslateChildren(this);
				
				//EmitGCCollect();
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
			if (node.IsStatic == true)
			{
				if (node.IsExtension == true)
				{
					EmitSourceFile(TranslateDataType(node.ReturnType) + " " + node.MangledIdentifier + ";\n");
				}
				else
				{
					EmitSourceFile(TranslateDataType(node.ReturnType) + " " + classNode.MangledIdentifier + "::" + node.MangledIdentifier + ";\n");
				}
			}

			// Attributes
			if (classNode.IsNative == false)
			{
				if (node.IsStatic == true)
				{
					EmitHeaderFile("static ");
				}
				if (node.IsConst == true)
				{
					// Constness should be checked by compiler, not natively.
					// This allows us to instantiate consts in our instance constructor.
					// EmitHeaderFile("const ");
				}
			}
			else
			{
				if (node.IsNative == true)
				{
					return;
				}
			}

			// Data type.
			if (node.IsExtension == true)
			{
				EmitHeaderFile("extern ");
			}
			EmitHeaderFile(TranslateDataType(node.ReturnType) + " ");

			// Identifier
			EmitHeaderFile(node.MangledIdentifier);

			// Semicolon.		
			EmitHeaderFile(";");
		}

		EmitHeaderFile("\n");
	}
	
	public virtual override void TranslateVariableStatement(CVariableStatementASTNode node)
	{
		CClassASTNode classNode = (node.Parent.Parent) as CClassASTNode;
		
		// Data type.
		EmitSourceFile(TranslateDataType(node.Type) + " ");

		// Identifier
		EmitSourceFile(node.MangledIdentifier);

		// Assignment?
		if (node.AssignmentExpression != null)
		{
			EmitSourceFile(" = " + (node.AssignmentExpression as CExpressionBaseASTNode).TranslateExpr(this));
		}

		// Semicolon!
		EmitSourceFile(";\n");
	}
	
	public virtual override void TranslateBlockStatement(CBlockStatementASTNode node)
	{
		node.TranslateChildren(this);
	}
	
	public virtual override void TranslateBreakStatement(CBreakStatementASTNode node)
	{
		// HACK: needs removing, there should be no reason to do this.
		CASTNode accept_break_node = node.Parent;
		while (accept_break_node != null &&
			   accept_break_node.AcceptBreakStatement() == false)
		{
			accept_break_node = accept_break_node.Parent;
		}

		if (accept_break_node is CCaseStatementASTNode ||
			accept_break_node is CDefaultStatementASTNode)
		{
			EmitSourceFile("goto " + m_switchBreakJumpLabel + ";\n");
		}
		else
		{
			EmitSourceFile("break;\n");
		}
	}
	
	public virtual override void TranslateContinueStatement(CContinueStatementASTNode node)
	{
		EmitSourceFile("continue;\n");
	}
	
	public virtual override void TranslateDoStatement(CDoStatementASTNode node)
	{	
		EmitSourceFile("do\n");
		EmitSourceFile("{\n");
		node.BodyStatement.Translate(this);
		EmitSourceFile("}\n");
		EmitSourceFile("while (" + (node.ExpressionStatement as CExpressionBaseASTNode).TranslateExpr(this) + ");\n");
	}
	
	public virtual override void TranslateForEachStatement(CForEachStatementASTNode node)
	{
		node.BodyStatement.Translate(this);
	}
	
	public virtual override void TranslateForStatement(CForStatementASTNode node)
	{
		EmitSourceFile("for (");

		if (node.InitialStatement != null)
		{
			node.InitialStatement.Translate(this);
			EmitSourceFile(" ");
		}
		else
		{
			EmitSourceFile("; ");
		}
		
		if (node.ConditionExpression != null)
		{
			EmitSourceFile((node.ConditionExpression as CExpressionBaseASTNode).TranslateExpr(this) + "; ");
		}
		else
		{
			EmitSourceFile("; ");
		}
		
		if (node.IncrementExpression != null)
		{
			EmitSourceFile((node.IncrementExpression as CExpressionBaseASTNode).TranslateExpr(this) + ")\n", );
		}
		else
		{
			EmitSourceFile(")\n");
		}

		EmitSourceFile("{\n");
		node.BodyStatement.Translate(this);
		EmitSourceFile("}\n");
	}
	
	public virtual override void TranslateIfStatement(CIfStatementASTNode node)
	{
		EmitSourceFile("if (" + (node.ExpressionStatement as CExpressionBaseASTNode).TranslateExpr(this) + ")\n");
		EmitSourceFile("{\n");
		node.BodyStatement.Translate(this);
		EmitSourceFile("}\n");
		if (node.ElseStatement != null)
		{
			CIfStatementASTNode elseIf =  (node.ElseStatement as CIfStatementASTNode);
			if (elseIf != null)
			{
				EmitSourceFile("else ");
				node.ElseStatement.Translate(this);
			}
			else
			{
				EmitSourceFile("else\n");
				EmitSourceFile("{\n");
				node.ElseStatement.Translate(this);
				EmitSourceFile("}\n");
			}
		}
	}
	
	public virtual override void TranslateReturnStatement(CReturnStatementASTNode node)
	{
		EmitSourceFile("{\n");
		//EmitGCCollect();
		if (node.ReturnExpression != null)
		{
			EmitSourceFile("return (" + (node.ReturnExpression as CExpressionBaseASTNode).TranslateExpr(this) + ");\n");
		}
		else
		{
			EmitSourceFile("return;\n");
		}
		EmitSourceFile("}\n");
	}
	
	public virtual override void TranslateSwitchStatement(CSwitchStatementASTNode node)
	{
		string internal_var_name				 = NewInternalVariableName();
		string internal_var_name_jump_statement = "jmp_" + NewInternalVariableName();
		
		// Store expression in a temp variable.
		EmitSourceFile(TranslateDataType(node.ExpressionStatement.ExpressionResultType) + " " + internal_var_name + " = " + (node.ExpressionStatement as CExpressionBaseASTNode).TranslateExpr(this) + ";\n");

		// Skip first child, thats the expression.
		int outer_index = 0;
		foreach (CASTNode iter in node.Children)
		{
			CCaseStatementASTNode caseStmt = (iter as CCaseStatementASTNode);
			CDefaultStatementASTNode defaultStmt = (iter as CDefaultStatementASTNode);

			if (caseStmt != null)
			{
				if (outer_index != 0)
				{
					EmitSourceFile("else ");
				}
				EmitSourceFile("if (");

				int index = 0;
				foreach (CASTNode exprIter in caseStmt.Expressions)
				{
					if ((index++) != 0)
					{
						EmitSourceFile(" || ");
					}
					CExpressionBaseASTNode expr = <CExpressionBaseASTNode>(exprIter);
					EmitSourceFile(internal_var_name + " == " + expr.TranslateExpr(this));
				}

				EmitSourceFile(")\n");
				EmitSourceFile("{\n");
				
				string previousLabel = m_switchBreakJumpLabel;
				m_switchBreakJumpLabel = internal_var_name_jump_statement;

				caseStmt.BodyStatement.Translate(this);

				m_switchBreakJumpLabel = previousLabel;

				EmitSourceFile("}\n");	
			
				outer_index++;		
			}
			else if (defaultStmt != null)
			{
				if (outer_index != 0)
				{
					EmitSourceFile("else\n");
					EmitSourceFile("{\n");
				}
			
				string previousLabel = m_switchBreakJumpLabel;
				m_switchBreakJumpLabel = internal_var_name_jump_statement;

				defaultStmt.BodyStatement.Translate(this);
				
				m_switchBreakJumpLabel = previousLabel;

				if (outer_index != 0)
				{
					EmitSourceFile("}\n");	
				}
			
				outer_index++;
				break;
			}
			else
			{
			// TODO: Make it ignore expression of switch block.
			//	GetContext().FatalError("Internal error. Unknown switch statement child node.", node.Token);
			}
		}

		// Emit the break label.
		EmitSourceFile(internal_var_name_jump_statement + ": ;\n");

		return;
	}
	
	public virtual override void TranslateThrowStatement(CThrowStatementASTNode node)
	{
		EmitSourceFile("throw (" + (<CExpressionBaseASTNode>node.Expression).TranslateExpr(this) + ");\n");
	}
	
	public virtual override void TranslateTryStatement(CTryStatementASTNode node)
	{
		EmitSourceFile("try\n");
		EmitSourceFile("{\n");	
		node.BodyStatement.Translate(this);
		EmitSourceFile("}\n");

		foreach (CASTNode n in node.Children)
		{
			CCatchStatementASTNode catchStmt = n as CCatchStatementASTNode;
			if (catchStmt != null)
			{
				EmitSourceFile("catch ("+TranslateDataType(catchStmt.VariableStatement.Type)+" " + catchStmt.VariableStatement.MangledIdentifier + ")\n");
				EmitSourceFile("{\n");	
				catchStmt.BodyStatement.Translate(this);
				EmitSourceFile("}\n");
			}		
		}
	}
	
	public virtual override void TranslateWhileStatement(CWhileStatementASTNode node)
	{
		EmitSourceFile("while (" + (<CExpressionBaseASTNode>node.ExpressionStatement).TranslateExpr(this) + ")\n");
		EmitSourceFile("{\n");
		node.BodyStatement.Translate(this);
		EmitSourceFile("}\n");
	}
	
	public virtual override void TranslateExpressionStatement(CExpressionASTNode node)
	{	
		EmitSourceFile((<CExpressionBaseASTNode>node.LeftValue).TranslateExpr(this) + ";\n");
	}
	
	public virtual override string TranslateExpression(CExpressionASTNode node)
	{
		return Enclose((<CExpressionBaseASTNode>node.LeftValue).TranslateExpr(this));
	}
	
	public virtual override string TranslateAssignmentExpression(CAssignmentExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);

		// We need to deal with index based assignments slightly differently.
		CIndexExpressionASTNode left_index_base = (left_base as CIndexExpressionASTNode);
		if (left_index_base != null)
		{
			string set_expr = (<CExpressionBaseASTNode>left_index_base.LeftValue).TranslateExpr(this);

			switch (node.Token.Type)
			{
				case TokenIdentifier.OP_ASSIGN:		return TranslateIndexExpression(left_index_base, true, right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_AND:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " & " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_OR:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " | " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_XOR:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " ^ " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SHL:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " << " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SHR:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " >> " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_MOD:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " % " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_ADD:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " + " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SUB:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " - " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_MUL:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " * " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_DIV:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " / " + right_base.TranslateExpr(this));
				default:
					{
						GetContext().FatalError("Internal error. Unknown assignment operator.", node.Token);
						return "";
					}
			}
		}
		else
		{
			switch (node.Token.Type)
			{
				case TokenIdentifier.OP_ASSIGN:		
					{
						return (left_base.TranslateExpr(this) + " = " + right_base.TranslateExpr(this));	
					}
				case TokenIdentifier.OP_ASSIGN_AND:	return (left_base.TranslateExpr(this) + " &= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_OR:	return (left_base.TranslateExpr(this) + " |= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_XOR:	return (left_base.TranslateExpr(this) + " ^= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SHL:	return (left_base.TranslateExpr(this) + " <<= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SHR:	return (left_base.TranslateExpr(this) + " >>= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_MOD:	return (left_base.TranslateExpr(this) + " %= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_ADD:	return (left_base.TranslateExpr(this) + " += " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_SUB:	return (left_base.TranslateExpr(this) + " -= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_MUL:	return (left_base.TranslateExpr(this) + " *= " + right_base.TranslateExpr(this));
				case TokenIdentifier.OP_ASSIGN_DIV:	return (left_base.TranslateExpr(this) + " /= " + right_base.TranslateExpr(this));
				default:
					{
						GetContext().FatalError("Internal error. Unknown assignment operator.", node.Token);
						return "";
					}
			}
		}
	}
	
	public virtual override string TranslateBaseExpression(CBaseExpressionASTNode node)
	{
		CClassASTNode scope = node.FindClassScope(m_semanter);
		if (scope != null)
		{
			return scope.SuperClass.MangledIdentifier;
		}
		else
		{
			GetContext().FatalError("Internal error. Attempt to access base class of object with no base class..", node.Token);
		}
		return ""; // Shuts up Warning C4715
	}
	
	public virtual override string TranslateBinaryMathExpression(CBinaryMathExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);

		switch (node.Token.Type)
		{
			case TokenIdentifier.OP_AND:		return Enclose(left_base.TranslateExpr(this) + " & " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_OR:		return Enclose(left_base.TranslateExpr(this) + " | " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_XOR:		return Enclose(left_base.TranslateExpr(this) + " ^ " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_SHL:		return Enclose(left_base.TranslateExpr(this) + " << " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_SHR:		return Enclose(left_base.TranslateExpr(this) + " >> " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_MOD:		return Enclose(left_base.TranslateExpr(this) + " % " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_ADD:		return Enclose(left_base.TranslateExpr(this) + " + " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_SUB:		return Enclose(left_base.TranslateExpr(this) + " - " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_MUL:		return Enclose(left_base.TranslateExpr(this) + " * " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_DIV:		return Enclose(left_base.TranslateExpr(this) + " / " + right_base.TranslateExpr(this));
			default:
				{
					GetContext().FatalError("Internal error. Unknown binary math operator.", node.Token);
					return "";
				}
		}
	}
	
	public virtual override string TranslateCastExpression(CCastExpressionASTNode node)
	{
		CExpressionBaseASTNode expr = <CExpressionBaseASTNode>(node.RightValue);

		string exprTrans = expr.TranslateExpr(this);

		CDataType fromType = expr.ExpressionResultType;
		CDataType toType   = node.Type;

		if (toType is CBoolDataType)
		{
			if (fromType is CBoolDataType)		return exprTrans;
			if (fromType is CIntDataType)		return Enclose(exprTrans + " != 0");
			if (fromType is CFloatDataType)		return Enclose(exprTrans + " != 0");
			if (fromType is CArrayDataType)		return Enclose(exprTrans + "->Length() != 0");
			if (fromType is CStringDataType)	return Enclose(exprTrans + ".Length() != 0");
			if (fromType is CObjectDataType)	return Enclose(exprTrans + " != 0");		
		}
		else if (toType is CIntDataType)
		{
			if (fromType is CBoolDataType)		return Enclose(exprTrans + " ? 1 : 0");
			if (fromType is CIntDataType)		return exprTrans;
			if (fromType is CFloatDataType)		return "int(" + exprTrans + ")";
			if (fromType is CStringDataType)	return exprTrans + ".ToInt()";
			if (fromType is CArrayDataType)		return Enclose(exprTrans + "->Length() != 0 ? 1 : 0");
			if (fromType is CObjectDataType)	return Enclose(exprTrans + " != 0 ? 1 : 0");
		}
		else if (toType is CFloatDataType)
		{
			if (fromType is CBoolDataType)		return Enclose(exprTrans + " ? 1.0f : 0.0f");
			if (fromType is CIntDataType)		return "float(" + exprTrans + ")";
			if (fromType is CFloatDataType)		return exprTrans;
			if (fromType is CStringDataType)	return exprTrans + ".ToFloat()";
			if (fromType is CArrayDataType)		return Enclose(exprTrans + "->Length() != 0 ? 1.0f : 0.0f");
			if (fromType is CObjectDataType)	return Enclose(exprTrans + " != 0 ? 1.0f : 0.0f");
		}
		else if (toType is CStringDataType)
		{
			if (fromType is CBoolDataType)		return Enclose(exprTrans + " ? lsString(\"1\") : lsString(\"0\")");
			if (fromType is CIntDataType)		return "lsString(" + exprTrans + ")";
			if (fromType is CFloatDataType)		return "lsString(" + exprTrans + ")";
			if (fromType is CStringDataType)	return exprTrans;
			if (fromType is CArrayDataType)		return exprTrans + "->ToString()";
			if (fromType is CObjectDataType)	return exprTrans + "->ToString()";
		}
		else if (toType is CObjectDataType && fromType is CObjectDataType)
		{
			// Converting interface to object.
			if (fromType.GetClass(m_semanter).IsInterface == true &&
				toType.GetClass(m_semanter).IsInterface == false)
			{
				return "lsCast<" + TranslateDataType(toType) + ">(" + Enclose(exprTrans) + ", " + (node.ExceptionOnFail ? "true" : "false") + ")";
			}

			// Upcasting (make sure we are not an array, arrays are special cases).
			else if (!(fromType is CArrayDataType) &&
					 !(toType is CArrayDataType) &&
					 fromType.GetClass(m_semanter).InheritsFromClass(m_semanter, toType.GetClass(m_semanter)))
			{
				return exprTrans;
			}

			// Downcasting
			else
			{
				return "lsCast<" + TranslateDataType(toType) + ">(" + Enclose(exprTrans) + ", " + (node.ExceptionOnFail ? "true" : "false") + ")";
			}
		}

		GetContext().FatalError("Internal error. Can not cast from '" + fromType.ToString() + "' to '" + toType.ToString() + "'.", node.Token);
		return "";
	}
	
	public virtual override string TranslateClassRefExpression(CClassRefExpressionASTNode node)
	{
		return node.ExpressionResultType.GetClass(m_semanter).MangledIdentifier;
	}
	
	public virtual override string TranslateCommaExpression(CCommaExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);
		return Enclose(left_base.TranslateExpr(this)) + ", " + Enclose(right_base.TranslateExpr(this));
	}
	
	public virtual override string TranslateComparisonExpression(CComparisonExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);

		switch (node.Token.Type)
		{			
			case TokenIdentifier.OP_EQUAL:			return Enclose(left_base.TranslateExpr(this) + " == " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_NOT_EQUAL:		return Enclose(left_base.TranslateExpr(this) + " != " + right_base.TranslateExpr(this)); 
			case TokenIdentifier.OP_GREATER:		return Enclose(left_base.TranslateExpr(this) + " > " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_LESS:			return Enclose(left_base.TranslateExpr(this) + " < " + right_base.TranslateExpr(this)); 
			case TokenIdentifier.OP_GREATER_EQUAL:	return Enclose(left_base.TranslateExpr(this) + " >= " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_LESS_EQUAL:	return Enclose(left_base.TranslateExpr(this) + " <= " + right_base.TranslateExpr(this)); 
			default:
				{
					GetContext().FatalError("Internal error. Unknown comparison operator.", node.Token);
					return "";
				}
		}
	}
	
	public virtual override string TranslateFieldAccessExpression(CFieldAccessExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);

		CClassASTNode left_class = left_base.ExpressionResultType.GetClass(m_semanter);
		
		// Class access.
		if (left_base is CBaseExpressionASTNode				 ||
			left_base.ExpressionResultType is CFloatDataType ||
			left_base.ExpressionResultType is CIntDataType	 ||
			left_base.ExpressionResultType is CBoolDataType	 ||
			left_base.ExpressionResultType is CClassReferenceDataType)
		{
			return left_class.MangledIdentifier + "::" + right_base.TranslateExpr(this);
		}

		// Value access.
		else if (left_base.ExpressionResultType is CStringDataType)
		{
			return left_base.TranslateExpr(this) + "." + right_base.TranslateExpr(this);
		}

		// Pointer access.
		else if (left_base.ExpressionResultType is CObjectDataType)
		{
			return left_base.TranslateExpr(this) + "->" + right_base.TranslateExpr(this);
		}

		// Wut
		else
		{
			GetContext().FatalError("Internal error. Unknown field access data type.", node.Token);
			return "";
		}

		return "";
	}
	
	public virtual override string TranslateIdentifierExpression(CIdentifierExpressionASTNode node)
	{
		return node.ResolvedDeclaration.MangledIdentifier;
	}
	
	public virtual override string TranslateIndexExpression(CIndexExpressionASTNode node, bool set = false, string set_expr = "", bool postfix = false)
	{
		CExpressionBaseASTNode index_base  = <CExpressionBaseASTNode>(node.IndexExpression);		
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);		
		CClassASTNode left_class = index_base.ExpressionResultType.GetClass(m_semanter);

		string op = ".";
		if (left_base.ExpressionResultType is CObjectDataType)
		{
			op = "->";
		}

		if (set == true)
		{
			return left_base.TranslateExpr(this) + op + "SetIndex(" + index_base.TranslateExpr(this) + ", " + set_expr + ", " + (postfix ? "true" : "false") + ")";
		}
		else
		{
			return left_base.TranslateExpr(this) + op + "GetIndex(" + index_base.TranslateExpr(this) + ")";
		}
	}
	
	public virtual override string TranslateLiteralExpression(CLiteralExpressionASTNode node)
	{
		string lit = node.Literal;

		if (node.ExpressionResultType is CBoolDataType)
		{
			return lit == "0" || lit.ToLower() == "false" || lit == "" ? "false" : "true";
		}
		else if (node.ExpressionResultType is CIntDataType)
		{
			return lit;
		}
		else if (node.ExpressionResultType is CFloatDataType)
		{
			return lit + "f";
		}
		else if (node.ExpressionResultType is CStringDataType)
		{
			return "lsString(\"" + EscapeCString(lit) + "\")";
		}
		else if (node.ExpressionResultType is CNullDataType)
		{
			return "NULL";
		}
		else
		{
			GetContext().FatalError("Internal error. Unknown literal.", node.Token);				
		}

		return ""; // Shuts up Warning C4715
	}
	
	public virtual override string TranslateLogicalExpression(CLogicalExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);

		switch (node.Token.Type)
		{	
			case TokenIdentifier.OP_LOGICAL_AND:	return Enclose(left_base.TranslateExpr(this) + " && " + right_base.TranslateExpr(this));
			case TokenIdentifier.OP_LOGICAL_OR:		return Enclose(left_base.TranslateExpr(this) + " || " + right_base.TranslateExpr(this));
			default:
				{
					GetContext().FatalError("Internal error. Unknown logical operator.", node.Token);
					return "";
				}
		}
	}
	
	public virtual override string TranslateMethodCallExpression(CMethodCallExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);

		string args = "";

		CClassMemberASTNode member = (node.ResolvedDeclaration as CClassMemberASTNode);

		if (member != null && member.IsExtension == true && member.IsStatic == false)
		{
			args += left_base.TranslateExpr(this);
		}

		foreach (CASTNode iter in node.ArgumentExpressions)
		{
			if (args != "")
			{
				args += ", ";
			}
			
			CExpressionBaseASTNode arg  = <CExpressionBaseASTNode>(iter);
			args += Enclose(arg.TranslateExpr(this));
		}

		CClassASTNode left_class = left_base.ExpressionResultType.GetClass(m_semanter);
		
		// Extension method.
		if (member != null && member.IsExtension == true)
		{
			return node.ResolvedDeclaration.MangledIdentifier  + "(" + args + ")";
		}

		// Class access.
		else if (left_base is CBaseExpressionASTNode			 	||
			left_base.ExpressionResultType is CFloatDataType		||
			left_base.ExpressionResultType is CIntDataType			||
			left_base.ExpressionResultType is CBoolDataType			||
			left_base.ExpressionResultType is CClassReferenceDataType)
		{
			return left_base.TranslateExpr(this) + "::" + node.ResolvedDeclaration.MangledIdentifier  + "(" + args + ")";
		}

		// Value access.
		else if (left_base.ExpressionResultType is CStringDataType)
		{
			return left_base.TranslateExpr(this) + "." + node.ResolvedDeclaration.MangledIdentifier  + "(" + args + ")";
		}

		// Pointer access.
		else if (left_base.ExpressionResultType is CObjectDataType)
		{
			return left_base.TranslateExpr(this) + "->" + node.ResolvedDeclaration.MangledIdentifier  + "(" + args + ")";
		}

		// Wut
		else
		{
			GetContext().FatalError("Internal error. Unknown field access data type.", node.Token);
			return "";
		}
	}
	
	public virtual override string TranslateNewExpression(CNewExpressionASTNode node)
	{
		string result = "";

		if (node.IsArray == true)
		{
			if (node.ArrayInitializer != null)
			{
				result = node.ArrayInitializer.TranslateExpr(this);
			}
			else
			{
				CExpressionASTNode expr = <CExpressionASTNode>(node.ArgumentExpressions.GetIndex(0));
				CArrayDataType arrayType = <CArrayDataType>(node.DataType);

				string defaultValue = "";
				if (arrayType.ElementType is CBoolDataType)
				{
					defaultValue = "false";
				}
				else if (arrayType.ElementType is CIntDataType)
				{
					defaultValue = "0";
				}
				else if (arrayType.ElementType is CFloatDataType)
				{
					defaultValue = "0.0f";
				}
				else if (arrayType.ElementType is CStringDataType)
				{
					defaultValue = "lsString(\"\")";
				}
				else
				{
					defaultValue = "NULL";
				}

				result = "((new lsArray<" + TranslateDataType(arrayType.ElementType) + ">(" + expr.TranslateExpr(this) + "))->Init(" + defaultValue + "))";
			}
		}
		else
		{
			// Create a new object.
			result += "(new " + node.DataType.GetClass(m_semanter).MangledIdentifier + "())";

			// Invoke the constructor.
			result += "->" + node.ResolvedConstructor.MangledIdentifier + "(";
			
			int index = 0;
			foreach (CExpressionBaseASTNode expr in node.ArgumentExpressions)
			{
				if ((index++) != 0)
				{
					result += ", ";
				}
				result += expr.TranslateExpr(this);
			}

			result += ")";
		}

		return Enclose(result);
	}
	
	public virtual override string TranslatePostFixExpression(CPostFixExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);

		switch (node.Token.Type)
		{			
			case TokenIdentifier.OP_DECREMENT, 
				 TokenIdentifier.OP_INCREMENT:		
				{
					// We need to deal with index based assignments slightly differently.
					CIndexExpressionASTNode left_index_base = (left_base as CIndexExpressionASTNode);
					if (left_index_base != null)
					{
						string set_expr = (<CExpressionBaseASTNode>left_index_base.LeftValue).TranslateExpr(this);

						switch (node.Token.Type)
						{
							case TokenIdentifier.OP_DECREMENT:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " - 1", false);
							case TokenIdentifier.OP_INCREMENT:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " + 1", false);
						}
					}
					else
					{
						switch (node.Token.Type)
						{
							case TokenIdentifier.OP_DECREMENT:		return Enclose(left_base.TranslateExpr(this) + "--");
							case TokenIdentifier.OP_INCREMENT:		return Enclose(left_base.TranslateExpr(this) + "++");
						}
					}
					
					GetContext().FatalError("Internal error. Unknown prefix operator.", node.Token);
					return "";
				}
			default:
				{
					GetContext().FatalError("Internal error. Unknown prefix operator.", node.Token);
					return "";
				}
		}
	}
	
	public virtual override string TranslatePreFixExpression(CPreFixExpressionASTNode node)
	{
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);

		switch (node.Token.Type)
		{	
			case TokenIdentifier.OP_NOT:			return Enclose("~" + left_base.TranslateExpr(this));		
			case TokenIdentifier.OP_LOGICAL_NOT:	return Enclose("!" + left_base.TranslateExpr(this));
			case TokenIdentifier.OP_ADD:			return Enclose("+" + left_base.TranslateExpr(this));
			case TokenIdentifier.OP_SUB:			return Enclose("-" + left_base.TranslateExpr(this));
			case TokenIdentifier.OP_DECREMENT,
				 TokenIdentifier.OP_INCREMENT:		
				{
					// We need to deal with index based assignments slightly differently.
					CIndexExpressionASTNode left_index_base = (left_base) as CIndexExpressionASTNode;
					if (left_index_base != null)
					{
						string set_expr = (<CExpressionBaseASTNode>left_index_base.LeftValue).TranslateExpr(this);

						switch (node.Token.Type)
						{
							case TokenIdentifier.OP_DECREMENT:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " - 1", true);
							case TokenIdentifier.OP_INCREMENT:	return TranslateIndexExpression(left_index_base, true, left_base.TranslateExpr(this) + " + 1", true);
						}
					}
					else
					{
						switch (node.Token.Type)
						{
							case TokenIdentifier.OP_DECREMENT:		return Enclose("--" + left_base.TranslateExpr(this));
							case TokenIdentifier.OP_INCREMENT:		return Enclose("++" + left_base.TranslateExpr(this));
						}
					}
					
					GetContext().FatalError("Internal error. Unknown prefix operator.", node.Token);
					return "";
				}
			default:
				{
					GetContext().FatalError("Internal error. Unknown prefix operator.", node.Token);
					return "";
				}
		}
	}
	
	public virtual override string TranslateSliceExpression(CSliceExpressionASTNode node)
	{
		CExpressionBaseASTNode start_base  = (node.StartExpression as CExpressionBaseASTNode);
		CExpressionBaseASTNode end_base  = (node.EndExpression as CExpressionBaseASTNode);
		CExpressionBaseASTNode left_base  = (node.LeftValue as CExpressionBaseASTNode);

		string op = ".";

		if (left_base.ExpressionResultType is CObjectDataType)
		{
			op = "->";
		}

		if (start_base != null && end_base == null)
		{
			return left_base.TranslateExpr(this) + op + "GetSlice(" + start_base.TranslateExpr(this) + ")";
		}
		else if (start_base == null && end_base != null)
		{
			return left_base.TranslateExpr(this) + op + "GetSlice(0, " + end_base.TranslateExpr(this) + ")";
		}
		else if (start_base != null && end_base != null)
		{
			return left_base.TranslateExpr(this) + op + "GetSlice(" + start_base.TranslateExpr(this) + ", " + end_base.TranslateExpr(this) + ")";
		}
		else
		{
			return left_base.TranslateExpr(this) + op + "GetSlice(0)";
		}
	}
	
	public virtual override string TranslateTernaryExpression(CTernaryExpressionASTNode node)
	{	
		CExpressionBaseASTNode left_base  = <CExpressionBaseASTNode>(node.LeftValue);
		CExpressionBaseASTNode right_base = <CExpressionBaseASTNode>(node.RightValue);
		CExpressionBaseASTNode expr_base = <CExpressionBaseASTNode>(node.Expression);

		return Enclose(expr_base.TranslateExpr(this) + " ? " + left_base.TranslateExpr(this) + " : " + right_base.TranslateExpr(this));
	}
	
	public virtual override string TranslateThisExpression(CThisExpressionASTNode node)
	{
		if (node.FindClassMethodScope(m_semanter).IsExtension == true)
		{
			return "ext_this";
		}
		else
		{
			return "this";
		}
	}
	
	public virtual override string TranslateTypeExpression(CTypeExpressionASTNode node)
	{
		CExpressionBaseASTNode expr  = <CExpressionBaseASTNode>(node.LeftValue);
		string exprTrans = expr.TranslateExpr(this);

		switch (node.Token.Type)
		{
			case TokenIdentifier.KEYWORD_IS:
				{		
					CDataType		 fromType	= expr.ExpressionResultType;
					CObjectDataType toType		= null;

					if (node.Type is CBoolDataType ||	
						node.Type is CIntDataType ||	
						node.Type is CFloatDataType ||		
						node.Type is CStringDataType ||	
						node.Type is CArrayDataType)
					{
						toType = node.Type.GetBoxClass(m_semanter).ObjectDataType;
					}
					else if (node.Type is CObjectDataType)	
					{
						toType = node.Type.GetClass(m_semanter).ObjectDataType;
					}

					// Converting interface to object.
					if (fromType.GetClass(m_semanter).IsInterface == true &&
						toType.GetClass(m_semanter).IsInterface == false)
					{
						return Enclose("lsCast<" + TranslateDataType(toType) + ">(" + exprTrans + ", false) != 0");
					}

					// Upcasting
					else if (fromType.GetClass(m_semanter).InheritsFromClass(m_semanter, toType.GetClass(m_semanter)))
					{
						return Enclose(exprTrans + " != 0");
					}

					// Downcasting
					else
					{
						return Enclose("lsCast<" + TranslateDataType(toType) + ">(" + exprTrans + ", false) != 0");
					}
				}
			case TokenIdentifier.KEYWORD_AS:
				{
					return Enclose(exprTrans);
				}
		}

		GetContext().FatalError("Internal error. Can not perform '" + node.Token.Literal + "' operator.", node.Token);
		return "";
	}
	
	public virtual override string TranslateArrayInitializerExpression(CArrayInitializerASTNode node)
	{
		string result = "lsConstructArray<" + TranslateDataType((<CArrayDataType>node.ExpressionResultType).ElementType) + ">(" + node.Expressions.Count();

		foreach (CExpressionBaseASTNode iter in node.Expressions)
		{
			result += ", " + iter.TranslateExpr(this);
		}

		result += ")";

		return result;
	}
	
}



