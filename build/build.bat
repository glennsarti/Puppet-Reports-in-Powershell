@ECHO OFF

REM This assumes NUGET.EXE is in the same directory as this script or in the path
REM If not download it from  http://nuget.org/nuget.exe

SETLOCAL

REM Does string have a trailing slash? if so remove it
SET THISDIR=%~dp0
IF %THISDIR:~-1%==\ SET THISDIR=%THISDIR:~0,-1%

SET WORKING=%THISDIR%\working
SET TOOLS=%WORKING%\tools
SET SRC=%THISDIR%\..\src

PUSHD
CD /D %THISDIR%

ECHO Cleaning the working directory
RD /S /Q "%WORKING%" > NUL
MKDIR "%WORKING%"

ECHO Copy source ready for packing...
MKDIR "%TOOLS%"
XCOPY "%SRC%" "%TOOLS%" /s /e /v /c /i /f /y

ECHO Removing extra files...
DEL "%WORKING%\Tools\InstallPowerYamlGithub.cmd"

SET PKGVERSION=%APPVEYOR_BUILD_VERSION%
IF NOT [%PKGVERSION%] == [] SET PKGVERSION=-Version "0.9.%PKGVERSION%"
ECHO Using package version %PKGVERSION%

ECHO Run Nuget Pack
"nuget.exe" pack  "%~dp0Package.nuspec" -OutputDirectory "%THISDIR%" -BasePath "%WORKING%" -NonInteractive %PKGVERSION%

EXIT /B %ERRORLEVEL%
