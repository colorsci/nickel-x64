<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

  <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/WSUS/WSUSComposite/2008/04" />


 
  <pattern>
    <rule context="/tns:WSUSComposite">
      <assert
        mssmlbpa:helpID="SelfUpdateTreeCheck"
        mssml:severity="error"
        mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
        test="tns:SelfUpdateTree/tns:SelfUpdateNode/tns:CabFileExists = 'True'">

        <mssmlbpa:title mssml:locid="SelfUpdateTreeCheck_Title"/>
        <mssmlbpa:problem mssml:locid="SelfUpdateTreeCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="SelfUpdateTreeCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="SelfUpdateTreeCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230525</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="SelfUpdateTreeCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:SelfUpdateTree/tns:SelfUpdateNode/tns:CabFileExists = 'True'">

        <mssmlbpa:title mssml:locid="SelfUpdateTreeCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="SelfUpdateTreeCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

  <pattern>
    <rule context="/tns:WSUSComposite">
      <assert
          mssmlbpa:helpID="ProductLanguageCheck"
          mssml:severity="warning"
          mssml:category="mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ProductLanguage/tns:AllUpdateLanguagesEnabled = 'False'">

        <mssmlbpa:title mssml:locid="ProductLanguageCheck_Title"/>
        <mssmlbpa:problem mssml:locid="ProductLanguageCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="ProductLanguageCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="ProductLanguageCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230526</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="ProductLanguageCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ProductLanguage/tns:AllUpdateLanguagesEnabled = 'False'">

        <mssmlbpa:title mssml:locid="ProductLanguageCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="ProductLanguageCheck_Compliant"/>
      </report>
    </rule>
  </pattern>


  <pattern>
    <rule context="/tns:WSUSComposite">
      <assert
          mssmlbpa:helpID="ContentSystemDriveCheck"
          mssml:severity="warning"
          mssml:category="mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ContentDatabase/tns:LocalContentCacheOnSystemDrive = 'False'">

        <mssmlbpa:title mssml:locid="ContentSystemDriveCheck_Title"/>
        <mssmlbpa:problem mssml:locid="ContentSystemDriveCheck_Problem"/>
        <mssmlbpa:impact mssml:locid="ContentSystemDriveCheck_Impact"/>
        <mssmlbpa:resolution mssml:locid="ContentSystemDriveCheck_Resolution"/>
        <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230527</mssmlbpa:helpTopic>
      </assert>
      <report
          mssmlbpa:helpID="ContentSystemDriveCheck"
          mssml:severity="info"
          mssml:category="mssmlbpa:compliant mssmlbpa:performance mssmlbpa:advisory mssmlbpa:markupv2"
          test="tns:ContentDatabase/tns:LocalContentCacheOnSystemDrive = 'False'">

        <mssmlbpa:title mssml:locid="ContentSystemDriveCheck_Title"/>
        <mssmlbpa:compliant mssml:locid="ContentSystemDriveCheck_Compliant"/>
      </report>
    </rule>
  </pattern>

</schema>
