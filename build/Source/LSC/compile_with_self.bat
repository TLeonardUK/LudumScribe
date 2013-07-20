@echo OFF
set OLDDIR=%CD%
cd ..\..\
Bin\LSC.exe -action compile -source "D:\main\LudumScribe\LudumScribe\build\Source\LSC\LSCSelf.lsproject" -config "Debug" -platform "Win32"
cd %OLDDIR%
pause