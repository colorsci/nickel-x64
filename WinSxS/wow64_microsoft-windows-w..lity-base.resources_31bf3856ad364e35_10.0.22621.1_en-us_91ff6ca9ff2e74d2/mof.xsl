<?xml version="1.0"?>
<!-- Copyright (c) Microsoft Corporation.  All rights reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    
    <!-- Root template selects all children of the CIM/DECLARATIONS tag -->
	
	<xsl:template match="/">
		<xsl:apply-templates select="COMMAND//RESULTS//CIM//CLASS"/>
		<xsl:apply-templates select="COMMAND//RESULTS//CIM//INSTANCE"/>
	</xsl:template>
	
	<!-- CLASS template formats a single CIM non-association class  -->
	
	<xsl:template match="CLASS">
		<DIV CLASS="mofclass">
			<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/><br/></SPAN>
			<SPAN CLASS="mofkeyword">class</SPAN>
			<xsl:value-of select="@NAME"/>
			<xsl:apply-templates select="CLASSPATH"/>
			<xsl:if test="*[@SUPERCLASS]">
				<SPAN CLASS="mofsymbol">: </SPAN><xsl:value-of select="@SUPERCLASS"/>
			</xsl:if>
			<BR/>
			<SPAN CLASS="mofsymbol">{</SPAN><BR/>
			<xsl:apply-templates select="PROPERTY"/>
			<xsl:apply-templates select="PROPERTY.ARRAY"/>
			<xsl:apply-templates select="PROPERTY.REFERENCE"/>
			<xsl:apply-templates select="METHOD"/>
			<SPAN CLASS="mofsymbol">};</SPAN>
		</DIV>
	</xsl:template>
	
	<!-- QUALIFIER template formats a list of qualifier name/value pairs -->
	
	<xsl:template match="QUALIFIER">
		<xsl:if test="QUALIFIER[0]"><SPAN CLASS="mofsymbol">[</SPAN></xsl:if>
			<SPAN CLASS="mofqualifier"><xsl:value-of select="@NAME"/></SPAN>
			<SPAN CLASS="mofsymbol">(</SPAN><xsl:apply-templates/><SPAN CLASS="mofsymbol">)</SPAN><xsl:if test="position()!=last()">,
		</xsl:if>
		<xsl:if test="last()"><SPAN CLASS="mofsymbol">]</SPAN>
		</xsl:if>
		
	</xsl:template>
	
	<!-- VALUE template formats a non-array property or qualifier value -->
	
	<xsl:template match="VALUE">
		<xsl:if test="name(..)='PROPERTY' and name()='VALUE'"><SPAN CLASS="mofsymbol">=</SPAN></xsl:if>
		<xsl:choose>
			<xsl:when test="parent::PROPERTY[@TYPE='string']"><SPAN CLASS="mofstring">"<xsl:value-of select="normalize-space(.)"/>"</SPAN></xsl:when>
			<xsl:when test="parent::PROPERTY[@TYPE='datetime']"><SPAN CLASS="mofstring">"<xsl:value-of select="normalize-space(.)"/>"</SPAN></xsl:when>
			<xsl:when test="parent::PROPERTY[@TYPE='char16']"><SPAN CLASS="mofchar">'<xsl:value-of select="normalize-space(.)"/>'</SPAN></xsl:when>
			<xsl:otherwise><SPAN CLASS="mofvalue"><xsl:value-of select="."/></SPAN></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- VALUE.ARRAY/VALUE template formats an array or qualifier property -->
	<!-- value element                                                     -->
	<xsl:template match="VALUE.ARRAY/VALUE">
	 <xsl:choose>
	  <xsl:when test="ancestor::PROPERTY.ARRAY[@TYPE='string']/VALUE.ARRAY/VALUE"><SPAN CLASS="mofstring">"<xsl:value-of select="normalize-space(.)"/>"</SPAN></xsl:when>
	  <xsl:when test="ancestor::PROPERTY.ARRAY[@TYPE='datetime']/VALUE.ARRAY/VALUE"><SPAN CLASS="mofstring">"<xsl:value-of select="normalize-space(.)"/>"</SPAN></xsl:when>
	  <xsl:when test="ancestor::PROPERTY.ARRAY[@TYPE='char16']/VALUE.ARRAY/VALUE"><SPAN CLASS="mofchar">'<xsl:value-of select="normalize-space(.)"/>'</SPAN></xsl:when>
	  <xsl:otherwise><SPAN CLASS="mofvalue"><xsl:value-of select="."/></SPAN></xsl:otherwise>
	 </xsl:choose>
	 <xsl:if test="position()!=last()">,</xsl:if>
	</xsl:template>
	
	<!-- VALUE.ARRAY template formats an array property or qualifier value -->
	<xsl:template match="VALUE.ARRAY">
		<xsl:if test="name(..)='PROPERTY.ARRAY' and name()='VALUE.ARRAY'"><SPAN CLASS="mofsymbol">=</SPAN></xsl:if>
		<SPAN CLASS="mofsymbol">{</SPAN><xsl:apply-templates select="VALUE"/><SPAN CLASS="mofsymbol">}</SPAN>
	</xsl:template>
	
	<!-- CLASSPATH template -->
	<xsl:template match="CLASSPATH">
		<xsl:value-of select="@CLASSNAME"/>
	</xsl:template>
	
	<!-- PROPERTY template formats a single CIM non-array property  -->
	
	<xsl:template match="PROPERTY">
	    <DD>
		<DIV CLASS="mofproperty">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<SPAN CLASS="mofkeyword"><xsl:value-of select="@TYPE"/></SPAN>
		<SPAN CLASS="mofproperty"><xsl:value-of select="@NAME"/></SPAN>
		<xsl:apply-templates select="VALUE"/>
		<SPAN CLASS="mofsymbol">;</SPAN><BR/>
		</DIV>
		</DD>
	</xsl:template>
	
	<!-- PROPERTY.ARRAY template formats a single CIM array property  -->
	
	<xsl:template match="PROPERTY.ARRAY">
	    <DD>
		<DIV CLASS="mofproperty">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<SPAN CLASS="mofkeyword"><xsl:value-of select="@TYPE"/></SPAN>
		<SPAN CLASS="mofproperty"><xsl:value-of select="@NAME"/></SPAN>
		<SPAN CLASS="mofsymbol">[</SPAN><xsl:value-of select="@ARRAYSIZE"/><SPAN CLASS="mofsymbol">]</SPAN>
		<xsl:apply-templates select="VALUE.ARRAY"/><SPAN CLASS="mofsymbol">;</SPAN><BR/>
		</DIV>
		</DD>
	</xsl:template>
	
	<!-- METHOD template formats a single CIM method  -->
	
	<xsl:template match="METHOD">
		<DIV CLASS="mofmethod">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<SPAN CLASS="mofkeyword"><xsl:value-of select="@TYPE"/></SPAN>
		<SPAN CLASS="mofmethod"><xsl:value-of select="@NAME"/></SPAN>
		<SPAN CLASS="mofsymbol">(</SPAN>
		<xsl:apply-templates select="METHODPARAMETER|PARAMETER|PARAMETER.OBJECT|PARAMETER.REFERENCE"/>
		<SPAN CLASS="mofsymbol">);</SPAN>
		</DIV>
	</xsl:template>
	
	<!-- METHODPARAMETER template and the next 3 formats a single CIM method parameter  -->
	
	<xsl:template match="METHODPARAMETER">
		<DIV CLASS="mofmethodparameter">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<xsl:choose>
			<xsl:when test="PARAMETER">
				<SPAN CLASS="mofkeyword"><xsl:value-of select="PARAMETER[@TYPE]"/></SPAN>
			</xsl:when>
			<xsl:when test="PARAMETER.REFERENCE">
				<SPAN CLASS="mofkeyword">object ref</SPAN>
			</xsl:when>
			<xsl:when test="PARAMETER.REFERENCE[@REFERENCECLASS]">
				<SPAN CLASS="mofkeyword"><xsl:value-of select="PARAMETER.REFERENCE[@REFERENCECLASS]"/> ref</SPAN>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="@NAME"/><xsl:if test="position()!=last()"><SPAN CLASS="mofsymbol">,</SPAN>
		</xsl:if>
		</DIV>
	</xsl:template>
	
   	<xsl:template match="PARAMETER">
		<DIV CLASS="mofmethodparameter">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<SPAN CLASS="mofkeyword"><xsl:value-of select="@TYPE"/></SPAN>
		<xsl:value-of select="@NAME"/><xsl:if test="position()!=last()"><SPAN CLASS="mofsymbol">,</SPAN>
		</xsl:if>
		</DIV>
	</xsl:template>
    
    <xsl:template match="PARAMETER.OBJECT">
		<DIV CLASS="mofmethodparameter">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
        <xsl:if test="not(@REFERENCECLASS)"><SPAN CLASS="mofkeyword">object ref</SPAN></xsl:if>
        <xsl:if test="@REFERENCECLASS"><SPAN CLASS="mofkeyword"><xsl:value-of select="@REFERENCECLASS"/> ref</SPAN></xsl:if>
		<xsl:value-of select="@NAME"/><xsl:if test="position()!=last()"><SPAN CLASS="mofsymbol">,</SPAN>
		</xsl:if>
		</DIV>
	</xsl:template> 
    
   	<xsl:template match="PARAMETER.REFERENCE">
		<DIV CLASS="mofmethodparameter">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
        <xsl:if test="not(@REFERENCECLASS)"><SPAN CLASS="mofkeyword">object ref</SPAN></xsl:if>
        <xsl:if test="@REFERENCECLASS"><SPAN CLASS="mofkeyword"><xsl:value-of select="@REFERENCECLASS"/> ref</SPAN></xsl:if>
		<xsl:value-of select="@NAME"/><xsl:if test="position()!=last()"><SPAN CLASS="mofsymbol">,</SPAN>
		</xsl:if>
		</DIV>
	</xsl:template>
    
	<!-- INSTANCE template formats a single CIM non-association instance  -->
	
	<xsl:template match="INSTANCE">
		<DIV CLASS="mofinstance">
			<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/><br/></SPAN>
			<SPAN CLASS="mofkeyword">instance of</SPAN><xsl:text>
