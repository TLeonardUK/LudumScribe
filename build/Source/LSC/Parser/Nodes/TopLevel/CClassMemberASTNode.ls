// -----------------------------------------------------------------------------
// 	CClassMemberASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Member type type.
// =================================================================
public enum MemberType
{
	Method,
	Field
}

// =================================================================
//	Stores information on a class member declaration.
// =================================================================
public class CClassMemberASTNode : CDeclarationASTNode
{
	public AccessLevel MemberAccessLevel;
	public bool IsStatic;
	public bool IsAbstract;
	public bool IsVirtual;
	public bool IsConst;
	public bool IsOverride;
	public bool IsConstructor;
	public bool IsExtension;
	
	public MemberType MemberMemberType;
	
	public CMethodBodyASTNode Body;
	public CExpressionASTNode Assignment;
	public List<CVariableStatementASTNode> Arguments = new List<CVariableStatementASTNode>();
	public CDataType ReturnType;
	
	// Constructors.
	public CClassMemberASTNode(CASTNode parent, CToken token)
	{
		this.CDeclarationASTNode(parent, token);
		
		MemberAccessLevel			= AccessLevel.Public;
		IsStatic			= false;
		IsAbstract			= false;
		IsVirtual			= false;
		IsConst				= false;
		IsConstructor		= false;
		IsOverride			= false;
		IsExtension			= false;
		MemberMemberType	= MemberType.Method;

		Body				= null;
		Assignment			= null;
		ReturnType			= null;
	}
	
	// General management.
	public virtual override string ToString()
	{
		if (ReturnType == null)
		{
			return Identifier;
		}
	
		string val = ReturnType.ToString();

		if (MemberMemberType == MemberType.Field)
		{
			if (IsStatic == true)
			{
				val = "static " + val;
			}
			if (IsConst == true)
			{
				val = "const " + val;
			}

			val += " " + Identifier;
		}
		else if (MemberMemberType == MemberType.Method)
		{
			if (IsStatic == true)
			{
				val = "static " + val;
			}
			if (IsAbstract == true)
			{
				val = "abstract " + val;
			}
			if (IsVirtual == true)
			{
				val = "virtual " + val;
			}
			if (IsOverride == true)
			{
				val = "override " + val;
			}

			val += " " + Identifier;
			val += "(";

			int index = 0;
			foreach (CASTNode iter in Arguments)
			{
				if (index++)
				{
					val += ", ";
				}
				val += iter.ToString();
			}

			val += ")";
		}

		return val;
	}
	
	// Semantic analysis.
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CClassMemberASTNode="+Identifier);
		
		// Only semant once.
		if (Semanted == true)
		{
			return this;
		}
		Semanted = true;

		CClassASTNode classScope = FindClassScope(semanter);

		// If we are constructor, replace return type with us.
		if (IsConstructor == true &&
			IsStatic == false &&
			classScope.InstanceConstructor != this)
		{
			ReturnType = FindClassScope(semanter).ObjectDataType;
		}

		// Semant the type/return type of this member.
		ReturnType = ReturnType.Semant(semanter, this);

		// No assignment? Add default.
		if (Assignment == null && MemberMemberType == MemberType.Field)
		{
			// Add default assignment expression.
			Assignment = semanter.ConstructDefaultAssignmentExpr(this, Token, ReturnType);
		}

		// Semant arguments.	
		List<CDataType> argument_types = new List<CDataType>();
		foreach (CVariableStatementASTNode arg in Arguments)
		{
			arg.Semant(semanter);

			argument_types.AddLast(arg.Type);

			if (arg.Type is CVoidDataType)
			{
				semanter.GetContext().FatalError("Methods arguments cannot be of type void.", Token);
			}
		}
		
		// Check for duplicate identifiers.
		if (MemberMemberType == MemberType.Field)
		{
			CheckForDuplicateIdentifier(semanter, Identifier);
		}
		else
		{
			CheckForDuplicateMethodIdentifier(semanter, Identifier, argument_types, this);
		}

