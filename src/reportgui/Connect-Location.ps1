function Open-Location {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string]$Servername

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string]$ConnectAs

   ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$TargetDirectory

  )
  Begin {
    [void] (Get-PSDrive 'PuppetReports' -ErrorAction 'SilentlyContinue' | Remove-PSDrive)
  }
  
  Process {
    if (($ServerName -eq '') -or ($ServerName -eq 'localhost'))
    {
      Write-Verbose 'Connecting to local filesystem...'
      [void](New-PSDrive -Name 'PuppetReports' -PSProvider FileSystem -Root $TargetDirectory -Scope Script)
    }
    else
    {
      Write-Verbose "Connecting to $($ServerName) ..."
    }
  }
}
