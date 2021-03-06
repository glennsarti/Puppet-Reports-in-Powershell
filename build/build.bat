@ECHO OFF

REM This assumes NUGET.EXE is in the same directory as this script or in the path
REM If not download it from http://nuget.org/nuget.exe

SETLOCAL

REM Does string have a trailing slash? if so remove it
SET THISDIR=%~dp0
IF %THISDIR:~-1%==\ SET THISDIR=%THISDIR:~0,-1%

SET WORKING=%THISDIR%\working
SET TOOLS=%WORKING%\tools
SET TOOLS_MODULE=%WORKING%\tools\module
SET SRC=%THISDIR%\..\src

PUSHD
CD /D %THISDIR%

ECHO Cleaning the working directory
RD /S /Q "%WORKING%" > NUL
MKDIR "%WORKING%"
ECHO Creating directory structure
MKDIR "%TOOLS%"
MKDIR "%TOOLS_MODULE%"

ECHO Checking poweryaml
IF NOT EXIST "%SRC%\poweryaml\PowerYaml.psm1" (
  ECHO Installing poweryaml

  CALL "%THISDIR%\..\InstallPowerYamlGithub.cmd"
)
IF NOT EXIST "%SRC%\poweryaml\PowerYaml.psm1" (
  ECHO Missing poweryaml.  Throwing an error
  EXIT /B 255
)

ECHO Copy source ready for packing...
XCOPY "%SRC%" "%TOOLS_MODULE%" /s /e /v /c /i /f /y

ECHO Removing extra files...
DEL "%TOOLS_MODULE%\InstallPowerYamlGithub.cmd"

ECHO Copying chocolatey support files...
COPY "%THISDIR%\chocolateyInstall.ps1" "%TOOLS%\chocolateyInstall.ps1"
COPY "%THISDIR%\chocolateyUninstall.ps1" "%TOOLS%\chocolateyUninstall.ps1"

ECHO Copying Nuspec package
COPY "%THISDIR%\Package.nuspec" "%WORKING%\Package.nuspec"

ECHO Getting the package version from various sources
SET PKGVERSION=0.0.1
IF NOT [%1] == [] SET PKGVERSION=%1
IF NOT [%APPVEYOR_BUILD_VERSION%] == [] SET PKGVERSION=%APPVEYOR_BUILD_VERSION%
ECHO Using package version %PKGVERSION%

ECHO Munging files with version numbers
powershell "& { . '%THISDIR%\mungefile.ps1' -File '%WORKING%\Package.nuspec' -SearchFor '0.0.1' -ReplaceWith '%PKGVERSION%' } "
powershell "& { . '%THISDIR%\mungefile.ps1' -File '%TOOLS_MODULE%\POSHPuppetReports.psd1' -SearchFor '0.0.1' -ReplaceWith '%PKGVERSION%' } "

IF NOT [%PKGVERSION%] == [] SET PKGVERSION=-Version "%PKGVERSION%"

ECHO Run Nuget Pack
"nuget.exe" pack "%WORKING%\Package.nuspec" -NonInteractive %PKGVERSION% -NoPackageAnalysis

EXIT /B %ERRORLEVEL%