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

$transformPath = (Join-Path -Path $global:ScriptDirectory -ChildPath '..\transforms')

#Load Required Assemblies
Write-Verbose 'Loading WPF assemblies'
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
Write-Verbose 'Loading Windows Forms assemblies'
Add-Type -AssemblyName System.Windows.Forms
Write-Verbose 'Loading the POSHPuppetReports module'
Import-Module "$PSScriptRoot\..\POSHPuppetReports.psd1"

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

# Wire up the XAML
Write-Verbose "Adding XAML event handlers..."
(Get-WPFControl 'buttonBrowseReportPath').Add_Click({
  $dialogWindow = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    SelectedPath = (Get-WPFControl 'textReportPath').Text;
    ShowNewFolderButton = $false;
    Description = "Browse for Puppet Report path";
  }
  
  $result = $dialogWindow.ShowDialog()
  
  if ($result.ToString() -eq 'Ok') {
    (Get-WPFControl 'textReportPath').Text = $dialogWindow.SelectedPath
  }
})
(Get-WPFControl 'buttonConnect').Add_Click({
  $location = ((Get-WPFControl 'textReportPath').Text)
  
  if (Test-Path -Path $location) {
    # Remove the PuppetReports Drive if it exists...
    (Get-PSDrive 'PuppetReports' -ErrorAction 'SilentlyContinue' | Remove-PSDrive)
    # Create a PuppetReports: drive
    [void](New-PSDrive -Name 'PuppetReports' -PSProvider FileSystem -Root $location -Scope Script)
  
    # Populate the list box
    Write-Verbose 'Populating the report list...'
    [xml]$xmlDoc = '<reports xmlns=""></reports>'
   	Get-Item -Path 'PuppetReports:\*.yaml' | Sort-Object ($_.LastWriteTime) -Descending | % {
   	  $xmlNode = $xmlDoc.CreateElement('report')
   	  $xmlNode.SetAttribute('name',$_.name.ToString())
   	  $xmlNode.SetAttribute('datemodified',($_.LastWriteTime.ToString('dd MMM yyyy HH:mm:ss')))
   	  $xmlNode.innerText = ($_.FullName)
   	  $xmlDoc.reports.AppendChild($xmlNode)
    }
    # Write the xml document to the XAML for databinding
    (Get-WPFControl 'xmlReportList').Document = $xmlDoc
  
    Write-Verbose 'Expanding the report list'
    # Expand the Reports List
    (Get-WPFControl 'expandReportList').IsExpanded = $true   
    # Contract the Report Location
    (Get-WPFControl 'expandReportLocation').IsExpanded = $false
    
    $wpfWindow.Title = "Puppet Report Viewer - $location"
  }
  else
  {
    [void] ([System.Windows.MessageBox]::Show('The report path does not exist','Error','Ok','Information'))
    return
  }
})
(Get-WPFControl 'listReports').Add_MouseDoubleClick({
  param($sender,$e)

  # Parse the control tree looking for the descendant ListViewItem
	$originalSource = [System.Windows.DependencyObject]$e.OriginalSource;
  while ( ($originalSource -ne $null) -and ($originalSource.GetType().ToString() -ne 'System.Windows.Controls.ListViewItem') )  {
  	$originalSource = [System.Windows.Media.VisualTreeHelper]::GetParent($originalSource)
  }
  if ($originalSource -eq $null) { return; }
  
  # Get the data context (XMLElement)
  $dc = $originalSource.DataContext
  $reportName = ($dc."#text")
	
  # Get the template name
  $index = (Get-WPFControl 'comboReportList').selectedIndex
  if ($index -eq -1) {  # No transform has been selected
    [void] ([System.Windows.MessageBox]::Show('Please select a Report Type to use','Error','Ok','Information'))
    return;
  }
  $transformName = (Get-WPFControl 'comboReportList').Items[$index]
  
  # Actually do the conversion
  Write-Verbose "Parsing report $($reportName) with transform $($transformName)..."
  Invoke-ConvertReport -YAMLFilename $reportName -TransformFilename $transformName -TransformParentPath $transformPath
  Write-Verbose "Conversion finished..."
})

# Populate XAML items
Write-Verbose "Populating XAML controls..."
Get-ChildItem -Path $transformPath | % {
  $transfromName = ($_.Name) -replace '.xsl',''
  [void]( (Get-WPFControl 'comboReportList').Items.Add($transfromName) )
}
$readMe = $global:ScriptDirectory + '\reportgui.readme.html'
if (Test-Path -Path $readMe) {
  Write-Verbose "Displaying ReadMe..."
  (Get-WPFControl 'reportBrowser').NavigateToString( ([IO.File]::ReadAllText($readMe) ) )
}

# Show the GUI
Write-Verbose "Showing the window..."
[void]($wpfWindow.ShowDialog())
Write-Verbose "Cleanup..."
$wpfWindow.Close()
$wpfWindow = $null
