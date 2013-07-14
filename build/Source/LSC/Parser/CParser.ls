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
	private CToken m_eof_token = new CToken();
	private CToken m_sof_token = new CToken();
	
	private CASTNode m_root;
	private CASTNode m_scope;
	
	private List<CASTNode> m_scope_stack = new List<CASTNode>();
	
	// =================================================================
	//	Returns true if at the offset is beyond the end of tokens.
	// =================================================================
	private bool EndOfTokens(int offset = 0)
	{
		return m_token_offset + offset >= <int>m_context.GetTokenList().Count();
	}

	// =================================================================
	//	Advances the token stream and returns the next token.
	// =================================================================
	private CToken NextToken()
	{
		if (EndOfTokens())
		{
			return m_eof_token;
		}

		CToken token = m_context.GetTokenList().GetIndex(m_token_offset);
		m_token_offset++;

		return token;
	}

	// =================================================================
	//	Returns a token at an offset ahead in the stream.
	// =================================================================
	private CToken LookAheadToken(int offset = 1)
	{
		offset--;

		if (EndOfTokens(offset))
		{
			return m_eof_token;
		}

		return m_context.GetTokenList().GetIndex(m_token_offset + offset);
	}

	// =================================================================
	//	Returns current token in the stream.
	// =================================================================
	private CToken CurrentToken()
	{
		return m_context.GetTokenList().GetIndex(m_token_offset - 1);
	}

	// =================================================================
	//	Returns previous token in the stream.
	// =================================================================
	private CToken PreviousToken()
	{
		if (m_token_offset < 2)
		{
			return m_sof_token;
		}

		return m_context.GetTokenList().GetIndex(m_token_offset - 2);
	}

	// =================================================================
	//	Advances the token stream and throws an error if the next
	//	token is not what was expected.
	// =================================================================
	private CToken ExpectToken(TokenIdentifier type)
	{
		CToken token = NextToken();
		if (token.Type != type)
		{
			m_context.FatalError("Unexpected token '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
		}
		return token;
	}

	// =================================================================
	//	Rewinds the token stream by the given amount.
	// =================================================================
	private void RewindStream(int offset = 1)
	{
		m_token_offset -= offset;
	}

	// =================================================================
	//	Pushs a scope onto the stack.
	// =================================================================
	private void PushScope(CASTNode node)
	{
		m_scope_stack.AddLast(m_scope);
		m_scope = node;
	}

	// =================================================================
	//	Pops a scope off the scope stack.
	// =================================================================
	private void PopScope()
	{
		m_scope = m_scope_stack.GetIndex(m_scope_stack.Count() - 1);
		m_scope_stack.RemoveLast();
	}

	// =================================================================
	//	Retrieves the current scope.
	// =================================================================
	private CASTNode CurrentScope()
	{
		return m_scope;
	}
	
	// =================================================================
	//	Looks ahead in the token stream to see if we have a 
	//	generic list following.
	// =================================================================
	private bool IsGenericTypeListFollowing(int final_token_offset)
	{
		if (LookAheadToken().Type != TokenIdentifier.OP_LESS)
		{
			return false;
		}

		int  lookAheadIndex = 2;
		int  depth = 1;
		bool isGeneric = false;

		// Keep reading till we get to the end of our potential "generic type list"
		while (EndOfTokens(lookAheadIndex) == false && 
				lookAheadIndex < 32)
		{
			CToken lat = LookAheadToken(lookAheadIndex);
			if (lat.Type == TokenIdentifier.OP_LESS)
			{
				depth++;
			}
			else if (lat.Type == TokenIdentifier.OP_GREATER)
			{
				depth--;
				if (depth <= 0)
				{
					break;
				}
			}
			else if (lat.Type == TokenIdentifier.OP_SHR)
			{
				depth -= 2;
				if (depth <= 0)
				{
					break;
				}
			}
			else if (lat.Type != TokenIdentifier.IDENTIFIER &&
						lat.Type != TokenIdentifier.KEYWORD_INT &&
						lat.Type != TokenIdentifier.KEYWORD_FLOAT &&
						lat.Type != TokenIdentifier.KEYWORD_STRING &&
						lat.Type != TokenIdentifier.KEYWORD_VOID)
			{
				break;
			}

			lookAheadIndex++;
		}

		if (depth <= 0)
		{
			final_token_offset = lookAheadIndex;
			return true;
		}

		return false;
	}
	
	// =================================================================
	//	Retrieves the current class scope.
	// =================================================================
	private CClassASTNode CurrentClassScope()
	{
		CASTNode scope = m_scope;

		while (scope != null)
		{
			CClassASTNode class_scope = scope as CClassASTNode;
			if (class_scope != null)
			{
				return class_scope;
			}
			scope = scope.Parent;
		}

		m_context.FatalError("Expecting to be inside class scope.", CurrentToken());
	}

	// =================================================================
	//	Retrieves the current class member scope.
	// =================================================================
	private CClassMemberASTNode CurrentClassMemberScope()
	{
		/*
		CASTNode scope = m_scope;

		while (scope != null)
		{
			CClassMemberASTNode class_scope = dynamic_cast<CClassMemberASTNode*>(scope);
			if (class_scope != null)
			{
				return class_scope;
			}
			scope = scope.Parent;
		}
		*/

		foreach (CASTNode iter in m_scope_stack)
		{		
			CClassMemberASTNode class_scope = iter as CClassMemberASTNode;
			if (class_scope != null)
			{
				return class_scope;
			}
		}

		m_context.FatalError("Expecting to be inside class member scope.", CurrentToken());
	}
	
	// =================================================================
	//	Parses a top-level statement. Using/Class/Etc
	// =================================================================
	private void ParseTopLevelStatement()
	{
		if (EndOfTokens())
		{
			return;
		}

		CToken token = NextToken();
		switch (token.Type)
		{
			// Using statement.
			case TokenIdentifier.KEYWORD_USING:
				{
					ParseUsingStatement();
					return;
				}

			// Class statement.
			case TokenIdentifier.KEYWORD_PUBLIC
			   , TokenIdentifier.KEYWORD_PRIVATE
			   , TokenIdentifier.KEYWORD_PROTECTED
			   , TokenIdentifier.KEYWORD_STATIC
			   , TokenIdentifier.KEYWORD_ABSTRACT
			   , TokenIdentifier.KEYWORD_INTERFACE
			   , TokenIdentifier.KEYWORD_CLASS
			   , TokenIdentifier.KEYWORD_ENUM:
				{
					ParseClassStatement();
					return;
				}

			// Dafuq?
			default:
				{
					m_context.FatalError("Unexpected token '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
					return;
				}
		}
	}
	
	// =================================================================
	//	Parses a using statement: using native|library|copy x.y.z;
	// =================================================================
	private void ParseUsingStatement()
	{
		bool path_is_dir = false;
		List<string> path_segments = new List<string>();
		CToken start_token = CurrentToken();
		int counter = 0;

		bool isNative	= false;
		bool isCopy		= false;
		bool isLibrary	= false;

		// We choosing a native file.
		if (LookAheadToken().Type == TokenIdentifier.KEYWORD_NATIVE)
		{
			ExpectToken(TokenIdentifier.KEYWORD_NATIVE);
			isNative = true;
		}

		// We copy file/dir?
		else if (LookAheadToken().Type == TokenIdentifier.KEYWORD_COPY)
		{
			ExpectToken(TokenIdentifier.KEYWORD_COPY);
			isCopy = true;
		}

		// Linking a library?
		else if (LookAheadToken().Type == TokenIdentifier.KEYWORD_LIBRARY)
		{
			ExpectToken(TokenIdentifier.KEYWORD_LIBRARY);
			isLibrary = true;
		}

		while (true)
		{
			if (counter > 0 && LookAheadToken().Type == TokenIdentifier.OP_MUL)
			{
				CToken token = ExpectToken(TokenIdentifier.OP_MUL);
				path_is_dir = true;

				break;
			}
			else
			{
				CToken token = NextToken();
				path_segments.AddLast(token.Literal);
			}

			counter++;

			if (LookAheadToken().Type != TokenIdentifier.SEMICOLON)
			{
				ExpectToken(TokenIdentifier.PERIOD);
			}
			else
			{
				break;
			}
		}

		ExpectToken(TokenIdentifier.SEMICOLON);

		// Compile into a relative file path.
		string path = "";
		string using_statement = "";
		for (int i = 0; i < path_segments.Count(); i++)
		{
			if (using_statement != "")
			{
				using_statement += ".";
			}
			using_statement += path_segments.GetIndex(i);
			path += "/" + path_segments.GetIndex(i);
		}

		// Try and file this file.
		string file_ext	 = m_context.GetCompiler().GetFileExtension();
		string package_path = m_context.GetCompiler().GetPackageDirectory();
		string local_path	 = Path.GetAbsolute(Path.StripFilename(m_context.GetFilePath()) + path);
		string remote_path	 = Path.GetAbsolute(package_path + path);
		string final_path	 = "";

		if (isNative == true)
		{
			file_ext = m_context.GetCompiler().GetProjectConfig().GetString("TRANSLATOR_NATIVE_FILE_EXTENSION");
		}
		if (isLibrary == true)
		{
			file_ext = m_context.GetCompiler().GetProjectConfig().GetString("TRANSLATOR_LIBRARY_FILE_EXTENSION");
		}
		if (isCopy == true)
		{
			file_ext = "";
		}

		// Referenced as a wildcard directory.
		if (path_is_dir == true)
		{
			// Local path?
			if (Directory.Exists(local_path))
			{
				final_path = local_path;
			}

			// Remote path?
			else if (Directory.Exists(remote_path))
			{
				final_path = remote_path;
			}

			// Dosen't exist?
			else
			{
				m_context.FatalError("Unable to find referenced directory '" + using_statement + "'.", start_token);
				return;
			}

			string[] files = Directory.List(final_path, DirectoryListType.Files);
			foreach (string iter in files)
			{
				string file_path = final_path + "/" + iter;	
			
				// Check extension.
				if (file_ext != "" && Path.ExtractExtension(file_path) != file_ext)
				{
					continue;
				}

				if (!m_context.AddUsingFile(file_path, isNative, isLibrary, isCopy))
				{
					m_context.Warning("Using statement imports duplicate file '" + file_path + "'.", start_token);
				}
			}
		}

		// Referenced as a file.
		else
		{
			string local_path_spec_ext   = local_path;
			local_path_spec_ext = local_path_spec_ext.Replace(local_path_spec_ext.LastIndexOf('/'), 1, ".");

			string remote_path_spec_ext  = remote_path;
			remote_path_spec_ext = remote_path_spec_ext.Replace(remote_path_spec_ext.LastIndexOf('/'), 1, ".");

			local_path += "." + file_ext;
			remote_path += "." + file_ext;

			// Local path?
			if (File.Exists(local_path))
			{
				final_path = local_path;
			}

			// Remote path?
			else if (File.Exists(remote_path))
			{
				final_path = remote_path;
			}

			// Local path with defined extension.
			else if (File.Exists(local_path_spec_ext))
			{
				final_path = local_path_spec_ext;
			}

			// Remote path with defined extension.
			else if (File.Exists(remote_path_spec_ext))
			{
				final_path = remote_path_spec_ext;
			}

			// Dosen't exist?
			else
			{
				m_context.FatalError("Unable to find referenced file '" + using_statement + "'.", start_token);
				return;
			}

			// Store the file.
			if (!m_context.AddUsingFile(final_path, isNative, isLibrary, isCopy))
			{
				m_context.Warning("Using statement imports duplicate file '" + final_path + "'.", start_token);
			}
		}
	}

	// =================================================================
	//	Parses a data type value.
	// =================================================================
	private CDataType ParseDataType(bool acceptArrays = true)
	{
		CToken token = NextToken();

		CDataType baseDataTypeNode = null;
	
		// Read in main data type.
		switch (token.Type)
		{
			case TokenIdentifier.KEYWORD_BOOL:
				{
					baseDataTypeNode = new CBoolDataType(token);
					break;
				}
			case TokenIdentifier.KEYWORD_VOID:
				{
					baseDataTypeNode = new CVoidDataType(token);
					break;
				}
			case TokenIdentifier.KEYWORD_INT:
				{
					baseDataTypeNode = new CIntDataType(token);
					break;
				}
			case TokenIdentifier.KEYWORD_FLOAT:
				{
					baseDataTypeNode = new CFloatDataType(token);
					break;
				}
			case TokenIdentifier.KEYWORD_STRING:
				{
					baseDataTypeNode = new CStringDataType(token);
					break;
				}
		//	case TokenIdentifier.KEYWORD_OBJECT:
			//	{
				//	baseDataTypeNode = new CIdentifierDataType(token, "object", List<CDataType*>());
					//break;
				//}
			case TokenIdentifier.IDENTIFIER:
				{	
					RewindStream();
					baseDataTypeNode = ParseIdentifierDataType();
					break;
				}
			default:
				{		
					m_context.FatalError("Unexpected token while parsing data type '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
					return null;
				}
		}
	
		// Read in array type.
		if (LookAheadToken(1).Type == TokenIdentifier.OPEN_BRACKET &&
			LookAheadToken(2).Type == TokenIdentifier.CLOSE_BRACKET &&
			acceptArrays == true)
		{
			ExpectToken(TokenIdentifier.OPEN_BRACKET);
			ExpectToken(TokenIdentifier.CLOSE_BRACKET);

			baseDataTypeNode = baseDataTypeNode.ArrayOf();

			while (LookAheadToken(1).Type == TokenIdentifier.OPEN_BRACKET &&
				   LookAheadToken(2).Type == TokenIdentifier.CLOSE_BRACKET)
			{
				baseDataTypeNode = baseDataTypeNode.ArrayOf();
	
				ExpectToken(TokenIdentifier.OPEN_BRACKET);
				ExpectToken(TokenIdentifier.CLOSE_BRACKET);
			}
		}

		return baseDataTypeNode;
	}

	// =================================================================
	//	Parses an identifier data type.
	// =================================================================
	private CIdentifierDataType ParseIdentifierDataType()
	{
		List<CDataType> generic_args = new List<CDataType>();

		CToken token = NextToken();

		if (token.Type != TokenIdentifier.IDENTIFIER)
		{
			m_context.FatalError("Unexpected token while parsing data type '" + token.Literal + "' (0x0x" + string.FromIntToHex(<int>token.Type) + ").", token);
		}

		// Read in generic type.
		if (LookAheadToken().Type == TokenIdentifier.OP_LESS)
		{
			ExpectToken(TokenIdentifier.OP_LESS);

			if (LookAheadToken().Type == TokenIdentifier.OP_GREATER ||
				LookAheadToken().Type == TokenIdentifier.OP_SHR)
			{
				m_context.FatalError("Generic classes must be declared one or more arguments.", token);
			}
		
			while (true)
			{
				generic_args.AddLast(ParseDataType());
			
				// We crack shift-right's: deals with cases like;
				// <float, test<int, float>>
				if (LookAheadToken().Type == TokenIdentifier.OP_SHR)
				{
					CToken tok = LookAheadToken() ;
					tok.Type = TokenIdentifier.OP_GREATER;
					tok.Literal = ">";

					CToken newtoken = tok;
					tok.Column++;

					m_context.GetTokenList().Insert(m_token_offset, newtoken);

					break;
				}
				else if (LookAheadToken().Type == TokenIdentifier.OP_GREATER)
				{
					break;
				}
				else
				{
					ExpectToken(TokenIdentifier.COMMA);
				}
			}

			ExpectToken(TokenIdentifier.OP_GREATER);
		}

		// Create and return identifier type. 
		// FIXME: Memory leak!
		return new CIdentifierDataType(token, token.Literal, generic_args);
	}
	
	// =================================================================
	//	Parses a class statement: public class XYZ { }
	// =================================================================
	private CClassASTNode ParseClassStatement()
	{
		CToken start_token = CurrentToken();
		CClassASTNode classNode = new CClassASTNode(CurrentScope(), start_token);

		// Read in all attributes.
		bool readAccessLevel = false;
		bool readingAttributes = true;	
		int attributeCount = 0;
		CToken token = start_token;

		while (readingAttributes)
		{
			switch (token.Type)
			{
				case TokenIdentifier.KEYWORD_PUBLIC:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classNode.ClassAccessLevel = AccessLevel.Public;
						readAccessLevel = false;
						break;
					}
			
				case TokenIdentifier.KEYWORD_PRIVATE:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classNode.ClassAccessLevel = AccessLevel.Private;
						readAccessLevel = false;
						break;
					}

				case TokenIdentifier.KEYWORD_PROTECTED:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classNode.ClassAccessLevel = AccessLevel.Protected;
						readAccessLevel = false;
						break;
					}

				case TokenIdentifier.KEYWORD_STATIC:
					{
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class cannot be declared as static.", token);
						}
						if (classNode.IsStatic == true)
						{						
							m_context.FatalError("Encountered duplicate static attribute.", token);
						}
					//	if (classNode.IsNative == true)
					//	{						
					//		m_context.FatalError("Native class cannot be declared as static.", token);
					//	}
						classNode.IsStatic = true;
						break;
					}

				case TokenIdentifier.KEYWORD_ABSTRACT:
					{
						if (classNode.IsStatic == true)
						{						
							m_context.FatalError("Static class cannot be declared as abstract.", token);
						}
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Encountered duplicate abstract attribute.", token);
						}
						if (classNode.IsNative == true)
						{						
							m_context.FatalError("Native class cannot be declared as abstract.", token);
						}
						classNode.IsAbstract = true;
						break;
					}

				case TokenIdentifier.KEYWORD_SEALED:
					{
						if (classNode.IsStatic == true)
						{						
							m_context.FatalError("Static class cannot be declared as sealed.", token);
						}
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class cannot be declared as sealed.", token);
						}
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class cannot be declared as sealed.", token);
						}
						classNode.IsSealed = true;
						break;
					}

				case TokenIdentifier.KEYWORD_NATIVE:
					{
					//	if (classNode.IsStatic == true)
					//	{						
					//		m_context.FatalError("Static class cannot be declared as native.", token);
					//	}
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class cannot be declared as native.", token);
						}
						if (classNode.IsNative == true)
						{						
							m_context.FatalError("Encountered duplicate native attribute.", token);
						}
						classNode.IsNative = true;

						ExpectToken(TokenIdentifier.OPEN_PARENT);
						classNode.MangledIdentifier = ExpectToken(TokenIdentifier.STRING_LITERAL).Literal;
						ExpectToken(TokenIdentifier.CLOSE_PARENT);

						break;
					}
				

				case TokenIdentifier.KEYWORD_BOX:
					{
						if (classNode.HasBoxClass == true)
						{						
							m_context.FatalError("Encountered duplicate box class attribute.", token);
						}

						ExpectToken(TokenIdentifier.OPEN_PARENT);
						classNode.HasBoxClass = true;
						classNode.BoxClassIdentifier = ExpectToken(TokenIdentifier.STRING_LITERAL).Literal;
						ExpectToken(TokenIdentifier.CLOSE_PARENT);

						break;
					}

				case TokenIdentifier.KEYWORD_INTERFACE:
					{
						if (classNode.IsStatic == true)
						{						
							m_context.FatalError("Interfaces cannot be declared as static.", token);
						}
						if (classNode.IsAbstract == true)
						{						
							m_context.FatalError("Interfaces cannot be declared as abstract.", token);
						}
						classNode.IsInterface = true;
						readingAttributes = false;
						break;
					}

				case TokenIdentifier.KEYWORD_ENUM:
					{
						if ((attributeCount > 0 && readAccessLevel == false) ||
							(attributeCount > 1 && readAccessLevel == true))
						{
							classNode.IsEnum = true;
							readingAttributes = false;
						}
						else
						{
							m_context.FatalError("Attributes cannot have any attributes applied except public/private/protected.", token);					
						}
						break;
					}

				case TokenIdentifier.KEYWORD_CLASS:
					{
						readingAttributes = false;
						break;
					}

				default:
					{
						m_context.FatalError("Unexpected token while parsing class attributes '" + token.Literal + "' (0x0x" + string.FromIntToHex(<int>token.Type) + ").", token);
						break;
					}
			}

			// Read in next attribute.
			if (readingAttributes == true)
			{
				token = NextToken();
				attributeCount++;
			}
		}
	
		// Read in the identifier.
		CToken ident_token = ExpectToken(TokenIdentifier.IDENTIFIER);
		classNode.Identifier = ident_token.Literal;
		classNode.Token = ident_token;

		// Enums and class are read entirely differently :3.
		if (classNode.IsEnum == true)
		{
			PushScope(classNode);

			CClassBodyASTNode body = new CClassBodyASTNode(CurrentScope(), CurrentToken());
			PushScope(body);

			classNode.Body = body;

			List<int> used_indexes = new List<int>();

			ExpectToken(TokenIdentifier.OPEN_BRACE);
			while (LookAheadToken().Type != TokenIdentifier.CLOSE_BRACE)
			{
				CToken tok = ExpectToken(TokenIdentifier.IDENTIFIER);

				CClassMemberASTNode member = new CClassMemberASTNode(CurrentScope(), tok);
				member.MemberAccessLevel = AccessLevel.Public;
				member.Identifier = tok.Literal;
				member.IsConst = true;
				member.IsStatic = true;
				member.MemberMemberType = MemberType.Field;
				member.ReturnType = new CIntDataType(tok);

				if (LookAheadToken().Type == TokenIdentifier.OP_ASSIGN)
				{
					NextToken();

					CToken lit = ExpectToken(TokenIdentifier.INT_LITERAL);
					int index = lit.Literal.ToInt();

					member.Assignment = new CExpressionASTNode(member, tok);
					member.Assignment.LeftValue = new CLiteralExpressionASTNode(member.Assignment, lit, member.ReturnType, lit.Literal);				

					used_indexes.AddLast(index);
				}
				else
				{
					int use_index = 1;

					while (true)
					{
						bool found = false;

						for (int i = 0; i < used_indexes.Count(); i++)
						{
							if (used_indexes.GetIndex(i) == use_index)
							{
								found = true;
								break;
							}
						}

						if (found == false)
						{
							break;
						}

						use_index++;
					}
				
					member.Assignment = new CExpressionASTNode(member, tok);
					member.Assignment.LeftValue = new CLiteralExpressionASTNode(member.Assignment, tok, member.ReturnType, <string>use_index);
					
					used_indexes.AddLast(use_index);
				}			
			
				if (LookAheadToken().Type == TokenIdentifier.COMMA)
				{
					NextToken();
				}
				else
				{
					break;
				}
			}
			ExpectToken(TokenIdentifier.CLOSE_BRACE);

			PopScope();
			PopScope();
		}
		else
		{
			// Read in generic tags.
			if (LookAheadToken().Type == TokenIdentifier.OP_LESS)
			{
			//	if (classNode.IsInterface == true)
			//	{
			//		m_context.FatalError("Interfaces cannot be generic.", token);
			//	}
			//	if (classNode.IsNative == true)
			//	{
			//		m_context.FatalError("Native classes cannot be generics.", token);
			//	}

				classNode.IsGeneric = true;

				PushScope(classNode);
				ExpectToken(TokenIdentifier.OP_LESS);

				while (true)
				{
					CToken generic_token = ExpectToken(TokenIdentifier.IDENTIFIER);
					classNode.GenericTypeTokens.AddLast(generic_token);

					if (LookAheadToken().Type == TokenIdentifier.OP_GREATER)
					{
						break;
					}
					else
					{
						ExpectToken(TokenIdentifier.COMMA);
					}
				}

				ExpectToken(TokenIdentifier.OP_GREATER);
				PopScope();
			}

			// Read in all inherited classes.
			if (LookAheadToken().Type == TokenIdentifier.COLON)
			{
				NextToken();
				PushScope(classNode);

				bool continueParsing = true;

				if (LookAheadToken().Type == TokenIdentifier.KEYWORD_NULL)
				{
					ExpectToken(TokenIdentifier.KEYWORD_NULL);

					classNode.InheritsNull = true;
					if (classNode.IsNative == false)
					{
						m_context.FatalError("Only native classes can inherit from null.", token);
					}
					if (classNode.IsInterface == true)
					{
						m_context.FatalError("Interfaces cannot inherit from null.", token);
					}

					continueParsing = false;
					if (LookAheadToken().Type == TokenIdentifier.COMMA)
					{
						continueParsing = true;
						ExpectToken(TokenIdentifier.COMMA);
					}
				}
		
				if (continueParsing == true)
				{
					while (true)
					{
						classNode.InheritedTypes.AddLast(ParseIdentifierDataType());
			
						if (LookAheadToken().Type == TokenIdentifier.COMMA)
						{
							NextToken();
						}
						else
						{
							break;
						}
					}
				}

				PopScope();
			}

			// Read in class block.
			ExpectToken(TokenIdentifier.OPEN_BRACE);

			PushScope(classNode);
			classNode.Body = ParseClassBody();
			PopScope();

			ExpectToken(TokenIdentifier.CLOSE_BRACE);
		}

		return classNode;
	}
	
	// =================================================================
	//	Parses statements contained in a class body.
	//	Does not deal with reading the { and } from the token stream.
	// =================================================================
	private CClassBodyASTNode ParseClassBody()
	{
		CClassBodyASTNode body = new CClassBodyASTNode(CurrentScope(), CurrentToken());
		PushScope(body);

		while (true)
		{
			CToken token = LookAheadToken();
			if (token.Type == TokenIdentifier.CLOSE_BRACE)
			{
				break;
			}
			else if (token.Type == TokenIdentifier.EndOfFile)
			{
				m_context.FatalError("Unexpected end-of-file, expecting closing brace.", token);
			}
			ParseClassBodyStatement();
		}

		PopScope();

		return body;
	}

	// =================================================================
	//	Parses a statement contained in a class body.
	// =================================================================
	private CASTNode ParseClassBodyStatement()
	{
		CToken token = NextToken();
		switch (token.Type)
		{
			// Empty Statement.
			case TokenIdentifier.SEMICOLON:
				{
					return null;
				}

			// Variable/Function statement.
			case TokenIdentifier.KEYWORD_PUBLIC
			   , TokenIdentifier.KEYWORD_PRIVATE
			   , TokenIdentifier.KEYWORD_PROTECTED
			   , TokenIdentifier.KEYWORD_STATIC
			   , TokenIdentifier.KEYWORD_ABSTRACT
			   , TokenIdentifier.KEYWORD_VIRTUAL
			   , TokenIdentifier.KEYWORD_CONST

	//		   , TokenIdentifier.KEYWORD_OBJECT
			   , TokenIdentifier.KEYWORD_BOOL
			   , TokenIdentifier.KEYWORD_VOID
			//   , TokenIdentifier.KEYWORD_BYTE
			//   , TokenIdentifier.KEYWORD_SHORT
			   , TokenIdentifier.KEYWORD_INT
			//   , TokenIdentifier.KEYWORD_LONG
			   , TokenIdentifier.KEYWORD_FLOAT
			//   , TokenIdentifier.KEYWORD_DOUBLE
			   , TokenIdentifier.KEYWORD_STRING
			   , TokenIdentifier.IDENTIFIER
			   , TokenIdentifier.OP_NOT:
				{
					return ParseClassMemberStatement();
				}

			// Dafuq?
			default:
				{
					m_context.FatalError("Unexpected token '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
				}
		}

		return null;
	}
	
	// =================================================================
	//	Parses a statement that can either be a member or a method.
	// =================================================================
	private CClassMemberASTNode ParseClassMemberStatement()
	{
		CToken start_token = CurrentToken();
		CClassASTNode classScope = CurrentClassScope();
		CClassMemberASTNode classMemberNode = new CClassMemberASTNode(CurrentScope(), start_token);

		// Read in all attributes.
		bool readAccessLevel = false;
		bool readingAttributes = true;	
		CToken token = start_token;

		while (readingAttributes)
		{
			switch (token.Type)
			{
				case TokenIdentifier.KEYWORD_PUBLIC:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classMemberNode.MemberAccessLevel = AccessLevel.Public;
						readAccessLevel = false;
						break;
					}
			
				case TokenIdentifier.KEYWORD_PRIVATE:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classMemberNode.MemberAccessLevel = AccessLevel.Private;
						readAccessLevel = false;
						break;
					}
				
				case TokenIdentifier.KEYWORD_PROTECTED:
					{
						if (readAccessLevel == true)
						{						
							m_context.FatalError("Encountered duplicate access level attribute.", token);
						}
						classMemberNode.MemberAccessLevel = AccessLevel.Protected;
						readAccessLevel = false;
						break;
					}

				case TokenIdentifier.KEYWORD_STATIC:
					{
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class member cannot be declared as static.", token);
						}
						if (classMemberNode.IsVirtual == true)
						{						
							m_context.FatalError("Virtual class member cannot be declared as static.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.Warning("Constant values are implicitly static, unneccessary static keyword.", token);
						}
						else if (classMemberNode.IsStatic == true)
						{						
							m_context.FatalError("Encountered duplicate static attribute.", token);
						}
						if (classMemberNode.IsOverride == true)
						{						
							m_context.FatalError("Overriden class member cannot be declared as static.", token);
						}
					//	if (classMemberNode.IsNative == true)
					//	{						
					//		m_context.FatalError("Native class member cannot be declared static.", token);
					//	}
						classMemberNode.IsStatic = true;
						break;
					}

				case TokenIdentifier.KEYWORD_ABSTRACT:
					{
						if (classMemberNode.IsStatic == true)
						{						
							m_context.FatalError("Static class member cannot be declared as abstract.", token);
						}
						if (classMemberNode.IsVirtual == true)
						{						
							m_context.FatalError("Virtual class member cannot be declared as abstract.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.FatalError("Const class member cannot be declared abstract.", token);
						}
						if (classMemberNode.IsNative == true)
						{						
							m_context.FatalError("Native class member cannot be declared abstract.", token);
						}
						if (classMemberNode.IsOverride == true)
						{						
							m_context.FatalError("Overriden class member cannot be declared as abstract.", token);
						}
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Encountered duplicate abstract attribute.", token);
						}
						classMemberNode.IsAbstract = true;
						classMemberNode.IsVirtual  = true;
						break;
					}

				case TokenIdentifier.KEYWORD_VIRTUAL:
					{
						if (classMemberNode.IsStatic == true)
						{						
							m_context.FatalError("Static class member cannot be declared as abstract.", token);
						}
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class member cannot be declared as virtual.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.FatalError("Const class member cannot be declared virtual.", token);
						}
						if (classMemberNode.IsOverride == true)
						{						
							m_context.Warning("Overriden class members are implicitly virtual, unneccessary virtual keyword.", token);
						}
						else if (classMemberNode.IsVirtual == true)
						{						
							m_context.FatalError("Encountered duplicate virtual attribute.", token);
						}
						classMemberNode.IsVirtual = true;
						break;
					}
				
				case TokenIdentifier.KEYWORD_CONST:
					{
						if (classMemberNode.IsStatic == true)
						{						
							m_context.Warning("Constant values are implicitly static, unneccessary static keyword.", token);
						}
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class member cannot be declared as const.", token);
						}
						if (classMemberNode.IsVirtual == true)
						{						
							m_context.FatalError("Virtual class member cannot be declared as const.", token);
						}
						if (classMemberNode.IsNative == true)
						{						
							m_context.FatalError("Native class member cannot be declared as const.", token);
						}
						if (classMemberNode.IsOverride == true)
						{						
							m_context.FatalError("Overriden class member cannot be declared as const.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.FatalError("Encountered duplicate const attribute.", token);
						}
						classMemberNode.IsStatic = true;
						classMemberNode.IsConst = true;
						break;
					}

				case TokenIdentifier.KEYWORD_NATIVE:
					{
					//	if (classMemberNode.IsStatic == true)
					//	{						
					//		m_context.FatalError("Static class member cannot be declared as native.", token);
					//	}
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class member cannot be declared as native.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.FatalError("Const class member cannot be declared as native.", token);
						}
					//	if (classMemberNode.IsOverride == true)
					//	{						
					//		m_context.FatalError("Overriden class member cannot be declared as native.", token);
					//	}
						if (classMemberNode.IsNative == true)
						{						
							m_context.FatalError("Encountered duplicate native attribute.", token);
						}

						ExpectToken(TokenIdentifier.OPEN_PARENT);
						classMemberNode.MangledIdentifier = ExpectToken(TokenIdentifier.STRING_LITERAL).Literal;
						ExpectToken(TokenIdentifier.CLOSE_PARENT);

						classMemberNode.IsNative = true;
						break;
					}
				
				case TokenIdentifier.KEYWORD_OVERRIDE:
					{
						if (classMemberNode.IsStatic == true)
						{						
							m_context.FatalError("Static class member cannot be declared as overidden.", token);
						}
						if (classMemberNode.IsAbstract == true)
						{						
							m_context.FatalError("Abstract class member cannot be declared as overidden.", token);
						}
						if (classMemberNode.IsConst == true)
						{						
							m_context.FatalError("Const class member cannot be declared as overidden.", token);
						}
					//	if (classMemberNode.IsNative == true)
					//	{						
					//		m_context.FatalError("Native class member cannot be declared as overidden.", token);
					//	}
						if (classMemberNode.IsOverride == true)
						{						
							m_context.FatalError("Encountered duplicate override attribute.", token);
						}

						classMemberNode.IsOverride = true;
						classMemberNode.IsVirtual = true;
						break;
					}

				case TokenIdentifier.KEYWORD_BOOL
				   , TokenIdentifier.KEYWORD_VOID
				   , TokenIdentifier.KEYWORD_INT
				   , TokenIdentifier.KEYWORD_FLOAT
				   , TokenIdentifier.KEYWORD_STRING
				   , TokenIdentifier.IDENTIFIER
				   , TokenIdentifier.OP_NOT:
					{
						RewindStream();
						readingAttributes = false;
						break;
					}

				default:
					{
						m_context.FatalError("Unexpected token while parsing class attributes '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
						break;
					}
			}

			// Read in next attribute.
			if (readingAttributes == true)
			{
				token = NextToken();
			}
		}
	
		// Read in the data type.
		CASTNode scope = CurrentScope();
		PushScope(classMemberNode);

		// Are we a constructor?
		CToken lookAhead = LookAheadToken();
		CToken lookAhead2 = LookAheadToken(2);

		if (lookAhead.Type == TokenIdentifier.IDENTIFIER &&
				 lookAhead.Literal == classScope.Identifier &&
				 lookAhead2.Type == TokenIdentifier.OPEN_PARENT)
		{
			if (classMemberNode.IsStatic == true)
			{
				m_context.FatalError("Constructors cannot be static.", CurrentToken());	
			}
			if (classMemberNode.IsAbstract == true)
			{
				m_context.FatalError("Constructors cannot be abstract.", CurrentToken());	
			}
			if (classMemberNode.IsVirtual == true)
			{
				m_context.FatalError("Constructors cannot be virtual.", CurrentToken());	
			}
			if (classMemberNode.IsOverride == true)
			{
				m_context.FatalError("Constructors cannot be overriden.", CurrentToken());	
			}

			ExpectToken(TokenIdentifier.IDENTIFIER);

			classMemberNode.Identifier = CurrentToken().Literal;
			classMemberNode.ReturnType = new CVoidDataType(CurrentToken());
			classMemberNode.IsConstructor = true;
		}
		else
		{
			classMemberNode.ReturnType = ParseDataType();

			ExpectToken(TokenIdentifier.IDENTIFIER);
			classMemberNode.Identifier = CurrentToken().Literal;
		}

		// Read in identifier.
		classMemberNode.MemberMemberType = MemberType.Field;

		// Read in arguments (if available).
		if (LookAheadToken().Type == TokenIdentifier.OPEN_PARENT)
		{
			ExpectToken(TokenIdentifier.OPEN_PARENT);
			ParseMethodArguments(classMemberNode);
			ExpectToken(TokenIdentifier.CLOSE_PARENT);

			classMemberNode.MemberMemberType = MemberType.Method;
		}
		else
		{		
			if (classMemberNode.IsAbstract == true)
			{
				m_context.FatalError("Class fields cannot be declared abstract.", CurrentToken());
			}
			if (classMemberNode.IsVirtual == true)
			{
				m_context.FatalError("Class fields cannot be declared virtual.", CurrentToken());
			}
			if (classMemberNode.IsOverride == true)
			{
				m_context.FatalError("Class fields cannot be declared as overridden.", CurrentToken());
			}
			if (CurrentClassScope().IsInterface == true)
			{
				m_context.FatalError("Interfaces can only contain method declarations.", CurrentToken());
			}
		}

		// Can't add non-native variables to native-classes.
		if (classMemberNode.MemberMemberType == MemberType.Field && classScope.IsNative == true && classMemberNode.IsNative == false && classMemberNode.IsStatic == false)
		{
			m_context.FatalError("Cannot insert non-native instance variable '" + classMemberNode.Identifier + "' into native class '" + classScope.Identifier + "'.", CurrentToken());
		}
		classMemberNode.IsExtension = (classScope.IsNative == true && classMemberNode.IsNative == false);

		// Read in equal value.
		if (classMemberNode.MemberMemberType == MemberType.Field &&
			LookAheadToken().Type == TokenIdentifier.OP_ASSIGN)
		{
			if (classMemberNode.IsNative == true)
			{
				m_context.FatalError("Native members cannot be assigned values.", CurrentToken());
			}

			ExpectToken(TokenIdentifier.OP_ASSIGN);

			if (classMemberNode.IsConst == true)
			{
				classMemberNode.Assignment = ParseConstExpr(false);
			}
			else
			{
				classMemberNode.Assignment = ParseExpr(false);
			}
		}
		else if (classMemberNode.MemberMemberType == MemberType.Field)
		{
			if (classMemberNode.IsConst == true)
			{
				m_context.FatalError("Constant member expects initialization expression.", CurrentToken());
			}
		}

		// Read in block.
		if (classMemberNode.MemberMemberType == MemberType.Method &&
			LookAheadToken().Type == TokenIdentifier.OPEN_BRACE)
		{
			if (CurrentClassScope().IsInterface == true)
			{
				m_context.FatalError("Interface methods cannot have bodies.", CurrentToken());
			}
			if (classMemberNode.IsNative == true)
			{
				m_context.FatalError("Native methods cannot have bodies.", CurrentToken());
			}

			ExpectToken(TokenIdentifier.OPEN_BRACE);

			classMemberNode.Body = ParseMethodBody();

			ExpectToken(TokenIdentifier.CLOSE_BRACE);
		}
		else
		{
			// Check if body etc is correct.
			if (classMemberNode.MemberMemberType == MemberType.Method &&
				classMemberNode.IsAbstract == false &&
				CurrentClassScope().IsInterface == false &&
				CurrentClassScope().IsNative == false)
			{
				m_context.FatalError("Expecting method body declaration.", CurrentToken());
			}

			ExpectToken(TokenIdentifier.SEMICOLON);
		}

		PopScope();

		return classMemberNode;
	}

	// =================================================================
	//	Parses an argument declaration list: (int x, float y, bool z)
	//	Opening and closing parenthesis are not read.
	// =================================================================
	private void ParseMethodArguments(CClassMemberASTNode method)
	{
		while (LookAheadToken().Type != TokenIdentifier.CLOSE_PARENT)
		{
			CVariableStatementASTNode argumentNode = new CVariableStatementASTNode(CurrentScope(), CurrentToken());
			method.Arguments.AddLast(argumentNode);

			PushScope(argumentNode);

			// Parse datatype.
			argumentNode.Type = ParseDataType();

			// Parse identifier.
			argumentNode.Identifier = ExpectToken(TokenIdentifier.IDENTIFIER).Literal;
			argumentNode.Token = CurrentToken();
			argumentNode.IsParameter = true;
		
			// Read in equal value.
			if (LookAheadToken().Type == TokenIdentifier.OP_ASSIGN)
			{
				ExpectToken(TokenIdentifier.OP_ASSIGN);
				argumentNode.AssignmentExpression = ParseConstExpr(false, true);
			}

			PopScope();

			if (LookAheadToken().Type == TokenIdentifier.CLOSE_PARENT)
			{
				break;
			}
			else
			{
				ExpectToken(TokenIdentifier.COMMA);
			}
		}
	}

	// =================================================================
	//	Parses statements in a method block.
	// =================================================================
	private CMethodBodyASTNode ParseMethodBody()
	{
		CMethodBodyASTNode body = new CMethodBodyASTNode(CurrentScope(), CurrentToken());
		PushScope(body);

		while (true)
		{
			CToken token = LookAheadToken();
			if (token.Type == TokenIdentifier.CLOSE_BRACE)
			{
				break;
			}
			else if (token.Type == TokenIdentifier.EndOfFile)
			{
				m_context.FatalError("Unexpected end-of-file, expecting closing brace.", token);
			}
			ParseMethodBodyStatement();
		}

		PopScope();

		return body;
	}

	// =================================================================
	//	Parses a single statement from a method body.
	// =================================================================
	private CASTNode ParseMethodBodyStatement()
	{
		CToken token = NextToken();
		switch (token.Type)
		{
			// Empty Statement.
			case TokenIdentifier.SEMICOLON:
				{
					// Return empty block.
					return new CBlockStatementASTNode(CurrentScope(), CurrentToken());;
				}

			// Block Statement.
			case TokenIdentifier.OPEN_BRACE:
				{
					RewindStream();
					return ParseBlockStatement();
				}

			// Flow of control statements.
			case TokenIdentifier.KEYWORD_IF:
				{
					return ParseIfStatement();
				}
			case TokenIdentifier.KEYWORD_WHILE:
				{
					return ParseWhileStatement();
				}
			case TokenIdentifier.KEYWORD_BREAK:
				{
					return ParseBreakStatement();
				}
			case TokenIdentifier.KEYWORD_CONTINUE:
				{
					return ParseContinueStatement();
				}
			case TokenIdentifier.KEYWORD_RETURN:
				{
					return ParseReturnStatement();
				}
			case TokenIdentifier.KEYWORD_DO:
				{
					return ParseDoStatement();
				}
			case TokenIdentifier.KEYWORD_SWITCH:
				{
					return ParseSwitchStatement();
				}
			case TokenIdentifier.KEYWORD_FOR:
				{
					return ParseForStatement();
				}
			case TokenIdentifier.KEYWORD_FOREACH:
				{
					return ParseForEachStatement();
				}
			case TokenIdentifier.KEYWORD_TRY:
				{
					return ParseTryStatement();
				}
			case TokenIdentifier.KEYWORD_THROW:
				{
					return ParseThrowStatement();
				}

			// No const or static declarations in method!
			case TokenIdentifier.KEYWORD_STATIC:
				{
					m_context.FatalError("Static declarations are not permitted in a methods body. Please put static declarations in the class body instead.", token);
				}
			case TokenIdentifier.KEYWORD_CONST:
				{
					m_context.FatalError("Constant declarations are not permitted in a methods body. Please put constant declarations in the class body instead.", token);
				}

			// Local variable declaration.		
			case TokenIdentifier.KEYWORD_BOOL
			   , TokenIdentifier.KEYWORD_VOID
			   , TokenIdentifier.KEYWORD_INT
			   , TokenIdentifier.KEYWORD_FLOAT
			   , TokenIdentifier.KEYWORD_STRING
			   , TokenIdentifier.IDENTIFIER:
				{
					// If what follows is another identifier or a template specification
					// then we are dealign with a variable declaration.
					if (LookAheadToken().Type == TokenIdentifier.OPEN_BRACKET ||
						LookAheadToken().Type == TokenIdentifier.IDENTIFIER ||
						LookAheadToken().Type == TokenIdentifier.OP_LESS)
					{
						bool isVarDeclaration = true;

						// Check this is not a generic class reference, in which case, its an expression.
						if (LookAheadToken().Type == TokenIdentifier.OP_LESS)
						{		
							int final_token_offset = 0;
							if (IsGenericTypeListFollowing(final_token_offset) &&
								LookAheadToken(final_token_offset + 1).Type == TokenIdentifier.PERIOD)
							{
								isVarDeclaration = false;
							}
						}
						else
						{
							int la = 1;

							// Try and read array references.
							while (LookAheadToken(la).Type == TokenIdentifier.OPEN_BRACKET)
							{
								la++;
								if (LookAheadToken(la).Type != TokenIdentifier.CLOSE_BRACKET)
								{
									isVarDeclaration = false;
								}
								else
								{
									la++;
								}
							}

							// Is there an identifier ahead.
							if (isVarDeclaration == true)
							{
								if (LookAheadToken(la).Type != TokenIdentifier.IDENTIFIER)
								{
									isVarDeclaration = false;
								}
							}
						}

						if (isVarDeclaration == true)
						{
							RewindStream();
							CASTNode node_c = ParseLocalVariableStatement(true, true, true);
							ExpectToken(TokenIdentifier.SEMICOLON);
							return node_c;
						}
					}

					// Otherwise its a general expression.
					RewindStream();
					CASTNode node = ParseExpr(false);
					ExpectToken(TokenIdentifier.SEMICOLON);
					return node;
				}

			// If its nothing else its an expression.
			default:
				{				
					RewindStream();
					CASTNode node = ParseExpr(false);
					ExpectToken(TokenIdentifier.SEMICOLON);
					return node;
				}
		}

		return null;
	}
	
	// =================================================================
	//	Parses an if statement; if (x > y) { } else { }
	// =================================================================
	private CIfStatementASTNode ParseIfStatement()
	{
		CIfStatementASTNode node = new CIfStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);

		ExpectToken(TokenIdentifier.OPEN_PARENT);	
		node.ExpressionStatement = ParseExpr(false);
		ExpectToken(TokenIdentifier.CLOSE_PARENT);

		node.BodyStatement = ParseMethodBodyStatement();

		if (LookAheadToken().Type == TokenIdentifier.KEYWORD_ELSE)
		{
			NextToken();
			node.ElseStatement = ParseMethodBodyStatement();
		}

		PopScope();

		return node;
	}

	// =================================================================
	//	Parses a block statement.
	// =================================================================
	private CBlockStatementASTNode ParseBlockStatement()
	{
		CBlockStatementASTNode node = new CBlockStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);

		ExpectToken(TokenIdentifier.OPEN_BRACE);	

		while (true)
		{
			CToken token = LookAheadToken();
			if (token.Type == TokenIdentifier.CLOSE_BRACE)
			{
				break;
			}
			else if (token.Type == TokenIdentifier.EndOfFile)
			{
				m_context.FatalError("Unexpected end-of-file, expecting closing brace.", token);
			}
			ParseMethodBodyStatement();
		}

		ExpectToken(TokenIdentifier.CLOSE_BRACE);

		PopScope();
		return node;
	}
	
	// =================================================================
	//	Parses a while statement; while (x > y) { } else 
	// =================================================================
	private CWhileStatementASTNode ParseWhileStatement()
	{
		CWhileStatementASTNode node = new CWhileStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);

		ExpectToken(TokenIdentifier.OPEN_PARENT);	
		node.ExpressionStatement = ParseExpr(false);
		ExpectToken(TokenIdentifier.CLOSE_PARENT);

		node.BodyStatement = ParseMethodBodyStatement();

		PopScope();

		return node;
	}

	// =================================================================
	//	Parses a break statement; break;
	// =================================================================
	private CBreakStatementASTNode ParseBreakStatement()
	{
		CBreakStatementASTNode node = new CBreakStatementASTNode(CurrentScope(), CurrentToken());
		ExpectToken(TokenIdentifier.SEMICOLON);
		return node;
	}

	// =================================================================
	//	Parses a return statement; return;
	// =================================================================
	private CReturnStatementASTNode ParseReturnStatement()
	{
		CReturnStatementASTNode node = new CReturnStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);

		if (LookAheadToken().Type != TokenIdentifier.SEMICOLON)
		{
			node.ReturnExpression = ParseExpr(false);
		}
	
		ExpectToken(TokenIdentifier.SEMICOLON);	

		PopScope();
		return node;
	}

	// =================================================================
	//	Parses a continue statement; continue;
	// =================================================================
	private CContinueStatementASTNode ParseContinueStatement()
	{
		CContinueStatementASTNode node = new CContinueStatementASTNode(CurrentScope(), CurrentToken());
		ExpectToken(TokenIdentifier.SEMICOLON);
		return node;
	}

	// =================================================================
	//	Parses a do statement; do { } while (x < y) 
	// =================================================================
	private CDoStatementASTNode ParseDoStatement()
	{
		CDoStatementASTNode node = new CDoStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);
	
		node.BodyStatement = ParseMethodBodyStatement();

		if (LookAheadToken().Type == TokenIdentifier.KEYWORD_WHILE)
		{
			ExpectToken(TokenIdentifier.KEYWORD_WHILE);	
			ExpectToken(TokenIdentifier.OPEN_PARENT);	
			node.ExpressionStatement = ParseExpr(false);
			ExpectToken(TokenIdentifier.CLOSE_PARENT);
		}

		PopScope();

		return node;
	}

	// =================================================================
	//	Parses a switch statement.
	// =================================================================
	private CSwitchStatementASTNode ParseSwitchStatement()
	{
		CSwitchStatementASTNode node = new CSwitchStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);
	
		ExpectToken(TokenIdentifier.OPEN_PARENT);	
		node.ExpressionStatement = ParseExpr(false, true);
		ExpectToken(TokenIdentifier.CLOSE_PARENT);

		ExpectToken(TokenIdentifier.OPEN_BRACE);

		bool parsing = true;
		bool parsedCase = false;
		bool parsedDefault = false;
		while (parsing)
		{
			CToken token = LookAheadToken();
			switch (token.Type)
			{
				case TokenIdentifier.KEYWORD_CASE:
					{
						ExpectToken(TokenIdentifier.KEYWORD_CASE);

						parsedCase = true;
						if (parsedDefault == true)
						{
							m_context.FatalError("Encounted case block after default block. Default block must be last.", token);
						}

						CCaseStatementASTNode caseNode = new CCaseStatementASTNode(CurrentScope(), CurrentToken());
						PushScope(caseNode);
					
						while (true)
						{
							CExpressionASTNode node_b = ParseExpr(false, true);
							if (node_b != null)
							{
								caseNode.Expressions.AddLast(node_b);
							}
						
							if (LookAheadToken().Type == TokenIdentifier.COLON)
							{
								break;
							}
							else
							{
								ExpectToken(TokenIdentifier.COMMA);
							}
						}
						ExpectToken(TokenIdentifier.COLON);

						if (LookAheadToken().Type == TokenIdentifier.KEYWORD_CASE)
						{
							m_context.FatalError("Case blocks cannot fall-through. Use commas to seperate expressions in a single case statement instead.", token);
						}

						caseNode.BodyStatement = ParseMethodBodyStatement();

						PopScope();
						break;
					}
				case TokenIdentifier.KEYWORD_DEFAULT:
					{
						ExpectToken(TokenIdentifier.KEYWORD_DEFAULT);

						if (parsedCase == false)
						{
							m_context.Warning("Encounted default block without any case blocks. Empty switch statement?", token);
						}
						if (parsedDefault == true)
						{
							m_context.FatalError("Encounted duplicate default block in switch statement.", token);
						}
						parsedDefault = true;

						CDefaultStatementASTNode defaultNode = new CDefaultStatementASTNode(CurrentScope(), CurrentToken());
						PushScope(defaultNode);
					
						ExpectToken(TokenIdentifier.COLON);
					
						if (LookAheadToken().Type == TokenIdentifier.CLOSE_BRACE)
						{
							m_context.FatalError("Default blocks cannot be empty.", token);
						}

						defaultNode.BodyStatement = ParseMethodBodyStatement();

						PopScope();
						break;
					}
				case TokenIdentifier.CLOSE_BRACE:
					{
						parsing = false;
						break;
					}
				case TokenIdentifier.EndOfFile:
					{
						m_context.FatalError("Unexpected end-of-file, expecting closing brace.", token);
						break;
					}
				default:
					{	
						m_context.FatalError("Unexpected token '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);
						break;
					}
			}
		}
		ExpectToken(TokenIdentifier.CLOSE_BRACE);

		PopScope();
		return node;
	}

	// =================================================================
	//	Parses a for statement.
	// =================================================================
	private CForStatementASTNode ParseForStatement()
	{
		CBlockStatementASTNode outer_block = new CBlockStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(outer_block);

		CForStatementASTNode node = new CForStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);

		ExpectToken(TokenIdentifier.OPEN_PARENT);	

		if (LookAheadToken().Type != TokenIdentifier.SEMICOLON)
		{
			node.InitialStatement = ParseMethodBodyStatement();
		}
		else
		{
			ExpectToken(TokenIdentifier.SEMICOLON);	
		}

		if (LookAheadToken().Type != TokenIdentifier.SEMICOLON)
		{
			node.ConditionExpression = ParseExpr(false);
		}
		ExpectToken(TokenIdentifier.SEMICOLON);	

		if (LookAheadToken().Type != TokenIdentifier.CLOSE_PARENT)
		{
			node.IncrementExpression = ParseExpr(false);
		}

		ExpectToken(TokenIdentifier.CLOSE_PARENT);	

		node.BodyStatement = ParseMethodBodyStatement();

		PopScope();
		PopScope();

		return node;
	}

	// =================================================================
	//	Parses a foreach statement.
	// =================================================================
	private CForEachStatementASTNode ParseForEachStatement()
	{
		CBlockStatementASTNode outer_block = new CBlockStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(outer_block);

		CForEachStatementASTNode node = new CForEachStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);
	
		ExpectToken(TokenIdentifier.OPEN_PARENT);		

		CToken token = NextToken();
		if (/*token.Type == TokenIdentifier.KEYWORD_OBJECT ||*/
			token.Type == TokenIdentifier.KEYWORD_BOOL ||
			token.Type == TokenIdentifier.KEYWORD_VOID ||
			//token.Type == TokenIdentifier.KEYWORD_BYTE ||
			//token.Type == TokenIdentifier.KEYWORD_SHORT ||
			token.Type == TokenIdentifier.KEYWORD_INT ||
			//token.Type == TokenIdentifier.KEYWORD_LONG ||
			token.Type == TokenIdentifier.KEYWORD_FLOAT ||
			//token.Type == TokenIdentifier.KEYWORD_DOUBLE ||
			token.Type == TokenIdentifier.KEYWORD_STRING ||
			token.Type == TokenIdentifier.IDENTIFIER)
		{
			bool isVarDeclaration = false;

			// If what follows is another identifier or a template specification
			// then we are dealign with a variable declaration.
			if (LookAheadToken().Type == TokenIdentifier.OPEN_BRACKET ||
				LookAheadToken().Type == TokenIdentifier.IDENTIFIER ||
				LookAheadToken().Type == TokenIdentifier.OP_LESS)
			{
				isVarDeclaration = true;

				// Check this is not a generic class reference, in which case, its an expression.
				if (LookAheadToken().Type == TokenIdentifier.OP_LESS)
				{		
					int final_token_offset = 0;
					if (IsGenericTypeListFollowing(final_token_offset) &&
						LookAheadToken(final_token_offset + 1).Type == TokenIdentifier.PERIOD)
					{
						isVarDeclaration = false;
					}
				}
				else
				{
					int la = 1;

					// Try and read array references.
					while (LookAheadToken(la).Type == TokenIdentifier.OPEN_BRACKET)
					{
						la++;
						if (LookAheadToken(la).Type != TokenIdentifier.CLOSE_BRACKET)
						{
							isVarDeclaration = false;
						}
						else
						{
							la++;
						}
					}

					// Is there an identifier ahead.
					if (isVarDeclaration == true)
					{
						if (LookAheadToken(la).Type != TokenIdentifier.IDENTIFIER)
						{
							isVarDeclaration = false;
						}
					}
				}

				if (isVarDeclaration == true)
				{
					RewindStream();
					node.VariableStatement = ParseLocalVariableStatement(true, true, true);
				}
			}

			// Otherwise its a general expression.
			if (isVarDeclaration == false)
			{
				RewindStream();
				node.VariableStatement = ParseExpr(false);
			}
		}
		else
		{
			m_context.FatalError("Unexpected token '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + "), expecting expression or variable declaration.", token);
		}

		ExpectToken(TokenIdentifier.KEYWORD_IN);	
		node.ExpressionStatement = ParseExpr(false);
		ExpectToken(TokenIdentifier.CLOSE_PARENT);
	
		node.BodyStatement = ParseMethodBodyStatement();

		PopScope();
		PopScope();

		return node;
	}

	// =================================================================
	//	Parses a local variable statement..
	// =================================================================
	private CVariableStatementASTNode ParseLocalVariableStatement(bool acceptMultiple = true, bool acceptAssignment = true, bool acceptNonConstAssignment = true)
	{
		CToken start_token = CurrentToken();

		// Read in the data type.
		CDataType type = ParseDataType();
	
		CVariableStatementASTNode start_node = null;

		while (true)
		{
			CVariableStatementASTNode node = new CVariableStatementASTNode(CurrentScope(), start_token);
			node.Type = type;

			if (start_node == null)
			{
				start_node = node;
			}

			PushScope(node);

			// Read in identifier.
			node.Identifier = ExpectToken(TokenIdentifier.IDENTIFIER).Literal;
			node.Token = CurrentToken();

			// Read in equal value.
			if (acceptAssignment == true)
			{
				if (LookAheadToken().Type == TokenIdentifier.OP_ASSIGN)
				{
					ExpectToken(TokenIdentifier.OP_ASSIGN);

					if (acceptNonConstAssignment == true)
					{
						node.AssignmentExpression = ParseExpr(false);
					}
					else
					{
						node.AssignmentExpression = ParseConstExpr(false);
					}
				}
			}

			PopScope();

			if (LookAheadToken().Type == TokenIdentifier.COMMA && acceptMultiple == true)
			{
				ExpectToken(TokenIdentifier.COMMA);
			}
			else
			{
				break;
			}
		}

		return start_node;
	}

	// =================================================================
	//	Parses a try statement.
	// =================================================================
	private CTryStatementASTNode ParseTryStatement()
	{
		CTryStatementASTNode node = new CTryStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);
	
		node.BodyStatement = ParseBlockStatement();
	
		bool parsing = true;
		bool parsedCatch = false;
		bool parsedFinally = false;
		while (parsing)
		{
			CToken token = LookAheadToken();
			switch (token.Type)
			{
				case TokenIdentifier.KEYWORD_CATCH:
					{
						ExpectToken(TokenIdentifier.KEYWORD_CATCH);

						parsedCatch = true;
						if (parsedFinally == true)
						{
							m_context.FatalError("Encounted catch block after finally block. Finally block must be last.", token);
						}

						CCatchStatementASTNode catchNode = new CCatchStatementASTNode(CurrentScope(), CurrentToken());
						PushScope(catchNode);
					
						ExpectToken(TokenIdentifier.OPEN_PARENT);
						catchNode.VariableStatement = ParseLocalVariableStatement(false, false, false);
						ExpectToken(TokenIdentifier.CLOSE_PARENT);

						catchNode.BodyStatement = ParseBlockStatement();

						PopScope();
						break;
					}
				default:
					{
						parsing = false;
					}
			}
		}

		PopScope();
		return node;
	}

	// =================================================================
	//	Parses a throw statement.
	// =================================================================
	private CThrowStatementASTNode ParseThrowStatement()
	{
		CThrowStatementASTNode node = new CThrowStatementASTNode(CurrentScope(), CurrentToken());
		PushScope(node);
	
		node.Expression = ParseExpr(false);

		ExpectToken(TokenIdentifier.SEMICOLON);

		PopScope();
		return node;
	}
	
	// =================================================================
	//	Parses an array initialization list.
	//
	//	{ 1, 2, 3, 4, 5 }
	// =================================================================
	private CArrayInitializerASTNode ParseArrayInitializer()
	{
		ExpectToken(TokenIdentifier.OPEN_BRACE);

		CArrayInitializerASTNode node = new CArrayInitializerASTNode(null, CurrentToken());
		PushScope(node);

		while (true)
		{
			node.Expressions.AddLast(ParseExpr(false, true));

			if (LookAheadToken().Type != TokenIdentifier.COMMA)
			{
				break;
			}
			ExpectToken(TokenIdentifier.COMMA);
		}

		PopScope();
		ExpectToken(TokenIdentifier.CLOSE_BRACE);

		return node;
	}
	
	// =================================================================
	//	Parses an expression.
	// =================================================================	
	private CExpressionASTNode ParseExpr(bool useNullScope, bool noSequencePoints = false)
	{
		CASTNode lvalue = 
			noSequencePoints == true ?
			ParseExprAssignment() :
			ParseExprComma();

		if (lvalue != null)
		{
			CExpressionASTNode node = new CExpressionASTNode(useNullScope == true ? null : CurrentScope(), CurrentToken());
			node.LeftValue = lvalue;
			node.AddChild(lvalue);
			return node;
		}
		else
		{
			m_context.FatalError("Expected an expression.", CurrentToken());
		}

		return null;
	}

	// =================================================================
	//	Parses a constant expression.
	// =================================================================	
	private CExpressionASTNode ParseConstExpr(bool useNullScope, bool noSequencePoints = false)
	{
		CASTNode lvalue = 
			noSequencePoints == true ?
			ParseExprAssignment() :
			ParseExprComma();

		if (lvalue != null)
		{
			CExpressionASTNode node = new CExpressionASTNode(useNullScope == true ? null : CurrentScope(), CurrentToken());
			node.IsConstant = true;
			node.LeftValue = lvalue;
			node.AddChild(lvalue);
			return node;
		}
		else
		{
			m_context.FatalError("Expected an expression.", CurrentToken());
		}

		return null;
	}
	
	// =================================================================
	//	Parses a comma expression.
	//		x += 3, z += 5
	// =================================================================	
	private CASTNode ParseExprComma()
	{
		CASTNode lvalue = ParseExprAssignment();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.COMMA)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprAssignment();

			// Create operator node.
			CCommaExpressionASTNode node = new CCommaExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);

			lvalue = node;
		}

		return lvalue;
	}
	
	// =================================================================
	//	Parses an assignment expression.
	//		<<=
	//		>>=
	//		~=
	//		^=
	//		|=
	//		&=
	//		%=
	//		/=
	//		*=
	//		-=
	//		+=
	//		=
	// =================================================================	
	private CASTNode ParseExprAssignment()
	{
		CASTNode lvalue = ParseExprTernary();

		// Operator next?
		CToken op = LookAheadToken();
		if (op.Type != TokenIdentifier.OP_ASSIGN &&
			op.Type != TokenIdentifier.OP_ASSIGN_SUB &&
			op.Type != TokenIdentifier.OP_ASSIGN_ADD &&
			op.Type != TokenIdentifier.OP_ASSIGN_MUL &&
			op.Type != TokenIdentifier.OP_ASSIGN_DIV &&
			op.Type != TokenIdentifier.OP_ASSIGN_MOD &&
			op.Type != TokenIdentifier.OP_ASSIGN_AND &&
			op.Type != TokenIdentifier.OP_ASSIGN_OR  &&
			op.Type != TokenIdentifier.OP_ASSIGN_XOR &&
			op.Type != TokenIdentifier.OP_ASSIGN_SHL &&
			op.Type != TokenIdentifier.OP_ASSIGN_SHR)
		{
			return lvalue;
		}
		NextToken();

		// Create and parse operator
		CASTNode rvalue = ParseExprTernary();

		// Create operator node.
		CAssignmentExpressionASTNode node = new CAssignmentExpressionASTNode(null, op);
		node.LeftValue = lvalue;
		node.RightValue = rvalue;
		node.AddChild(lvalue);
		node.AddChild(rvalue);

		return node;
	}

	// =================================================================
	//	Parses a ternary expression.
	//		expr ? expr : expr
	// =================================================================
	private CASTNode ParseExprTernary()
	{
		CASTNode lvalue = ParseExprLogical();

		// Operator next?
		CToken op = LookAheadToken();
		if (op.Type != TokenIdentifier.OP_TERNARY)
		{
			return lvalue;
		}
		NextToken();

		// Create and parse operator
		CASTNode rvalue = ParseExpr(true, true);
		ExpectToken(TokenIdentifier.COLON);
		CASTNode rrvalue = ParseExpr(true, true);

		// Create operator node.
		CTernaryExpressionASTNode node = new CTernaryExpressionASTNode(null, op);
		node.Expression	= lvalue;
		node.LeftValue		= rvalue;
		node.RightValue	= rrvalue;

		node.AddChild(lvalue);
		node.AddChild(rvalue);
		node.AddChild(rrvalue);

		return node;
	}

	// =================================================================
	//	Parses a logical expression.
	//		&&
	//		||
	// =================================================================	
	private CASTNode ParseExprLogical()
	{
		CASTNode lvalue = ParseExprIsAs();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_LOGICAL_AND &&
				op.Type != TokenIdentifier.OP_LOGICAL_OR)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprIsAs();

			// Create operator node.
			CLogicalExpressionASTNode node = new CLogicalExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);

			lvalue = node;
		}

		return lvalue;
	}
	
	// =================================================================
	//	Parses an is/as expression.
	//		x is y
	//		y as x
	// =================================================================	
	private CASTNode ParseExprIsAs()
	{
		CASTNode lvalue = ParseExprBitwise();

		// Operator next?
		CToken op = LookAheadToken();
		if (op.Type != TokenIdentifier.KEYWORD_IS &&
			op.Type != TokenIdentifier.KEYWORD_AS)
		{
			return lvalue;
		}
		NextToken();

		// Create and parse operator
		CDataType rvalue = ParseDataType();

		// Create operator node.
		CTypeExpressionASTNode node = new CTypeExpressionASTNode(null, op);
		node.Type = rvalue;
		node.LeftValue = lvalue;
		node.AddChild(lvalue);

		return node;
	}

	// =================================================================
	//	Parses a bitwise expression.
	//		&
	//		^
	//		|
	// =================================================================	
	private CASTNode ParseExprBitwise()
	{
		CASTNode lvalue = ParseExprCompare();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_AND &&
				op.Type != TokenIdentifier.OP_OR &&
				op.Type != TokenIdentifier.OP_XOR &&
				op.Type != TokenIdentifier.OP_SHL &&
				op.Type != TokenIdentifier.OP_SHR)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprCompare();

			// Create operator node.
			CBinaryMathExpressionASTNode node = new CBinaryMathExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);

			lvalue = node;
		}
	
		return lvalue;
	}

	// =================================================================
	//	Parses a comparison expression.
	//		==
	//		!=
	//		<=
	//		>=
	//		<
	//		>
	// =================================================================	
	private CASTNode ParseExprCompare()
	{
		CASTNode lvalue = ParseExprAddSub();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_LESS &&
				op.Type != TokenIdentifier.OP_LESS_EQUAL &&
				op.Type != TokenIdentifier.OP_GREATER &&
				op.Type != TokenIdentifier.OP_GREATER_EQUAL &&
				op.Type != TokenIdentifier.OP_EQUAL &&
				op.Type != TokenIdentifier.OP_NOT_EQUAL)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprAddSub();

			// Create operator node.
			CComparisonExpressionASTNode node = new CComparisonExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);
	
			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a add/sub expression.
	//		+
	//		-
	// =================================================================	
	private CASTNode ParseExprAddSub()
	{
		CASTNode lvalue = ParseExprMulDiv();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_ADD &&
				op.Type != TokenIdentifier.OP_SUB)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprMulDiv();

			// Create operator node.
			CBinaryMathExpressionASTNode node = new CBinaryMathExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);
	
			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a mul/div/mod expression.
	//		*
	//		/
	//		%
	// =================================================================	
	private CASTNode ParseExprMulDiv()
	{
		CASTNode lvalue = ParseExprPrefix();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_MUL &&
				op.Type != TokenIdentifier.OP_MOD &&
				op.Type != TokenIdentifier.OP_DIV)
			{
				return lvalue;
			}
			NextToken();

			// Create and parse operator
			CASTNode rvalue = ParseExprPrefix();

			// Create operator node.
			CBinaryMathExpressionASTNode node = new CBinaryMathExpressionASTNode(null, op);
			node.LeftValue = lvalue;
			node.RightValue = rvalue;
			node.AddChild(lvalue);
			node.AddChild(rvalue);

			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a cast expression.
	//		<type-cast>
	// =================================================================	
	private CASTNode ParseExprTypeCast()
	{
		CASTNode lvalue = null;

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_LESS)
			{
				if (lvalue != null)
				{
					return lvalue;
				}
				else
				{
					return ParseExprPostfix();
				}
			}
			NextToken();

			// Create and parse operator
			CDataType dt = ParseDataType();

			ExpectToken(TokenIdentifier.OP_GREATER);

			// Read rvalue.	
			CASTNode rvalue = ParseExprPostfix();

			// Create operator node.
			CCastExpressionASTNode node = new CCastExpressionASTNode(null, op, true);
			node.Type = dt;
			node.RightValue = rvalue; 
			node.AddChild(rvalue);

			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a prefix expression.
	//		++
	//		--
	//		+
	//		-
	//		~
	//		!
	// =================================================================	
	private CASTNode ParseExprPrefix()
	{
		bool hasUnary = false;
	
		// Operator next?
		CToken op = LookAheadToken();
		if (op.Type == TokenIdentifier.OP_INCREMENT ||
			op.Type == TokenIdentifier.OP_DECREMENT ||
			op.Type == TokenIdentifier.OP_ADD ||
			op.Type == TokenIdentifier.OP_SUB ||
			op.Type == TokenIdentifier.OP_NOT ||
			op.Type == TokenIdentifier.OP_LOGICAL_NOT)
		{
			NextToken();
			hasUnary = true;
		}

		CASTNode lvalue = ParseExprTypeCast();
	
		// Perform unary operation.
		if (hasUnary == true)
		{
			CPreFixExpressionASTNode node = new CPreFixExpressionASTNode(null, op);
			(<CPreFixExpressionASTNode>node).LeftValue = lvalue;
			node.AddChild(lvalue);

			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a postfix expression.
	//		++
	//		--
	//		x.y
	//		x.y(arg1, arg2, arg3)
	//		[x..y]
	//		[..y]
	//		[x..]
	//		[123]
	// =================================================================	
	private CASTNode ParseExprPostfix()
	{
		CASTNode lvalue = ParseExprFactor();

		while (true)
		{
			// Operator next?
			CToken op = LookAheadToken();
			if (op.Type != TokenIdentifier.OP_INCREMENT &&
				op.Type != TokenIdentifier.OP_DECREMENT &&
				op.Type != TokenIdentifier.PERIOD &&
				op.Type != TokenIdentifier.OPEN_BRACKET)
			{
				return lvalue;
			}
			NextToken();

			// Create operator node.
			CASTNode node = null;

			// PostFix ++ and --
			if (op.Type == TokenIdentifier.OP_DECREMENT ||
				op.Type == TokenIdentifier.OP_INCREMENT)
			{
				node = new CPostFixExpressionASTNode(null, op);
				(<CPostFixExpressionASTNode>node).LeftValue = lvalue;
				node.AddChild(lvalue);
			}

			// Sub-script / slice
			else if (op.Type == TokenIdentifier.OPEN_BRACKET)
			{
				// [:]
				if (LookAheadToken().Type == TokenIdentifier.COLON)
				{
					ExpectToken(TokenIdentifier.COLON);

					// [:]
					if (LookAheadToken().Type == TokenIdentifier.CLOSE_BRACKET)
					{
						node = new CSliceExpressionASTNode(null, op);
						(<CSliceExpressionASTNode>node).LeftValue = lvalue;
						node.AddChild(lvalue);
					}

					// [:(end)]
					else
					{
						CASTNode slice_end = ParseExpr(true);

						node = new CSliceExpressionASTNode(null, op);
						(<CSliceExpressionASTNode>node).LeftValue = lvalue;
						(<CSliceExpressionASTNode>node).EndExpression = slice_end;
						node.AddChild(slice_end);
						node.AddChild(lvalue);
					}
				}

				// [(start)]
				else
				{
					CASTNode slice_start = ParseExpr(true);

					// [(start):] 
					if (LookAheadToken().Type == TokenIdentifier.COLON)
					{					
						ExpectToken(TokenIdentifier.COLON);

						// [(start):] 
						if (LookAheadToken().Type == TokenIdentifier.CLOSE_BRACKET)
						{
							node = new CSliceExpressionASTNode(null, op);
							(<CSliceExpressionASTNode>node).LeftValue = lvalue;
							(<CSliceExpressionASTNode>node).StartExpression = slice_start;
							node.AddChild(slice_start);
							node.AddChild(lvalue);
						}

						// [(start):(end)]
						else
						{
							CASTNode slice_end = ParseExpr(true);

							node = new CSliceExpressionASTNode(null, op);
							(<CSliceExpressionASTNode>node).LeftValue = lvalue;
							(<CSliceExpressionASTNode>node).StartExpression = slice_start;
							(<CSliceExpressionASTNode>node).EndExpression = slice_end;
							node.AddChild(slice_start);
							node.AddChild(slice_end);
							node.AddChild(lvalue);
						}
					}

					// [(start)]
					else
					{
						node = new CIndexExpressionASTNode(null, op);
						(<CSliceExpressionASTNode>node).LeftValue = lvalue;
						(<CIndexExpressionASTNode>node).IndexExpression = slice_start;
						node.AddChild(slice_start);
						node.AddChild(lvalue);
					}
				}

				ExpectToken(TokenIdentifier.CLOSE_BRACKET);
			}

			// Read in member access.
			else if (op.Type == TokenIdentifier.PERIOD)
			{
				CToken identToken = ExpectToken(TokenIdentifier.IDENTIFIER);
			
				CASTNode rvalue = new CIdentifierExpressionASTNode(null, identToken);

				// Method access?
				if (LookAheadToken().Type == TokenIdentifier.OPEN_PARENT)
				{				
					node = new CMethodCallExpressionASTNode(null, op);
					(<CMethodCallExpressionASTNode>node).LeftValue = lvalue;
					(<CMethodCallExpressionASTNode>node).RightValue = rvalue;
					node.AddChild(lvalue);
					node.AddChild(rvalue);

					ExpectToken(TokenIdentifier.OPEN_PARENT);
				
					// Read in arguments.
					while (LookAheadToken().Type != TokenIdentifier.CLOSE_PARENT)
					{
						CASTNode expr = ParseExpr(true, true);

						(<CMethodCallExpressionASTNode>node).ArgumentExpressions.AddLast(expr);
						node.AddChild(expr);

						if (LookAheadToken().Type == TokenIdentifier.COMMA)
						{
							ExpectToken(TokenIdentifier.COMMA);
						}
						else
						{
							break;
						}
					}

					ExpectToken(TokenIdentifier.CLOSE_PARENT);
				}

				// Field access?
				else
				{
					node = new CFieldAccessExpressionASTNode(null, op);
					(<CFieldAccessExpressionASTNode>node).LeftValue = lvalue;
					(<CFieldAccessExpressionASTNode>node).RightValue = rvalue;
					node.AddChild(lvalue);
					node.AddChild(rvalue);
				}
			}

			lvalue = node;
		}

		return lvalue;
	}

	// =================================================================
	//	Parses a factor expression:
	//		Literals
	//		Identifiers
	//		Sub Expressions
	// =================================================================	
	private CASTNode ParseExprFactor()
	{
		CToken token = NextToken();

		switch (token.Type)
		{
			case TokenIdentifier.KEYWORD_INT
			   , TokenIdentifier.KEYWORD_FLOAT
			   , TokenIdentifier.KEYWORD_STRING
			   , TokenIdentifier.KEYWORD_BOOL
			   , TokenIdentifier.IDENTIFIER:
				{
					// Method call?
					if (LookAheadToken().Type == TokenIdentifier.OPEN_PARENT)
					{
						CASTNode rvalue = new CIdentifierExpressionASTNode(null, token);

						CMethodCallExpressionASTNode node = new CMethodCallExpressionASTNode(null, token);
						if (CurrentClassMemberScope().IsStatic == true)
						{
							node.LeftValue = new CClassRefExpressionASTNode(null, token);
							node.LeftValue.Token.Literal = CurrentClassScope().Identifier;
						}
						else
						{
							node.LeftValue = new CThisExpressionASTNode(null, token);					
						}
						node.RightValue = rvalue;
						node.AddChild(node.LeftValue);
						node.AddChild(rvalue);

						ExpectToken(TokenIdentifier.OPEN_PARENT);
				
						// Read in arguments.
						while (LookAheadToken().Type != TokenIdentifier.CLOSE_PARENT)
						{
							CASTNode expr = ParseExpr(true, true);
							(<CMethodCallExpressionASTNode>node).ArgumentExpressions.AddLast(expr);
							node.AddChild(expr);

							if (LookAheadToken().Type == TokenIdentifier.COMMA)
							{
								ExpectToken(TokenIdentifier.COMMA);
							}
							else
							{
								break;
							}
						}
					
						ExpectToken(TokenIdentifier.CLOSE_PARENT);

						return node;
					}
					else
					{
						CIdentifierExpressionASTNode node = new CIdentifierExpressionASTNode(null, token);

						// Arrrrrrrrgh, we now have to work out if this identifier is a reference to a generic
						// class, and if it is, read in its generic types. This is a total bitch, as its perfectly
						// possible to have ambiguous lookaheads, eg.
						//	
						//		myClass<int>.Derp
						//		myClass<3
						//		myClass<3,5,6
						//		myClass<3,5,6>6
						//
						// To solve this what we basically do is keep reading nested <>'s until we get to the closing
						// < and check if a period follows it. We limit the scan-ahead range to a small number of tokens.
						// This is not ideal at all, but I can't think of a better more full-proof method at the moment.
						//
						int final_token_offset = 0;
						if (IsGenericTypeListFollowing(final_token_offset) &&
							LookAheadToken(final_token_offset + 1).Type == TokenIdentifier.PERIOD)
						{
							ExpectToken(TokenIdentifier.OP_LESS);
							while (true)
							{
								node.GenericTypes.AddLast(ParseDataType());

								if (LookAheadToken().Type == TokenIdentifier.COMMA)
								{
									ExpectToken(TokenIdentifier.COMMA);
								}
								else
								{
									break;
								}
							}
							ExpectToken(TokenIdentifier.OP_GREATER);
						}

						return node;
					}
				}		
			case TokenIdentifier.KEYWORD_BASE:
				{
					return new CBaseExpressionASTNode(null, token);
				}	
			case TokenIdentifier.KEYWORD_NEW:
				{
					CNewExpressionASTNode node = new CNewExpressionASTNode(null, token);				
					PushScope(node);

					node.DataType = ParseDataType(false);

					if (LookAheadToken().Type == TokenIdentifier.OPEN_BRACKET)
					{				
						node.IsArray  = true;
						node.DataType = node.DataType.ArrayOf();

						ExpectToken(TokenIdentifier.OPEN_BRACKET);
						if (LookAheadToken().Type != TokenIdentifier.CLOSE_BRACKET)
						{
							node.ArgumentExpressions.AddLast(ParseExpr(false, true));
						}
						ExpectToken(TokenIdentifier.CLOSE_BRACKET);

						while (LookAheadToken().Type == TokenIdentifier.OPEN_BRACKET)
						{
							ExpectToken(TokenIdentifier.OPEN_BRACKET);
							if (LookAheadToken().Type != TokenIdentifier.CLOSE_BRACKET)
							{
								m_context.FatalError("Attempt to initialize array in a multidimensional syntax - only jagged arrays are supported!", CurrentToken());					
								break;
							}
							ExpectToken(TokenIdentifier.CLOSE_BRACKET);

							node.DataType = node.DataType.ArrayOf();
						}
					}
					else
					{
						ExpectToken(TokenIdentifier.OPEN_PARENT);
						while (LookAheadToken().Type != TokenIdentifier.CLOSE_PARENT)
						{
							node.ArgumentExpressions.AddLast(ParseExpr(false, true));

							if (LookAheadToken().Type == TokenIdentifier.CLOSE_PARENT)
							{
								break;
							}
							else
							{
								ExpectToken(TokenIdentifier.COMMA);
							}
						}
						ExpectToken(TokenIdentifier.CLOSE_PARENT);
					}

					// Read array initialization.
					if (node.DataType is CArrayDataType)
					{
						if (LookAheadToken().Type == TokenIdentifier.OPEN_BRACE)
						{
							node.ArrayInitializer = ParseArrayInitializer();
							node.AddChild(node.ArrayInitializer);
						}
						else
						{
							if (node.ArgumentExpressions.Count() == 0)
							{
								m_context.FatalError("Arrays must have either a length expression or an initialization list.", CurrentToken());					
								break;
							}
						}
					}

					PopScope();

					return node;
				}			
			case TokenIdentifier.OPEN_BRACE:
				{
					RewindStream();
					return ParseArrayInitializer();
				}
			case TokenIdentifier.KEYWORD_THIS:
				{
					return new CThisExpressionASTNode(null, token);
				}	
			case TokenIdentifier.STRING_LITERAL:
				{
					return new CLiteralExpressionASTNode(null, token, new CStringDataType(token), token.Literal);
				}
			case TokenIdentifier.FLOAT_LITERAL:
				{
					return new CLiteralExpressionASTNode(null, token, new CFloatDataType(token), token.Literal);
				}
			case TokenIdentifier.INT_LITERAL:
				{
					return new CLiteralExpressionASTNode(null, token, new CIntDataType(token), token.Literal);
				}
			case TokenIdentifier.KEYWORD_TRUE:
				{
					return new CLiteralExpressionASTNode(null, token, new CBoolDataType(token), "1");
				}

			case TokenIdentifier.KEYWORD_FALSE:
				{
					return new CLiteralExpressionASTNode(null, token, new CBoolDataType(token), "0");
				}

			case TokenIdentifier.KEYWORD_NULL:
				{
					return new CLiteralExpressionASTNode(null, token, new CNullDataType(token), token.Literal);
				}
			case TokenIdentifier.OPEN_PARENT:
				{
					CASTNode node = ParseExpr(true);

					ExpectToken(TokenIdentifier.CLOSE_PARENT);
					return node;
				}
			default:
				{
					m_context.FatalError("Unexpected token while parsing expression '" + token.Literal + "' (0x" + string.FromIntToHex(<int>token.Type) + ").", token);					
					break;
				}
		}

		return null;
	}
	
	// =================================================================
	//	Constructs the parser.
	// =================================================================
	public CParser()
	{
	}
	
	// =================================================================
	//	Get the root node of the AST.
	// =================================================================
	public CASTNode GetASTRoot()
	{
		return m_root;
	}

	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		List<CToken> tokens = context.GetTokenList();

		m_context		= context;
		m_token_offset	= 0;

		// Create an end of file token for use in errors.
		m_eof_token.Row		= 1;
		m_eof_token.Column	= 1;
		if (tokens.Count() > 1)
		{
			CToken other = tokens.GetIndex(m_context.GetTokenList().Count() - 1);
			m_eof_token.Literal	= other.Literal;
			m_eof_token.Row		= other.Row;
			m_eof_token.Column	= other.Column + m_eof_token.Literal.Length();
		}
		m_eof_token.Type		= TokenIdentifier.EndOfFile;
		m_eof_token.Literal		= "<end-of-file>";
		m_sof_token.SourceFile	= m_context.GetFilePath();

		// Create a start of file token for use in errors.
		m_sof_token.Type		= TokenIdentifier.StartOfFile;
		m_sof_token.Literal		= "<start-of-file>";
		m_sof_token.SourceFile	= m_context.GetFilePath();
		m_sof_token.Row			= 1;
		m_sof_token.Column		= 1;

		// Create the root AST node.
		m_root  = new CPackageASTNode(null, m_sof_token);
		PushScope(m_root);

		// Keep parsing top-level statements until we 
		// run out of tokens.
		while (!EndOfTokens())
		{
			ParseTopLevelStatement();
		}

		PopScope();

		return true;
	}

	// =================================================================
	//	Evalulates an expression.
	// =================================================================
	public bool Evaluate(CTranslationUnit context)
	{
		List<CToken> tokens = context.GetTokenList();

		m_context		= context;
		m_token_offset	= 0;

		// Create an end of file token for use in errors.
		m_eof_token.Row		= 1;
		m_eof_token.Column	= 1;
		if (tokens.Count() > 1)
		{
			CToken other = tokens.GetIndex(m_context.GetTokenList().Count() - 1);
			m_eof_token.Literal	= other.Literal;
			m_eof_token.Row		= other.Row;
			m_eof_token.Column	= other.Column + m_eof_token.Literal.Length();
		}
		m_eof_token.Type		= TokenIdentifier.EndOfFile;
		m_eof_token.Literal		= "<end-of-file>";
		m_sof_token.SourceFile	= m_context.GetFilePath();

		// Create a start of file token for use in errors.
		m_sof_token.Type		= TokenIdentifier.StartOfFile;
		m_sof_token.Literal		= "<start-of-file>";
		m_sof_token.SourceFile	= m_context.GetFilePath();
		m_sof_token.Row			= 1;
		m_sof_token.Column		= 1;

		// Create the root AST node.
		m_root = ParseExpr(false);

		return EndOfTokens();
	}
	
}



