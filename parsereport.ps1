param()

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"


Get-Module | Where-Object { $_.Name -eq 'PowerYaml' } | Remove-Module
Import-Module "$PSScriptRoot\poweryaml\PowerYaml.psm1"
$yamlfile = 'Z:\Projects\puppet-reports-in-powershell\examples\201405200656.yaml'

$objYaml = Get-Yaml -FromFile $yamlfile

$xmlDoc = [xml]"<report />"

function Write-ResourceStatusSummary($objYaml, $xmlDoc) {
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
      $statuses[$resourceMetrics[$index + 1]] = $resourceMetrics[$index + 2]
    } 
  }
  $statuses["No change"] = $noChange
  
  $summaryNode = $xmlDoc.createElement('resourcesummary')
  [void]($summaryNode.SetAttribute('total',$total))
  
  $statuses.Keys | ForEach-Object {
    $node = $xmlDoc.createElement('status')
    $node.SetAttribute('name',$_)
    $node.SetAttribute('count',$statuses[$_])
    if ($total -gt 0)
    { $node.SetAttribute('percent',[int](($statuses[$_] / $total)*100)) }
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
      'System.String' { $xmlNode.innerText = $attrValue; break ; }
      'System.Object[]' { $xmlNode.innerText = $attrValue; break ; }
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

Write-ResourceStatusSummary $objYaml $xmlDoc
Write-ResourceStatus $objYaml $xmlDoc

#$xmlDoc.innerXml
$xmlDoc.innerXml | Out-File C:\temp\Test.XML

