@ECHO OFF

SETLOCAL

RMDIR "%~dp0poweryaml" /S /Q > NUL

SET TempDest=%TEMP%\poweryamlnuget
RMDIR "%TEMPDEST%" /s /q
MKDIR "%TEMPDEST%"

ECHO Installing PowerYaml Nuget Package...
nuget install poweryaml -o "%TEMPDEST%" -ExcludeVersion

ECHO Copying package files to the project...
RMDIR "%~dp0poweryaml" /s /q
XCOPY "%TEMPDEST%\PowerYaml\tools" "%~dp0poweryaml" /s /e /c /i /y
