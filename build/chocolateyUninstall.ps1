$packageName = 'poshpuppetreports' # arbitrary name for the package, used in messages

try { 
  $installDir = Join-Path (Join-Path $PSHome "Modules") "POSHPuppetReports"

  # Remove the folder from the powershell modules directory
  if (Test-Path  $installDir) {
    [void] (Remove-Item $installDir -Recurse -Confirm:$false -Force -ErrorAction 'Stop')
  }
  else
  {
    Write-Debug "Installation directory doesn't exist"
  }

  # Removing shortcuts for the reports into the "Start Menu"
  $shortcutPath = ([Environment]::GetFolderPath('CommonStartMenu')) + '\POSH Puppet Reports\Report GUI.lnk'
  if (Test-Path $shortcutPath) {
    [void] (Remove-Item $shortcutPath -Recurse -Confirm:$false -Force -ErrorAction 'Stop')
  }

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

