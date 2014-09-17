function Write-ResourceStatus($objYaml, $xmlDoc) {
  $resourcesNode = $xmlDoc.createElement('resources')

  $objYaml.resource_statuses.Keys | % {
    $resourceNode = $xmlDoc.createElement('resource')
    [void]($resourceNode.SetAttribute('name',$_))
    $resource = $objYaml.resource_statuses[$_]

    $resource.Keys | % {
      $eventsObject = $resource[$_]
      if ($_ -eq 'events')
      {
        # The events resource is special as it can come in as null, an array or hashtable. Need to tailor the XML rendering based on object type
        $eventsNode = $xmlDoc.createElement('events')
        if ($eventsObject -ne $null) {        
          switch ($eventsObject.GetType().ToString() ) {
            "System.Collections.Hashtable" {
              Write-HashTableToXML 'event' $eventsObject $eventsNode
              break;
            }
            "System.Object[]" {
              $eventsObject | % {
                Write-HashTableToXML 'event' $_ $eventsNode
              }
              break;
            }
            default { Throw "Write-ResourceStatus: Unknown object type $($eventsObject.GetType().ToString())"; return $null; }
          }
        }
        [void]($resourceNode.AppendChild($eventsNode))
      }
      else
      {    
        Write-HashTableToXML $_ $eventsObject $resourceNode
      }
    }
    [void]($resourcesNode.AppendChild($resourceNode))
  }
  [void]($xmlDoc.DocumentElement.AppendChild($resourcesNode))
}
