// -----------------------------------------------------------------------------
// 	os.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to interact with
//	the target languages runtime/environment/os/shiz.
// -----------------------------------------------------------------------------
using native {NATIVE_PACKAGE_NAMESPACE}.System.OS;

// -----------------------------------------------------------------------------
//	This class is used to interact with the target languages garbage collector.
//	Some target languages will not allow interaction with the garbage collector,
//	if this is the case then the method of this class will act as if they
//	are empty.
// -----------------------------------------------------------------------------
public static native("lsOS") class OS
{
	public static native("GetTicks") 				int 	GetTicks			();
	public static native("Exit") 					void 	Exit				(int exitcode = 0);
	public static native("Execute") 				bool 	Execute				(string executable, string command_line);
	public static native("GetEnvironmentString") 	string	GetEnvironmentString();

	public static Map<string,string> GetEnvironmentMap()
	{
		Map<string,string> map = new Map<string,string>();
		
		string[] cracked = GetEnvironmentString().Split("|");
		foreach (string var in cracked)
		{
			string[] varSplit = var.Split("=");
			map.Insert(varSplit[0], varSplit[1]);
		}
		
		return map;
	}
}
