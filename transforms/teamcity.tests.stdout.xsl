<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
##teamcity[testSuiteStarted name='puppetReport']
    <xsl:for-each select="report/resources/resource">
    <xsl:sort select="@name" data-type="text" order="ascending" />
##teamcity[testStarted name='<xsl:value-of select="@name" />']    
    <xsl:choose>
      <xsl:when test='out_of_sync_count &gt; 0'>
##teamcity[testFailed name='<xsl:value-of select="@name" />' message='Has of out of sync properties']
      </xsl:when>
    </xsl:choose>
##teamcity[testFinished name='<xsl:value-of select="@name" />' duration='<xsl:value-of select="evaluation_time_ms" />']
    </xsl:for-each>
##teamcity[testSuiteFinished name='puppetReport']
</xsl:template>
</xsl:stylesheet>
