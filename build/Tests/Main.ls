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
		string herp = "Hello World";
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

		object 		herpObj 	= herp;
		string[][] 	herpUncast 	= <string[][]>herpObj;	
	}
}
