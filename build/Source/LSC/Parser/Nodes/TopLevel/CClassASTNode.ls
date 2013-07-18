// -----------------------------------------------------------------------------
// 	CClassASTNode.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Stores information on a class declaration.
// =================================================================
public class CClassASTNode : CDeclarationASTNode
{
	protected bool m_semanting;
	
	// Parsing infered data.
	public AccessLevel ClassAccessLevel;
	public bool IsStatic;
	public bool IsAbstract;
	public bool IsInterface;
	public bool IsSealed;
	public bool IsGeneric;
	public bool InheritsNull;
	public bool IsInstanced;
	public bool IsEnum;
	public CASTNode InstancedBy;
	
	public bool HasBoxClass;
	public string BoxClassIdentifier;
	
	public List<CToken> GenericTypeTokens = new List<CToken>();
	public List<CIdentifierDataType> InheritedTypes = new List<CIdentifierDataType>();
	
	public CClassBodyASTNode Body;
	
	public CObjectDataType ObjectDataType;
	public CClassReferenceDataType ClassReferenceDataType;
	
	public CClassMemberASTNode ClassConstructor;
	public CClassMemberASTNode InstanceConstructor;
	
	// Semanting infered data.
	public List<CClassASTNode> GenericInstances = new List<CClassASTNode>();
	public CClassASTNode GenericInstanceOf; 
	public List<CDataType> GenericInstanceTypes = new List<CDataType>();
	
	public CClassASTNode SuperClass;
	public List<CClassASTNode> Interfaces = new List<CClassASTNode>();
	
	// =================================================================
	//	Converts this node to a string representation.
	// =================================================================
	public virtual override string ToString()
	{
		string result = Identifier;

		if (IsGeneric == true)
		{
			result += "<";
			if (GenericInstanceOf != null)
			{
				int index = 0;
				foreach (CDataType iter in GenericInstanceTypes)
				{
					if ((index++) != 0)
					{
						result += ",";
					}
					result += iter.ToString();
				}
			}
			else
			{
				int index = 0;
				foreach (CToken iter in GenericTypeTokens)
				{
					if ((index++) != 0)
					{
						result += ",";
					}
					result += iter.Literal;
				}
			}
			result += ">";
		}

		return result;	
	}
	
	// =================================================================
	//	Constructs a new instance of this class.
	// =================================================================
	public CClassASTNode(CASTNode parent, CToken token)
	{	
		CDeclarationASTNode(parent, token);
		Identifier				= "";
		ClassAccessLevel		= AccessLevel.Public;
		IsStatic				= false;
		IsAbstract				= false;
		IsInterface				= false;
		IsGeneric				= false;
		Body					= null;
		SuperClass				= null;
		InheritsNull			= false;
		ObjectDataType			= new CObjectDataType(token, this);
		ClassReferenceDataType	= new CClassReferenceDataType(token, this);
		m_semanting				= false;
		GenericInstanceOf		= null;
		ClassConstructor		= null;
		InstanceConstructor		= null;
		IsInstanced				= false;
		InstancedBy				= null;
		HasBoxClass				= false;
		BoxClassIdentifier		= "";
		IsEnum					= false;
	}
	
