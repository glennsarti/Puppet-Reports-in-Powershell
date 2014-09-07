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