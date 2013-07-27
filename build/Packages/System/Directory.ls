// -----------------------------------------------------------------------------
// 	directory.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common directory manipulation.
// -----------------------------------------------------------------------------
using native {NATIVE_PACKAGE_NAMESPACE}.System.Directory;

// -----------------------------------------------------------------------------
//	Specifies what type of information Directory.List should return.
// -----------------------------------------------------------------------------
public enum DirectoryListType
{
	Directories = 1,		// Don't change the values, native code makes assumptions based on it.
	Files = 2
}

// -----------------------------------------------------------------------------
//	This class is used to perform several common directory manipulation functions.
// -----------------------------------------------------------------------------
public static native("lsDirectory") class Directory
{
	public static native("Create") 				bool Create					(string path, bool recursive=false);
	public static native("Delete") 				bool Delete					(string path, bool recursive=false);
	public static native("Copy") 				bool Copy					(string path, string from, bool merge=false);
	public static native("Rename") 				bool Rename					(string from, string to);
	public static native("Exists") 				bool Exists					(string path);

	public static native("GetWorkingDirectory") string GetWorkingDirectory	();
	public static native("SetWorkingDirectory") bool   SetWorkingDirectory	(string path);
	
	public static native("List") 				string[] List				(string from, DirectoryListType listTypes, bool recursive=false);
	public static native("ListVolumes") 		string[] ListVolumes		();
}
