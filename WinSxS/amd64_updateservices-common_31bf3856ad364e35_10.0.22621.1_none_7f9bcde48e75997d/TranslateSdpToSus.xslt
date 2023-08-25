<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/2001/XMLSchema"
    xmlns:sdp="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/SoftwareDistributionPackage.xsd"
    xmlns:usp="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/UpdateServicesPackage.xsd"
    xmlns:bt="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/BaseTypes.xsd"
    xmlns:lar="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/LogicalApplicabilityRules.xsd"
    xmlns:cmd="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/CommandLineInstallation.xsd"
    xmlns:bar="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/BaseApplicabilityRules.xsd"
    xmlns:msiar="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/MsiApplicabilityRules.xsd"
    xmlns:msi="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/MsiInstallation.xsd"
    xmlns:msp="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/MspInstallation.xsd"
    xmlns:uei="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/UpdateExeInstallation.xsd"
    xmlns:psf="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/WindowsPatch.xsd"
    xmlns:drv="http://schemas.microsoft.com/wsus/2005/04/CorporatePublishing/Installers/WindowsDriver.xsd"
    xmlns:mspblob="http://www.microsoft.com/msi/patch_applicability.xsd"
    xmlns:upd="http://schemas.microsoft.com/msus/2002/12/Update"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output encoding="UTF-8" method="xml" indent="yes" />

  <xsl:template match="usp:UpdateServicesPackage">
    <upd:Update>
      <upd:UpdateIdentity
          UpdateID="{usp:SoftwareDistributionPackage/sdp:Properties/@PackageID}"
          RevisionNumber="{usp:UpdateServicesProperties/@RevisionNumber}" />
      <upd:Properties
          DefaultPropertiesLanguage="{usp:SoftwareDistributionPackage/sdp:LocalizedProperties/sdp:Language}"
          CreationDate="{usp:SoftwareDistributionPackage/sdp:Properties/@CreationDate}"
          PublisherID="{usp:UpdateServicesProperties/@PublisherID}"
          IsLocallyPublished="true">

        <xsl:choose>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:Properties/@UpdateType">
            <xsl:attribute name="UpdateType">
              <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:Properties/@UpdateType" />
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="UpdateType">Software</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:Properties/@UpdateType = 'Detectoid'">
            <xsl:attribute name="ExplicitlyDeployable">false</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="ExplicitlyDeployable">true</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:Properties/@PublicationState">
            <xsl:attribute name="PublicationState">
              <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:Properties/@PublicationState" />
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="PublicationState">Published</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="usp:UpdateServicesProperties/@MinDownloadSize">
          <xsl:attribute name="MinDownloadSize">
            <xsl:value-of select="usp:UpdateServicesProperties/@MinDownloadSize" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="usp:UpdateServicesProperties/@MaxDownloadSize">
          <xsl:attribute name="MaxDownloadSize">
            <xsl:value-of select="usp:UpdateServicesProperties/@MaxDownloadSize" />
          </xsl:attribute>
        </xsl:if>
        <!-- 
                    Handler is only written out if there is a InstallableItem element containing
                      one of the known install handler elements, else the parent update has no 
                      handler which is instead specified at the bundled child level 
                -->
        <xsl:choose>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/cmd:CommandLineInstallerData">
            <xsl:attribute name="Handler">http://schemas.microsoft.com/msus/2002/12/UpdateHandlers/CommandLineInstallation</xsl:attribute>
          </xsl:when>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/msi:MsiInstallerData">
            <xsl:attribute name="Handler">http://schemas.microsoft.com/msus/2002/12/UpdateHandlers/WindowsInstaller</xsl:attribute>
          </xsl:when>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/msp:MspInstallerData">
            <xsl:attribute name="Handler">http://schemas.microsoft.com/msus/2002/12/UpdateHandlers/WindowsInstaller</xsl:attribute>
          </xsl:when>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/uei:UpdateExeInstallerData">
            <xsl:attribute name="Handler">http://schemas.microsoft.com/msus/2002/12/UpdateHandlers/WindowsPatch</xsl:attribute>
          </xsl:when>
          <xsl:when test="usp:SoftwareDistributionPackage/sdp:Properties/@UpdateType = 'Driver'">
            <xsl:attribute name="Handler">http://schemas.microsoft.com/msus/2002/12/UpdateHandlers/WindowsDriver</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@MsrcSeverity">
          <xsl:attribute name="MsrcSeverity">
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@MsrcSeverity" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:Properties/@CanSourceBeRequired">
          <xsl:attribute name="CanSourceBeRequired">
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:Properties/@CanSourceBeRequired" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="usp:UpdateServicesProperties/@CompatibleProtocolVersion">
          <xsl:attribute name="CompatibleProtocolVersion">
            <xsl:value-of select="usp:UpdateServicesProperties/@CompatibleProtocolVersion" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:InstallProperties and not(usp:UpdateServicesProperties/@MetadataOnly = 'true')">
          <upd:InstallationBehavior>
            <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:InstallProperties/@*">
              <xsl:attribute name="{name()}">
                <xsl:value-of select="." />
              </xsl:attribute>
            </xsl:for-each>
          </upd:InstallationBehavior>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:UninstallProperties">
          <upd:UninstallationBehavior>
            <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:UninstallProperties/@*">
              <xsl:attribute name="{name()}">
                <xsl:value-of select="." />
              </xsl:attribute>
            </xsl:for-each>
          </upd:UninstallationBehavior>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:Properties/sdp:MoreInfoUrl">
          <upd:MoreInfoUrl>
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:Properties/sdp:MoreInfoUrl" />
          </upd:MoreInfoUrl>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:Properties/sdp:SupportUrl">
          <upd:SupportUrl>
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:Properties/sdp:SupportUrl" />
          </upd:SupportUrl>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:SecurityBulletinID">
          <xsl:element name="upd:SecurityBulletinID">
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:SecurityBulletinID"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:CveID">
          <xsl:element name="upd:CveID">
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:CveID" />
          </xsl:element>
        </xsl:if>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:KBArticleID">
          <xsl:element name="upd:KBArticleID">
            <xsl:value-of select="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/sdp:KBArticleID" />
          </xsl:element>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="usp:UpdateServicesProperties/usp:BundleLanguage">
            <xsl:for-each select="usp:UpdateServicesProperties/usp:BundleLanguage">
              <upd:Language>
                <xsl:value-of select="." />
              </upd:Language>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:Language">
              <upd:Language>
                <xsl:value-of select="." />
              </upd:Language>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </upd:Properties>
      <upd:LocalizedPropertiesCollection>
        <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:LocalizedProperties">
          <upd:LocalizedProperties>
            <upd:Language>
              <xsl:value-of select="./sdp:Language" />
            </upd:Language>
            <upd:Title>
              <xsl:value-of select="./sdp:Title" />
            </upd:Title>
            <xsl:if test="./sdp:Description">
              <upd:Description>
                <xsl:value-of select="./sdp:Description" />
              </upd:Description>
            </xsl:if>
          </upd:LocalizedProperties>
        </xsl:for-each>
      </upd:LocalizedPropertiesCollection>
      <upd:Relationships>
        <xsl:if test="usp:SoftwareDistributionPackage/sdp:SupersededPackages/sdp:PackageID">
          <upd:SupersededUpdates>
            <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:SupersededPackages/sdp:PackageID">
              <xsl:element name="upd:UpdateIdentity">
                <xsl:attribute name="UpdateID">
                  <xsl:value-of select="." />
                </xsl:attribute>
              </xsl:element>
            </xsl:for-each>
          </upd:SupersededUpdates>
        </xsl:if>
        <upd:Prerequisites>
          <upd:AtLeastOne IsCategory="true">
            <xsl:choose>
              <xsl:when test="usp:UpdateServicesProperties/usp:ProductCategoryUpdateID">
                <xsl:for-each select="usp:UpdateServicesProperties/usp:ProductCategoryUpdateID">
                  <xsl:element name="upd:UpdateIdentity">
                    <xsl:attribute name="UpdateID">
                      <xsl:value-of select="." />
                    </xsl:attribute>
                  </xsl:element>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <!-- Locally Published Applications -->
                <upd:UpdateIdentity UpdateID="5CC25303-143F-40f3-A2FF-803A1DB69955"/>
              </xsl:otherwise>
            </xsl:choose>
          </upd:AtLeastOne>
          <upd:AtLeastOne IsCategory="true">
            <xsl:choose>
              <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData">
                <xsl:choose>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Updates'">
                    <upd:UpdateIdentity UpdateID="CD5FFD1E-E932-4E3A-BF74-18BF0B1BBD83" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Critical Updates'">
                    <upd:UpdateIdentity UpdateID="E6CF1350-C01B-414D-A61F-263D14D133B4" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Security Updates'">
                    <upd:UpdateIdentity UpdateID="0FA1201D-4330-4FA8-8AE9-B877473B6441" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Feature Packs'">
                    <upd:UpdateIdentity UpdateID="B54E7D24-7ADD-428F-8B75-90A396FA584F" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Update Rollups'">
                    <upd:UpdateIdentity UpdateID="28BC880E-0592-4CBF-8F95-C79B17911D5F" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Service Packs'">
                    <upd:UpdateIdentity UpdateID="68C5B0A3-D1A6-4553-AE49-01D3A7827828" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Tools'">
                    <upd:UpdateIdentity UpdateID="B4832BD8-E735-4761-8DAF-37F882276DAB" />
                  </xsl:when>
                  <xsl:when test="usp:SoftwareDistributionPackage/sdp:UpdateSpecificData/@UpdateClassification='Drivers'">
                    <upd:UpdateIdentity UpdateID="EBFC1FC5-71A4-4F7B-9ACA-3B9A503104A0" />
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="usp:SoftwareDistributionPackage/sdp:ApplicationSpecificData">
                <upd:UpdateIdentity UpdateID="5C9376AB-8CE6-464a-B136-22113DD69801" />
              </xsl:when>
            </xsl:choose>
          </upd:AtLeastOne>
          <xsl:if test="usp:SoftwareDistributionPackage/sdp:Properties/@RestrictToClientServicingApi = 'true'">
            <upd:AtLeastOne>
              <upd:UpdateIdentity UpdateID="B7A590E9-DB06-43f6-9B06-4AD73869CCA2" />
            </upd:AtLeastOne>
          </xsl:if>
          <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:Prerequisites/sdp:AtLeastOne">
            <upd:AtLeastOne>
              <xsl:for-each select="./sdp:PackageID">
                <upd:UpdateIdentity UpdateID="{.}" />
              </xsl:for-each>
            </upd:AtLeastOne>
          </xsl:for-each>
        </upd:Prerequisites>
        <xsl:if test="usp:UpdateServicesProperties/usp:BundledUpdates/usp:UpdateIdentity">
          <upd:BundledUpdates>
            <upd:AtLeastOne>
              <xsl:for-each select="usp:UpdateServicesProperties/usp:BundledUpdates/usp:UpdateIdentity">
                <xsl:element name="upd:UpdateIdentity">
                  <xsl:for-each select="./@*">
                    <xsl:attribute name="{name()}">
                      <xsl:value-of select="." />
                    </xsl:attribute>
                  </xsl:for-each>
                </xsl:element>
              </xsl:for-each>
            </upd:AtLeastOne>
          </upd:BundledUpdates>
        </xsl:if>
      </upd:Relationships>
      <!--
                Because the Applicability Rules are contained in two elements (usp:SoftwareDistributionPackage/sdp:ApplicabilityRules
                  and the usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules elements) and are supposed 
                  to be combined this XSLT assumes that those applicability rules have been combined into the source document 
                  usp:SoftwareDistributionPackage/sdp:ApplicabilityRules before processing. Especially since this XSLT will be
                  used to process the xml for each InstallableItem separately.
            -->
      <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules">
        <upd:ApplicabilityRules>
          <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsInstalled">
            <upd:IsInstalled>
              <xsl:copy-of select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsInstalled/*" />
            </upd:IsInstalled>
          </xsl:if>
          <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsSuperseded">
            <upd:IsSuperseded>
              <xsl:copy-of select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsSuperseded/*" />
            </upd:IsSuperseded>
          </xsl:if>
          <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsInstallable">
            <upd:IsInstallable>
              <xsl:copy-of select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:IsInstallable/*" />
            </upd:IsInstallable>
          </xsl:if>
          <xsl:if test="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:Metadata">
            <upd:Metadata>
              <xsl:copy-of select="usp:SoftwareDistributionPackage/sdp:InstallableItem/sdp:ApplicabilityRules/sdp:Metadata/*" />
            </upd:Metadata>
          </xsl:if>
        </upd:ApplicabilityRules>
      </xsl:if>

      <xsl:if test="usp:UpdateServicesProperties/usp:InstallableItemInfo">
        <upd:Files>
          <xsl:for-each select="usp:UpdateServicesProperties/usp:InstallableItemInfo/usp:File">
            <upd:File>
              <xsl:for-each select="./@*">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="." />
                </xsl:attribute>
              </xsl:for-each>
              <xsl:attribute name="DigestAlgorithm">SHA1</xsl:attribute>
              <xsl:if test="/usp:UpdateServicesPackage/usp:SoftwareDistributionPackage/sdp:InstallableItem/msp:MspInstallerData">
                <xsl:attribute name="PatchingType">SelfContained</xsl:attribute>
              </xsl:if>
              <xsl:if test="sdp:AdditionalDigest">
                <upd:AdditionalDigest>
                  <xsl:for-each select="./sdp:AdditionalDigest/@*">
                    <xsl:attribute name="{name()}">
                      <xsl:value-of select="." />
                    </xsl:attribute>
                  </xsl:for-each>
                  <xsl:value-of select="./sdp:AdditionalDigest" />
                </upd:AdditionalDigest>
              </xsl:if>
            </upd:File>
          </xsl:for-each>
        </upd:Files>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/cmd:CommandLineInstallerData">
          <upd:HandlerSpecificData xsi:type="cmd:CommandLineInstallation">
            <cmd:InstallCommand>
              <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/cmd:CommandLineInstallerData/@*">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="." />
                </xsl:attribute>
              </xsl:for-each>
              <xsl:copy-of select="usp:SoftwareDistributionPackage/sdp:InstallableItem/cmd:CommandLineInstallerData/cmd:ReturnCode" />
            </cmd:InstallCommand>
            <xsl:if test="usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory">
              <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/cmd:CommandLineInstallerData/cmd:WindowsInstallerRepairPath">
                <cmd:RepairPath>
                  <xsl:attribute name="TargetId">
                    <xsl:value-of select="./@TargetId"/>
                  </xsl:attribute>
                  <xsl:attribute name="TargetType">MsiProduct</xsl:attribute>
                  <xsl:attribute name="RelativeToServer">true</xsl:attribute>
                  <xsl:attribute name="Path">
                    <xsl:value-of select="/usp:UpdateServicesPackage/usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory" />
                  </xsl:attribute>
                </cmd:RepairPath>
              </xsl:for-each>
            </xsl:if>
          </upd:HandlerSpecificData>
        </xsl:when>
        <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/msi:MsiInstallerData">
          <upd:HandlerSpecificData xsi:type="msp:WindowsInstallerApp">
            <msp:MsiData>
              <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/msi:MsiInstallerData/@*">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="." />
                </xsl:attribute>
              </xsl:for-each>
              <xsl:if test="usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory">
                <msp:RepairPath>
                  <xsl:attribute name="RelativeToServer">true</xsl:attribute>
                  <xsl:attribute name="Path">
                    <xsl:value-of select="usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory" />
                  </xsl:attribute>
                </msp:RepairPath>
              </xsl:if>
            </msp:MsiData>
          </upd:HandlerSpecificData>
        </xsl:when>
        <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/msp:MspInstallerData">
          <upd:HandlerSpecificData xsi:type="msp:WindowsInstaller">
            <msp:MspData>
              <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/msp:MspInstallerData/@*">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="." />
                </xsl:attribute>
              </xsl:for-each>
              <xsl:if test="usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory">
                <msp:RepairPath>
                  <xsl:attribute name="RelativeToServer">true</xsl:attribute>
                  <xsl:attribute name="Path">
                    <xsl:value-of select="usp:UpdateServicesProperties/usp:InstallableItemInfo/@InstallPointDirectory" />
                  </xsl:attribute>
                </msp:RepairPath>
              </xsl:if>
            </msp:MspData>
          </upd:HandlerSpecificData>
        </xsl:when>
        <xsl:when test="usp:SoftwareDistributionPackage/sdp:InstallableItem/uei:UpdateExeInstallerData">
          <upd:HandlerSpecificData xsi:type="psf:WindowsPatch">
            <psf:WindowsPatchData>
              <xsl:for-each select="usp:SoftwareDistributionPackage/sdp:InstallableItem/uei:UpdateExeInstallerData/@*">
                <xsl:attribute name="{name()}">
                  <xsl:value-of select="."/>
                </xsl:attribute>
              </xsl:for-each>
            </psf:WindowsPatchData>
          </upd:HandlerSpecificData>
        </xsl:when>
      </xsl:choose>
    </upd:Update>
  </xsl:template>
</xsl:stylesheet>
