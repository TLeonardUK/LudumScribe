@echo OFF
set OLDDIR=%CD%
cd ..\
Bin\Bootstrapper.exe -action compile -source "D:\main\ludumscribe\ludumscribe\build\Tests\Main.lsproject" -config "Debug" -platform "Win32"
cd %OLDDIR%
echo ==============================================================================
echo Running Build
echo ==============================================================================
Build\Main.ls\Debug\Win32\Main.exe
echo ==============================================================================