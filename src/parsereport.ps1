param([string[]]$Report = '', [string[]]$Transform = '', [string]$OutputDir = '', [switch]$OutputXML = $false)

$ErrorActionPreference = "Stop"
$DebugPreference = "Continue" #"SilentlyContinue"
$VerbosePreference = "Continue" #"SilentlyContinue"

# Load required modules
# TODO Do we need to change this behaviour?  Only load if it isn't already
Write-Verbose 'Removing PowerYaml Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'PowerYaml' } | Remove-Module
Write-Verbose 'Loading the PowerYaml module'
Import-Module "$PSScriptRoot\poweryaml\PowerYaml.psm1"

Write-Verbose 'Removing PuppetReportParser Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'PuppetReportParser' } | Remove-Module
Write-Verbose 'Loading the PuppetReportParser module'
Import-Module "$PSScriptRoot\PuppetReportParser.psm1"

Convert-Report -Report $Report -Transform $Transform -OutputDir $OutputDir -OutputXML:$OutputXML -Verbose