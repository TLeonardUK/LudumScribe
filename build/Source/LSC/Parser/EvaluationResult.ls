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
		m_type = EvaluationDataType.Bool;
		m_boolValue = value;
	}
	public EvaluationResult(int value)
	{
		m_type = EvaluationDataType.Int;
		m_intValue = value;
	}
	public EvaluationResult(float value)
	{
		m_type = EvaluationDataType.Float;
		m_floatValue = value;
	}
	public EvaluationResult(string value)
	{
		m_type = EvaluationDataType.String;
		m_stringValue = value;
	}
	
	public void SetBool(bool value)
	{
		m_type = EvaluationDataType.Bool;
		m_boolValue = value;
	}
	public void SetInt(int value)
	{
		m_type = EvaluationDataType.Int;
		m_intValue = value;
	}
	public void SetFloat(float value)
	{
		m_type = EvaluationDataType.Float;
		m_floatValue = value;
	}
	public void SetString(string value)
	{
		m_type = EvaluationDataType.String;
		m_stringValue = value;
	}
	
	public bool GetBool()
	{	
		if (m_type != EvaluationDataType.Bool)
		{
			SetType(EvaluationDataType.Bool);
		}
		return m_boolValue;
	}
	public int GetInt()
	{
		if (m_type != EvaluationDataType.Int)
		{
			SetType(EvaluationDataType.Int);
		}
		return m_intValue;
	}
	public float GetFloat()
	{
		if (m_type != EvaluationDataType.Float)
		{
			SetType(EvaluationDataType.Float);
		}
		return m_floatValue;
	}
	public string GetString()
	{
		if (m_type != EvaluationDataType.String)
		{
			SetType(EvaluationDataType.String);
		}
		return m_stringValue;
	}
	
	public EvaluationDataType GetType()
	{
		return m_type;
	}
	public void SetType(EvaluationDataType type)
	{
		if (type == m_type)
		{
			return;
		}

		switch (m_type)
		{
			case EvaluationDataType.Bool:
			{
				switch (type)
				{
					case EvaluationDataType.Int:
					{
						m_intValue = m_boolValue ? 1 : 0;
						break;
					}
					case EvaluationDataType.Float:
					{
						m_floatValue = (m_boolValue ? 1.0 : 0.0);
						break;
					}
					case EvaluationDataType.String:
					{
						m_stringValue = m_boolValue ? "1" : "0";
						break;
					}
				}
				break;
			}
			case EvaluationDataType.Int:
			{
				switch (type)
				{
					case EvaluationDataType.Bool:
					{					
						m_boolValue = (m_intValue != 0);
						break;
					}
					case EvaluationDataType.Float:
					{
						m_floatValue = <float>m_intValue;
						break;
					}
					case EvaluationDataType.String:
					{
						m_stringValue = <string>m_intValue;
						break;
					}
				}
				break;
			}
			case EvaluationDataType.Float:
			{
				switch (type)
				{
					case EvaluationDataType.Bool:
					{
						m_boolValue = (m_floatValue != 0);
						break;
					}
					case EvaluationDataType.Int:
					{
						m_intValue = <int>m_floatValue;
						break;
					}
					case EvaluationDataType.String:
					{
						m_stringValue = <string>m_floatValue;
						break;
					}
				}
				break;
			}
			case EvaluationDataType.String:
			{
				switch (type)
				{
					case EvaluationDataType.Bool:
					{
						m_boolValue = (m_stringValue != "" && m_stringValue != "0");
						break;
					}
					case EvaluationDataType.Int:
					{
						m_intValue = m_stringValue.ToInt();
						break;
					}
					case EvaluationDataType.Float:
					{
						m_floatValue = m_stringValue.ToFloat();
						break;
					}
				}
				break;
			}
		}

		m_type = type;
	}
}


