<!--
  Schematron Rule Document for Scenario: WebServer
  -->
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

  <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/WebServer/WebServerComposite/2008/04" />

<pattern>
    <rule context="/tns:WebServerComposite/tns:ExecuteWritePermissions/tns:Section">
      <assert
        mssmlbpa:helpID="ExecuteWritePermissionsCheck"
        mssml:severity="error"
        mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
        test="tns:AreWriteAndExecuteGranted = 'false'">

        <value-of select="tns:Location" />
        <mssmlbpa:title mssml:locid="ExecuteWritePermissionsCheck_Title"/>
        <mssmlbpa:problem mssml:locid="ExecuteWritePermissionsCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="ExecuteWritePermissionsCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="ExecuteWritePermissionsCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130708</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="ExecuteWritePermissionsCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:AreWriteAndExecuteGranted = 'false'">

        <mssmlbpa:title mssml:locid="ExecuteWritePermissionsCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="ExecuteWritePermissionsCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:NotListedCgisAllowed">
      <assert
          mssmlbpa:helpID="NotListedCGIsAllowedCheck"
          mssml:severity="error"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'false'">

        <mssmlbpa:title mssml:locid="NotListedCGIsAllowedCheck_Title"/>
        <mssmlbpa:problem mssml:locid="NotListedCGIsAllowedCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="NotListedCGIsAllowedCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="NotListedCGIsAllowedCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130712</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="NotListedCGIsAllowedCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'false'">

        <mssmlbpa:title mssml:locid="NotListedCGIsAllowedCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="NotListedCGIsAllowedCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:NotListedIsapisAllowed">
      <assert
          mssmlbpa:helpID="NotListedISAPIsAllowedCheck"
          mssml:severity="error"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'false'">

        <mssmlbpa:title mssml:locid="NotListedISAPIsAllowedCheck_Title"/>
        <mssmlbpa:problem mssml:locid="NotListedISAPIsAllowedCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="NotListedISAPIsAllowedCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="NotListedISAPIsAllowedCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130711</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="NotListedISAPIsAllowedCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'false'">

        <mssmlbpa:title mssml:locid="NotListedISAPIsAllowedCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="NotListedISAPIsAllowedCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:AppPoolPrivilegedIdentity/tns:ApplicationPool">
      <assert
          mssmlbpa:helpID="AppPoolIdentityCheck"
          mssml:severity="error"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:IsIdentityPrivileged = 'false'">

        <value-of select="tns:Name" />
        <mssmlbpa:title mssml:locid="AppPoolIdentityCheck_Title"/>
        <mssmlbpa:problem mssml:locid="AppPoolIdentityCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="AppPoolIdentityCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="AppPoolIdentityCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130713</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="AppPoolIdentityCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:IsIdentityPrivileged = 'false'">

        <mssmlbpa:title mssml:locid="AppPoolIdentityCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="AppPoolIdentityCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:CustomErrors/tns:Section">
      <assert
          mssmlbpa:helpID="CustomErrorsCheck"
          mssml:severity="error"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ErrorModeCompliant = 'true'">

        <value-of select="tns:Path" />
        <value-of select="tns:Location" />
        <mssmlbpa:title mssml:locid="CustomErrorsCheck_Title"/>
        <mssmlbpa:problem mssml:locid="CustomErrorsCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="CustomErrorsCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="CustomErrorsCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130716</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="CustomErrorsCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ErrorModeCompliant = 'true'">

        <mssmlbpa:title mssml:locid="CustomErrorsCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="CustomErrorsCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:ExpiredCertificates/tns:Binding">
      <assert
          mssmlbpa:helpID="ExpiredCertificatesCheck"
          mssml:severity="warning"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:Expired = 'false'">

        <value-of select="tns:IPAddress" />
        <value-of select="tns:Port"/>
        <value-of select="tns:Hash"/>
        <value-of select="tns:Store"/>
        <mssmlbpa:title mssml:locid="ExpiredCertificatesCheck_Title"/>
        <mssmlbpa:problem mssml:locid="ExpiredCertificatesCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="ExpiredCertificatesCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="ExpiredCertificatesCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130709</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="ExpiredCertificatesCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:Expired = 'false'">

        <mssmlbpa:title mssml:locid="ExpiredCertificatesCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="ExpiredCertificatesCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WebServerComposite/tns:BasicAuthSSL/tns:Section">
      <assert
          mssmlbpa:helpID="BasicAuthSSLCheck"
          mssml:severity="error"
          mssml:category="mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:IsBasicAuthEnabledWithoutSSL = 'false'">

        <value-of select="tns:Location" />
        <mssmlbpa:title mssml:locid="BasicAuthSSLCheck_Title"/>
        <mssmlbpa:problem mssml:locid="BasicAuthSSLCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="BasicAuthSSLCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="BasicAuthSSLCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=130717</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="BasicAuthSSLCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:security mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:IsBasicAuthEnabledWithoutSSL = 'false'">

        <mssmlbpa:title mssml:locid="BasicAuthSSLCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="BasicAuthSSLCheck_Compliant"/>
      </report>
    </rule>
  </pattern>
</schema>