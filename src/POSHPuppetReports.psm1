# Import this modules functions etc.
Get-ChildItem -Path $PSScriptRoot | Unblock-File
Get-ChildItem -Path $PSScriptRoot\*.ps1 | ForEach-Object {
  Write-Verbose "Importing $($_.Name)..."
  . ($_.Fullname)
}
