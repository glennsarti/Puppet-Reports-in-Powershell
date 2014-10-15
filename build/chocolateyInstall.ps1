$packageName = 'poshpuppetreports' # arbitrary name for the package, used in messages

try { 
  $installDir = Join-Path (Join-Path $PSHome "Modules") "POSHPuppetReports"

  $sourceDir = Join-Path (Split-Path -parent $MyInvocation.MyCommand.Definition) "module"

  # Copy the folder to the powershell modules directory
  [void] (Copy-Item -Path $sourceDir -Destination $installDir -Recurse -Confirm:$false -Force -ErrorAction 'Stop')
  
  # Create a shortcut for the reports into the "Start Menu"
  $shortcutPath = ([Environment]::GetFolderPath('CommonStartMenu')) + '\POSH Puppet Reports\Report GUI.lnk'
  if (! (Test-Path $shortcutPath)) {
    Write-Debug 'Creating shortcut folder...'
    [void](New-Item -Path $shortcutPath -ItemType Directory -Force)
  }
  $shortcutFile = $shortcutPath + '\Puppet Report GUI.lnk'  
  $targetPath = '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe'  

  # TODO: Waiting on FerventCoder to release new chocolatey package with the Install-ChocolateyShortcut function available. Until then, use old-school WScript.
  #Install-ChocolateyShortcut -shortcutFilePath $shortcutPath -targetPath $targetPath  
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($shortcutFile)
  $Shortcut.TargetPath = $targetPath
  $Shortcut.Arguments = "`"& { . '$($installDir)\reportgui\reportgui.ps1'}`""
  $Shortcut.Save()
  
  
  # Add in the file assocication and command for YAML files...
  $fileExtRegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.yaml"

  # Create the file extension if it doesn't exist
  if (! (Test-Path -Path "Registry::$($fileExtRegKey)")) {
    [void](New-Item -Path "Registry::$($fileExtRegKey)")
  }
  
  # Create the file association to extension if it doesn't exist
  [string]$yamlFileClass = ""
  try
  {
    $yamlFileClass = (Get-ItemProperty -Path "Registry::$($fileExtRegKey)").PSObject.Properties["(default)"].Value.ToString();
  }
  catch
  {
    $yamlFileClass = ""
  }
  if ($yamlFileClass -eq "") {
    $yamlFileClass = "YAMLFile"
    [void](Set-Item -Path "Registry::$($fileExtRegKey)" -Value $yamlFileClass)
  }
  $fileAssocRegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\$yamlFileClass"
  
  # Create the file association if it doesn't exist
  if (! (Test-Path -Path "Registry::$($fileAssocRegKey)")) {  
    [void](New-Item -Path "Registry::$($fileAssocRegKey)")
  }
  # Create the file association name
  try
  {
    $ignoreThis = (Get-ItemProperty -Path "Registry::$($fileAssocRegKey)").PSObject.Properties["(default)"].Value.ToString();
  }
  catch
  {
    [void](Set-Item -Path "Registry::$($fileAssocRegKey)" -Value "YAML Ain't Markup Language File")
  }
  
  # Now the basic YAML file stuff is associated, just splat in the Puppet Report Viewer bits...
  [void](New-Item -Path "Registry::$($fileAssocRegKey)\Shell" -ErrorAction "Ignore")
  [void](New-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer" -ErrorAction "Ignore")
  [void](Set-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer" -Value "Open in Puppet Report Viewer"  -ErrorAction "Ignore" -Force -Confirm:$false)
  [void](New-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer\Command" -ErrorAction "Ignore")
  [void](Set-Item -Path "Registry::$($fileAssocRegKey)\Shell\OpenWithPOSHPuppetReportViewer\Command" -ErrorAction "Ignore" -Force -Confirm:$false `
         -Value "$($targetPath) `"& { . '$($installDir)\reportgui\reportgui.ps1' '%1'}`"" -Type 'ExpandString')
    
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