	// =================================================================
	//	Performs semantic analysis on this node.
	// =================================================================
	public virtual override CASTNode Semant(CSemanter semanter)
	{
		Trace.Write("CClassASTNode="+Identifier);
		
		// Only semant once.
		if (Semanted == true)
		{
			//m_semanting = false;
			return this;
		}
		Semanted = true;
		
		// Check for duplicate identifiers (only if we are not an instanced class).
		if (GenericInstanceOf == null)
		{
			Parent.CheckForDuplicateIdentifier(semanter, Identifier, this);
		}
		
		if (IsGeneric		  == false ||
			GenericInstanceOf != null)
		{
		
			// Work out mangled identifier.
			if (MangledIdentifier == "")
			{
				MangledIdentifier = semanter.GetMangled("ls_" + Identifier);
			}

			// Interface cannot use inheritance.
			if (InheritedTypes.Count() > 0 && IsInterface == true)
			{
				semanter.GetContext().FatalError("Interfaces cannot inherit from other interfaces or classes.", Token);
			}		
			if (InheritedTypes.Count() > 0 && IsStatic == true)
			{
				semanter.GetContext().FatalError("Static classes cannot inherit from interfaces.", Token);
			}
			
			// Flag this class as semanting - we do this so we can detect
			// inheritance loops.
			if (m_semanting == true)
			{
				semanter.GetContext().FatalError("Detected illegal cyclic inheritance of '" + Identifier + "'.", Token);
			}
			m_semanting = true;
		
			// Semant inherited types.
			bool foundSuper = false;
			foreach (CIdentifierDataType type in InheritedTypes)
			{
				CClassASTNode node = type.SemantAsClass(semanter, this, true);

				if (type.Identifier == Identifier)
				{
					semanter.GetContext().FatalError("Attempt to inherit class from itself.", Token);
				}

				if (node.IsInterface == true)
				{
					Interfaces.AddLast(node);
				}
				else
				{
					if (foundSuper == true)
					{
						semanter.GetContext().FatalError("Multiple inheritance is not supported. Use interfaces instead.", Token);
					}
					SuperClass = node;
					foundSuper = true;
				}
			}

			// Native classes are not allowed to implement interfaces.
			//if (IsNative == true && Interfaces.Count() > 0)
			//{
			//	semanter.GetContext().FatalError("Native classes cannot implement interfaces.", Token);
			//}

			// If no inherited types the we inherit from object.
			if (SuperClass == null && IsNative == false)
			{
				SuperClass = <CClassASTNode>(FindDeclaration(semanter, "object"));

				if (SuperClass == null)
				{
					semanter.GetContext().FatalError("Could not find base class to inherit from.", Token);
				}
			}
			else if (SuperClass != null)
			{
				// Check super class is valid.
				if (SuperClass.IsSealed == true)
				{
					semanter.GetContext().FatalError("Classes cannot inherit from sealed class.", Token);
				}
			
				// Cannot inherit in static classes.
				if (IsStatic == true)
				{
					semanter.GetContext().FatalError("Static classes cannot inherit from other classes.", Token);
				}
			}
			
			// Semant inherited classes.
			if (SuperClass != null)
			{
				SuperClass.Semant(semanter);
			}			
			foreach (CClassASTNode interfaceClass in Interfaces)
			{
				interfaceClass.Semant(semanter);
			}
		
			// Look for interface in parent classes.
			if (SuperClass != null)
			{
				foreach (CClassASTNode interfaceClass in Interfaces)
				{
					if (SuperClass.InheritsFromClass(semanter, interfaceClass) == true)
					{
						semanter.GetContext().FatalError("Attempt to implement interface '" + interfaceClass.Identifier + "' that is already implemented by a parent class.", Token);
					}
				}
			}

			// Remove semanting flag.
			m_semanting = false;		
		}

		// If we are generic we only semant children of instanced classes.
		if (IsGeneric		  == false ||
			GenericInstanceOf != null)
		{
			// Create static class constructor.
			if (IsInterface == false)
			{
				CClassMemberASTNode defaultCtor = FindClassMethod(semanter, "__"+Identifier+"_ClassConstructor", new List<CDataType>(), false);
				if (defaultCtor == null)
				{
					CClassMemberASTNode member		= new CClassMemberASTNode(null, Token);
					member.MemberMemberType			= MemberType.Method;
					member.Identifier				= "__"+Identifier+"_ClassConstructor";
					member.MemberAccessLevel		= AccessLevel.Public;
					member.Body						= new CMethodBodyASTNode(member, Token);
					member.IsConstructor			= true;
					member.IsStatic					= true;
					member.ReturnType				= new CVoidDataType(Token);
					member.IsExtension				= IsNative;
					Body.AddChild(member);

					ClassConstructor				= member; 
				}

				if (IsNative == false && IsEnum == false)
				{
					// Create instance constructor.
					CClassMemberASTNode instanceCtor = FindClassMethod(semanter, "__"+Identifier+"_InstanceConstructor", new List<CDataType>(), false);
					if (instanceCtor == null)
					{
						CClassMemberASTNode member		= new CClassMemberASTNode(null, Token);
						member.MemberMemberType			= MemberType.Method;
						member.Identifier				= "__"+Identifier+"_InstanceConstructor";
						member.MemberAccessLevel		= AccessLevel.Public;
						member.Body						= new CMethodBodyASTNode(member, Token);
						member.IsConstructor			= true;
						member.IsStatic					= false;
						member.ReturnType				= new CVoidDataType(Token);
						Body.AddChild(member);

						InstanceConstructor				= member; 
					}
				}

				// If no argument-less constructor has been provided, lets create a default one.
				if (IsStatic == false && IsAbstract == false && IsInterface == false && IsNative == false && IsEnum == false)
				{
					CClassMemberASTNode defaultCtor_a = FindClassMethod(semanter, Identifier, new List<CDataType>(), false);
					if (defaultCtor_a == null)
					{
						CClassMemberASTNode member 	= new CClassMemberASTNode(null, Token);
						member.MemberMemberType		= MemberType.Method;
						member.Identifier			= Identifier;
						member.MemberAccessLevel	= AccessLevel.Public;
						member.Body					= new CMethodBodyASTNode(member, Token);
						member.IsConstructor		= true;
						member.ReturnType			= new CVoidDataType(Token);
						Body.AddChild(member);
					}
				}
		
			}
			
			// Semant all members.
			SemantChildren(semanter);
		}

		return this;
	}
		
