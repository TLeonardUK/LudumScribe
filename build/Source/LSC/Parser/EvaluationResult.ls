// -----------------------------------------------------------------------------
// 	EvaluationResult.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// =================================================================
//	Data types.
// =================================================================
public enum EvaluationDataType
{
	Int,
	Float,
	String,
	Bool
}

// =================================================================
//	Stores a constant evaluation result.
// =================================================================
public class EvaluationResult
{
	private EvaluationDataType m_type;
	
	private bool m_boolValue;
	private int m_intValue;
	private float m_floatValue;
	private string m_stringValue;
	
	public EvaluationResult(bool value)
	{
	}
	public EvaluationResult(int value)
	{
	}
	public EvaluationResult(float value)
	{
	}
	public EvaluationResult(string value)
	{
	}
	
	public void SetBool(bool value)
	{
	}
	public void SetInt(int value)
	{
	}
	public void SetFloat(float value)
	{
	}
	public void SetString(string value)
	{
	}
	
	public bool GetBool()
	{
	}
	public int GetInt()
	{
	}
	public float GetFloat()
	{
	}
	public string GetString()
	{
	}
	
	public EvaluationDataType GetType()
	{
	}
	public void SetType(EvaluationDataType type)
	{
	}
}


