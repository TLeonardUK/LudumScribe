// -----------------------------------------------------------------------------
// 	path.ls
// 	Copyright (C) 2012-2013 TwinDrills, All Rights Reserved
// -----------------------------------------------------------------------------
//	This package contains the declarations of the class used to perform
//	common path manipulation.
// -----------------------------------------------------------------------------
using native Native.{PLATFORM}.System.Path;

// -----------------------------------------------------------------------------
//	This class is used to perform several common path manipulation functions.
// -----------------------------------------------------------------------------
public static native("lsPath") class Path
{
	public static native("IsRelative") 			bool 	IsRelative			(string path);
	public static native("IsAbsolute") 			bool 	IsAbsolute			(string path);
	
	public static native("Normalize") 			string 	Normalize			(string path);
	public static native("GetRelative") 		string 	GetRelative			(string path, string relative);
	public static native("GetAbsolute") 		string 	GetAbsolute			(string path);
	
	public static native("StripDirectory") 		string 	StripDirectory		(string path);
	public static native("StripFilename") 		string 	StripFilename		(string path);
	public static native("StripExtension") 		string 	StripExtension		(string path);
	public static native("StripVolume") 		string 	StripVolume			(string path);

	public static native("ChangeExtension") 	string 	ChangeExtension		(string path, string newFragment);
	public static native("ChangeFilename") 		string 	ChangeFilename		(string path, string newFragment);
	public static native("ChangeDirectory") 	string 	ChangeDirectory		(string path, string newFragment);
	public static native("ChangeVolume") 		string 	ChangeVolume		(string path, string newFragment);
	
	public static native("ExtractDirectory") 	string 	ExtractDirectory	(string path);
	public static native("ExtractFilename") 	string 	ExtractFilename		(string path);
	public static native("ExtractExtension") 	string 	ExtractExtension	(string path);
	public static native("ExtractVolume") 		string 	ExtractVolume		(string path);
	
	public static native("Join") 				string   Join				(string[] path);
	public static native("Crack") 				string[] Crack				(string path);	
}
