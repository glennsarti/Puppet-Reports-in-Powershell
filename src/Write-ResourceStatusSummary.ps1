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
  $total = 0
  for($index = $resourceMetrics.GetLowerBound(0); $index -lt $resourceMetrics.GetUpperBound(0); $index = $index + 3) {
    
    if ($resourceMetrics[$index] -eq 'total')
    {
      $total = $resourceMetrics[$index + 2]
    } 
    else
    {
      $statusInfo = @{}
      $statusInfo['count'] = $resourceMetrics[$index + 2]
      $statusInfo['id'] = $resourceMetrics[$index]
      $statuses[$resourceMetrics[$index + 1]] = $statusInfo
    } 
  }
  $statusInfo = @{}
    
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
