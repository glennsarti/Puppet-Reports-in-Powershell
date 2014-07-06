@ECHO OFF

SETLOCAL
SET TempDest=%TEMP%\poweryamlnuget
RMDIR "%TEMPDEST%" /s /q
MKDIR "%TEMPDEST%"

ECHO Installing PowerYaml Nuget Package...
nuget install poweryaml -o "%TEMPDEST%" -ExcludeVersion

ECHO Copying package files to the project...
RMDIR "%~dp0poweryaml" /s /q
XCOPY "%TEMPDEST%\PowerYaml\tools" "%~dp0..\poweryaml" /s /e /c /i /y