		// If we are a class or instance constructor then we need to
		// add some stub code to the start.
		if (IsConstructor == true)
		{
			if (IsStatic == true)
			{
				AddClassConstructorStub(semanter);
			}
			else
			{
				if (classScope.InstanceConstructor == this)
				{
					AddInstanceConstructorStub(semanter);
				}
				else
				{
					AddInstanceConstructorPrefix(semanter);
				}
			}
		}
		else
		{
			AddMethodConstructorStub(semanter);
		}

		// Semant the body.
		if (Body != null)
		{
			Body.Semant(semanter);
		}
		
		// If we are a class or instance constructor then we need to
		// add some stub code to the end.
		if (IsConstructor == true)
		{
			if (IsStatic == false)
			{
				if (classScope.InstanceConstructor != this)
				{
					AddInstanceConstructorPostfix(semanter);
				}
			}
		}

		// We need to make sure to return a value.
		if (MemberMemberType == MemberType.Method &&
			(ReturnType is CVoidDataType) == false)
		{
			AddDefaultReturnExpression(semanter);
		}

		// Entry point.
		if (Identifier == "Main")
		{
			if (IsStatic == false)
			{
				semanter.GetContext().FatalError("Entry point is expected to be static.", Token);
			}
			else if (argument_types.Count() != 1 || (<CIntDataType>ReturnType) == null || (<CArrayDataType>argument_types.GetIndex(0)) == null || (<CStringDataType>((<CArrayDataType>argument_types.GetIndex(0)).ElementType)) == null)
			{
				semanter.GetContext().FatalError("Entry point must match signature: int Main(string[] args).", Token);
			}
			else
			{
				CClassMemberASTNode node = semanter.GetContext().GetEntryPoint();
				if (node == null)
				{
					semanter.GetContext().SetEntryPoint(this);
				}
				else
				{
					semanter.GetContext().FatalError("Encountered duplicate entry point", Token);
				}
			}
		}

