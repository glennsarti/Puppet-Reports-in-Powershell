<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
  <head><title>Basic HTML Puppet Report</title>
  </head>
  <style>
    body { font-family:tahoma; font-size:14pt; }
    td { font-family:tahoma; font-size:14pt; }
    table { font-family:tahoma; font-size:14pt; }
    
    .DefaultStatusBackgound { background-color:#707070; }
    .changedstatus { background-color:orange; }
    .out_of_syncstatus { background-color:blue; }
    .nochangestatus { background-color:green; }
    .failedstatus { background-color:red; }
    .failed_to_restartstatus { background-color:red; }
    
    #SummaryTable { border:2px solid #707070; }
    #SummaryTable tr td { padding:5px; margin:5px; text-align:center; border-bottom:1px solid #C0C0C0;  }
        
    .OuterPercentage { width:100px; height:28px; background-color:#F0F0F0; border:1px solid #808080; overflow: auto; overflow-y:hidden; overflow-x:hidden; }
    .OuterPercentage div { float:left; height:24px; margin:2px; padding-top:2px; padding-bottom:2px; border:0px; margin:0px; }
    .OuterPercentage div:nth-child(1) { color:white; text-align:right; }
    .OuterPercentage div:nth-child(2) { color:black; text-align:left; }
  </style>
  <body>
  <center>
  <div style='padding:10px; margin:10px; font-size:18pt;' >Puppet Report on <xsl:value-of select="/report/reportinformation/time" /> for <xsl:value-of select="/report/reportinformation/host" /></div>
      
  <table cellpadding='0' cellspacing='0' id='SummaryTable'>
    <tr><td></td><td>Resources</td><td>Status</td></tr>
    <xsl:for-each select="report/resourcesummary/status[@count > 0]">
    <xsl:sort select="@count" data-type="number" order="descending" />
    <xsl:sort select="@name" data-type="text" order="ascending" />
    <tr>
      <td><div class='OuterPercentage'>
        <div>
          <xsl:attribute name="style">width:<xsl:value-of select="@percent" />px;</xsl:attribute>
          <xsl:attribute name="class">DefaultStatusBackgound <xsl:value-of select="@id" />status</xsl:attribute>
          <xsl:if test="@percent &gt; 50"><xsl:value-of select="@percent" />%</xsl:if><span />
        </div>
        <div> 
          <xsl:if test="@percent &lt; 51"><xsl:value-of select="@percent" />%</xsl:if>
        </div>
        </div></td>
      <td><xsl:value-of select="@count" /></td>
      <td><xsl:value-of select="@name" /></td>
    </tr>    
    </xsl:for-each>
  </table>
  
  </center>
  </body>     
</html>
</xsl:template>
</xsl:stylesheet>
