// -----------------------------------------------------------------------------
// 	CIdentifierDataType.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Base class for all data types.
// =================================================================
public class CIdentifierDataType : CDataType
{
	private bool m_do_not_semant_dt;

	public string Identifier;
	public List<CDataType> GenericTypes = new List<CDataType>();
	
	public CIdentifierDataType(CToken token, string identifier, List<CDataType> genericTypes)
	{
		Token = token;
		Identifier = identifier;
		GenericTypes = genericTypes;
	}
	
	public virtual override CClassASTNode GetClass(CSemanter semanter)
	{
		return null;
	}
	
	public virtual override bool IsEqualTo(CSemanter semanter, CDataType type)
	{
		semanter.GetContext().FatalError("CIdentifierDataType.IsEqualTo invoked! This should have already been resolved!", Token);
		return false;
	}
	
	public virtual override bool CanCastTo(CSemanter semanter, CDataType type)
	{
		return IsEqualTo(semanter, type);
	}
	
	public virtual override string ToString()
	{
		if (GenericTypes.Count() > 0)
		{
			string args = "";
			foreach (CDataType iter in GenericTypes)
			{
				if (args != "")
				{
					args += ",";
				}
				args += iter.ToString();
			}
			return Identifier + "<" + args + ">";
		}
		else
		{
			return Identifier;
		}
	}
	
	public virtual override CDataType Semant(CSemanter semanter, CASTNode node)
	{
		Trace.Write("CIdentifierDataType");
		
		List<CDataType> generic_arguments = new List<CDataType>();

		foreach (CDataType iter in GenericTypes)
		{
			generic_arguments.AddLast(iter.Semant(semanter, node));
		}

		CDataType type = node.FindDataType(semanter, Identifier, generic_arguments, false, m_do_not_semant_dt);
		if (type == null)
		{
			semanter.GetContext().FatalError("Unknown data type '" + ToString() + "'.", Token);
		}
		
		return type.Semant(semanter, node);
	}
	
	public virtual CClassASTNode SemantAsClass(CSemanter semanter, CASTNode node, bool do_not_semant)
	{
		m_do_not_semant_dt = do_not_semant;
		CObjectDataType type = Semant(semanter, node) as CObjectDataType;
		m_do_not_semant_dt = false;
		
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

