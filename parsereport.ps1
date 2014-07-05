param([string[]]$Report = '', [string[]]$Transform = '', [string]$OutputDir = '', [switch]$OutputXML = $false)

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

# References
# Report v3/4 Reference for Puppet 2.7.x and 3.x
# http://docs.puppetlabs.com/puppet/3/reference/format_report.html

# Fatal Sanity Checks
if ($Report -eq '') { Throw 'No puppet report file was specified' }
$Report | % {
  if (!(Test-Path $_)) { Throw ('Report file ' + $_ + ' does not exist') }
}
if ($Transform -eq '') { Throw 'No transform was specified' }
$Transform | % {
  if (!(Test-Path "$PSScriptRoot\transforms\$($_).xsl")) { Throw ('Transform file ' + $_ + ' does not exist') }
}
if ($OutputDir -ne '') {
  if (!(Test-Path $OutputDir)) { Throw ('Output directory of ' + $OutputDir + ' does not exist') }
}
if (!(Test-Path "$PSScriptRoot\poweryaml\PowerYaml.psm1")) { Throw 'Could not find the PowerYaml module file' }

# Load required modules
Write-Debug 'Removing PowerYaml Module if it is already loaded...'
Get-Module | Where-Object { $_.Name -eq 'PowerYaml' } | Remove-Module
Write-Debug 'Loading the PowerYaml module'
Import-Module "$PSScriptRoot\poweryaml\PowerYaml.psm1"

# Function definitions
function Transform-XML($xmlDocument, $transformFilename) {
	$xmlContentReader = ([System.Xml.XmlReader]::Create( (New-Object System.IO.StringReader($xmlDocument.innerXML))))

	$StyleSheet = New-Object System.Xml.Xsl.XslCompiledTransform
	$StyleSheet.Load($transformFile)

	$stringWriter = New-Object System.IO.StringWriter
	$XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
		
	$StyleSheet.Transform( [System.Xml.XmlReader]$xmlContentReader, [System.Xml.XmlWriter]$XmlWriter)
	Write-Output $stringWriter.ToString()
}

function Write-ResourceStatusSummary($objYaml, $xmlDoc) {
  $reportInfoNode = $xmlDoc.createElement('reportinformation')  
  $node = $xmlDoc.createElement('host'); $node.innerText = $objYaml.host; [void]($reportInfoNode.appendChild($node))
  $node = $xmlDoc.createElement('time'); $node.innerText = $objYaml.time; [void]($reportInfoNode.appendChild($node))
  $node = $xmlDoc.createElement('reportformat'); $node.innerText = $objYaml.report_format; [void]($reportInfoNode.appendChild($node))
  $node = $xmlDoc.createElement('puppetversion'); $node.innerText = $objYaml.puppet_version; [void]($reportInfoNode.appendChild($node))
  $node = $xmlDoc.createElement('status'); $node.innerText = $objYaml.status; [void]($reportInfoNode.appendChild($node))
  $node = $xmlDoc.createElement('environment'); $node.innerText = $objYaml.environment; [void]($reportInfoNode.appendChild($node))
  [void]($xmlDoc.DocumentElement.appendChild($reportInfoNode))

  $statuses = @{}
  $resourceMetrics = $objYaml.metrics['resources'].values
  $noChange = 0
  $total = 0
  for($index = $resourceMetrics.GetLowerBound(0); $index -lt $resourceMetrics.GetUpperBound(0); $index = $index + 3) {
    
    if ($resourceMetrics[$index] -eq 'total')
    {
      $noChange = $noChange + $resourceMetrics[$index + 2]
      $total = $resourceMetrics[$index + 2]
    } 
    else
    {
      $noChange = $noChange - $resourceMetrics[$index + 2]

      $statusInfo = @{}
      $statusInfo['count'] = $resourceMetrics[$index + 2]
      $statusInfo['id'] = $resourceMetrics[$index]
      $statuses[$resourceMetrics[$index + 1]] = $statusInfo
    } 
  }
  $statusInfo = @{}
  $statusInfo['count'] = $noChange
  $statusInfo['id'] = 'nochange'
  $statuses["No change"] = $statusInfo
  
  $summaryNode = $xmlDoc.createElement('resourcesummary')
  [void]($summaryNode.SetAttribute('total',$total))
  
  $statuses.Keys | ForEach-Object {
    $node = $xmlDoc.createElement('status')
    $node.SetAttribute('name',$_)
    $node.SetAttribute('id',$statuses[$_].id)
    $node.SetAttribute('count',$statuses[$_].count)
    if ($total -gt 0)
    { $node.SetAttribute('percent',[int](($statuses[$_].count / $total)*100)) }
    else
    { $node.SetAttribute('percent',0) }

    [void]($summaryNode.AppendChild($node))
    
  }
  [void]($xmlDoc.DocumentElement.AppendChild($summaryNode))
}

