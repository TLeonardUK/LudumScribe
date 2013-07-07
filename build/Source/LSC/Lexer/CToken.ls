// -----------------------------------------------------------------------------
// 	CToken.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Enumeration of different token types.
// =================================================================
public enum TokenIdentifier
{
	KEYWORD_ABSTRACT,
	KEYWORD_EVENT,
	KEYWORD_NEW,
	KEYWORD_STRUCT,
	KEYWORD_AS,
	KEYWORD_EXPLICIT,
	KEYWORD_SWITCH,
	KEYWORD_BASE,
	KEYWORD_EXTERN,
	KEYWORD_OPERATOR,
	KEYWORD_THROW,
	KEYWORD_BREAK,
	KEYWORD_FINALLY,
	KEYWORD_OUT,
	KEYWORD_IN,
	KEYWORD_FIXED,
	KEYWORD_OVERRIDE,
	KEYWORD_TRY,
	KEYWORD_CASE,
	KEYWORD_PARAMS,
	KEYWORD_TYPEOF,
	KEYWORD_CATCH,
	KEYWORD_FOR,
	KEYWORD_PRIVATE,
	KEYWORD_PUBLIC,
	KEYWORD_FOREACH,
	KEYWORD_PROTECTED,
	KEYWORD_CHECKED,
	KEYWORD_GOTO,
	KEYWORD_UNCHECKED,
	KEYWORD_CLASS,
	KEYWORD_IF,
	KEYWORD_READONLY,
	KEYWORD_UNSAFE,
	KEYWORD_CONST,
	KEYWORD_IMPLICIT,
	KEYWORD_REF,
	KEYWORD_CONTINUE,
	KEYWORD_RETURN,
	KEYWORD_USING,
	KEYWORD_VIRTUAL,
	KEYWORD_DEFAULT,
	KEYWORD_INTERFACE,
	KEYWORD_SEALED,
	KEYWORD_VOLATILE,
	KEYWORD_DELEGATE,
	KEYWORD_INTERNAL,
	KEYWORD_DO,
	KEYWORD_IS,
	KEYWORD_SIZEOF,
	KEYWORD_LOCK,
	KEYWORD_STACKALLOC,
	KEYWORD_ELSE,
	KEYWORD_STATIC,
	KEYWORD_ENUM,
	KEYWORD_NAMESPACE,
	KEYWORD_MODULE,
	KEYWORD_PACKAGE,
	KEYWORD_IMPORT,
	KEYWORD_INCLUDE,
	KEYWORD_END,
	KEYWORD_GENERATOR,
	KEYWORD_WHILE,
	KEYWORD_NATIVE,
	KEYWORD_BOX,
	
	KEYWORD_COPY,
	KEYWORD_LIBRARY,
	
	KEYWORD_THIS,
	KEYWORD_TRUE,
	KEYWORD_FALSE,
	KEYWORD_NULL,
	
	//KEYWORD_OBJECT,
	KEYWORD_BOOL,
	KEYWORD_VOID,
	//KEYWORD_BYTE,
	//KEYWORD_SHORT,
	KEYWORD_INT,
	//KEYWORD_LONG,
	KEYWORD_FLOAT,
	//KEYWORD_DOUBLE,
	KEYWORD_STRING,
	
	OP_LOGICAL_NOT, // !
	OP_LOGICAL_OR, // ||
	OP_LOGICAL_AND, // 
	
	OP_SHL, // <<
	OP_SHR, // >>
	OP_AND, // 
	OP_OR, // |
	OP_XOR, // ^
	OP_NOT, // ~
	OP_MOD, // %
	OP_ADD, // +
	OP_SUB, // -
	OP_DIV, // /
	OP_MUL, // 
	OP_TERNARY, // ?
	
	OP_EQUAL, // ==
	OP_NOT_EQUAL, // !=
	OP_GREATER_EQUAL, // >=
	OP_LESS_EQUAL, // <=
	OP_GREATER, // >
	OP_LESS, // <
	
	OP_ASSIGN, // ==
	OP_ASSIGN_SUB, // -=
	OP_ASSIGN_ADD, // +=
	OP_ASSIGN_MUL, // =
	OP_ASSIGN_DIV, // /=
	OP_ASSIGN_MOD, // %=
	OP_ASSIGN_AND, // =
	OP_ASSIGN_OR, // |=
	OP_ASSIGN_XOR, // ^=
	OP_ASSIGN_SHL, // <<=
	OP_ASSIGN_SHR, // >>=
	
	OP_INCREMENT, // ++
	OP_DECREMENT, // --
	
	OPEN_BRACKET, // [
	CLOSE_BRACKET, // ]
	OPEN_BRACE, // {
	CLOSE_BRACE, // }
	OPEN_PARENT, //(
	CLOSE_PARENT, // )
	
