Function Invoke-ShowMainWindow() {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [AllowEmptyString()]
    [string]$autoloadTransform = ""

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [AllowEmptyString()]
    [string]$AutoloadReport = ""
  )  
  Process {
    # Load XAML from the external file
    Write-Verbose "Loading the window XAML..."
    [xml]$xaml = (Get-Content (Join-Path -Path $global:ScriptDirectory -ChildPath 'reportgui.xaml'))
    
    # Build the GUI
    Write-Verbose "Parsing the window XAML..."
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $thisWindow = [Windows.Markup.XamlReader]::Load($reader)

    # Wire up the XAML
    Write-Verbose "Adding XAML event handlers..."
    (Get-WPFControl 'buttonBrowseReportPath' -Window $thisWindow).Add_Click({
      # TODO Perhaps create a wizard to enter a server name and automatically create a UNC to the default puppet path? \\<server>\c$\ProgramData....
      $dialogWindow = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        SelectedPath = (Get-WPFControl 'textReportPath' -Window $thisWindow).Text;
        ShowNewFolderButton = $false;
        Description = "Browse for Puppet Report path";
      }
      
      $result = $dialogWindow.ShowDialog()
      
      if ($result.ToString() -eq 'Ok') {
        (Get-WPFControl 'textReportPath' -Window $thisWindow).Text = $dialogWindow.SelectedPath
      }
    })
    (Get-WPFControl 'buttonConnect' -Window $thisWindow).Add_Click({
      $location = ((Get-WPFControl 'textReportPath' -Window $thisWindow).Text)
      
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
        (Get-WPFControl 'xmlReportList' -Window $thisWindow).Document = $xmlDoc
      
        Write-Verbose 'Expanding the report list'
        # Expand the Reports List
        (Get-WPFControl 'expandReportList' -Window $thisWindow).IsExpanded = $true   
        # Contract the Report Location
        (Get-WPFControl 'expandReportLocation' -Window $thisWindow).IsExpanded = $false
        
        $thisWindow.Title = "Puppet Report Viewer - $location"
      }
      else
      {
        [void] ([System.Windows.MessageBox]::Show('The report path does not exist','Error','Ok','Information'))
        return
      }
    })
    (Get-WPFControl 'listReports' -Window $thisWindow).Add_MouseDoubleClick({
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
      $index = (Get-WPFControl 'comboReportList' -Window $thisWindow).selectedIndex
      if ($index -eq -1) {  # No transform has been selected
        [void] ([System.Windows.MessageBox]::Show('Please select a Report Type to use','Error','Ok','Information'))
        return;
      }
      $transformName = (Get-WPFControl 'comboReportList' -Window $thisWindow).Items[$index]
      
      # Actually do the conversion
      Write-Verbose "Parsing report $($reportName) with transform $($transformName)..."
      Invoke-ConvertReport -YAMLFilename $reportName -TransformFilename $transformName -TransformParentPath $transformPath -WPFWindow $thisWindow
      Write-Verbose "Conversion finished..."
    })

    # Populate XAML items
    Write-Verbose "Populating XAML controls..."
    Get-ChildItem -Path $transformPath | % {
      $transfromName = ($_.Name) -replace '.xsl',''
      [void]( (Get-WPFControl 'comboReportList' -Window $thisWindow).Items.Add($transfromName) )
    }
    
    # Show the readme or autoload a report if specified
    if ( ($autoloadReport -ne "") -and ($autoloadTransform -ne "") )
    {
      Write-Verbose "Converting the report $($autoloadReport) with transform $($autoloadTransform) specified on the command line..."
      Invoke-ConvertReport -YAMLFilename $autoloadReport -TransformFilename $autoloadTransform -TransformParentPath $transformPath -WPFWindow $thisWindow
      Write-Verbose "Conversion finished..."
      
      # Set the UI to specified report path and transform name
      (Get-WPFControl 'textReportPath' -Window $thisWindow).Text = (Split-Path -Path $autoloadReport -Parent)  
      $comboBox = (Get-WPFControl 'comboReportList' -Window $thisWindow)
      for($index = 0; $index -lt $comboBox.Items.Count; $index++) {
        if ($comboBox.Items[$index] -eq $autoloadTransform) {
          $comboBox.SelectedIndex = $index
          break
        }
      }  
    }
    else
    {
      $readMe = $global:ScriptDirectory + '\reportgui.readme.html'
      if (Test-Path -Path $readMe) {
        Write-Verbose "Displaying ReadMe..."
        (Get-WPFControl 'reportBrowser' -Window $thisWindow).NavigateToString( ([IO.File]::ReadAllText($readMe) ) )
      }
    }

    # Show the GUI
    Write-Verbose "Showing the window..."
    [void]($thisWindow.ShowDialog())
    Write-Verbose "Cleanup..."
    $thisWindow.Close()
    $thisWindow = $null
  }
}
