<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">
  <!-- seg[@type='autopsy'] span added in htm-teiseg.xsl -->

  <xsl:template match="t:seg | t:w">
    <xsl:param name="parm-edition-type" tunnel="yes" required="no"/>
    <xsl:param name="parm-leiden-style" tunnel="yes" required="no"/>
    <xsl:if test="
        $parm-leiden-style = ('london', 'medcyprus') and (@part = 'M' or @part = 'F')
        and not(preceding-sibling::node()[1][self::t:gap])
        and not($parm-edition-type = 'diplomatic')">
      <xsl:text>-</xsl:text>
    </xsl:if>

    <span>
      <xsl:attribute name="data-text" select="." />
      <xsl:if test="@n">
        <xsl:attribute name="data-n" select="@n" />
        <xsl:attribute name="data-lemma" select="//t:div[@subtype = 'simple-lemmatized']//t:w[@n = current()/@n]/@lemma" />
      </xsl:if>
      <xsl:apply-templates/>
    </span>

    <!-- Found in tpl-certlow.xsl -->
    <xsl:call-template name="cert-low"/>

    <xsl:if test="
        $parm-leiden-style = ('london', 'medcyprus') and (@part = 'I' or @part = 'M')
        and not(following-sibling::node()[1][self::t:gap])
        and not(descendant::ex[last()])
        and not($parm-edition-type = 'diplomatic')">
      <xsl:text>-</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
