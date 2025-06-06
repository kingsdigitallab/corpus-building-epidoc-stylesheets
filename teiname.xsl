<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">
    
    <xsl:template match="t:name | t:persName">
      
        <span>
            <xsl:attribute name="data-type" select="lower-case(local-name())" />
            <xsl:attribute name="data-name-type" select="@type" />
            <xsl:attribute name="data-text" select="." />
            
            <xsl:apply-templates/>
        </span>
     
    </xsl:template>
</xsl:stylesheet>
