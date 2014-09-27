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
    
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}

