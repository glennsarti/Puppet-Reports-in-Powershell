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

    .failedresource { color:red; }
    
    #SummaryTable { border:2px solid #707070; }
    #SummaryTable tr td { padding:5px; margin:5px; text-align:center; border-bottom:1px solid #C0C0C0; }
    
    #ResourceList { border:2px solid #707070; }
    #ResourceList tr td { padding:5px; border-bottom:1px solid #808080; text-align:center;}
    #ResourceList tr td:nth-child(1) { text-align:left;}
    #ResourceList tr td:nth-child(5) { text-align:left;}
    #ResourceList tr:nth-child(1) td { background-color:black; color:white; font-weight:bold; text-align:center; }
    
        
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
    <xsl:for-each select="report/resourcesummary/status">
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
  <br />
  
  <table cellpadding='0' cellspacing='0' id='ResourceList'>
    <tr>
      <td>Resource</td><td>Eval. Time</td><td>Properties Changed</td><td >Properties Out of Sync</td><td>Events</td><td>Skipped</td>
    </tr>
    <xsl:for-each select="report/resources/resource">
    <xsl:sort select="@name" data-type="text" order="ascending" />
    <tr>
      <xsl:if test="events/event/status='failure'">
        <xsl:attribute name="class">failedresource</xsl:attribute> 
      </xsl:if>
      <td><xsl:value-of select="@name" /></td>
      <td><xsl:value-of select="evaluation_time" /></td>
      <td><xsl:value-of select="change_count" /></td>
      <td><xsl:value-of select="out_of_sync_count" /></td>

      <td>
      <xsl:for-each select="events/event">
        <xsl:choose>
        <xsl:when test="property">
          <xsl:value-of select="property" /> has status <xsl:value-of select="status" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="message" />
        </xsl:otherwise>
        </xsl:choose>
        <br />
      </xsl:for-each>
      </td>
      <td><xsl:value-of select="skipped" /></td>
    </tr>    
    </xsl:for-each>
  </table>

  </center>
  </body>     
</html>
</xsl:template>
</xsl:stylesheet>