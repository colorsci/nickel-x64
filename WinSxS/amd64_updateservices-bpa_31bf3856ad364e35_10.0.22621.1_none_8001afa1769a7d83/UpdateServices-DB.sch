<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

  <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/WSUS/WSUSComposite/2008/04" />


  <pattern>
    <rule context="/tns:WSUSComposite">
      <assert
          mssmlbpa:helpID="DomainControllerCheck"
          mssml:severity="warning"
          mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:DomainController/tns:RunningOnDomainController = 'False'">

        <mssmlbpa:title mssml:locid="DomainControllerCheck_Title"/>
        <mssmlbpa:problem mssml:locid="DomainControllerCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="DomainControllerCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="DomainControllerCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230523</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="DomainControllerCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:DomainController/tns:RunningOnDomainController = 'False'">

        <mssmlbpa:title mssml:locid="DomainControllerCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="DomainControllerCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

<pattern>
    <rule context="/tns:WSUSComposite">
      <assert
          mssmlbpa:helpID="DatabaseSystemDriveCheck"
          mssml:severity="warning"
          mssml:category="mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ContentDatabase/tns:DatabaseError = 'False' and tns:ContentDatabase/tns:AnyDatabaseFileOnSystemDrive = 'False'">

        <mssmlbpa:title mssml:locid="DatabaseSystemDriveCheck_Title"/>
        <mssmlbpa:problem mssml:locid="DatabaseSystemDriveCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="DatabaseSystemDriveCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="DatabaseSystemDriveCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230524</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="DatabaseSystemDriveCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ContentDatabase/tns:DatabaseError = 'False' and tns:ContentDatabase/tns:AnyDatabaseFileOnSystemDrive = 'False'">

        <mssmlbpa:title mssml:locid="DatabaseSystemDriveCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="DatabaseSystemDriveCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

</schema>
