<?xml version="1.0" ?>
<!--  Copyright (c) Microsoft Corporation.  All rights reserved. -->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:cim="http://schemas.dmtf.org/wsman/2005/06/base">
    <xsl:output method="text"/>
    
    <xsl:param name="singleIndent" select="'    '"/>    
    <xsl:template name="doIndent">
        <xsl:for-each select="ancestor::*">
            <xsl:value-of select="$singleIndent"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="cim:Location"/>
    
    <xsl:template match="*[text()] | *[@xsi:nil]">
      <xsl:if test="name(preceding-sibling::node()[1]) != name()">
        <xsl:call-template name="doIndent"/>
        <xsl:value-of select="local-name()"/>
        <xsl:if test="@Name">
          <xsl:value-of select="': '"/>
          <xsl:value-of select="@Name"/>
        </xsl:if>
        <xsl:value-of select="' = '"/>
      </xsl:if>
      <xsl:if test="name(preceding-sibling::node()[1]) = name()">
        <xsl:if test="@Name">
          <xsl:value-of select="@Name"/>
          <xsl:value-of select="' = '"/>
        </xsl:if>
      </xsl:if>

      <xsl:if test="not(@xsi:nil)"><xsl:value-of select="."/></xsl:if>
      <xsl:if test="@xsi:nil"><xsl:value-of select="'null'"/></xsl:if>

      <xsl:if test="@Source='GPO'"><xsl:value-of select="' [Source=&quot;GPO&quot;]'"/></xsl:if>
        
      <xsl:if test="@Source='Compatibility'"><xsl:value-of select="' [Source=&quot;Compatibility&quot;]'"/></xsl:if>
        
      <xsl:if test="name(following-sibling::node()[1]) = name()">, </xsl:if>
      <xsl:if test="name(following-sibling::node()[1]) != name()">
        <xsl:value-of select="'&#xA;'"/>
      </xsl:if>        
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:call-template name="doIndent"/>
        <xsl:value-of select="local-name()"/>
        <xsl:if test="@Source='GPO'"><xsl:value-of select="' [Source=&quot;GPO&quot;]'"/></xsl:if>
        <xsl:if test="@Source='Compatibility'"><xsl:value-of select="' [Source=&quot;Compatibility&quot;]'"/></xsl:if>
        <xsl:value-of select="'&#xA;'"/>
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>

