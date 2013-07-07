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
		
	// =================================================================
	//	Processes input and performs the actions requested.
	// =================================================================
	public bool Process(CTranslationUnit context)
	{
		m_context = context;
		return Build();
	}
		
	// =================================================================
	//	Returns the context being translated.
	// =================================================================
	public CTranslationUnit GetContext()
	{
		return m_context;
	}
}



