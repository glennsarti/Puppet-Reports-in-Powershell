@ECHO OFF

SETLOCAL

SET DSTDIR="%~dp0src\poweryaml"
RMDIR "%DSTDIR%" /S /Q > NUL

ECHO Cloning PowerYaml
git clone https://github.com/scottmuc/PowerYaml "%DSTDIR%" 

ECHO Removing the Git directory (Stops it being detected as a submodule)
RMDIR "%DSTDIR%\.git" /s /q
DEL "%DSTDIR%\.git*"