		return this;
	}
	
	public virtual override CASTNode Finalize(CSemanter semanter)
	{
		// Work out mangled identifier.
		if (MangledIdentifier == "")
		{
			CClassASTNode scope = FindClassScope(semanter);
			
			if (MemberMemberType == MemberType.Field)
			{
				if (IsExtension == false)
				{
					MangledIdentifier = semanter.GetMangled("ls_f" + Identifier);
				}
				else
				{
					MangledIdentifier = semanter.GetMangled(scope.MangledIdentifier + "_f" + Identifier);
				}
			}
			else
			{
				if (IsExtension == false)
				{
					if (scope.IsInterface == true)
					{
						MangledIdentifier = semanter.GetMangled("ls_" + scope.Identifier + "_" + Identifier);
					}
					else
					{
						MangledIdentifier = semanter.GetMangled("ls_" + Identifier);
					}
				}
				else
				{
					MangledIdentifier = semanter.GetMangled(scope.MangledIdentifier + "_" + Identifier);
				}
			}
		}

		// Look for overridden mangled identifiers for virtuals / interfaces.
		if (IsExtension == false)
		{

			// Create a list of arguments.
			List<CDataType> types = new List<CDataType>();
			foreach (CVariableStatementASTNode arg in Arguments)
			{
				types.AddLast(arg.Type);
			}

			// If we are overriding then lets use the mangled identifier of our override.
			CClassASTNode scope = FindClassScope(semanter);
			while (scope != null)
			{
				CClassMemberASTNode node = scope.FindClassMethod(semanter, Identifier, types, true, this, this);
				if (node != null && 
					((IsOverride == true && node.IsVirtual == true) || scope.IsInterface == true))
				{
					if (node.MangledIdentifier == "")
					{
						node.Finalize(semanter);
					}
					MangledIdentifier = node.MangledIdentifier;
				}

				foreach (CClassASTNode interf in scope.Interfaces)
				{
					CClassMemberASTNode interf_node = interf.FindClassMethod(semanter, Identifier, types, true, this, this);
					if (interf_node != null)
					{
						if (interf_node.MangledIdentifier == "")
						{
							interf_node.Finalize(semanter);
						}
						MangledIdentifier = interf_node.MangledIdentifier;
					}
				}

				scope = scope.SuperClass;
			}

		}
		
		FinalizeChildren(semanter);
		return this;
	}

	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CClassMemberASTNode clone = new CClassMemberASTNode(null, Token);
		
		clone.IsNative			 	= this.IsNative;
		clone.MangledIdentifier 	= this.MangledIdentifier;
		clone.Identifier		 	= this.Identifier;
		clone.MemberAccessLevel		= this.MemberAccessLevel;
		clone.IsStatic			 	= this.IsStatic;
		clone.IsAbstract		 	= this.IsAbstract;
		clone.IsVirtual		 		= this.IsVirtual;
		clone.IsOverride		 	= this.IsOverride;
		clone.IsConst				= this.IsConst;
		clone.IsExtension		 	= this.IsExtension;
		clone.MemberMemberType		= this.MemberMemberType;
		clone.ReturnType		 	= this.ReturnType;
		clone.IsConstructor	 		= this.IsConstructor;
		
		foreach (CVariableStatementASTNode iter in Arguments)
		{
			CVariableStatementASTNode arg = <CVariableStatementASTNode>(iter.Clone(semanter));
			clone.Arguments.AddLast(arg);
			clone.AddChild(arg);
		}

		if (Body != null)
		{
			clone.Body				 = <CMethodBodyASTNode>(this.Body.Clone(semanter));
			clone.AddChild(clone.Body);
		}

		if (Assignment != null)
		{
			clone.Assignment		 = <CExpressionASTNode>(this.Assignment.Clone(semanter));
			clone.AddChild(clone.Assignment);
		}

		return clone;
	}

	public virtual override void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
		CClassASTNode ourClass				= FindClassScope(semanter);//dynamic_cast<CClassASTNode*>(Parent.Parent);
		CClassASTNode referenceClass		= referenceBy.FindClassScope(semanter);	
		
		// If we are in a different package and our class is private, then refuse access.
		if (ourClass.Token.SourceFile != referenceClass.Token.SourceFile && 
			ourClass.ClassAccessLevel != AccessLevel.Public)
		{
			semanter.GetContext().FatalError("Class member '"+Identifier+"' is not accessible from this package.", referenceBy.Token);	
		}

		// If the class we are referenced in extends from the class this member is in.
		if (referenceClass.InheritsFromClass(semanter, ourClass))
		{
			// Same class then we have access to everything.
			if (referenceClass == ourClass)
			{
				// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				//			 TODO: Fix all of below, its ugly, hacky and just plain horrible.
				// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				CClassMemberASTNode methodScope = referenceBy.FindClassMethodScope(semanter);
			
				// If we are the instance constructor we need to check if we are accessing variables
				// before they are declared.
				if (methodScope == ourClass.InstanceConstructor)
				{
					// See if we are the l-value of an assignment, in which case we don't give a shit 
					// about the member.
					bool lValueAssignment = false;
					CASTNode lastScope = referenceBy;
					CASTNode scope = lastScope.Parent;
					while (scope != null)
					{
						CAssignmentExpressionASTNode assignment = <CAssignmentExpressionASTNode>(scope);
						if (assignment != null)
						{
							lValueAssignment = (assignment.LeftValue == lastScope);
							break;
						}
						lastScope = scope;
						scope = scope.Parent;
					}

					if (lValueAssignment == false)
					{
						CASTNode referenceParent = referenceBy;
						while (referenceParent != null &&
							   referenceParent.Parent != methodScope.Body)
						{
							referenceParent = referenceParent.Parent;
						}

						// Check assignment index and member index, which *should* have a one-to-one mapping.
						// Using this we can determine if we are assigning member before its declared.
						int indexOfAssignmentExpression = methodScope.Body.Children.IndexOf(referenceParent);
						int indexOfMemberDeclaration    = ourClass.Body.Children.IndexOf(this);
					
						if (indexOfAssignmentExpression <= indexOfMemberDeclaration)
						{
							semanter.GetContext().FatalError("Attempt to access variable '" + Identifier + "' before it is declared.", referenceBy.Token);	
						}
					}
				}

				return;
			}

			// Otherwise we only have access to public and protected variables.
			else
			{
				if (this.MemberAccessLevel != AccessLevel.Public &&
					this.MemberAccessLevel != AccessLevel.Protected)
				{
					semanter.GetContext().FatalError("Class member '" + Identifier + "' is not accessible from here.", referenceBy.Token);	
				}
			}
		}

		// Otherwise we are accessing class from outside its inheritance tree so check if its public,
		// if not then refuse access.
		else
		{
			if (this.MemberAccessLevel != AccessLevel.Public)
			{
				semanter.GetContext().FatalError("Class member '" + Identifier + "' is not accessible from here.", referenceBy.Token);	
			}
		}
	}
	
	public void AddClassConstructorStub(CSemanter semanter)
	{
		CClassASTNode classScope = FindClassScope(semanter);

		// Find all fields with assignment expressions
		// and add their assignment to this constructor.
		foreach (CASTNode iter in classScope.Body.Children)
		{
			CClassMemberASTNode member = iter as CClassMemberASTNode;
			if (member != null)
			{
				if (member.IsStatic   == true && 
					member.MemberMemberType == MemberType.Field &&
					member.IsNative   == false)
				{
					if (member.Assignment == null)
					{
						member.Semant(semanter);
					}
				
					CToken op	= member.Assignment.Token.Copy();
					op.Type		= TokenIdentifier.OP_ASSIGN;
					op.Literal	= "=";
					
					CToken identTok	 = member.Assignment.Token.Copy();
					identTok.Type	 = TokenIdentifier.IDENTIFIER;
					identTok.Literal = member.Identifier;
					
					CIdentifierExpressionASTNode ident = new CIdentifierExpressionASTNode(null, identTok);
					
					CAssignmentExpressionASTNode assignment = new CAssignmentExpressionASTNode(null, op);
					assignment.LeftValue  = ident;
					assignment.IgnoreConst = true;
					assignment.RightValue = member.Assignment;//.Clone(semanter);
					assignment.AddChild(assignment.RightValue);
					assignment.AddChild(ident);

					CExpressionASTNode expr = new CExpressionASTNode(null, member.Assignment.Token);
					expr.LeftValue = assignment;
					expr.AddChild(assignment);

					Body.AddChild(expr);
				}
			}
		}
	}
	
	public void AddInstanceConstructorStub(CSemanter semanter)
	{
		CClassASTNode classScope = FindClassScope(semanter);
		
		// Find all fields with assignment expressions
		// and add their assignment to this constructor.
		// TODO: IN reverse
		for (int i = classScope.Body.Children.Count() - 1; i >= 0; i--)
		{
			CASTNode iter = classScope.Body.Children.GetIndex(i);
			CClassMemberASTNode member = iter as CClassMemberASTNode;
			if (member != null)
			{
				if (member.IsStatic   == false && 
					member.MemberMemberType == MemberType.Field &&
					member.IsNative   == false)
				{
					if (member.Assignment == null)
					{
						member.Semant(semanter);
					}
				
					CToken op	= member.Assignment.Token.Copy();
					op.Type		= TokenIdentifier.OP_ASSIGN;
					op.Literal	= "=";
					
					CToken identTok	 = member.Assignment.Token.Copy();
					identTok.Type	 = TokenIdentifier.IDENTIFIER;
					identTok.Literal = member.Identifier;
					
					CIdentifierExpressionASTNode ident = new CIdentifierExpressionASTNode(null, identTok);
					
					CAssignmentExpressionASTNode assignment = new CAssignmentExpressionASTNode(null, op);
					assignment.LeftValue  = ident;
					assignment.IgnoreConst = true;
					assignment.RightValue = member.Assignment;//.Clone(semanter);
					assignment.AddChild(assignment.RightValue);
					assignment.AddChild(ident);

					CExpressionASTNode expr = new CExpressionASTNode(null, member.Assignment.Token);
					expr.LeftValue = assignment;
					expr.AddChild(assignment);

					Body.AddChild(expr, true);
				}
			}
		}
	}
	
	public void AddInstanceConstructorPostfix(CSemanter semanter)
	{
		// Return the class instance.
		CReturnStatementASTNode ret = new CReturnStatementASTNode(null, Token);
		ret.ReturnExpression = new CThisExpressionASTNode(null, Token);
		ret.AddChild(ret.ReturnExpression);
		Body.AddChild(ret);
	}
	
	public void AddInstanceConstructorPrefix(CSemanter semanter)
	{
		CClassASTNode classScope = FindClassScope(semanter);

		//if (classScope.IsEnum == false && classScope.IsNative == false && classScope.IsGeneric == false && classScope.IsStatic == false && classScope.InstanceConstructor == null)
		//{
		//	printf("WTF!");
		//}

		// Call instance constructor.
		if (classScope.InstanceConstructor != null)
		{	
			CToken identTok	 = classScope.InstanceConstructor.Token.Copy();
			identTok.Type	 = TokenIdentifier.IDENTIFIER;
			identTok.Literal = classScope.InstanceConstructor.Identifier;

			CMethodCallExpressionASTNode call = new CMethodCallExpressionASTNode(null, identTok);
			call.LeftValue = new CThisExpressionASTNode(null, identTok);
			call.RightValue = new CIdentifierExpressionASTNode(null, identTok);
			call.AddChild(call.LeftValue);
			call.AddChild(call.RightValue);

			CExpressionASTNode expr = new CExpressionASTNode(null, identTok);
			expr.LeftValue = call;
			expr.AddChild(call);

			Body.AddChild(expr, true);
		}

		// Now we add a call to the superclass's constructor.
		if (classScope.SuperClass != null)
		{	
			CClassMemberASTNode baseConstructor = classScope.SuperClass.FindClassMethod(semanter, classScope.SuperClass.Identifier, new List<CDataType>(), false);
			if (classScope.SuperClass.IsNative == false)
			{
				CToken identTok	 = baseConstructor.Token.Copy();
				identTok.Type	 = TokenIdentifier.IDENTIFIER;
				identTok.Literal = baseConstructor.Identifier;

				CMethodCallExpressionASTNode call = new CMethodCallExpressionASTNode(null, identTok);
				call.LeftValue = new CBaseExpressionASTNode(null, identTok);
				call.RightValue = new CIdentifierExpressionASTNode(null, identTok);
				call.AddChild(call.LeftValue);
				call.AddChild(call.RightValue);

				CExpressionASTNode expr = new CExpressionASTNode(null, identTok);
				expr.LeftValue = call;
				expr.AddChild(call);

				Body.AddChild(expr, true);
			}
		}
	}
	
	public void AddDefaultReturnExpression(CSemanter semanter)
	{
		// Make sure we don't already end with a return statement.
		if (Body == null || (Body.Children.Count() >= 1 && (Body.Children.GetIndex(Body.Children.Count() - 1) is CReturnStatementASTNode)))
		{
			return;
		}

		// Add default return statement.  
		CReturnStatementASTNode node = new CReturnStatementASTNode(Body, Token);
		node.ReturnExpression = semanter.ConstructDefaultAssignmentExpr(node, Token, ReturnType);

		node.Semant(semanter);
	}
	
	public void AddMethodConstructorStub(CSemanter semanter)
	{
	}
	
	public bool EqualToMember(CSemanter semanter, CClassMemberASTNode other)
	{
		if (MemberMemberType != other.MemberMemberType)
		{
			return false;
		}
		if (Identifier != other.Identifier)
		{
			return false;
		}
		if (!ReturnType.IsEqualTo(semanter, other.ReturnType))
		{
			return false;
		}

		if (MemberMemberType == MemberType.Method)
		{
			if (Arguments.Count() != other.Arguments.Count())
			{
				return false;
			}

			for (int i = 0; i < Arguments.Count(); i++)
			{
				CVariableStatementASTNode arg1 = Arguments.GetIndex(i);
				CVariableStatementASTNode arg2 = other.Arguments.GetIndex(i);

				if (!arg1.Type.IsEqualTo(semanter, arg2.Type))
				{
					return false;
				}
			}
		}

		return true;
	}
	
	public virtual override void Translate(CTranslator translator)
	{
		translator.TranslateClassMember(this);
	}	
}

