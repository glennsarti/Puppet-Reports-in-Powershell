param([string[]]$Report = '', [string[]]$Transform = '', [string]$TransformDir = '', [string]$OutputDir = '', [switch]$OutputXML = $false)

$ErrorActionPreference = "Stop"
$DebugPreference = "Continue" #"SilentlyContinue"
$VerbosePreference = "Continue" #"SilentlyContinue"

# Load required modules
Write-Verbose 'Removing POSHPuppetReports Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'POSHPuppetReports' } | Remove-Module
Write-Verbose 'Loading the PuppetReportParser module'
Import-Module "$PSScriptRoot\src\POSHPuppetReports.psd1" -Verbose:($VerbosePreference -eq 'Continue')

ConvertFrom-PuppetReport -Report $Report -Transform $Transform -OutputDir $OutputDir -OutputXML:$OutputXML -TransformDir $TransformDir -Verbose:($VerbosePreference -eq 'Continue')
