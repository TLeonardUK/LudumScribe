// -----------------------------------------------------------------------------
// 	Main.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This file just contains some code to test parts of the language.
// -----------------------------------------------------------------------------
using System.*;

public class Application
{
	public static void Main()
	{
		//string herp = "Hello World";
		//IO.Print(herp[-3:]);
		//IO.Print(herp[1:]);
		//IO.Print(herp[:3]);
		//IO.Print(herp[1:3]);
		//IO.Print(herp[:]);
	
		//object o = "Herp Derp";

		//string[][] herp;
		//herp = new string[10][];
		//herp[0] = new string[10];
		
		//int[] derp = new int[10];		
		//IO.Print("POSTFIX:"+(derp[0]++)+"\n");
		//IO.Print(" PREFIX:"+(++derp[0])+"\n");		
			
		string derp = "herp";
		foreach (int chr in derp)
		{
			IO.Print("CHR1:"+chr+"\n");
		}

		int prechr = 0;
		foreach (prechr in derp)
		{
			IO.Print("CHR2:"+prechr+"\n");
		}

		string[] h = new string[10];
		h[1] = "HERP";
		h[4] = "DERP";
		foreach (string chr in h)
		{
			IO.Print("H:"+chr+"\n");
		}

		//object 		herpObj 	= herp;
		//object[][] 	d   		= <object[][]>herp; // Should throw error.		
		//string[][] 	herpUncast 	= <string[][]>herpObj;	
	}
}
