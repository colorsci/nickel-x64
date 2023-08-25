<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
  <!--Current transformation is used to transform PerProviderSubscription Mobile Operator(PPS MO)
      object defined in WFA Passpoint2 release specification to windows Wi-Fi profile xml.
      The credentials are not saved as a part of the profile. For this purpose another transformation will 
      get PPS MO credentials and they will be saved separatly in crypted form as profile metadata.
      Currently transformation supports following authentication outer and inner methods
      1) EapTTLS with PAP
      2) EapTTLS with MSCHAPv2 (default if nothing specified)
      -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:template name="WlanProfile" match="/">
      <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <!-- Connection Name-->
        <name>
          <xsl:value-of select="//Node[NodeName='FriendlyName']/Value"/>
        </name>
        <!--SSID config-->
        <SSIDConfig>
          <SSID>
            <name>
              <xsl:if test="//Node[NodeName='FriendlyName']">
                <xsl:value-of select="//Node[NodeName='FriendlyName']/Value"/>
              </xsl:if>
              <!-- Default "hotspot2" SSID-->
              <!-- Due to the legacy purpose any profile should have the SSID-->
              <xsl:if test="not(//Node[NodeName='FriendlyName'])">hotspot2</xsl:if>
            </name>
          </SSID>
        </SSIDConfig>
        <!-- Hotspot2 connection parameters-->
        <xsl:if test="//Node[NodeName='FQDN']">
          <Hotspot2>
            <DomainName>
              <xsl:value-of select="//Node[NodeName='FQDN']/Value"/>
            </DomainName>
            <xsl:call-template name="NAIRealm">
                <xsl:with-param name="partnersNode" select="//Node[NodeName='OtherHomePartners']"/>
                <xsl:with-param name="realm" select="//Node[NodeName='Credential']/Node[NodeName='Realm']"/>
            </xsl:call-template>
            <xsl:call-template name="Network3GPP">
              <xsl:with-param name="homeOIListNode" select="//Node[NodeName='HomeOIList']"/>
            </xsl:call-template>
            <xsl:call-template name="RoamingConsortium">
              <xsl:with-param name="roamingOINode" select="//Node[NodeName='RoamingConsortiumOI']"/>
            </xsl:call-template>
          </Hotspot2>
        </xsl:if>
        <!-- Connection type and connection mode-->
        <connectionType>ESS</connectionType>
        <connectionMode>auto</connectionMode>
        <!-- Eap UserName password Credentials -->
        <xsl:call-template name="EapAuthenticationMethod">
          <xsl:with-param name="node" select="//Node[NodeName='Credential']"/>
        </xsl:call-template>
      </WLANProfile>
    </xsl:template>

  <xsl:template name="Network3GPP" xml:space="default">
    <xsl:param name="homeOIListNode"></xsl:param>
    <xsl:if test="$homeOIListNode">
      <Network3GPP xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <xsl:for-each select="$homeOIListNode//Node[NodeName='HomeOI']">
          <PLMNID>
            <xsl:value-of select="Value"/>
          </PLMNID>
        </xsl:for-each>
      </Network3GPP>
    </xsl:if>
  </xsl:template>

  <xsl:template name="NAIRealm" xml:space="default">
    <xsl:param name="partnersNode"></xsl:param>
    <xsl:param name="realm"></xsl:param>
    <xsl:if test="$partnersNode or $realm">
      <NAIRealm xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <xsl:for-each select="$partnersNode//Node[NodeName='FQDN']">
          <name><xsl:value-of select="Value"/></name>
        </xsl:for-each>
        <xsl:if test="$realm">
            <name><xsl:value-of select="$realm/Value"/></name>
        </xsl:if>
      </NAIRealm>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="RoamingConsortium" xml:space="default">
    <xsl:param name="roamingOINode"></xsl:param>
    <xsl:if test="$roamingOINode">
      <RoamingConsortium xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <xsl:for-each select="$roamingOINode//Node[NodeName='RoamingConsortiumOI']">
          <OUI>
            <xsl:value-of select="Value"/>
          </OUI>
        </xsl:for-each>
      </RoamingConsortium>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="EapTTLS">
    <xsl:param name="node"></xsl:param>
    <xsl:param name="certList"></xsl:param>
    <xsl:param name="realm"></xsl:param>
    <MSM xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <security>
            <authEncryption>
                <authentication>WPA2</authentication>
                <encryption>AES</encryption>
                <useOneX>true</useOneX>
            </authEncryption>
            <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">
                <cacheUserData>true</cacheUserData>
                <authMode>user</authMode>
                <EAPConfig>
                    <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
                        <EapMethod>
                            <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">21</Type>
                            <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>
                            <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>
                            <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">311</AuthorId>
                        </EapMethod>
                        <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
                            <EapTtls xmlns="http://www.microsoft.com/provisioning/EapTtlsConnectionPropertiesV1">
                                <ServerValidation>
                                    <ServerNames/>
                                    <xsl:if test="$certList">
                                        <xsl:for-each select="$certList//Node[NodeName='CertSHA256Fingerprint']" >
                                            <TrustedRootCAHash>
                                                <xsl:call-template name="FormatHash">
                                                    <xsl:with-param name="length" select="2"/>
                                                    <xsl:with-param name="text" select="./Value"/>
                                                    <xsl:with-param name="delimiter" select="' '"/>
                                                </xsl:call-template>
                                            </TrustedRootCAHash>
                                        </xsl:for-each>
                                    </xsl:if>
                                    <DisablePrompt>false</DisablePrompt>
                                </ServerValidation>
                                <xsl:if test="$node//Node[NodeName='InnerMethod']='PAP'">
                                    <!-- PAP is inner method-->
                                    <Phase2Authentication>
                                        <PAPAuthentication/>
                                    </Phase2Authentication>
                                </xsl:if>
                                <xsl:if test="not($node//Node[NodeName='InnerMethod']='PAP')">
                                    <!-- MSCHAPv2 is inner method-->
                                    <!-- If the inner protocol is not PAP that it it MSCHAPv2 by default-->
                                    <Phase2Authentication>
                                        <MSCHAPv2Authentication>
                                            <UseWinlogonCredentials>false</UseWinlogonCredentials>
                                        </MSCHAPv2Authentication>
                                    </Phase2Authentication>
                                </xsl:if>
                                <Phase1Identity>
                                    <IdentityPrivacy>true</IdentityPrivacy>
                                    <xsl:if test="$realm">
                                        <AnonymousIdentity>anonymous@<xsl:value-of select="$realm/Value"></xsl:value-of></AnonymousIdentity>
                                    </xsl:if>
                                    <xsl:if test="not($realm)">
                                        <AnonymousIdentity>anonymous</AnonymousIdentity>
                                    </xsl:if>
                                </Phase1Identity>
                            </EapTtls>
                        </Config>
                    </EapHostConfig>
                </EAPConfig>
            </OneX>
        </security>
    </MSM>
  </xsl:template>

  <xsl:template name="EapAuthenticationMethod">
    <xsl:param name="node"></xsl:param>
    <xsl:choose>
      <xsl:when test="$node//Node[NodeName='EAPType']/Value=21" >
        <!-- Currently only Eap TTLS is supported-->
        <xsl:call-template name="EapTTLS">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="certList" select="//Node[NodeName='AAAServerTrustRoot']"/>
            <xsl:with-param name="realm" select="$node//Node[NodeName='Realm']"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

 <xsl:template name="FormatHash">
        <xsl:param name="text"/>
        <xsl:param name="length"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="string-length($text) > $length">
                <xsl:value-of select="substring($text, 1, $length)"/>
                <xsl:copy-of select="$delimiter"/>
                <xsl:call-template name="FormatHash">
                    <xsl:with-param name="text" select="substring($text, $length + 1)"/>
                    <xsl:with-param name="delimiter">
                        <xsl:copy-of select="$delimiter"/>
                    </xsl:with-param>
                    <xsl:with-param name="length" select="$length"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