function Write-HashTableToXML($attrName, $attrValue, $rootNode) {
  $xmlNode = $rootNode.OwnerDocument.createElement($attrName)
  if ($attrValue -ne $null) {
    switch ($attrValue.GetType().ToString()) {
      'System.String' {
        # Special property.  Convert it to ms as well
        if ($attrName -eq 'evaluation_time') {
          $xmlMSnode = $rootNode.OwnerDocument.createElement($attrName + '_ms')
          $xmlMSnode.innerText = [int](([float]$attrValue)*1000)
          [void]($rootNode.appendChild($xmlMSnode))
        }
        $xmlNode.innerText = $attrValue;
        break ;
      }
      'System.Object[]' {
        if ( ($attrValue[0]).GetType().ToString() -eq 'System.Collections.HashTable' ) {
          $attrValue | % { Write-HashTableToXML $attrName $_ $xmlNode }
        } else {
          $xmlNode.innerText = $attrValue;
        }
        break ;
      }
      'System.Collections.Hashtable' { $attrValue.Keys | % { Write-HashTableToXML $_ $attrValue[$_] $xmlNode }; break ; }
      default { $xmlNode.innerText = ('Unknown type ' + $attrValue.GetType().ToString()); break ; }
    }
    
  }
  [void]($rootNode.appendChild($xmlNode))
}

function Write-ResourceStatus($objYaml, $xmlDoc) {
  $resourcesNode = $xmlDoc.createElement('resources')

  $objYaml.resource_statuses.Keys | % {
    $resourceNode = $xmlDoc.createElement('resource')
    [void]($resourceNode.SetAttribute('name',$_))
    $resource = $objYaml.resource_statuses[$_]

    $resource.Keys | % {  
      Write-HashTableToXML $_ ($resource[$_]) $resourceNode
    }
    [void]($resourcesNode.AppendChild($resourceNode))
  }
  [void]($xmlDoc.DocumentElement.AppendChild($resourcesNode))
}

# Process the reports and transforms...
$Report | % {
  $yamlFile = $_

  Write-Debug "Reading $yamlFile ..."
  $objYaml = Get-Yaml -FromFile $yamlFile

  $xmlDoc = [xml]"<report />"
  Write-Debug "Creating Resource Status Summary XML..."
  Write-ResourceStatusSummary $objYaml $xmlDoc
  
  # TODO: Write out the Metric.Time table to determine the total time
  
  Write-Debug "Creating Resource Status XML..."
  Write-ResourceStatus $objYaml $xmlDoc

  if ($OutputXML) {    
    $filename = Join-Path -Path $OutputDir -ChildPath ( (Get-ChildItem $yamlFile).BaseName + '.xml')
    Write-Debug "Writing XML to $filename ..."
    $xmlDoc.innerXml | Out-File $filename -Encoding ASCII -Force -Confirm:$false
  }

  $Transform | % {
    $transformFile = "$PSScriptRoot\transforms\$($_).xsl"
    
    if ($_.ToLower().EndsWith('.stdout')) {
      Write-Debug "Applying transform $transformFile , output to STDOUT..."
      Transform-XML -XMLDocument $xmlDoc -transformFilename $transformFile
    } else {
      $filename = Join-Path -Path $OutputDir -ChildPath ( (Get-ChildItem $yamlFile).BaseName + '.' + $_)
      Write-Debug "Applying transform $transformFile , output to $filename ..."
      Transform-XML -XMLDocument $xmlDoc -transformFilename $transformFile | Out-File $filename -Force -Confirm:$false 
    }    
  }
}