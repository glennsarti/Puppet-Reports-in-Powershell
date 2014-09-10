Function Invoke-ConvertReport() {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$YAMLFilename

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$TransformFilename

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$TransformParentPath
  )  
  Process {
    $outputDir = ($Env:Temp)
    
    $resultContent = (Convert-Report -Report $YAMLFilename -Transform $TransformFilename -TransformDir $TransformParentPath -OutputDir $outputDir -Verbose:($VerbosePreference -eq 'Continue'))
    $fileContent = [IO.File]::ReadAllText($resultContent)

    if ($TransformFilename.EndsWith('.stdout')) {
      $fileContent = "<html><body><pre>" + $fileContent + "</pre></body></html>"
    }
    (Get-WPFControl 'reportBrowser').NavigateToString($fileContent)
    Write-Verbose "Removing temporary file $resultContent ..."
    [void](Remove-Item -Path $resultContent -Force -Confirm:$false)
  }
}
