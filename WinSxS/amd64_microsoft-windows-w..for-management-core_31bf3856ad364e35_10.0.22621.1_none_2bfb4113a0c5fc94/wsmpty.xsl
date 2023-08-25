<?xml version="1.0" ?>
<!--  Copyright (c) Microsoft Corporation.  All rights reserved. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    
    <xsl:param name="singleIndent" select="'    '"/>    
    <xsl:template name="doIndent">
        <xsl:for-each select="ancestor::*">
            <xsl:value-of select="$singleIndent"/>
        </xsl:for-each>
    </xsl:template>
        
    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*[text()]">
        <xsl:call-template name="doIndent"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>
    
    <xsl:template match="*[*]">
        <xsl:call-template name="doIndent"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="'&#xA;'"/>
            <xsl:apply-templates select="node()"/>
            <xsl:call-template name="doIndent"/>
        </xsl:copy>
        <xsl:value-of select="'&#xA;'"></xsl:value-of>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:call-template name="doIndent"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>

</xsl:stylesheet>

