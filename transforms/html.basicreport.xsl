<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
<xsl:template match="/">
    <html>
    <head><title>Basic HTML Puppet Report</title></head>
    <style>
      body { font-family:tahoma; font-size:10pt; }
      td { font-family:tahoma; font-size:10pt; }
      table { font-family:tahoma; font-size:10pt; }
      
      .BlueBackground { background-color:blue; }
      .GreenBackground { background-color:green; }
      .OrangeBackground { background-color:orange; }
    </style>
    <body>
    
    <div width='200' height='40'>
      <xsl:for-each select="report/resourcesummary/status[@percent > 0]">      
        <div style='float:left;'>
          <xsl:attribute name="width">
          <xsl:value-of select="percent" />%
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@name='No change'">
            <xsl:attribute name="class">GreenBackground</xsl:attribute>
            </xsl:when>
            <xsl:when test="@name='Changed'">
            <xsl:attribute name="class">OrangeBackground</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
            <xsl:attribute name="class">BlueBackground</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose> 
          </div>
      </xsl:for-each>
    </div>
    <br />
    <table style='padding:0px; margin:0px; border:1px solid black;' cellpadding='0' cellspacing='0'>
      <tr height='40'>
      <xsl:for-each select="report/resourcesummary/status[@percent > 0]">      
        <td style=''>
          <xsl:attribute name="width">
          <xsl:value-of select="percent" />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@name='No change'">
            <xsl:attribute name="class">GreenBackground</xsl:attribute>
            </xsl:when>
            <xsl:when test="@name='Changed'">
            <xsl:attribute name="class">OrangeBackground</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
            <xsl:attribute name="class">BlueBackground</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose> 
          <img /></td>
      </xsl:for-each>
      
      
      </tr>    
    </table>

    </body>  
    </html>
</xsl:template>
</xsl:stylesheet>
