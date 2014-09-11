$packageName = 'poshpuppetreports' # arbitrary name for the package, used in messages

try { 
  $installDir = Join-Path (Join-Path $PSHome "Modules") "POSHPuppetReports"

  $sourceDir = Join-Path (Split-Path -parent $MyInvocation.MyCommand.Definition) "module"

  # Copy the folder to the powershell modules directory
  [void] (Copy-Item -Path $sourceDir -Destination $installDir -Recurse -Confirm:$false -Force -ErrorAction 'Stop')
     
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

