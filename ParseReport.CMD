@ECHO OFF

REM powershell "& { . '%~dp0parsereport.ps1' -Report '%~dp0examples\201407020852.yaml','%~dp0examples\201405290717.yaml' -Transform 'detailed.report.html' -OutputXML -OutputDir '%~dp0downloads'}"
powershell "& { . '%~dp0parsereport.ps1' -Report '%~dp0examples\201407020852.yaml' -Transform 'teamcity.tests.stdout' -OutputDir '%~dp0downloads'}"