	COMMA,				// ,
	COLON, // :
	SEMICOLON, // ;
	PERIOD, // .
	SLICE, // ..
	SCOPE, // .
	
	IDENTIFIER, // herpderp
	STRING_LITERAL, // "avalue"
	FLOAT_LITERAL, // 0.1337
	INT_LITERAL, // 1337
	
	EndOfFile, // <eof>
	StartOfFile, // <sof>
	PreProcessor, // #asdasd
}

// =================================================================
//	Enumeration of different token types.
// =================================================================
public class TokenMnemonicTableEntry
{
	public string Literal;
	public TokenIdentifier TokenType;
	
	public TokenMnemonicTableEntry()
	{
	}
	public TokenMnemonicTableEntry(string lit, TokenIdentifier type)
	{
		Literal = lit;
		TokenType = type;
	}
}

// =================================================================
//	Struct stores information on an individual token.
// =================================================================
public class CToken
{
	// =================================================================
	//	Mnemonic table.
	// =================================================================
	public static TokenMnemonicTableEntry[] TOKEN_MNEMONIC_TABLE = 
	{
		new TokenMnemonicTableEntry("abstract",		TokenIdentifier.KEYWORD_ABSTRACT),
		new TokenMnemonicTableEntry("event",		TokenIdentifier.KEYWORD_EVENT),
		new TokenMnemonicTableEntry("new",			TokenIdentifier.KEYWORD_NEW),
		new TokenMnemonicTableEntry("struct",		TokenIdentifier.KEYWORD_STRUCT),
		new TokenMnemonicTableEntry("as",			TokenIdentifier.KEYWORD_AS),
		new TokenMnemonicTableEntry("explicit",		TokenIdentifier.KEYWORD_EXPLICIT),
		new TokenMnemonicTableEntry("switch",		TokenIdentifier.KEYWORD_SWITCH),
		new TokenMnemonicTableEntry("base",			TokenIdentifier.KEYWORD_BASE),
		new TokenMnemonicTableEntry("extern",		TokenIdentifier.KEYWORD_EXTERN),
		new TokenMnemonicTableEntry("operator",		TokenIdentifier.KEYWORD_OPERATOR),
		new TokenMnemonicTableEntry("throw",		TokenIdentifier.KEYWORD_THROW),
		new TokenMnemonicTableEntry("break",		TokenIdentifier.KEYWORD_BREAK),
		new TokenMnemonicTableEntry("finally",		TokenIdentifier.KEYWORD_FINALLY),
		new TokenMnemonicTableEntry("out",			TokenIdentifier.KEYWORD_OUT),
		new TokenMnemonicTableEntry("in",			TokenIdentifier.KEYWORD_IN),
		new TokenMnemonicTableEntry("fixed",		TokenIdentifier.KEYWORD_FIXED),
		new TokenMnemonicTableEntry("override",		TokenIdentifier.KEYWORD_OVERRIDE),
		new TokenMnemonicTableEntry("try",			TokenIdentifier.KEYWORD_TRY),
		new TokenMnemonicTableEntry("case",			TokenIdentifier.KEYWORD_CASE),
		new TokenMnemonicTableEntry("params",		TokenIdentifier.KEYWORD_PARAMS),
		new TokenMnemonicTableEntry("typeof",		TokenIdentifier.KEYWORD_TYPEOF),
		new TokenMnemonicTableEntry("catch",		TokenIdentifier.KEYWORD_CATCH),
		new TokenMnemonicTableEntry("for",			TokenIdentifier.KEYWORD_FOR),
		new TokenMnemonicTableEntry("private",		TokenIdentifier.KEYWORD_PRIVATE),
		new TokenMnemonicTableEntry("public",		TokenIdentifier.KEYWORD_PUBLIC),
		new TokenMnemonicTableEntry("foreach",		TokenIdentifier.KEYWORD_FOREACH),
		new TokenMnemonicTableEntry("protected",	TokenIdentifier.KEYWORD_PROTECTED),
		new TokenMnemonicTableEntry("checked",		TokenIdentifier.KEYWORD_CHECKED),
		new TokenMnemonicTableEntry("goto",			TokenIdentifier.KEYWORD_GOTO),
		new TokenMnemonicTableEntry("unchecked",	TokenIdentifier.KEYWORD_UNCHECKED),
		new TokenMnemonicTableEntry("class",		TokenIdentifier.KEYWORD_CLASS),
		new TokenMnemonicTableEntry("if",			TokenIdentifier.KEYWORD_IF),
		new TokenMnemonicTableEntry("readonly",		TokenIdentifier.KEYWORD_READONLY),
		new TokenMnemonicTableEntry("unsafe",		TokenIdentifier.KEYWORD_UNSAFE),
		new TokenMnemonicTableEntry("const",		TokenIdentifier.KEYWORD_CONST),
		new TokenMnemonicTableEntry("implicit",		TokenIdentifier.KEYWORD_IMPLICIT),
		new TokenMnemonicTableEntry("ref",			TokenIdentifier.KEYWORD_REF),
		new TokenMnemonicTableEntry("continue",		TokenIdentifier.KEYWORD_CONTINUE),
		new TokenMnemonicTableEntry("return",		TokenIdentifier.KEYWORD_RETURN),
		new TokenMnemonicTableEntry("using",		TokenIdentifier.KEYWORD_USING),
		new TokenMnemonicTableEntry("virtual",		TokenIdentifier.KEYWORD_VIRTUAL),
		new TokenMnemonicTableEntry("default",		TokenIdentifier.KEYWORD_DEFAULT),
		new TokenMnemonicTableEntry("interface",	TokenIdentifier.KEYWORD_INTERFACE),
		new TokenMnemonicTableEntry("sealed",		TokenIdentifier.KEYWORD_SEALED),
		new TokenMnemonicTableEntry("volatile",		TokenIdentifier.KEYWORD_VOLATILE),
		new TokenMnemonicTableEntry("delegate",		TokenIdentifier.KEYWORD_DELEGATE),
		new TokenMnemonicTableEntry("internal",		TokenIdentifier.KEYWORD_INTERNAL),
		new TokenMnemonicTableEntry("do",			TokenIdentifier.KEYWORD_DO),
		new TokenMnemonicTableEntry("is",			TokenIdentifier.KEYWORD_IS),
		new TokenMnemonicTableEntry("sizeof",		TokenIdentifier.KEYWORD_SIZEOF),
		new TokenMnemonicTableEntry("lock",			TokenIdentifier.KEYWORD_LOCK),
		new TokenMnemonicTableEntry("stackalloc",	TokenIdentifier.KEYWORD_STACKALLOC),
		new TokenMnemonicTableEntry("else",			TokenIdentifier.KEYWORD_ELSE),
		new TokenMnemonicTableEntry("static",		TokenIdentifier.KEYWORD_STATIC),
		new TokenMnemonicTableEntry("enum",			TokenIdentifier.KEYWORD_ENUM),
		new TokenMnemonicTableEntry("namespace",	TokenIdentifier.KEYWORD_NAMESPACE),
		new TokenMnemonicTableEntry("module",		TokenIdentifier.KEYWORD_MODULE),
		new TokenMnemonicTableEntry("package",		TokenIdentifier.KEYWORD_PACKAGE),
		new TokenMnemonicTableEntry("import",		TokenIdentifier.KEYWORD_IMPORT),
		new TokenMnemonicTableEntry("include",		TokenIdentifier.KEYWORD_INCLUDE),
		new TokenMnemonicTableEntry("end",			TokenIdentifier.KEYWORD_END),
		new TokenMnemonicTableEntry("generator",	TokenIdentifier.KEYWORD_GENERATOR),
		new TokenMnemonicTableEntry("while",		TokenIdentifier.KEYWORD_WHILE),
		new TokenMnemonicTableEntry("native",		TokenIdentifier.KEYWORD_NATIVE),
		new TokenMnemonicTableEntry("box",			TokenIdentifier.KEYWORD_BOX),
		new TokenMnemonicTableEntry("copy",			TokenIdentifier.KEYWORD_COPY),
		new TokenMnemonicTableEntry("library",		TokenIdentifier.KEYWORD_LIBRARY),

		new TokenMnemonicTableEntry("this",			TokenIdentifier.KEYWORD_THIS),
		new TokenMnemonicTableEntry("true",			TokenIdentifier.KEYWORD_TRUE),
		new TokenMnemonicTableEntry("false",		TokenIdentifier.KEYWORD_FALSE),
		new TokenMnemonicTableEntry("null",			TokenIdentifier.KEYWORD_NULL),

		new TokenMnemonicTableEntry("bool",			TokenIdentifier.KEYWORD_BOOL),
		new TokenMnemonicTableEntry("void",			TokenIdentifier.KEYWORD_VOID),
		new TokenMnemonicTableEntry("int",			TokenIdentifier.KEYWORD_INT),
		new TokenMnemonicTableEntry("float",		TokenIdentifier.KEYWORD_FLOAT),
		new TokenMnemonicTableEntry("string",		TokenIdentifier.KEYWORD_STRING),

		new TokenMnemonicTableEntry("!",			TokenIdentifier.OP_LOGICAL_NOT),		// !
		new TokenMnemonicTableEntry("||",			TokenIdentifier.OP_LOGICAL_OR),		// ||
		new TokenMnemonicTableEntry("&&",			TokenIdentifier.OP_LOGICAL_AND),		// &&

		new TokenMnemonicTableEntry("<<",			TokenIdentifier.OP_SHL),				// <<
		new TokenMnemonicTableEntry(">>",			TokenIdentifier.OP_SHR),				// >>
		new TokenMnemonicTableEntry("&",			TokenIdentifier.OP_AND),				// &
		new TokenMnemonicTableEntry("|",			TokenIdentifier.OP_OR),				// |
		new TokenMnemonicTableEntry("^",			TokenIdentifier.OP_XOR),				// ^
		new TokenMnemonicTableEntry("~",			TokenIdentifier.OP_NOT),				// ~
		new TokenMnemonicTableEntry("%",			TokenIdentifier.OP_MOD),				// %
		new TokenMnemonicTableEntry("+",			TokenIdentifier.OP_ADD),				// +
		new TokenMnemonicTableEntry("-",			TokenIdentifier.OP_SUB),				// -
		new TokenMnemonicTableEntry("/",			TokenIdentifier.OP_DIV),				// /
		new TokenMnemonicTableEntry("*",			TokenIdentifier.OP_MUL),				// *
		new TokenMnemonicTableEntry("?",			TokenIdentifier.OP_TERNARY),				// ?

		new TokenMnemonicTableEntry("==",			TokenIdentifier.OP_EQUAL),			// ==
		new TokenMnemonicTableEntry("!=",			TokenIdentifier.OP_NOT_EQUAL),		// !=
		new TokenMnemonicTableEntry(">=",			TokenIdentifier.OP_GREATER_EQUAL),	// >=
		new TokenMnemonicTableEntry("<=",			TokenIdentifier.OP_LESS_EQUAL),		// <=
		new TokenMnemonicTableEntry(">",			TokenIdentifier.OP_GREATER),			// >
		new TokenMnemonicTableEntry("<",			TokenIdentifier.OP_LESS),			// <

		new TokenMnemonicTableEntry("=",			TokenIdentifier.OP_ASSIGN),			// ==
		new TokenMnemonicTableEntry("-=",			TokenIdentifier.OP_ASSIGN_SUB),		// -=
		new TokenMnemonicTableEntry("+=",			TokenIdentifier.OP_ASSIGN_ADD),		// +=
		new TokenMnemonicTableEntry("/=",			TokenIdentifier.OP_ASSIGN_DIV),		// /=
		new TokenMnemonicTableEntry("%=",			TokenIdentifier.OP_ASSIGN_MOD),		// %=
		new TokenMnemonicTableEntry("&=",			TokenIdentifier.OP_ASSIGN_AND),		// &=
		new TokenMnemonicTableEntry("|=",			TokenIdentifier.OP_ASSIGN_OR),		// |=
		new TokenMnemonicTableEntry("^=",			TokenIdentifier.OP_ASSIGN_XOR),		// ^=
		new TokenMnemonicTableEntry("<<=",			TokenIdentifier.OP_ASSIGN_SHL),		// <<=
		new TokenMnemonicTableEntry(">>=",			TokenIdentifier.OP_ASSIGN_SHR),		// >>=

		new TokenMnemonicTableEntry("++",			TokenIdentifier.OP_INCREMENT),		// ++
		new TokenMnemonicTableEntry("--",			TokenIdentifier.OP_DECREMENT),		// --

		new TokenMnemonicTableEntry("[",			TokenIdentifier.OPEN_BRACKET),		// [
		new TokenMnemonicTableEntry("]",			TokenIdentifier.CLOSE_BRACKET),	// ]
		new TokenMnemonicTableEntry("{",			TokenIdentifier.OPEN_BRACE),		// {
		new TokenMnemonicTableEntry("}",			TokenIdentifier.CLOSE_BRACE),		// }
		new TokenMnemonicTableEntry("(",			TokenIdentifier.OPEN_PARENT),		// (
		new TokenMnemonicTableEntry(")",			TokenIdentifier.CLOSE_PARENT),		// )

		new TokenMnemonicTableEntry(",",			TokenIdentifier.COMMA),			// ,
		new TokenMnemonicTableEntry(":",			TokenIdentifier.COLON),			// :
		new TokenMnemonicTableEntry(";",			TokenIdentifier.SEMICOLON),		// ;
		new TokenMnemonicTableEntry(".",			TokenIdentifier.PERIOD),			// .
		new TokenMnemonicTableEntry("..",			TokenIdentifier.SLICE),			// ..
		new TokenMnemonicTableEntry(".",			TokenIdentifier.SCOPE)			// .
	};

	public string Literal;
	public TokenIdentifier Type;
	
	public string SourceFile;
	public int Row;
	public int Column;
}

