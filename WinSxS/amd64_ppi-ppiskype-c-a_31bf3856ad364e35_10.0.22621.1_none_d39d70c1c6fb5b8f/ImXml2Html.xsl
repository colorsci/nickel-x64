<?xml version="1.0"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:history="http://schemas.microsoft.com/2008/10/sip/convItems"
    xmlns:rtc="urn:microsoft-rtc-xslt-functions"
    >
  <!--
      This transform transforms the aggregated convlog imReceived items in Xml into 
      conversation env last message body in plain text format

      Author: xinkwang (simplified based on ConversationHistory.xsl)
        Date: 07/28/09
    -->
  <xsl:output method="html" encoding="utf-8" indent="yes"/>
  <xsl:template match="history:imReceived">
    <xsl:element name="html">
      <xsl:if test="string(history:messageInfo)"> 
        <xsl:value-of select="." disable-output-escaping="yes"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