</xsl:text>
			<xsl:value-of select="@CLASSNAME"/><xsl:text>
</xsl:text>
  			<SPAN CLASS="mofsymbol">{</SPAN><BR/><xsl:text>
</xsl:text>
 			<DL><xsl:text>
</xsl:text>
			<xsl:apply-templates select="PROPERTY"/>
			<xsl:apply-templates select="PROPERTY.ARRAY"/>
			<xsl:apply-templates select="PROPERTY.REFERENCE"/>
			</DL>
			<SPAN CLASS="mofsymbol">};</SPAN>
		</DIV>
	</xsl:template>
	
	<!-- VALUE.REFERENCE template formats a reference property value -->
	<xsl:template match="VALUE.REFERENCE">
		<SPAN CLASS="mofsymbol">=</SPAN>
		<SPAN CLASS="mofstring">"<xsl:apply-templates/>"</SPAN>
	</xsl:template>

	<xsl:template match="KEYBINDING/VALUE.REFERENCE">
			<SPAN CLASS="mofstring">"<xsl:apply-templates/>"</SPAN>
	</xsl:template>
	
	<xsl:template match="VALUE.REFERENCE/CLASSPATH">
		<xsl:apply-templates select="NAMESPACEPATH"/>:<xsl:value-of select="@CLASSNAME"/>
	</xsl:template>
	
	<xsl:template match="INSTANCEPATH">
		<xsl:apply-templates select="NAMESPACEPATH"/>:<xsl:apply-templates select="INSTANCENAME"/>
	</xsl:template>

	<xsl:template match="INSTANCENAME">
		<xsl:value-of select="@CLASSNAME"/>.<xsl:for-each select="KEYBINDING"><xsl:apply-templates select="."/></xsl:for-each>
	</xsl:template>
	
	<!-- NAMESPACEPATH template formats a reference property value -->
	<xsl:template match="NAMESPACEPATH">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="HOST">\\<xsl:value-of select="."/></xsl:template>

	<xsl:template match="LOCALNAMESPACEPATH"><xsl:apply-templates select="NAMESPACE"/></xsl:template>

	<xsl:template match="NAMESPACE">\<xsl:value-of select="@NAME"/></xsl:template>
	
	<!-- KEYBINDING template formats a reference property value -->
	<xsl:template match="KEYBINDING">
		<xsl:value-of select="@NAME"/>=<xsl:apply-templates select="KEYVALUE"/><xsl:if test="position()!=last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="KEYVALUE">
		<xsl:choose>
			<xsl:when test="parent::KEYBINDING[@TYPE='numeric']/VALUE"><SPAN CLASS="mofvalue">
                <xsl:value-of select="."/></SPAN></xsl:when>
			<xsl:when test="parent::KEYBINDING[@TYPE='boolean']/VALUE"><SPAN CLASS="mofvalue">
                <xsl:value-of select="."/></SPAN></xsl:when>
			<xsl:otherwise><SPAN CLASS="mofstring">"<xsl:value-of select="."/>"</SPAN></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- PROPERTY.REFERENCE template formats a single CIM reference property  -->
	
	<xsl:template match="PROPERTY.REFERENCE">
		<DIV CLASS="mofproperty">
		<SPAN CLASS="mofqualifierset"><xsl:text> </xsl:text><xsl:apply-templates select="QUALIFIER"/></SPAN>
		<SPAN CLASS="mofkeyword">
		<xsl:choose>
			<xsl:when test="@REFERENCECLASS"><xsl:value-of select="@REFERENCECLASS"/> ref</xsl:when>
			<xsl:otherwise>object ref</xsl:otherwise>
		</xsl:choose>
		</SPAN>
		<SPAN CLASS="mofproperty"><xsl:value-of select="@NAME"/></SPAN>
		<xsl:apply-templates select="VALUE.REFERENCE"/>
		<SPAN CLASS="mofsymbol">;</SPAN><BR/>
		</DIV>
	</xsl:template>
	
</xsl:stylesheet>
