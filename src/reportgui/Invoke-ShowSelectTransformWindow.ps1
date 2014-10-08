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
    [xml]$xmlDoc = '<transforms xmlns=""></transforms>'
    Get-ChildItem -Path $transformPath | Sort-Object ($_.Name) | % {
      $transfromName = ($_.Name) -replace '.xsl',''
      
      $index = $transfromName.LastIndexOf('.')
      if ($index -gt -1)
      {
        $typeText = $transfromName.SubString($index + 1, $transfromName.Length - $index - 1)
        if ($typeText -eq 'html') { $typeText = 'HTML' }
        if ($typeText -eq 'stdout') { $typeText = 'Text' }
      }
      else
      {
        $typeText = "Unknown"
      }
   	  $xmlNode = $xmlDoc.CreateElement('transform')
   	  $xmlNode.SetAttribute('transformname',$transfromName)
   	  $xmlNode.SetAttribute('typetext',$typeText)
   	  $xmlNode.innerText = ($transfromName)
   	  $xmlDoc.documentElement.AppendChild($xmlNode)
    }
    (Get-WPFControl 'xmlTransformList' -Window $thisWindow).Document = $xmlDoc

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