	// =================================================================
	//	Performs finalization on this class.
	// =================================================================
	public virtual override CASTNode Finalize(CSemanter semanter)
	{
		// If we are generic, only finalize instances.
		if (IsGeneric == false || GenericInstanceOf != null)
		{
			// Check for hiding variables and methods.
			foreach (CASTNode iter in Body.Children)
			{
				CClassMemberASTNode node = iter as CClassMemberASTNode;
				if (node != null)
				{
					CClassASTNode scope = SuperClass;
					while (scope != null)
					{
						foreach (CASTNode iter2 in scope.Body.Children)
						{
							CClassMemberASTNode node2 = iter2 as CClassMemberASTNode;
							if (node2 != null &&
								node.Identifier == node2.Identifier &&
								(
									(node.IsOverride == false && node2.IsVirtual == true) ||
									(node.MemberMemberType == MemberType.Field || node2.MemberMemberType == MemberType.Field) 
								))
							{
								if (node.MemberMemberType  == MemberType.Method ||
									node2.MemberMemberType == MemberType.Method)
								{
									semanter.GetContext().FatalError("Method '" + node.Identifier + "' in class '" + ToString() + "' hides existing declaration in class '" + scope.ToString() + "'.", node.Token);
								}
								else
								{
									semanter.GetContext().FatalError("Member '" + node.Identifier + "' in class '" + ToString() + "' hides existing declaration in class '" + scope.ToString() + "'.", node.Token);
								}
							}
						}
						scope = scope.SuperClass;
					}			
				}
			}

			// Flag us as abstract if we have any abstract methods in our inheritance tree.	
			if (IsAbstract == false)
			{
				CClassASTNode scope = this;
				List<CClassMemberASTNode> members = new List<CClassMemberASTNode>();
				while (scope != null && IsAbstract == false)
				{
					// Look for abstract methods in this scope.		
					foreach (CASTNode iter in scope.Body.Children)
					{
						CClassMemberASTNode member = (iter as CClassMemberASTNode);
						if (member != null && member.MemberMemberType == MemberType.Method)
						{
							// If member is abstract, check it is implemented in the members we have 
							// see higher in the inheritance tree so far.
							if (member.IsAbstract == true)
							{
								bool found = false;
								foreach (CClassMemberASTNode sub_member in members)
								{
									if (sub_member.EqualToMember(semanter, member))
									{
										found = true;
										break;
									}
								}

								// If not found, this class is abstract!
								if (found == false)
								{
									if (IsInstanced == true)
									{
										semanter.GetContext().FatalError("Cannot instantiate abstract class '" + ToString() + "'.", InstancedBy.Token);
									}
									IsAbstract = true;
								}
							}
							else
							{
								members.AddLast(member);
							}
						}
					}

					// Move up the inheritance tree.
					scope = scope.SuperClass;
				}
			}

			// Throw errors if we do not implement all interface functions.	
			foreach (CClassASTNode interfaceClass in Interfaces)
			{
				foreach (CASTNode iter2 in interfaceClass.Body.Children)
				{
					CClassMemberASTNode member = iter2 as CClassMemberASTNode;
					if (member != null &&
						member.MemberMemberType == MemberType.Method)
					{
						List<CDataType> argument_data_types = new List<CDataType>();
						foreach (CVariableStatementASTNode arg in member.Arguments)
						{
							argument_data_types.AddLast(arg.Type);
						}

						if (FindClassMethod(semanter, member.Identifier, argument_data_types, true, null, this) == null)
						{
							semanter.GetContext().FatalError("Class does not implement method '" + member.Identifier + "' of interface '" + interfaceClass.Identifier + "'.", Token);
						}
					}
				}
			}

			// Finalize children.
			FinalizeChildren(semanter);
		}

		// Finalize generic instances.
		else if (IsGeneric == true)
		{
			foreach (CClassASTNode iter in GenericInstances)
			{
				iter.Finalize(semanter);
			}
		}

		return this;
	}
	
