# Import functions etc.
Get-ChildItem -Path (Join-Path $PSScriptRoot -ChildPath 'functions') | Where-Object { ($_.Name -imatch '\.ps1$') } | ForEach-Object {
  Write-Verbose "Importing $($_.Name)..."
  . ($_.Fullname)
}

Export-ModuleMember -Function 'Convert-Report'