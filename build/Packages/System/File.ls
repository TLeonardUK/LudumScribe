// -----------------------------------------------------------------------------
// 	file.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common file manipulation.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.System.File;

// -----------------------------------------------------------------------------
//	This class is used to perform several common file manipulation functions.
// -----------------------------------------------------------------------------
public static native("lsFile") class File
{
	public static native("Create") 		bool Create	(string path, bool recursive=false);
	public static native("Delete") 		bool Delete	(string path);
	public static native("Copy") 		bool Copy	(string path, string from, bool overwrite=false);
	public static native("Rename") 		bool Rename	(string from, string to);
	public static native("Exists") 		bool Exists	(string path);
	
	// TODO: These need replacing with a proper IO framework.
	public static native("LoadText")	string LoadText	(string path);
	public static native("SaveText")	void   SaveText	(string path, string contents);
}
