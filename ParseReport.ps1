param([string[]]$Report = '', [string[]]$Transform = '', [string]$TransformDir = '', [string]$OutputDir = '', [switch]$OutputXML = $false)

$ErrorActionPreference = "Stop"
$DebugPreference = "Continue" #"SilentlyContinue"
$VerbosePreference = "Continue" #"SilentlyContinue"

# Load required modules
# TODO Do we need to change this behaviour?  Only load if it isn't already
Write-Verbose 'Removing PowerYaml Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'PowerYaml' } | Remove-Module
Write-Verbose 'Loading the PowerYaml module'
Import-Module "$PSScriptRoot\src\poweryaml\PowerYaml.psm1"

Write-Verbose 'Removing POSHPuppetReports Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'POSHPuppetReports' } | Remove-Module
Write-Verbose 'Loading the PuppetReportParser module'
Import-Module "$PSScriptRoot\src\POSHPuppetReports.psd1"

Convert-Report -Report $Report -Transform $Transform -OutputDir $OutputDir -OutputXML:$OutputXML -TransformDir $TransformDir -Verbose