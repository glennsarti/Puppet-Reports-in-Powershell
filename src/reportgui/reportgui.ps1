# Setup script defaults
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Bootstrap
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  $global:ScriptDirectory = (Split-Path ($Invocation.MyCommand.Path))
  $global:ScriptDirectory
}
[void] (Get-ScriptDirectory)

#Load Required Assemblies
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase

# Load other PS1 files
Get-ChildItem -Path $global:ScriptDirectory | Where-Object { ($_.Name -imatch '\.ps1$') -and ($_.Name -ne 'reportgui.ps1') } | % {
  Write-Verbose "Importing $($_.Name)..."
  . ($_.Fullname)
}

# Load XAML from the external file
Write-Verbose "Loading the window XAML..."
[xml]$xaml = (Get-Content (Join-Path -Path $global:ScriptDirectory -ChildPath 'reportgui.xaml'))

# Build the GUI
Write-Verbose "Parsing the window XAML..."
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Global:wpfWindow = [Windows.Markup.XamlReader]::Load($reader)

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

# Wire up the XAML
Write-Verbose "Adding XAML event handlers..."
(Get-WPFControl 'buttonConnect').Add_Click({
  $serverName = ((Get-WPFControl 'textServerName').Text)
  $userName = ((Get-WPFControl 'textUsername').Text)
  $location = ((Get-WPFControl 'textReportLocation').Text)
      
  [void]( Open-Location -ServerName $serverName -ConnectAs $userName -TargetDirectory $location )

  # Populate the list box
  Write-Verbose 'Populating the report list...'
  (Get-WPFControl 'listReports').Items.Clear()  
	Get-Item -Path 'PuppetReports:\*.yaml' | Sort-Object ($_.Name) | % {
    [void](Get-WPFControl 'listReports').Items.Add($_.Name)
  }
  
  Write-Verbose 'Expanding the report list'
  # Expand the Reports List
  (Get-WPFControl 'expandReportList').IsExpanded = $true   
  # Contract the Report Location
  (Get-WPFControl 'expandReportLocation').IsExpanded = $false
})
(Get-WPFControl 'listReports').Add_SelectionChanged({
  # Get the report name
  $index = (Get-WPFControl 'listReports').selectedIndex
  if ($index -eq -1)
  {
    # Clear the web browser
  }
  else
  {
    $reportName =  Join-Path -Path 'PuppetReports:' -ChildPath (Get-WPFControl 'listReports').Items[$index]
  }
  # Get the template name
  $index = (Get-WPFControl 'comboReportList').selectedIndex
  if ($index -eq -1) { return; } # No transform has been selected
  $transformName = (Get-WPFControl 'comboReportList').Items[$index]
  Write-Verbose "Parsing report $($reportName) with transform $($transformName)..."

})

# Populate XAML items
Write-Verbose "Populating XAML controls..."
Get-ChildItem -Path (Join-Path -Path $global:ScriptDirectory -ChildPath '..\transforms') | % {
  [void]( (Get-WPFControl 'comboReportList').Items.Add($_.Name) )
}

# Show the GUI
Write-Verbose "Showing the window..."
[void]($wpfWindow.ShowDialog())
Write-Verbose "Cleanup..."
$wpfWindow.Close()
$wpfWindow = $null
