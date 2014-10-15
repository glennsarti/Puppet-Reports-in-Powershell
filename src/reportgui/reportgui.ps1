param([string]$Report = '', [string]$Transform = '')
# Setup script defaults
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Bootstrap
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  $global:ScriptDirectory = (Split-Path ($Invocation.MyCommand.Path))
  $global:ScriptDirectory
}
[void] (Get-ScriptDirectory)

$transformPath = (Join-Path -Path $global:ScriptDirectory -ChildPath '..\transforms')

#Load Required Assemblies
Write-Verbose 'Loading WPF assemblies'
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
Write-Verbose 'Loading Windows Forms assemblies'
Add-Type -AssemblyName System.Windows.Forms
Write-Verbose 'Loading the POSHPuppetReports module'
Import-Module "$PSScriptRoot\..\POSHPuppetReports.psd1"

# Check the command line
$cmdLineError = ""
$autoloadReport = ""
$autoloadTransform = ""
if ($Report -ne '') {
  Write-Verbose "Report path was specified on the command line"
  if (!(Test-Path -Path $Report)) {
    Write-Verbose "Report does not exist"
    $cmdLineError += "The specified report does not exist`n`r"
  }
  else
  {
    Write-Verbose "Report exists"
    $autoloadReport = $Report
  }  
}
if ($Transform -ne '') {
  Write-Verbose "Transform name was specified on the command line"
  $TransformFile = (Join-Path -Path $transformPath -ChildPath ($Transform + ".xsl"))
  if (!(Test-Path -Path $TransformFile)) {
    Write-Verbose "Transform does not exist"
    $cmdLineError += "The specified transform does not exist`n`r"
  }
  else
  {
    Write-Verbose "Transform exists"
    $autoloadTransform = $Transform
  }  
}
if ($cmdLineError -ne '') {
  [void] ([System.Windows.MessageBox]::Show($cmdLineError,'Error','Ok','Information'))
}

# Load other PS1 files
Get-ChildItem -Path $global:ScriptDirectory | Where-Object { ($_.Name -imatch '\.ps1$') -and ($_.Name -ne 'reportgui.ps1') } | % {
  Write-Verbose "Importing $($_.Name)..."
  . ($_.Fullname)
}

if (($autoloadTransform -eq "") -and ($autoloadReport -ne "")) {  
  # Passed in only the report name.  Prompt for the transform name
  Write-Verbose "Report name was passed in the command line but no transform.  Prompting for which transform to use..."
  $autoloadTransform = Invoke-ShowSelectTransformWindow
  Write-Verbose "Selected transform is [$autoloadTransform]"
}

Invoke-ShowMainWindow -AutoloadTransform $autoloadTransform -AutoloadReport $autoloadReport
