param([string]$File = '',[string]$SearchFor = '', [string]$ReplaceWith = '')
Write-Host "Munging file $($File), searching for $SearchFor and replacing with $ReplaceWith"
(Get-Content -Path $File | ForEach-Object { $_ -replace "$SearchFor","$ReplaceWith" }) | Set-Content -Path $File