/* *****************************************************************

		CMakeBuilder.cpp

		Copyright (C) 2012 Tim Leonard - All Rights Reserved

   ***************************************************************** */

#include "CMakeBuilder.h"

#include "CBuilder.h"

#include "CPathHelper.h"
#include "CStringHelper.h"

#include "CASTNode.h"
#include "CPackageASTNode.h"

#include "CSemanter.h"

#include "CTranslationUnit.h"

#include "CCompiler.h"

// =================================================================
//	Build this mofo!
// =================================================================
bool CMakeBuilder::Build()
{
	std::string project_dir = m_context->GetCompiler()->GetProjectDirectory();

	std::string build_dir = m_context->GetCompiler()->GetBuildDirectory();
	CConfigState project_config = m_context->GetCompiler()->GetProjectConfig();

	std::vector<std::string> configs = CStringHelper::Split(project_config.GetString("SUPPORTED_CONFIGS"), '|');
	std::string config_name = project_config.GetString("CONFIG");
	std::string output_file_name = project_config.GetString("OUTPUT_FILE");

	std::vector<std::string> files = m_context->GetTranslatedFiles();

	std::string output_dir = project_config.GetString("OUTPUT_DIR");

	if (CPathHelper::IsRelative(output_dir))
	{
		output_dir = project_dir +"/" + output_dir;
	}
	output_dir = CPathHelper::GetAbsolutePath(CPathHelper::CleanPath(output_dir));

	// Gather all source files in the build folder.
	std::vector<std::string> source_files;
	std::vector<std::string> object_files;
	std::vector<std::string> header_files;
	std::vector<std::string> library_files;
	for (std::vector<std::string>::iterator iter = files.begin(); iter != files.end(); iter++)
	{
		std::string file = CPathHelper::CleanPath(*iter);
		std::string ext = CStringHelper::ToLower(CPathHelper::ExtractExtension(file));

		if (ext == "hpp" || ext == "h")
		{
			header_files.push_back(file);
		}
		else if (ext == "a" || ext == "o")
		{
			library_files.push_back(file);
			object_files.push_back(file);
		}
		else 
		{
			source_files.push_back(file);
			object_files.push_back(CPathHelper::StripExtension(file) + ".o");
		}
	}

	// Work out include directories.
	std::vector<std::string> include_paths;
	for (std::vector<std::string>::iterator iter = header_files.begin(); iter != header_files.end(); iter++)
	{
		std::string dir = CPathHelper::StripFilename(*iter) + "/";
		std::string relative = CPathHelper::GetRelativePath(dir, build_dir);
		if (relative == "")
		{
			relative = ".";
		}

		bool found = false;

		for (std::vector<std::string>::iterator iter2 = include_paths.begin(); iter2 != include_paths.end(); iter2++)
		{
			if (relative == *iter2)
			{
				found = true;
				break;
			}
		}

		if (found == false)
		{
			include_paths.push_back(relative);
		}
	}
	
	// Work out library directories.
	std::vector<std::string> full_library_paths;
	std::vector<std::string> full_library_names;
	for (std::vector<std::string>::iterator iter = library_files.begin(); iter != library_files.end(); iter++)
	{
		std::string dir = CPathHelper::StripFilename(*iter) + "/";
		std::string relative = CPathHelper::GetRelativePath(dir, build_dir);
		if (relative == "")
		{
			relative = ".";
		}

		bool found = false;

		for (std::vector<std::string>::iterator iter2 = full_library_paths.begin(); iter2 != full_library_paths.end(); iter2++)
		{
			if (relative == *iter2)
			{
				found = true;
				break;
			}
		}

		if (found == false)
		{
			full_library_paths.push_back(relative);
			full_library_names.push_back(CPathHelper::StripDirectory(*iter));
		}
	}
	
	std::string solution_file_path = build_dir + "/makefile";
	std::string solution_file = "";
	
	std::string source_file_string = "";
	std::string object_file_string = "";

	std::string source_dir = CPathHelper::GetAbsolutePath(build_dir);
	std::string object_dir = CPathHelper::GetAbsolutePath(build_dir);

	for (std::vector<std::string>::iterator iter = source_files.begin(); iter != source_files.end(); iter++)
	{
		std::string relative = CPathHelper::GetRelativePath(*iter, solution_file_path);
		source_file_string += (source_file_string != "" ? "  " : "") + source_dir + relative;
	}

	for (std::vector<std::string>::iterator iter = object_files.begin(); iter != object_files.end(); iter++)
	{
		std::string relative = CPathHelper::GetRelativePath(*iter, solution_file_path);
		object_file_string += (object_file_string != "" ? " " : "") + object_dir + relative;
	}

	solution_file += std::string("OUTPUT_FILE  = ") + output_file_name + "\n";
	solution_file += std::string("SOURCE_EXT   = cpp") + "\n";
	solution_file += std::string("SOURCE_DIR   = ") + source_dir + "\n";
	solution_file += std::string("OBJECT_DIR   = ") + object_dir + "\n";
	solution_file += std::string("OUTPUT_DIR   = ") + output_dir + "\n";
	solution_file += std::string("") + "\n";
	solution_file += std::string("SOURCE_FILES = ") + source_file_string + "\n";
	solution_file += std::string("OBJECT_FILES = ") + object_file_string + "\n";
	solution_file += std::string("") + "\n";	
	solution_file += std::string("CC		   = g++\n");
	solution_file += std::string("CFLAGS	   = -w -c -I ") + CPathHelper::GetAbsolutePath(build_dir) + " " + project_config.GetString("MAKE_CFLAGS") + "\n";
	solution_file += std::string("LDFLAGS	   = ") +  project_config.GetString("MAKE_LDFLAGS") + "\n";
	solution_file += std::string("") + "\n";		
	solution_file += std::string(".PHONY: all clean") + "\n";
	solution_file += std::string("") + "\n";		
	solution_file += std::string("all: $(OUTPUT_DIR)/$(OUTPUT_FILE)") + "\n";	
	solution_file += std::string("") + "\n";		
	solution_file += std::string("$(OUTPUT_DIR)/$(OUTPUT_FILE): $(OBJECT_FILES)") + "\n";
	solution_file += std::string("	@echo \"Linking $@...\"") + "\n";
	solution_file += std::string("	@$(CC) $(OBJECT_FILES) $(LDFLAGS) -o $@") + "\n";
	solution_file += std::string("") + "\n";
	solution_file += std::string("%.o: %.$(SOURCE_EXT)") + "\n";
	solution_file += std::string("	@echo \"Compiling $<...\"") + "\n";
	solution_file += std::string("	@$(CC) $(CFLAGS) $< -o $@") + "\n";
	solution_file += std::string("") + "\n";		
	solution_file += std::string("clean:") + "\n";
	solution_file += std::string("	$(RM) -r $(OBJECT_DIR)") + "\n";
	
	// Emit solution file.
	bool updated = true;
	std::string output = "";
	if (CPathHelper::LoadFile(solution_file_path, output))
	{
		if (output == solution_file)
		{
			updated = false;
		}
	}
	if (updated == true)
	{
		CPathHelper::SaveFile(solution_file_path, solution_file);
	}
	
	// Try and find location of msbuild.
	std::string path = CPathHelper::CleanPath(project_config.GetString("MAKE_PATH"));
	if (!CPathHelper::IsFile(path))
	{
		m_context->FatalError("Could not find Make at expected location, are you sure it is installed? Expected Location: " + path);
	}
	
	// Execute!
	std::string cmd_line =  "--makefile=" + solution_file_path + ""; 
	if (!m_context->Execute(path, cmd_line))
	{
		m_context->FatalError("Make could not compile output.");
	}

	return true;
}