	// =================================================================
	//	Creates a clone of this node.
	// =================================================================
	public virtual override CASTNode Clone(CSemanter semanter)
	{
		CClassASTNode clone = new CClassASTNode(null, Token);
		
		//clone.MangledIdentifier = this.MangledIdentifier;
		clone.IsNative			  = this.IsNative;
		clone.Identifier		 = this.Identifier;
		clone.ClassAccessLevel	 = this.ClassAccessLevel;
		clone.IsStatic			 = this.IsStatic;
		clone.IsAbstract		 = this.IsAbstract;
		clone.IsInterface		 = this.IsInterface;
		clone.IsSealed			 = this.IsSealed;
		clone.IsGeneric		 = this.IsGeneric;
		clone.InheritsNull		 = this.InheritsNull;
		clone.GenericTypeTokens = this.GenericTypeTokens;
		clone.InheritedTypes	 = this.InheritedTypes;	
		clone.HasBoxClass		 = this.HasBoxClass;
		clone.BoxClassIdentifier = this.BoxClassIdentifier;
		clone.IsEnum			 = this.IsEnum;
		clone.Body				 = <CClassBodyASTNode>(this.Body.Clone(semanter));
		clone.ObjectDataType	 = new CObjectDataType(Token, clone);
		clone.AddChild(clone.Body);

		if (ClassConstructor != null)
		{
			foreach (CASTNode iter in clone.Body.Children)
			{
				CClassMemberASTNode member = iter as CClassMemberASTNode;
				if (member != null)
				{
					if (member.Identifier == ClassConstructor.Identifier)
					{
						clone.ClassConstructor = member;
						break;
					}
				}
			}
		}
		
		if (InstanceConstructor != null)
		{
			foreach (CASTNode iter in clone.Body.Children)
			{
				CClassMemberASTNode member = iter as CClassMemberASTNode;
				if (member != null)
				{
					if (member.Identifier == InstanceConstructor.Identifier)
					{
						clone.InstanceConstructor = member;
						break;
					}
				}
			}
		}
		
		return clone;
	}
	
	// =================================================================
	//	Checks if we can access this declaration from the given node.
	// =================================================================
	public virtual override void CheckAccess(CSemanter semanter, CASTNode referenceBy)
	{
		// If we are in a different package and not public, then refuse access.
		if (Token.SourceFile != referenceBy.Token.SourceFile && this.ClassAccessLevel != AccessLevel.Public)
		{
			semanter.GetContext().FatalError("Class '" + ToString() + "' is not accessible from this package.", referenceBy.Token);
		}
	}
	
	// =================================================================
	//	Returns true if the given class is in the inheritance 
	//  or implementation tree for this class.
	// =================================================================
	public bool InheritsFromClass(CSemanter semanter, CClassASTNode node)
	{
		if (node == this)
		{
			return true;
		}

		Semant(semanter);
		node.Semant(semanter);

		CClassASTNode check = this;
		while (check != null)
		{
			// Check for direct class inheriting.
			if (check == node)
			{
				return true;
			}

			// Check for interface inheriting.
			foreach (CClassASTNode iter in check.Interfaces)
			{
				if ((iter) == node)
				{
					return true;
				}
			}

			check = check.SuperClass;
		}

		return false;
	}
	
	// =================================================================
	//	Gets the next scope up the tree to check when looking for
	//	declarations.
	// =================================================================
	public virtual override CASTNode GetParentSearchScope(CSemanter semanter)
	{
		return Parent;
	}

