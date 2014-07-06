@ECHO OFF

ECHO Cloning PowerYaml
git clone https://github.com/scottmuc/PowerYaml "%~dp0..\poweryaml" --depth 1

ECHO Removing the Git directory (Stops it being detected as a submodule)
RMDIR "%~dp0..\poweryaml\.git" /s /q
