set OLDDIR=$PWD
cd ../../
Bin/Bootstrapper.linux -action compile -source "Source\LSC\LSC.lsproject" -config "Debug" -platform "Linux"
cd $OLDDIR