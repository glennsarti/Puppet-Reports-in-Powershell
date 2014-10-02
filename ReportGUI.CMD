@ECHO OFF

SETLOCAL
SET REPNAME= 
SET TEMPNAME=
IF NOT [%1]==[] SET REPNAME=-Report '%1'
IF NOT [%2]==[] SET TRANSNAME=-Transform '%2'

powershell "& { . '%~dp0src\reportgui\reportgui.ps1' %REPNAME% %TRANSNAME%}"

EXIT /B %ERRORLEVEL%