$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$manifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'puppet'

# Find Puppet
$puppetBin = ''
# Try %ProgramFiles%\Puppet Labs\Puppet\bin
if ($puppetBin -eq '') {
  $misc = "$($Env:ProgramFiles)\Puppet Labs\Puppet\bin"
  if (Test-Path $misc) {
    $puppetBin = $misc
    Write-Verbose "Found puppet at $puppetBin"
  }
}
if ($puppetBin -eq '') {
  Throw 'Could not find the puppet installation directory'
}

# Get the puppet config
$puppetReportFile = (& "$puppetBin\puppet" config print lastrunreport) -replace '/','\' # Get the report dir from puppet and convert slashes to windows format
Write-Verbose "Last puppet report is being saved to $puppetReportFile"

# Clean the examples directory
Write-Verbose 'Cleaning the examples directory...'
Get-ChildItem -Path $PSScriptRoot | Where-Object { ! $_.PSIsContainer -and ($_.Extension.ToLower() -ne '.ps1') } | Remove-Item -Force -Confirm:$false

Get-ChildItem -Path $manifestPath | Where-Object { ! $_.PSIsContainer -and ($_.Extension.ToLower() -eq '.pp') } | % {
  $exampleFilePath = $_.FullName
  $exampleName = ($_.Name) -replace $_.Extension,''
  
  Write-Verbose "Creating report for $exampleName ..."
  & "$puppetBin\puppet" apply "$exampleFilePath"

  $misc = Join-Path -Path $PSScriptRoot -ChildPath "$($exampleName).yaml"
  Write-Verbose "Copying last run report to $misc ..."
  Copy-Item -Path $puppetReportFile -Destination $misc -Force -Confirm:$false

  Write-Host $exampleName -ForegroundColor Magenta
}

Write-Verbose 'Finished generating the examples'
