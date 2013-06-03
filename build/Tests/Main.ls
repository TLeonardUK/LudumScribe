// -----------------------------------------------------------------------------
// 	Main.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This file just contains some code to test parts of the language.
// -----------------------------------------------------------------------------
using System.*;
using System.Collections.*;

// GC
// Collections
// Extended String Functions

public class Application
{
	public static void Main()
	{
		int[] intArray = new int[10];
		intArray[5] = 123;
		
		Application[] objArray = new Application[10];
		objArray[5] = new Application();
	
	//	Derp d = new Derp();
	//	GC.Collect(true);
	//	d = new Derp();
	//	GC.Collect(true);
	//	d = new Derp();
	//	GC.Collect(true);	
	//	d = new Derp();
	//	GC.Collect(true);
	//	d = new Derp();
	//	GC.Collect(true);

		Console.WriteLine("Done. Press any key to continue.");
		Console.ReadChar();
	
//		while (true)
//		{		
//			Derp d = new Derp();		
			//GC.Collect();
//		}
	}
}
