$packageName = 'poshpuppetreports' # arbitrary name for the package, used in messages

try { 
  $installDir = Join-Path (Join-Path $PSHome "Modules") "POSHPuppetReports"

  # Remove the folder from the powershell modules directory
  [void] (Remove-Item $installDir -Recurse -Confirm:$false -Force -ErrorAction 'Stop')
     
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

