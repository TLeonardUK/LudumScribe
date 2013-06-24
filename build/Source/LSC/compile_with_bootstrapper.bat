@echo OFF
set OLDDIR=%CD%
cd ..\..\
Bin\Bootstrapper.exe -action compile -source "Source\LSC\LSC.lsproject" -config "Debug" -platform "Win32"
cd %OLDDIR%