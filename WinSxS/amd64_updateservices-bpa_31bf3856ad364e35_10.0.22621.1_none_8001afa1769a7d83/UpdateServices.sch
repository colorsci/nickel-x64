<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

  <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/WSUS/WSUSComposite/2008/04" />

<pattern>
    <rule context="/tns:WSUSComposite/tns:WSUSInstalled">
        <report
          mssml:severity="info"
          mssmlbpa:helpID="WsusNotInstalled"
          mssml:category="mssmlbpa:prerequisite mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'True'">
            <mssmlbpa:title mssml:locid="WsusNotInstalled_Title"/>
            <mssmlbpa:compliant mssml:locid="WsusNotInstalled_Compliant"/>
        </report>

        <assert
          mssml:severity="warning"
          mssmlbpa:helpID="WsusNotInstalled"
          mssml:category="mssmlbpa:prerequisite mssmlbpa:advisory mssmlbpa:markupv2"
          test=". = 'True'">
          <value-of select="."/>  
            <mssmlbpa:title mssml:locid="WsusNotInstalled_Title"/>
            <mssmlbpa:problem mssml:locid="WsusNotInstalled_Problem"/>
            <mssmlbpa:impact mssml:locid="WsusNotInstalled_Impact"/>
            <mssmlbpa:resolution mssml:locid="WsusNotInstalled_Resolution"/>
            <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=230522</mssmlbpa:helpTopic>
        </assert>
    </rule>
</pattern>

</schema>
