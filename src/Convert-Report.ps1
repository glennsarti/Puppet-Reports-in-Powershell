function Convert-Report {
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string[]]$Report

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string[]]$Transform

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string]$TransformDir = ''

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$OutputDir

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [switch]$OutputXML = $false

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [switch]$TeeToWriteHost = $false

  )
  
  Begin {
    # References
    # Report v3/4 Reference for Puppet 2.7.x and 3.x
    # http://docs.puppetlabs.com/puppet/3/reference/format_report.html

    # Fatal Sanity Checks
    #   Can't check for piped output until the Process section
    if ($TransformDir -eq '') { $TransformDir = "$PSScriptRoot\..\transforms" }
    if ($Transform -eq '') { Throw 'No transform was specified'; return; }
    $Transform | % {
      if (!(Test-Path "$TransformDir\$($_).xsl")) { Throw ('Transform file ' + $_ + '.xsl does not exist'); return; }
    }
    if ($OutputDir -ne '') {
      if (!(Test-Path $OutputDir)) { Throw ('Output directory of ' + $OutputDir + ' does not exist'); return; }
    }
  }
  
  Process {
    # Somewhat fatal Sanity Checks
    if ($Report -eq '') { Throw 'No puppet report file was specified'; return; }
    if (!(Test-Path $Report)) { Throw ('Report file ' + $Report + ' does not exist'); return; }

    # Process the report and transforms...
    $yamlFile = $Report

    Write-Verbose "Reading $yamlFile ..."
    $objYaml = Get-Yaml -FromFile $yamlFile

    $xmlDoc = [xml]"<report />"
    Write-Verbose "Creating Resource Status Summary XML..."
    Write-ResourceStatusSummary $objYaml $xmlDoc
    
    # TODO: Write out the Metric.Time table to determine the total time
    
    Write-Verbose "Creating Resource Status XML..."
    Write-ResourceStatus $objYaml $xmlDoc

    if ($OutputXML) {    
      $filename = Join-Path -Path $OutputDir -ChildPath ( (Get-ChildItem $yamlFile).BaseName + '.xml')
      Write-Verbose "Writing XML to $filename ..."
      $xmlDoc.innerXml | Out-File $filename -Encoding ASCII -Force -Confirm:$false
    }

    $Transform | % {
      $transformFile = "$TransformDir\$($_).xsl"
      $filename = Join-Path -Path $OutputDir -ChildPath ( (Get-ChildItem $yamlFile).BaseName + '.' + $_)
      Write-Verbose "Applying transform $transformFile , output to $filename ..."
      [void] (Transform-XML -XMLDocument $xmlDoc -transformFilename $transformFile | Out-File $filename -Force -Confirm:$false )
      
      if ($TeeToWriteHost) {
        # TODO Write out the file content to Write-Host.  Useful if the caller is trapping Stdout
      }

      Write-Output $filename
    }
  }
  
  End {
  }
  
 }
