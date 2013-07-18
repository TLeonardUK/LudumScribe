@echo OFF
set OLDDIR=%CD%
cd ..\..\

echo "Compiling With Bootstrapper ..."
Bin\Bootstrapper.exe -action compile -source "Source\LSC\LSCSelf.lsproject" -config "Debug" -platform "Win32" > "%OLDDIR%\bootstrapper_trace.log"
echo "Completed"

echo "Compiling With Self-Hosting Compiler ..."
Bin\LSC.exe -action compile -source "Source\LSC\LSCSelf.lsproject" -config "Debug" -platform "Win32" > "%OLDDIR%\self_trace.log"
echo "Completed"

cd %OLDDIR%
pause