	// =================================================================
	//	Gets the list of children to be searched when looking for
	//	declarations.
	// =================================================================
	public virtual override List<CASTNode> GetSearchScopeChildren(CSemanter semanter)
	{
		return Body.Children;
	}
		
	// =================================================================
	//	Instantiates a copy of this class if its a generic, or just
	//	returns the class if its not generic.
	// =================================================================
	public CClassASTNode GenerateClassInstance(CSemanter semanter, CASTNode referenceNode, List<CDataType> generic_arguments)
	{
		if (IsGeneric == true)
		{
			if (generic_arguments.Count() != GenericTypeTokens.Count())
			{
				if (generic_arguments.Count() == 0)
				{
					semanter.GetContext().FatalError("Class '" + Token.Literal + "' is generic and expects generic arguments.", referenceNode.Token);
				}
				else
				{
					semanter.GetContext().FatalError("Incorrect number of generic arguments given to class '" + Token.Literal + "' during instantiation.", referenceNode.Token);
				}
			}

			// Instance with these data types already exists?
			foreach (CClassASTNode instance in GenericInstances)
			{
				bool argumentsMatch = true;
				
				for (int i = 0; i < instance.GenericInstanceTypes.Count(); i++)
				{
					if (!instance.GenericInstanceTypes.GetIndex(i).IsEqualTo(semanter, generic_arguments.GetIndex(i)))
					{
						argumentsMatch = false;
						break;
					}
				}

				if (argumentsMatch == true)
				{
					return instance;
				}
			}

			// Nope, time to create it.
			CClassASTNode astNode			= <CClassASTNode>(this.Clone(semanter));
			astNode.Parent					= Parent; // We set the derived node to our parent so it can correctly find things in its scope, but so that it can't be found by others.
			astNode.GenericInstanceOf		= this;
			astNode.GenericInstanceTypes	= generic_arguments;
			GenericInstances.AddLast(astNode);

			// Create alias's for all generic type tokens.		
			for (int i = 0; i < generic_arguments.Count(); i++)
			{
				CToken		token	= GenericTypeTokens.GetIndex(i);
				CDataType	type	= generic_arguments.GetIndex(i);
				
				CAliasASTNode alias = new CAliasASTNode(astNode.Body, this.Token, token.Literal, type);
				astNode.Body.AddChild(alias);
				alias.Semant(semanter);
			}

			// Semant our new instance.
			astNode.Semant(semanter);

			return astNode;
		}
		else
		{
			if (generic_arguments.Count() > 0)
			{
				semanter.GetContext().FatalError("Class '" + Token.Literal + "' is not generic and cannot be instantiated.", referenceNode.Token);
			}
			return this;
		}
	}
	
