// -----------------------------------------------------------------------------
// 	Main.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This file just contains some code to test parts of the language.
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// Collections
// Reflection code

// 

public class Application
{


	public static int Main(string[] args)
	{
	/*	List<int> derp = new List<int>();
		derp.AddFirst(1);
		derp.AddFirst(2);
		derp.AddFirst(3);
		derp.AddFirst(4);
		derp.AddFirst(5);
		derp.AddFirst(5);
		derp.AddLast(99);
		
		foreach (int v in derp)
		{
			Console.WriteLine("Value:"+v);
		}

		return;
		*/
		
		string testString = "  This is a test  ";
		
		Console.WriteLine("\"" + testString + "\".Trim()=\"" + testString.Trim() + "\"");
		Console.WriteLine("\"" + testString + "\".TrimStart()=\"" + testString.TrimStart() + "\"");
		Console.WriteLine("\"" + testString + "\".TrimEnd()=\"" + testString.TrimEnd() + "\"");
		
		Console.WriteLine("\"" + testString + "\".SubString(4, 5)=\"" + testString.SubString(4, 5) + "\"");

		Console.WriteLine("\"" + testString + "\".PadLeft(20, \"#|\")=\"" + testString.PadLeft(20, "#|") + "\"");
		Console.WriteLine("\"" + testString + "\".PadRight(20, \"#|\")=\"" + testString.PadRight(20, "#|") + "\"");

		Console.WriteLine("\"" + testString + "\".Reverse()=\"" + testString.Reverse() + "\"");
		Console.WriteLine("\"" + testString + "\".Remove(3,3)=\"" + testString.Remove(3, 3) + "\"");
		Console.WriteLine("\"" + testString + "\".Insert(\"Derp\",3)=\"" + testString.Insert("Derp", 3) + "\"");
		Console.WriteLine("\"" + testString + "\".Replace(\"This\",\"Derp\")=\"" + testString.Replace("This", "Derp") + "\"");
		
		Console.WriteLine("\"" + testString + "\".LimitStart(10)=\"" + testString.LimitStart(10) + "\"");
		Console.WriteLine("\"" + testString + "\".LimitEnd(10)=\"" + testString.LimitEnd(10) + "\"");

		Console.WriteLine("\"" + testString + "\".LimitStart(3)=\"" + testString.LimitStart(3) + "\"");
		Console.WriteLine("\"" + testString + "\".LimitEnd(3)=\"" + testString.LimitEnd(3) + "\"");

		Console.WriteLine("\"" + testString + "\".ToLower()=\"" + testString.ToLower() + "\"");
		Console.WriteLine("\"" + testString + "\".ToUpper()=\"" + testString.ToUpper() + "\"");
		
		Console.WriteLine("\"" + testString + "\".Contains('test')=\"" + (<string>testString.Contains("test")) + "\"");		
		Console.WriteLine("\"" + testString + "\".ContainsAny({'d', 'derp'})=\"" + (<string>testString.ContainsAny({ 'd', 'derp' })) + "\"");

		Console.WriteLine("\"" + testString + "\".IndexOf('t')=\"" + (<string>testString.IndexOf("t")) + "\"");
		Console.WriteLine("\"" + testString + "\".LastIndexOf('t')=\"" + (<string>testString.LastIndexOf("t")) + "\"");

		
		Console.WriteLine("\"" + testString + "\".StartsWith('  This')=\"" + (<string>testString.StartsWith("  This")) + "\"");
		Console.WriteLine("\"" + testString + "\".EndsWith('test  ')=\"" + (<string>testString.EndsWith("test  ")) + "\"");
	
		Console.WriteLine("\",\".Join({'a', 'b', 'c'})=\"" + (",".Join({ "a", "b", "c" })) + "\"");
		Console.Write("\"a,b,,c,d\".Split(',')=[ ");
		string[] split = "a,b,,c,d".Split(",");
		for (int i = 0; i < split.Length(); i++)
		{
			if (i != 0)
			{
				Console.Write(", ");
			}
			Console.Write(split[i]);
		}		
		Console.WriteLine(" ]");
		
		
		Console.Write("[ 'a', 'b', 'c' ].Shift(-1)=[ ");
		string[] shift = { 'a', 'b', 'c' };
		shift.AddLast({ 'L', 'A', 'S', 'T' });
		shift.AddFirst({ 'F', 'I', 'R', 'S', 'T' });
		for (int i = 0; i < shift.Length(); i++)
		{
			if (i != 0)
			{
				Console.Write(", ");
			}
			Console.Write("'" + shift[i] + "'");
		}		
		Console.WriteLine(" ]");
		
		
		//Console.WriteLine("Done. Press any key to continue.");
		//Console.ReadChar();
	}
}
