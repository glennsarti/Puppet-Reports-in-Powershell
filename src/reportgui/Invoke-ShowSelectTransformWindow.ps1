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
    (Get-WPFControl 'listTransforms' -Window $thisWindow).Add_MouseDoubleClick({
      param($sender,$e)
    
      # Parse the control tree looking for the descendant ListViewItem
    	$originalSource = [System.Windows.DependencyObject]$e.OriginalSource;
      while ( ($originalSource -ne $null) -and ($originalSource.GetType().ToString() -ne 'System.Windows.Controls.ListViewItem') )  {
      	$originalSource = [System.Windows.Media.VisualTreeHelper]::GetParent($originalSource)
      }
      if ($originalSource -eq $null) { return; }
      
      $thisWindow.DialogResult = "ok"
    })
    (Get-WPFControl 'buttonUseTransform' -Window $thisWindow).Add_Click({
      $listView = (Get-WPFControl 'listTransforms' -Window $thisWindow)      
      if ($listView.SelectedItem -eq $null) {
        [void] ([System.Windows.MessageBox]::Show('Please select a transform from the list','Error','Ok','Information'))
        return
      }
      
      $thisWindow.DialogResult = "ok"      
    })

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
    } | Out-Null
    (Get-WPFControl 'xmlTransformList' -Window $thisWindow).Document = $xmlDoc

    # Show the GUI
    Write-Verbose "Showing the window..."
    [string]$selectedTransformName = ""    
    [void]($thisWindow.ShowDialog())
    if ($thisWindow.dialogResult) {
      $listView = (Get-WPFControl 'listTransforms' -Window $thisWindow)    
      $xmlElement = $listView.SelectedItem
      if ($xmlElement -ne $null) {
        $selectedTransformName = $xmlElement.transformName
        Write-Verbose "Selected transform from the dialog is $selectedTransformName"
      }
    }
    
    Write-Verbose "Cleanup..."
    [void] ($thisWindow.Close())
    $thisWindow = $null
    
    Write-Output $selectedTransformName
  }
}
