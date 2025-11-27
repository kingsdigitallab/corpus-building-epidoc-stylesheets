<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">

   <!-- Other div matches can be found in htm-teidiv*.xsl -->

   <!-- Text edition div -->
   <xsl:template match="t:div[@type = 'edition']" priority="1">
      <xsl:param name="parm-edition-type" tunnel="yes" required="no"/>
      <xsl:param name="parm-internal-app-style" tunnel="yes" required="no"/>
      <xsl:param name="parm-external-app-style" tunnel="yes" required="no"/>
      <xsl:param name="parm-resp-stmt" tunnel="yes" required="no"/>
      <xsl:param name="parm-autopsy" tunnel="yes" required="no"/>

      <div class="attribution">
         <xsl:choose>
            <xsl:when test="@resp">
               <xsl:text>Text encoding: </xsl:text>
               <xsl:for-each select="tokenize(@resp, ' ')">
                  <xsl:variable name="resp" select="normalize-space(.)"/>
                  <xsl:value-of
                     select="$parm-resp-stmt//t:name[@xml:id = substring-after($resp, '#')]"/>
                  <xsl:if test="position() != last()">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:if test="@source">
                  <xsl:text>; edition source: </xsl:text>
                  <xsl:choose>
                     <xsl:when test="@source = '#autopsy'"> autopsy <xsl:value-of
                           select="$parm-autopsy"/>
                     </xsl:when>
                     <xsl:when test="starts-with(@source, 'http')">
                        <a href="{@source}">
                           <xsl:value-of select="@source"/>
                        </a>
                     </xsl:when>
                     <xsl:when test="@source = '#image' or contains(@source, '.jpg')">
                        <xsl:text>image</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="@source"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Unknown</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </div>

      <div>
         <xsl:attribute name="id">
            <xsl:text>edition-</xsl:text>
            <xsl:value-of select="$parm-edition-type"/>
            <xsl:if test="@subtype and lower-case(@subtype) != 'primary'">
               <xsl:text>-</xsl:text>
               <xsl:value-of select="replace(@subtype, '-primary', '')"/>
            </xsl:if>
         </xsl:attribute>

         <!-- Found in htm-tpl-lang.xsl -->
         <xsl:call-template name="attr-lang"/>

         <xsl:apply-templates/>

         <xsl:choose>
            <!-- Apparatus creation: look in tpl-apparatus.xsl for documentation and templates -->
            <xsl:when test="$parm-internal-app-style = 'ddbdp'">
               <!-- Framework found in htm-tpl-apparatus.xsl -->
               <xsl:call-template name="tpl-apparatus"/>
            </xsl:when>
            <xsl:when test="$parm-internal-app-style = 'iospe'">
               <!-- Template found in htm-tpl-apparatus.xsl -->
               <xsl:call-template name="tpl-iospe-apparatus"/>
            </xsl:when>
            <xsl:when test="$parm-internal-app-style = 'fullex'">
               <!-- Template found in htm-tpl-apparatus.xsl -->
               <xsl:call-template name="tpl-fullex-apparatus"/>
            </xsl:when>

            <xsl:when test="$parm-internal-app-style = 'minex'">
               <!-- Template found in htm-tpl-apparatus.xsl -->
               <xsl:call-template name="tpl-minex-apparatus"/>
            </xsl:when>

            <xsl:when test="$parm-internal-app-style = 'medcyprus'">
               <!-- Template found in htm-tpl-apparatus.xsl -->
               <xsl:call-template name="tpl-medcyprus-apparatus"/>
            </xsl:when>


            <!--     the default if nothing is selected is to print no internal apparatus      -->
         </xsl:choose>
      </div>
   </xsl:template>


   <!-- Textpart div -->
   <xsl:template match="t:div[@type = 'edition']//t:div[@type = 'textpart']" priority="1">
      <xsl:param name="parm-leiden-style" tunnel="yes" required="no"/>
      <xsl:param name="parm-internal-app-style" tunnel="yes" required="no"/>
      <xsl:variable name="div-type">
         <xsl:for-each select="ancestor::t:div[@type != 'edition']">
            <xsl:value-of select="@type"/>
            <xsl:text>-</xsl:text>
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="div-loc">
         <xsl:for-each select="ancestor::t:div[@type = 'textpart'][@n]">
            <xsl:value-of select="@n"/>
            <xsl:text>-</xsl:text>
         </xsl:for-each>
      </xsl:variable>
      <xsl:if test="@n">
         <!-- prints div number -->
         <span class="textpartnumber" id="{$div-type}ab{$div-loc}{@n}">
            <!-- add ancestor textparts -->
            <xsl:if test="@subtype">
               <xsl:choose>
                  <xsl:when test="contains(@subtype, '-')">
                     <xsl:value-of select="substring-before(@subtype, '-')"/>
                     <xsl:text> (</xsl:text>
                     <xsl:value-of select="substring-after(@subtype, '-')"/>
                     <xsl:text>)</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="@subtype"/>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="@n"/>
         </span>
         <xsl:if test="child::*[1][self::t:div[@type = 'textpart'][@n]]">
            <br/>
         </xsl:if>
      </xsl:if>

      <!-- Custodial events here -->
      <!-- first get the value of the columns @corresp -->
      <xsl:variable name="corresp" select="@corresp"/>
      <!-- then find each custEvent with a matching @corresp value -->

      <xsl:variable name="div-n" select="@n"/>
      <xsl:variable name="div-subtype" select="@subtype"/>
      <xsl:for-each select="//t:idno[@xml:id = (tokenize(replace($corresp, '#', ''), ' '))]">
         <span class="corresp idno">
            <xsl:value-of select="."/>
         </span>
         <br/>
      </xsl:for-each>
      <xsl:for-each select="//t:custEvent[@corresp = (tokenize($corresp, ' '))]">

         <span class="custevent" id="ce{$div-loc}{$div-n}">

            <!-- type of event -->
            <xsl:variable name="type-string">
               <xsl:choose>
                  <xsl:when test="@type = 'MSI'">
                     <xsl:text>Multi-spectral image captured</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of
                        select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="t:graphic[@url]">
                  <xsl:variable name="gtype">
                     <xsl:choose>
                        <xsl:when test="@type = 'sketched'">scan of sketch</xsl:when>
                        <xsl:when test="@type = 'imaged'">digital photograph</xsl:when>
                        <xsl:when test="@type = 'engraved'">scan of engraving</xsl:when>
                        <xsl:when test="@type = 'MSI'">multi-spectral image</xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="@type"/>
                           <xsl:message>WARNING (<xsl:value-of select="//t:idno[@type = 'dclp']"/>):
                              unexpected type value for custodial event: <xsl:value-of
                                 select="@type"/></xsl:message>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <a href="{t:graphic/@url}" title="{$gtype} of {$div-subtype} {$div-n}">
                     <xsl:value-of select="$type-string"/>
                  </a>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$type-string"/>
               </xsl:otherwise>
            </xsl:choose>

            <!-- date of event -->
            <xsl:if test="@when">
               <xsl:text> </xsl:text>
               <xsl:value-of select="@when"/>
            </xsl:if>
            <xsl:if test="@from and @to">
               <xsl:text> </xsl:text>
               <xsl:value-of select="@from"/>-<xsl:value-of select="@to"/>
            </xsl:if>

            <!-- responsible individual -->
            <xsl:text> by </xsl:text>
            <xsl:choose>
               <xsl:when test="t:forename or t:surname">
                  <xsl:value-of select="t:forename"/>
                  <xsl:if test="t:forename and t:surname">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                  <xsl:value-of select="t:surname"/>
               </xsl:when>
               <xsl:otherwise> [unidentified responsible individual] </xsl:otherwise>
            </xsl:choose>

         </span>
         <br/>
      </xsl:for-each>

      <!--<br/>-->
      <xsl:apply-templates/>
      <xsl:if test="$parm-internal-app-style = 'iospe' and @n">
         <!-- Template found in htm-tpl-apparatus.xsl -->
         <xsl:call-template name="tpl-iospe-apparatus"/>
      </xsl:if>
   </xsl:template>
</xsl:stylesheet>
