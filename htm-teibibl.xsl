<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:f="http://example.com/ns/functions"
	xmlns:html="http://www.w3.org/1999/html" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="t f atom dc" version="2.0"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:import href="htm-teilistbiblandbibl.xsl" />
	<!--

Pietro notes on 14/8/2015 work on this template, from mail to Gabriel.

- I have converted the TEI bibliography of IRT and IGCyr to ZoteroRDF
(https://github.com/EAGLE-BPN/BiblioTEI2ZoteroRDF) in this passage I have tried to
distinguish books, bookparts, articles and conference proceedings.

- I have uploaded these to the zotero eagle open group bibliography
(https://www.zotero.org/groups/eagleepigraphicbibliography)

- I have created a parametrized template in my local epidoc xslts which looks at the json
and TEI output of the Zotero api basing the call on the content of ptr/@target in each
bibl. It needs both because the key to build the link is in the json but the TEI xml is
much more accessible for the other data. I tried also to grab the html div exposed in the
json, which would have been the easiest thing to do, but I can only get it escaped and
thus is not usable.
** If set on 'zotero' it prints surname, name, title and year with a link to the zotero
item in the eagle group bibliography. It assumes bibl only contains ptr and citedRange.
** If set on 'localTEI' it looks at a local bibliography (no zotero) and compares the
@target to the xml:id to take the results and print something (in the sample a lot, but
I'd expect more commonly Author-Year references(.
** I have also created sample values for irt and igcyr which are modification of the
zotero option but deal with some of the project specific ways of encoding the
bibliography. All examples only cater for book and article.



-->

	<!--

        Pietro Notes on 10.10.2016

        this should be modified based on parameters to

        * decide wheather to use zotero or a local version of the bibliography in TEI

        * assuming that the user has entered a unique tag name as value of ptr/@target, decide group or
    user in zotero to look up based on parameter value entered at transformation time

        * output style based on Zotero Style Repository stored in a parameter value entered at
    transformation time



    -->

	<xsl:template match="t:bibl">
		<xsl:param name="parm-bib" tunnel="yes" required="no" />
        <xsl:param name="parm-bibloc"
			tunnel="yes" required="no" />
        <xsl:param name="parm-zoteroUorG" tunnel="yes"
			required="no" />
        <xsl:param name="parm-zoteroKey" tunnel="yes" required="no" />
        <xsl:param
			name="parm-zoteroNS" tunnel="yes" required="no" />
        <xsl:param name="parm-zoteroStyle"
			tunnel="yes" required="no" />

        <xsl:choose>
			<!-- default general zotero behaviour prints
                author surname and name, title in italics, date and links to the zotero item page on the zotero
            bibliography.
                assumes the inscription source has no free text in bibl,
                !!!!!!!only a <ptr target='key'/> and a <citedRange>pp. 45-65</citedRange>!!!!!!!
            it also assumes that the content of ptr/@target is a unique tag used in the zotero bibliography as
            the ids assigned by Zotero are not
            reliable enough for this purpose according to Zotero forums.

            if there is no ptr/@target, this will try anyway and take a lot of time.
            -->

			<xsl:when test="$parm-bib = 'none'">
				<xsl:apply-templates />
			</xsl:when>

			<xsl:when test="$parm-bib = 'zotero'">
				<xsl:choose>
					<!--                    check if there is a ptr at all

                    WARNING. if the pointer is not there, the transformation will simply stop and return a premature
                    end of file message e.g. it cannot find what it is looking for via the zotero
                    api
                    -->
					<xsl:when test=".[t:ptr]">
						<!-- check if a namespace is provided for tags/xml:ids and use it as part of
                        the tag for zotero -->
                        <xsl:variable name="biblentry">
							<xsl:choose>
								<xsl:when test="$parm-zoteroNS">
									<xsl:value-of select="concat($parm-zoteroNS, ./t:ptr/@target)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="tokenize(./t:ptr/@target, '/')[last()]" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

                        <xsl:variable
							name="item-key" select="tokenize($biblentry, '/')[last()]" />
                        <xsl:message>
							<xsl:value-of select="$item-key" />
						</xsl:message>

                        <xsl:variable
							name="zoteroapi">
							<xsl:value-of
								select="concat('https://api.zotero.org/',$parm-zoteroUorG,'/',$parm-zoteroKey,'/items/',$item-key,'?format=atom&amp;content=citation&amp;style=',$parm-zoteroStyle)" />
						</xsl:variable>

						<xsl:variable
							name="atom-doc" select="document($zoteroapi)" />

                        <xsl:choose>
							<!--this
                            will print a citation according to the selected style with a link around
                            it pointing to the resource DOI, url or zotero item view-->
							<xsl:when test="not(ancestor::t:div[@type = 'bibliography'])">
								<xsl:variable name="pointerurl">
									<xsl:choose>
										<xsl:when
											test="$atom-doc//atom:link[@rel='alternate' and @type='text/html']">
											<xsl:value-of
												select="$atom-doc//atom:link[@rel='alternate' and @type='text/html']/@href" />
										</xsl:when>
										<xsl:when
											test="$atom-doc//dc:identifier[starts-with(., 'doi:')]">
											<xsl:value-of
												select="substring-after($atom-doc//dc:identifier[starts-with(., 'doi:')], 'doi:')" />
										</xsl:when>
										<xsl:when
											test="$atom-doc//dc:identifier[starts-with(., 'http')]">
											<xsl:value-of
												select="$atom-doc//dc:identifier[starts-with(., 'http')]" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$atom-doc//atom:id" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

                                <a
									href="{$pointerurl}">
									<xsl:value-of select="$atom-doc//atom:content" />
									<xsl:if test="t:citedRange">
										<xsl:text>, </xsl:text>
                                        <xsl:value-of select="t:citedRange" />
									</xsl:if>
								</a>
							</xsl:when>
							<!--if
                            it is in the bibliography print styled reference-->
							<xsl:otherwise>
								<xsl:sequence select="$atom-doc//atom:content" />
							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>

					<!-- if there is no ptr, print simply what is inside bibl and a warning
                        message-->
					<xsl:otherwise>
						<xsl:apply-templates />
                        <xsl:message>There is no ptr with a @target in the
		bibl element <xsl:copy-of
								select="." />. A target equal to a tag in your zotero bibliography
		is necessary.</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>


			<!--uses
            the local TEI bibliography at the path specified in parameter parm-bibloc -->
			<xsl:when test="$parm-bib = 'localTEI'">

				<xsl:variable name="biblentry" select="./t:ptr/@target" />
                <xsl:variable
					name="biblentryID" select="substring-after(./t:ptr/@target, '#')" />
				<!--                    parameter localbibl should contain the path to the bibliography relative to
                this xslt -->
                <xsl:variable
					name="textref"
					select="document(string($parm-bibloc))//t:bibl[@xml:id = $biblentryID]" />
                <xsl:for-each
					select="$biblentry">
					<xsl:choose>
						<!--this
                        will print a citation according to the selected style with a link around it
                        pointing to the resource DOI, url or zotero item view-->
						<xsl:when test="not(ancestor::t:div[@type = 'bibliography'])">

							<!-- basic  render for citations-->
                            <xsl:choose>
								<xsl:when test="$textref/@xml:id = $biblentryID">
									<xsl:choose>
										<xsl:when test="$textref//t:author">
											<xsl:value-of select="$textref//t:author[1]" />
                                            <xsl:if
												test="$textref//t:author[2]">
												<xsl:text>-</xsl:text>
                                                <xsl:value-of
													select="$textref//t:author[2]" />
											</xsl:if>
                                            <xsl:text>, </xsl:text>
										</xsl:when>
										<xsl:when test="$textref//t:editor">
											<xsl:value-of select="$textref//t:editor[1]" />
                                            <xsl:if
												test="$textref//t:editor[2]">
												<xsl:text>-</xsl:text>
                                                <xsl:value-of
													select="$textref//t:editor[2]" />
											</xsl:if>
										</xsl:when>
									</xsl:choose>
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of
										select="$textref//t:date" />
                                    <xsl:text>), </xsl:text>
                                    <xsl:value-of
										select="$textref//t:biblScope" />

								</xsl:when>
								<xsl:otherwise>
									<!--if
                                    this appears the id do not really correspond to each other,
                                    ther might be a typo or a missing entry in the bibliography-->
                                    <xsl:message>
										<xsl:text> there is no entry in your bibliography file at </xsl:text>
                                        <xsl:value-of select="$parm-bibloc" />
                                        <xsl:text> with the @xml:id</xsl:text>
                                        <xsl:value-of
											select="$biblentry" />
                                        <xsl:text>!</xsl:text>
									</xsl:message>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>

							<!--                        rudimental render for each entry in bibliography-->
                            <xsl:choose>
								<xsl:when test="$textref/@xml:id = $biblentryID">
									<xsl:value-of select="$textref" />
									<!--assumes
                                    a sligthly "formatted" bibliography...-->

								</xsl:when>
								<xsl:otherwise>
									<!--if
                                    this appears the id do not really correspond to each other,
                                    ther might be a typo or a missing entry in the bibliography-->
                                    <xsl:message>
										<xsl:text> there is no entry in your bibliography file at </xsl:text>
                                        <xsl:value-of select="$parm-bibloc" />
                                        <xsl:text> for the entry </xsl:text>
                                        <xsl:value-of
											select="$biblentry" />
                                        <xsl:text>!</xsl:text>
									</xsl:message>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:for-each>

			</xsl:when>
			<xsl:otherwise>
				<!-- This applyes other templates and does not call the zotero api -->
				<!--<xsl:apply-templates/>-->
                <xsl:apply-imports />
				<!-- so that the templates in 'htm-teilistbiblandbibl.xsl are applied (li aroub bibl
                elements) -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="t:ptr[@target]">
		<xsl:param name="parm-edn-structure" tunnel="yes" required="no" />
        <xsl:param
			name="parm-leiden-style" tunnel="yes" required="no" />
        <xsl:choose>
			<!-- MODIFIED for SigiDoc by MS 2023-06-16 -->
			<xsl:when
				test="$parm-leiden-style = 'medcyprus' or $parm-edn-structure = 'inslib' or $parm-edn-structure = 'sample' or $parm-edn-structure = 'sigidoc'">
				<!-- if you are running this template outside EFES, change the path to the
                bibliography authority list accordingly -->
                <xsl:variable
					name="bibliography-al"
					select="concat('file:', system-property('user.dir'), '/webapps/ROOT/content/xml/authority/bibliography.xml')" />
                <xsl:variable
					name="bibl-ref" select="translate(@target, '#', '')" />
                <xsl:choose>
					<xsl:when test="doc-available($bibliography-al) = fn:true()">
						<xsl:variable name="bibl"
							select="document($bibliography-al)//t:bibl[@xml:id = $bibl-ref][not(@sameAs)]" />
                        <a
							href="../concordance/bibliography/{$bibl-ref}.html" target="_blank">
							<xsl:choose>
								<xsl:when test="$bibl//t:bibl[@type = 'abbrev']">
									<xsl:apply-templates select="$bibl//t:bibl[@type = 'abbrev'][1]"
									/>
								</xsl:when>
								<xsl:when test="$bibl//t:title[@type = 'short']">
									<xsl:apply-templates select="$bibl//t:title[@type = 'short'][1]"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when
											test="$bibl[ancestor::t:div[@xml:id = 'series_collections']]">
											<i>
												<xsl:value-of select="$bibl/@xml:id" />
											</i>
										</xsl:when>
										<xsl:when
											test="$bibl[ancestor::t:div[@xml:id = 'authored_editions']] or ($bibl//t:name[@type = 'surname'] and $bibl//t:date)">
											<xsl:for-each
												select="$bibl//t:name[@type = 'surname'][not(parent::*/preceding-sibling::t:title[not(@type = 'short')])]">
												<xsl:apply-templates select="." />
                                                <xsl:if
													test="position() != last()"> – </xsl:if>
											</xsl:for-each>
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates
												select="$bibl//t:date" />
										</xsl:when>

										<xsl:when test="$bibl//t:surname and $bibl//t:date">
											<xsl:for-each
												select="$bibl//t:surname[not(parent::*/preceding-sibling::t:title[not(@type = 'short')])]">
												<xsl:apply-templates select="." />
                                                <xsl:if
													test="position() != last()"> – </xsl:if>
											</xsl:for-each>
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates
												select="$bibl//t:date" />
										</xsl:when>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$bibl-ref" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="t:title[not(ancestor::t:titleStmt)][not(@type = 'short')]"
		mode="#default inslib-dimensions inslib-placename sample-dimensions creta  medcyprus-location medcyprus-dimensions">
		<xsl:param name="parm-edn-structure" tunnel="yes" required="no" />
        <xsl:param
			name="parm-leiden-style" tunnel="yes" required="no" />
        <xsl:choose>
			<xsl:when
				test="$parm-edn-structure = ('inslib', 'sample') or $parm-leiden-style = 'medcyprus'">
				<i>
					<xsl:apply-templates />
				</i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>