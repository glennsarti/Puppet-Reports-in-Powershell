<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- https://google-developers.appspot.com/chart/interactive/docs/gallery/piechart -->
<xsl:template match="/">
<html>
  <head><title>Basic HTML Puppet Report</title>
  
  </head>
  <style>
    body { font-family:tahoma; font-size:14pt; }
    td { font-family:tahoma; font-size:14pt; }
    table { font-family:tahoma; font-size:14pt; }
    
    .BlueBackground { background-color:blue; }
    .GreenBackground { background-color:green; }
    .OrangeBackground { background-color:orange; }
    
    #SummaryTable { border:1px solid black; }
    #SummaryTable tr td { padding:5px; margin:5px;  }
  </style>
  <body>
  <center>
  <div style='padding:10px; margin:10px; font-size:18pt;' >Puppet Report on <xsl:value-of select="/report/reportinformation/time" /> for <xsl:value-of select="/report/reportinformation/host" /></div>
    
  <div id="piechart" style="width: 900px; height: 500px;"></div>
  
  <table cellpadding='0' cellspacing='0' id='SummaryTable'>
    <xsl:for-each select="report/resourcesummary/status[@count > 0]">      
    <xsl:sort select="@count" data-type="number" order="descending" />
    <xsl:sort select="@name" data-type="text" order="ascending" />
    <tr>
      <td>
        <xsl:value-of select="@count" /> (<xsl:value-of select="@percent" />%)
      </td>
      <td>
        <xsl:value-of select="@name" />
      </td>
    </tr>    
    </xsl:for-each>
  </table>
  
  </center>
  </body>     
</html>
</xsl:template>
</xsl:stylesheet>
