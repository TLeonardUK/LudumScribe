// -----------------------------------------------------------------------------
// 	CObjectDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CObjectDataType : CDataType
{
	protected CClassASTNode m_class;
	
	public CObjectDataType(CToken token, CClassASTNode classNode)
	{
		Token = token;
		m_class = classNode;
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
		return m_class;
	}
	
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		CObjectDataType other = type as CObjectDataType;
		CNullDataType otherNull = type as CNullDataType;
		if (otherNull != null)
		{
			return true;
		}
		return other != null && other.GetClass(semanter) == GetClass(semanter);
	}
	
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
		CObjectDataType obj = type as CObjectDataType;
		
		if (obj != null)
		{
			return m_class.InheritsFromClass(semanter, obj.GetClass(semanter));
		}
		else
		{
			// Check to see if the type could have been boxed, and if its boxed class
			// allows us to convert to whatever we are converting to.
			// Object can be upcast to anything that its boxed class allows.
			if (m_class.Identifier == "object" &&
				type.GetBoxClass(semanter) != null)
			{
				// Look to see if our box-class contains an argument that accepts us.
				CClassASTNode			node	= type.GetBoxClass(semanter);
				CClassMemberASTNode		field 	= node == null ? null : node.FindClassField(semanter, "Value", null, null); 

				return field != null && field.ReturnType.IsEqualTo(semanter, type);
			}
		}

		return false;
	}
	
	public virtual override string ToString()
	{
		return m_class.ToString();
	}
	
	public virtual override CDataType Semant(CSemanter semanter, CASTNode node)
	{
		Trace.Write("CObjectDataType");
		
		if (m_class.IsEnum == true)
		{
			return new CIntDataType(Token);
		}
		else
		{
			return this;
		}
	}
	
	public virtual CClassASTNode SemantAsClass(CSemanter semanter, CASTNode node)
	{
		CObjectDataType type = Semant(semanter, node) as CObjectDataType;
		if (type != null)
		{
			return type.GetClass(semanter);
		}
		else
		{
			semanter.GetContext().FatalError("Identifier does not reference a class or interface.", Token);
		}
		return null;
	}
}

