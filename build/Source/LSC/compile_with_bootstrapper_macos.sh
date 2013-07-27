set OLDDIR=$PWD
cd ../../
Bin/Bootstrapper.macos -action compile -source "Source\LSC\LSC.lsproject" -config "Debug" -platform "Macos"
cd $OLDDIR