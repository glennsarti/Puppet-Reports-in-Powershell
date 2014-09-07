function Transform-XML($xmlDocument, $transformFilename) {
	$xmlContentReader = ([System.Xml.XmlReader]::Create( (New-Object System.IO.StringReader($xmlDocument.innerXML))))

	$StyleSheet = New-Object System.Xml.Xsl.XslCompiledTransform
	$StyleSheet.Load($transformFile)

	$stringWriter = New-Object System.IO.StringWriter
	$XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
		
	$StyleSheet.Transform( [System.Xml.XmlReader]$xmlContentReader, [System.Xml.XmlWriter]$XmlWriter)
	Write-Output $stringWriter.ToString()
}