	// =================================================================
	//	Check for duplicate identifier.
	// =================================================================
	public virtual override CClassMemberASTNode FindClassMethod(CSemanter semanter, string identifier, List<CDataType> arguments, bool explicit_arguments, CASTNode ignoreNode=null, CASTNode referenceNode=null)
	{
		// Make sure this class is semanted.
		if (!Semanted)
		{
			Semant(semanter);
		}

		// Find all possible methods with the name.
		List<CClassMemberASTNode> nodes = new List<CClassMemberASTNode>();

		CClassASTNode scope = this;
		while (scope != null)
		{
			if (scope.Body != null)
			{
				foreach (CASTNode iter in scope.Body.Children)
				{
					CClassMemberASTNode member = iter as CClassMemberASTNode;
					if (member				!= null &&
						member.MemberMemberType	== MemberType.Method && 
						member.Identifier	== identifier &&
						member				!= ignoreNode &&
						arguments.Count()	<= member.Arguments.Count())
					{

						// Has one of the other members overridcen this method already?
						bool alreadyExists = false;
						foreach (CClassMemberASTNode member2 in nodes)
						{
							if (member.Identifier == member2.Identifier &&
								member.Arguments.Count() == member2.Arguments.Count() &&
								member.IsVirtual == true && member2.IsOverride == true)
							{
								bool argsSame = true;

								for ( int i = 0; i < member.Arguments.Count(); i++)
								{
									CVariableStatementASTNode arg = member.Arguments.GetIndex(i);
									CVariableStatementASTNode arg2 = member2.Arguments.GetIndex(i);
									if (!arg.Type.IsEqualTo(semanter, arg2.Type))
									{
										argsSame = false;
										break;
									}
								}

								if (argsSame == true)
								{
									alreadyExists = true;
									break;
								}
							}
						}

						if (alreadyExists == false)
						{
							member.Semant(semanter);
							nodes.AddLast(member);
						}
					}
				}
			}
			scope = scope.SuperClass;
		}

		// Try and find amatch!
		CClassMemberASTNode  match			= null;
		bool				 isExactMatch	= false;
		string				 errorMessage	= "";

		// Look for valid nodes.	
		foreach (CClassMemberASTNode member in nodes)
		{
			bool exact		= true;
			bool possible	= true;

			for ( int i = 0; i < member.Arguments.Count(); i++)
			{
				CVariableStatementASTNode arg = member.Arguments.GetIndex(i);

				if (arguments.Count() > member.Arguments.Count())
				{
					continue;
				}

				if (i < arguments.Count())
				{
					if (arguments.GetIndex(i).IsEqualTo(semanter, arg.Type))
					{
						continue;
					}
					exact = false;

					if (!explicit_arguments && CCastExpressionASTNode.IsValidCast(semanter, arguments.GetIndex(i), arg.Type, false))// arguments.at(i).CanCastTo(semanter, arg.Type))
					{
						continue;
					}
				}
				else if (arg.AssignmentExpression != null)
				{
					exact = false;
					if (!explicit_arguments)
					{
						continue;
					}
				}

				possible = false;
				break;
			}

			if (!possible)
			{
				continue;
			}

			if (exact == true)
			{
				if (isExactMatch == true)
				{
					semanter.GetContext().FatalError("Found ambiguous reference to method of class '" + Identifier + "'. Reference could mean either '" + match.ToString() + "' or '" + member.ToString() + "'.",
													 referenceNode == null ? Token : referenceNode.Token);
				}
				else
				{
					errorMessage	= "";
					match			= member;
					isExactMatch	= true;
				}
			}
			else
			{
				if (!isExactMatch)
				{
					if (match != null)
					{
						errorMessage = "Found ambiguous reference to method of class '" + Identifier + "'. Reference could mean either '" + match.ToString() + "' or '" + member.ToString() + "'.";
					}
					else
					{
						match = member;
					}
				}
			}
		}

		// Return?
		if (!isExactMatch)
		{
			if (errorMessage != "")
			{
				semanter.GetContext().FatalError(errorMessage, referenceNode == null ? Token : referenceNode.Token);
			}
			if (explicit_arguments == true)
			{
				return null;
			}
		}

		// No match available? :S
		if (match == null)
		{
			return null;
		}

		// Return matched class.
		return match;
	}	
	
	// =================================================================
	//	Check for duplicate identifier.
	// =================================================================
	public virtual override CClassMemberASTNode FindClassField(CSemanter semanter, string identifier, CASTNode ignoreNode, CASTNode referenceNode)
	{
		// Make sure this class is semanted.
		if (!Semanted)
		{
			Semant(semanter);
		}

		// Look for some sweet sweet methods.
		if (Body != null)
		{
			CClassMemberASTNode result = null;

			// Look for explicit member matchs.
			foreach (CASTNode iter in Body.Children)
			{
				CClassMemberASTNode classNode = iter as CClassMemberASTNode;
				if (classNode					!= null &&
					classNode					!= ignoreNode &&
					classNode.Identifier		== identifier &&
					classNode.MemberMemberType	== MemberType.Field)
				{
					
					result = classNode; 
				}
			}

			// Return result!
			if (result != null)
			{
				return result;
			}
		}

		// Look up the inheritance tree.
		if (SuperClass != null)
		{
			return SuperClass.FindClassField(semanter, identifier, ignoreNode, referenceNode);
		}
		else
		{
			return null;
		}
	}
	
	// =================================================================
	//	Causes this node to be translated.
	// =================================================================
	public virtual override void Translate(CTranslator translator)
	{
		if (IsGeneric == true)
		{		
			foreach (CClassASTNode instance in GenericInstances)
			{
				translator.TranslateClass(instance);
			}
		}
		else
		{
			translator.TranslateClass(this);
		}
	}	
}

