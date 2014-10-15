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

  # Remove the file assocication and command for YAML files...
  $fileExtRegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.yaml"
  # Create the file extension if it doesn't exist
  if (Test-Path -Path "Registry::$($fileExtRegKey)") {
    [string]$yamlFileClass = ""
    try
    {
      $yamlFileClass = (Get-ItemProperty -Path "Registry::$($fileExtRegKey)").PSObject.Properties["(default)"].Value.ToString();
    }
    catch
    {
      $yamlFileClass = ""
    }
    if ($yamlFileClass -ne "") {
      $fileAssocRegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\$yamlFileClass"      
      [void](Remove-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer\Command" -ErrorAction "Ignore" -Confirm:$false -Force)
      [void](Remove-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer" -ErrorAction "Ignore"  -Confirm:$false -Force)
    }
  }

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

