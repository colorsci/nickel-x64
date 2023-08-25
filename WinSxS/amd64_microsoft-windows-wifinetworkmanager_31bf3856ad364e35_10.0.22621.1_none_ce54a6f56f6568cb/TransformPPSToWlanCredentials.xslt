<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template name="PasspointCredentials" match="/">
      <!-- EapTtls based credentials -->
      <xsl:call-template name="EapTtlsCredentials">
        <xsl:with-param name="credsNode" select="//Node[NodeName='UsernamePassword']"/>
      </xsl:call-template>
    </xsl:template>

  <xsl:template name="EapTtlsCredentials">
    <xsl:param name="credsNode"/>
    <EapHostUserCredentials xmlns="http://www.microsoft.com/provisioning/EapHostUserCredentials" xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon" xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapMethodUserCredentials">
      <xsl:if test="$credsNode//Node[NodeName='EAPType']/Value=21">
        <!-- Only Eap TTLS credentials are supported-->
        <EapMethod>
          <eapCommon:Type>21</eapCommon:Type>
          <eapCommon:AuthorId>311</eapCommon:AuthorId>
        </EapMethod>
      </xsl:if>
      <Credentials xmlns="http://www.microsoft.com/provisioning/EapHostUserCredentials">
        <EapTtls xmlns="http://www.microsoft.com/provisioning/EapTtlsUserPropertiesV1">
          <Username><xsl:value-of select="$credsNode//Node[NodeName='Username']/Value"></xsl:value-of></Username>
          <Password><xsl:value-of select="$credsNode//Node[NodeName='Password']/Value"></xsl:value-of></Password>
        </EapTtls>
      </Credentials>
    </EapHostUserCredentials>
  </xsl:template>
  
</xsl:stylesheet>
