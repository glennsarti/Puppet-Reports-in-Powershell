Function Invoke-ShowSelectTransformWindow() {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
  )  
  Process {
    # Load XAML from the external file
    Write-Verbose "Loading the Select Transform window XAML..."
    [xml]$xaml = (Get-Content (Join-Path -Path $global:ScriptDirectory -ChildPath 'selecttransform.xaml'))
    
    # Build the GUI
    Write-Verbose "Parsing the window XAML..."
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $thisWindow = [Windows.Markup.XamlReader]::Load($reader)

    # Wire up the XAML

    # Populate XAML items

    # Show the GUI
    Write-Verbose "Showing the window..."
    $transformName = ""
    [void]($thisWindow.ShowDialog())    
    Write-Verbose "Cleanup..."
    $thisWindow.Close()
    $thisWindow = $null
    
    Write-Output $transformName
  }
}
