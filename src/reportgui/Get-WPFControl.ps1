function Get-WPFControl {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$ControlName

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [System.Windows.Window]$Window = $Global:wpfWindow
  )  
  Process {
    Write-Output $Window.FindName($ControlName)
  }
}

