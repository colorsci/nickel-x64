<?xml version="1.0"?>
<!-- Copyright (c) Microsoft Corporation.  All rights reserved. -->
<!-- Generic stylesheet for viewing XML -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    
  <!-- This template will always be executed, even if this stylesheet is not run on the document root -->
  <xsl:template match="/">
    <DIV STYLE="font-family:Courier; font-size:10pt; margin-bottom:2em">
      <!-- Scoped templates are used so they don't interfere with the "kick-off" template. -->
        <xsl:apply-templates/>
    </DIV>
  </xsl:template>

  <xsl:template match="*">
     <DIV STYLE="margin-left:1em; color:gray">
        &lt;<xsl:value-of select="local-name()"/>&gt;<xsl:apply-templates select="@*"/>/&gt;
     </DIV>
  </xsl:template>

  <xsl:template match="*[node()]">
     <DIV STYLE="margin-left:1em">
        <SPAN STYLE="color:gray">&lt;<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*"/>&gt;</SPAN><xsl:apply-templates select="node()"/><SPAN STYLE="color:gray">&lt;/<xsl:value-of select="local-name()"/>&gt;</SPAN>
      </DIV>
  </xsl:template>

  <xsl:template match="@*">
      <SPAN STYLE="color:navy"> <xsl:value-of select="local-name()"/>="<SPAN STYLE="color:black"><xsl:value-of select="."/></SPAN>"</SPAN>
  </xsl:template>

  <xsl:template match="processing-instruction()">
      <DIV STYLE="margin-left:1em; color:maroon">&lt;?<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*"/>?&gt;</DIV>
  </xsl:template>

  <xsl:template match="node()[nodeTypeString=cdatasection]"><pre>&lt;![CDATA[<xsl:value-of select="."/>]]&gt;</pre></xsl:template>

  <xsl:template match="text()"><xsl:value-of select="."/></xsl:template>

</xsl:stylesheet>
