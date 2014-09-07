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