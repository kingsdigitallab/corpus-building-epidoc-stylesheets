<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
   exclude-result-prefixes="#all" version="2.0">
   <!-- Contains named templates for default file structure (aka "metadata" aka "supporting data") -->

   <!-- Specific named templates for HGV, InsLib, RIB, IOSPE, EDH, etc. are found in:
               htm-tpl-struct-hgv.xsl
               htm-tpl-struct-inslib.xsl
               htm-tpl-struct-rib.xsl
               htm-tpl-struct-iospe.xsl
               htm-tpl-struct-edh.xsl
               etc.
  -->

   <xsl:template name="london-structure">
      <xsl:call-template name="default-structure"/>
   </xsl:template>

   <xsl:template name="default-structure">
      <html>
         <head>
            <title>
               <xsl:call-template name="default-title"/>
            </title>
            <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
            <!-- Found in htm-tpl-cssandscripts.xsl -->
            <xsl:call-template name="css-script"/>
         </head>
         <body>
            <xsl:call-template name="default-body-structure"/>
         </body>
      </html>
   </xsl:template>

   <xsl:template name="default-body-structure">
      <xsl:param name="parm-edition-type" tunnel="yes" required="no"/>
      <xsl:param name="parm-leiden-style" tunnel="yes" required="no"/>
      <!-- Heading for a ddb style file -->
      <xsl:if test="($parm-leiden-style = ('ddbdp', 'dclp', 'sammelbuch'))">
         <h1>
            <xsl:choose>
               <xsl:when test="//t:sourceDesc//t:bibl/text()">
                  <xsl:value-of select="//t:sourceDesc//t:bibl"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="//t:idno[@type = 'filename']"/>
               </xsl:otherwise>
            </xsl:choose>
         </h1>
      </xsl:if>

      <xsl:variable name="edition">
         <xsl:sequence select="//t:div[@type = 'edition']"/>
      </xsl:variable>
      <!-- Create copy of document excluding edition div -->
      <xsl:variable name="doc-without-edition">
         <xsl:apply-templates mode="strip-edition"/>
      </xsl:variable>
      <xsl:variable name="chardecl">
         <xsl:choose>
            <xsl:when test="//t:charDecl">
               <xsl:sequence select="//t:charDecl"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates mode="chardecl"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Main text output -->
      <xsl:variable name="maintxt">
         <div id="editions">
            <xsl:for-each select="$parm-edition-type">
               <xsl:apply-templates select="$edition/node()">
                  <xsl:with-param name="parm-edition-type" select="." tunnel="yes"/>
                  <xsl:with-param name="chardecl" select="$chardecl/node()" tunnel="yes"/>
               </xsl:apply-templates>
            </xsl:for-each>
         </div>
         <xsl:apply-templates select="$doc-without-edition/node()"/>
      </xsl:variable>

      <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
      <xsl:variable name="maintxt2">
         <xsl:apply-templates select="$maintxt" mode="sqbrackets"/>
      </xsl:variable>
      <xsl:apply-templates select="$maintxt2" mode="sqbrackets"/>

      <!-- Found in htm-tpl-license.xsl -->
      <xsl:call-template name="license"/>
   </xsl:template>

   <xsl:template name="default-title">
      <xsl:param name="parm-leiden-style" tunnel="yes" required="no"/>
      <xsl:choose>
         <xsl:when test="$parm-leiden-style = ('ddbdp', 'dclp', 'sammelbuch')">
            <xsl:choose>
               <xsl:when test="//t:sourceDesc//t:bibl/text()">
                  <xsl:value-of select="//t:sourceDesc//t:bibl"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="//t:idno[@type = 'filename']"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="//t:titleStmt/t:title/text()">
            <xsl:if test="//t:idno[@type = 'filename']/text()">
               <xsl:value-of select="//t:idno[@type = 'filename']"/>
               <xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:value-of select="//t:titleStmt/t:title"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>EpiDoc example output, default style</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- Mode to copy everything except edition div -->
   <xsl:template match="@* | node()" mode="strip-edition">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="strip-edition"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="t:div[@type = 'edition']" mode="strip-edition"/>

   <xsl:template match="node()" mode="chardecl">
      <xsl:apply-templates mode="chardecl"/>
   </xsl:template>

   <xsl:template match="xi:include" mode="chardecl">
      <xsl:copy-of select="document(@href)"/>
   </xsl:template>
</xsl:stylesheet>
