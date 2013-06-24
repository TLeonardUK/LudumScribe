// -----------------------------------------------------------------------------
// 	CBuilder.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Responsible for compiling translated source code into a final
//	binary executable.
// =================================================================
public class CBuilder
{
	protected CTranslationUnit m_context;
	
	protected abstract bool Build();
	
	public bool Process(CTranslationUnit context)
	{
	}
	
	public CTranslationUnit GetContext()
	{
	}
	
}



