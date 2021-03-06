<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns="http://www.loc.gov/mods/v3" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.loc.gov/mods/v3" 
    exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" version="1.0"/>
    <xsl:preserve-space elements="tei:head tei:bibl"/>

    <xsl:include href="Tei2Mods-functions.xsl"/>
    
    <!-- this parameter is currently not used -->
<!--    <xsl:param name="pg_head-section" select="'مخطوطات ومطبوعات'"/>-->
    <!--  -->
    <xsl:param name="p_url-boilerplate" select="'../xslt-boilerplate/modsbp_parameters.xsl'"/>
    
    <!-- it doesn't matter if one applies the transformation to bibl or biblStruct -->
    <xsl:template match="tei:bibl | tei:biblStruct">
        <xsl:variable name="v_type">
            <xsl:choose>
                <xsl:when test="descendant::tei:title/@level = 'm'">
                    <xsl:text>m</xsl:text>
                </xsl:when>
                <xsl:when test="descendant::tei:title/@level = 'a'">
                    <xsl:text>a</xsl:text>
                </xsl:when>
                <xsl:when test="descendant::tei:title/@level = 'j'">
                    <xsl:text>j</xsl:text>
                </xsl:when>
                <xsl:when test="descendant::tei:title/@level = 's'">
                    <xsl:text>m</xsl:text>
                </xsl:when>
                <!-- fallback option -->
                <!--<xsl:otherwise>
                    <xsl:text>m</xsl:text>
                </xsl:otherwise>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="t_bibl-mods">
            <xsl:with-param name="p_type" select="$v_type"/>
            <xsl:with-param name="p_lang" select="'ar'"/>
            <xsl:with-param name="p_author" select="descendant::tei:author"/>
            <xsl:with-param name="p_editor" select="descendant::tei:editor"/>
            <xsl:with-param name="p_edition" select="descendant::tei:edition"/>
            <!-- expects <tei:title> nodes as input -->
            <xsl:with-param name="p_title-article" select="descendant::tei:title[@level = 'a']"/>
            <xsl:with-param name="p_title-publication">
                <xsl:choose>
                    <xsl:when test="$v_type = 'm'">
                        <xsl:copy-of select="descendant::tei:title[@level = 'm']"/>
                    </xsl:when>
                    <xsl:when test="$v_type = 'j' or $v_type = 'a'">
                        <xsl:copy-of select="descendant::tei:title[@level = 'j']"/>
                    </xsl:when>
                    <!-- fallback option -->
                    <xsl:otherwise>
                        <xsl:copy-of select="descendant::tei:title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="p_publisher" select="descendant::tei:publisher"/>
            <xsl:with-param name="p_place-publication" select="descendant::tei:pubPlace"/>
            <!-- this needs to be changed to reflect the changes in the called template -->
            <xsl:with-param name="p_date-publication">
                <xsl:copy-of select="descendant::tei:date"/>
            </xsl:with-param>
            <xsl:with-param name="p_date-accessed" select="ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[1]/@when"/>
            <xsl:with-param name="p_issue">
                <xsl:choose>
                    <!-- check for correct encoding of issue information -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'issue']/@from = descendant::tei:biblScope[@unit = 'issue']/@to">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'issue']/@from"/>
                    </xsl:when>
                    <!-- check for ranges -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'issue']/@from != descendant::tei:biblScope[@unit = 'issue']/@to">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'issue']/@from"/>
                        <!-- probably an en-dash is the better option here -->
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'issue']/@to"/>
                    </xsl:when>
                    <!-- fallback: erroneous encoding of issue information with @n -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'issue']/@n">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'issue']/@n"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="p_volume">
                <xsl:choose>
                    <!-- check for correct encoding of volume information -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'volume']/@from = descendant::tei:biblScope[@unit = 'volume']/@to">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'volume']/@from"/>
                    </xsl:when>
                    <!-- check for ranges -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'volume']/@from != descendant::tei:biblScope[@unit = 'volume']/@to">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'volume']/@from"/>
                        <!-- probably an en-dash is the better option here -->
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'volume']/@to"/>
                    </xsl:when>
                    <!-- fallback: erroneous encoding of volume information with @n -->
                    <xsl:when test="descendant::tei:biblScope[@unit = 'volume']/@n">
                        <xsl:value-of select="descendant::tei:biblScope[@unit = 'volume']/@n"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="p_pages" select="descendant::tei:biblScope[@unit = 'page']"/>
            <!-- empty params that are node sets need to be set -->
            <xsl:with-param name="p_idno" select="descendant::tei:idno"/>
            <xsl:with-param name="p_url-licence"/>
            <!-- $p_url accepts more then one URL separated by whitespace -->
            <xsl:with-param name="p_url-self">
                <xsl:choose>
                    <xsl:when test="descendant::tei:idno[@type='url']">
                        <xsl:value-of select="descendant::tei:idno[@type='url']"/>
                    </xsl:when>
                    <xsl:when test="descendant::tei:ref[@type='url'][@target]">
                        <xsl:value-of select="descendant::tei:ref[@type='url']/@target"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
<!--            <xsl:with-param name="p_url-self" select="concat('https://rawgit.com/tillgrallert/digital-muqtabas/master/xml/', tokenize(base-uri(), '/')[last()], '#', @xml:id)"/>-->
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="/">
        <xsl:result-document href="../metadata/{$vgFileId}-bibl.MODS.xml">
            <xsl:value-of select="concat('&lt;?xml-stylesheet type=&quot;text/xsl&quot; href=&quot;',$p_url-boilerplate,'&quot;?&gt;')" disable-output-escaping="yes"/>
            <modsCollection xsi:schemaLocation="{$v_schema}">
                <!--<xsl:apply-templates select=".//tei:body//tei:bibl[contains(ancestor::tei:div/tei:head/text(),$pg_head-section)]"/>-->
                <xsl:apply-templates select=".//tei:body//tei:bibl[descendant::tei:title] | .//tei:body//tei:biblStruct"/>
                <!-- apply to the works listed in the particDesc -->
                <xsl:apply-templates select=".//tei:particDesc//tei:bibl[descendant::tei:title]"/>
            </modsCollection>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
