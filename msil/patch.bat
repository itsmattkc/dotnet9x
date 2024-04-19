@echo off
setlocal
cd /d %~dp0
mkdir build
mkdir temp
cd temp

goto patchFiles

:doPatch
..\..\bin\ildasm\ildasm.exe /out=%~1.asm ../../bin/dotnetfx20/URTInstallPath/%~1.dll
..\..\bin\patch\patch %~1.asm ..\%~1.patch
..\..\bin\dotnetfx20\URTInstallPath\ilasm.exe /dll %~1.asm
copy %~1.dll ..\build
goto :eof

:patchFiles
call:doPatch System.Windows.Forms
call:doPatch mscorlib
call:doPatch System.configuration
