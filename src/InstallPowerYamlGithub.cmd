@ECHO OFF

RMDIR "%~dp0poweryaml" /S /Q > NUL

ECHO Cloning PowerYaml
git clone https://github.com/scottmuc/PowerYaml "%~dp0poweryaml" 

ECHO Removing the Git directory (Stops it being detected as a submodule)
RMDIR "%~dp0poweryaml\.git" /s /q
DEL "%~dp0poweryaml\.git*"
