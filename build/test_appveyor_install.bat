@ECHO OFF

SETLOCAL
REM Does string have a trailing slash? if so remove it
SET THISDIR=%~dp0
IF %THISDIR:~-1%==\ SET THISDIR=%THISDIR:~0,-1%

ECHO Installing...
CINST poshpuppetreports -source https://ci.appveyor.com/nuget/puppet-reports-in-powershell-jssds0kkdns6