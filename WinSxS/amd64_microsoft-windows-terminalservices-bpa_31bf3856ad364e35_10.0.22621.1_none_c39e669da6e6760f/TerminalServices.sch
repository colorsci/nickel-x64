<!--
  Schematron Rule Document for Scenario: TerminalServices
  -->
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

    <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/TerminalServices/TerminalServicesComposite/2008/04" />

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSLicensing/tns:ActivationStatus">
            <report
                mssmlbpa:helpID="ActivationStatusCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(1)">

                <mssmlbpa:title mssml:locid="ActivationStatusCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ActivationStatusCheck_Problem_UnRegistered"/>
                <mssmlbpa:impact mssml:locid="ActivationStatusCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="ActivationStatusCheck_Resolution_UnRegistered"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=121484 </mssmlbpa:helpTopic>
            </report>

            <report
                mssmlbpa:helpID="ActivationStatusCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(2)">

                <mssmlbpa:title mssml:locid="ActivationStatusCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ActivationStatusCheck_Problem_StatusUnknown"/>
                <mssmlbpa:impact mssml:locid="ActivationStatusCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="ActivationStatusCheck_Resolution_StatusUnknown"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=121484 </mssmlbpa:helpTopic>
            </report>
           
            <report
                mssmlbpa:helpID="ActivationStatusCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(0)">
                
                <mssmlbpa:title mssml:locid="ActivationStatusCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ActivationStatusCheck_Compliant"/>
            </report>
        </rule>
    </pattern>
    
        <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSLicensing/tns:CALAvailable">
            <assert
                mssmlbpa:helpID="CALAvailableCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="CALAvailableCheck_Title"/>
                <mssmlbpa:problem mssml:locid="CALAvailableCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="CALAvailableCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="CALAvailableCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169582 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="CALAvailableCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="CALAvailableCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="CALAvailableCheck_Compliant"/>
            </report>
        </rule>
    </pattern>


    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDConnectionBroker/tns:RedirectorAltServerHaveSameIP">
            <assert
                mssmlbpa:helpID="RedirectorAltServerHaveSameIPCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RedirectorAltServerHaveSameIPCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RedirectorAltServerHaveSameIPCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RedirectorAltServerHaveSameIPCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RedirectorAltServerHaveSameIPCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169583 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="AlternateSrvSpecifiedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="RedirectorAltServerHaveSameIPCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RedirectorAltServerHaveSameIPCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDConnectionBroker/tns:AlternateSrvSpecified">
            <assert
                mssmlbpa:helpID="AlternateSrvSpecifiedCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="AlternateSrvSpecifiedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="AlternateSrvSpecifiedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="AlternateSrvSpecifiedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="AlternateSrvSpecifiedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169584 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="AlternateSrvSpecifiedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="AlternateSrvSpecifiedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="AlternateSrvSpecifiedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDMS/tns:RDSHCollection">
            <assert
                mssmlbpa:helpID="RDSHCollectionCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(tns:RDSHCollectionStatus) != number(0)">

                <value-of select="tns:RDSHCollectionReport" />
                <mssmlbpa:title mssml:locid="RDSHCollectionCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDSHCollectionCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDSHCollectionCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDSHCollectionCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=236495 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDSHCollectionCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(tns:RDSHCollectionStatus) != number(0)">
                
                <mssmlbpa:title mssml:locid="RDSHCollectionCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDSHCollectionCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSTerminalServer/tns:FireWallExceptionEnabled">
            <assert
                mssmlbpa:helpID="FireWallExceptionEnabledCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="FireWallExceptionEnabledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="FireWallExceptionEnabledCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="FireWallExceptionEnabledCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="FireWallExceptionEnabledCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169585 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="FireWallExceptionEnabledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="FireWallExceptionEnabledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="FireWallExceptionEnabledCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSTerminalServer/tns:MaxInstanceCount">
            <assert
                mssmlbpa:helpID="MaxInstanceCountCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:policy mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) >= number(5)">

                <mssmlbpa:title mssml:locid="MaxInstanceCountCheck_Title"/>
                <mssmlbpa:problem mssml:locid="MaxInstanceCountCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="MaxInstanceCountCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="MaxInstanceCountCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169586 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="MaxInstanceCountCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:policy mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) >= number(5)">
                
                <mssmlbpa:title mssml:locid="MaxInstanceCountCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="MaxInstanceCountCheck_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSTerminalServer/tns:RemoteDesktopDisabled">
            <assert
                mssmlbpa:helpID="RemoteDesktopDisabledCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(1)">

                <mssmlbpa:title mssml:locid="RemoteDesktopDisabledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RemoteDesktopDisabledCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RemoteDesktopDisabledCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RemoteDesktopDisabledCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=169587 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RemoteDesktopDisabledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(1)">
                
                <mssmlbpa:title mssml:locid="RemoteDesktopDisabledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RemoteDesktopDisabledCheck_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CAPSetup/tns:NumberCAPPoliciesActive">
            <assert
                mssmlbpa:helpID="NumberCAPPoliciesCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="NumberCAPPoliciesCheck_Title"/>
                <mssmlbpa:problem mssml:locid="NumberCAPPoliciesCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="NumberCAPPoliciesCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="NumberCAPPoliciesCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=121486 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="NumberCAPPoliciesCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="NumberCAPPoliciesCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="NumberCAPPoliciesCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:RAPSetup/tns:NumberRAPPoliciesActive">
            <assert
                mssmlbpa:helpID="NumberRAPPoliciesCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="NumberRAPPoliciesCheck_Title"/>
                <mssmlbpa:problem mssml:locid="NumberRAPPoliciesCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="NumberRAPPoliciesCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="NumberRAPPoliciesCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=121487 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="NumberRAPPoliciesCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="NumberRAPPoliciesCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="NumberRAPPoliciesCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CertConfiguration/tns:CertSettingsCompliant">
            <assert
                mssmlbpa:helpID="SSLCertConfiguredCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="SSLCertConfiguredCheck_Title"/>
                <mssmlbpa:problem mssml:locid="SSLCertConfiguredCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="SSLCertConfiguredCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="SSLCertConfiguredCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128175 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="SSLCertConfiguredCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="SSLCertConfiguredCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="SSLCertConfiguredCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CertConfiguration/tns:CertIsCACert">
            <assert
                mssmlbpa:helpID="SSLCertIsSelfSignedCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="SSLCertIsSelfSignedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="SSLCertIsSelfSignedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="SSLCertIsSelfSignedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="SSLCertIsSelfSignedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128176 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="SSLCertIsSelfSignedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="SSLCertIsSelfSignedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="SSLCertIsSelfSignedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CertConfiguration/tns:CertNameIsFQDN">
            <assert
                mssmlbpa:helpID="SSLCertNameIsFQDNCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="SSLCertNameIsFQDNCheck_Title"/>
                <mssmlbpa:problem mssml:locid="SSLCertNameIsFQDNCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="SSLCertNameIsFQDNCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="SSLCertNameIsFQDNCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128175 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="SSLCertNameIsFQDNCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="SSLCertNameIsFQDNCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="SSLCertNameIsFQDNCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CAPSetup/tns:NPSServerReachable">
            <assert
                mssmlbpa:helpID="NPSServerReachableCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="NPSServerReachableCheck_Title"/>
                <mssmlbpa:problem mssml:locid="NPSServerReachableCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="NPSServerReachableCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="NPSServerReachableCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128177 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="NPSServerReachableCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="NPSServerReachableCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="NPSServerReachableCheck_Compliant"/>
            </report>
        </rule>
    </pattern>


    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:LoadBalancedServerComposite/tns:LoadBalancedServersErrorFree">
            <assert
                mssmlbpa:helpID="LoadBalancedServerErrorneousCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="LoadBalancedServerErrorneousCheck_Title"/>
                <mssmlbpa:problem mssml:locid="LoadBalancedServerErrorneousCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="LoadBalancedServerErrorneousCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="LoadBalancedServerErrorneousCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128178 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="LoadBalancedServerErrorneousCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="LoadBalancedServerErrorneousCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="LoadBalancedServerErrorneousCheck_Compliant"/>
            </report>
        </rule>
    </pattern>


    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:ConnectionsExhausted">
            <assert
                mssmlbpa:helpID="ConnectionsExhaustedCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) = number(0)">

                <mssmlbpa:title mssml:locid="ConnectionsExhaustedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ConnectionsExhaustedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="ConnectionsExhaustedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="ConnectionsExhaustedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128179 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="ConnectionsExhaustedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(0)">

                <mssmlbpa:title mssml:locid="ConnectionsExhaustedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ConnectionsExhaustedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:ADForDomainReachable">
            <report
                mssmlbpa:helpID="ActiveDirectoryServerRechableCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) = number(0)">

                <mssmlbpa:title mssml:locid="ActiveDirectoryServerRechableCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ActiveDirectoryServerRechableCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="ActiveDirectoryServerRechableCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="ActiveDirectoryServerRechableCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128180 </mssmlbpa:helpTopic>
            </report>
            <report
                mssmlbpa:helpID="ActiveDirectoryServerRechableCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(1)">

                <mssmlbpa:title mssml:locid="ActiveDirectoryServerRechableCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ActiveDirectoryServerRechableCheck_Compliant"/>
            </report>
            <report
                mssmlbpa:helpID="ActiveDirectoryServerRechableCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) = number(2)">

                <mssmlbpa:title mssml:locid="ActiveDirectoryServerReachableCheckWarning_Title"/>
                <mssmlbpa:problem mssml:locid="ActiveDirectoryServerReachableCheckWarning_Problem"/>
                <mssmlbpa:impact mssml:locid="ActiveDirectoryServerReachableCheckWarning_Impact"/>
                <mssmlbpa:resolution mssml:locid="ActiveDirectoryServerReachableCheckWarning_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128180 </mssmlbpa:helpTopic>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:IISConfiguration/tns:WebSiteRunning">
            <assert
                mssmlbpa:helpID="WebSiteRunningCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) = number(1)">

                <mssmlbpa:title mssml:locid="WebSiteRunningCheck_Title"/>
                <mssmlbpa:problem mssml:locid="WebSiteRunningCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="WebSiteRunningCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="WebSiteRunningCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128181 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="WebSiteRunningCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="WebSiteRunningCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="WebSiteRunningCheck_Compliant"/>
            </report>
        </rule>
    </pattern>


    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:CAPSetup">
            <assert
                mssmlbpa:helpID="CAPPolicyIsNonCompliantCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(tns:SomeCAPPoliciesNonCompliant) != number(1)">
                <value-of select="tns:NamesCAPPoliciesNonCompliant"/>
                <mssmlbpa:title mssml:locid="CAPPolicyIsNonCompliantCheck_Title"/>
                <mssmlbpa:problem mssml:locid="CAPPolicyIsNonCompliantCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="CAPPolicyIsNonCompliantCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="CAPPolicyIsNonCompliantCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128182 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="CAPPolicyIsNonCompliantCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(tns:SomeCAPPoliciesNonCompliant) = number(0)">

                <mssmlbpa:title mssml:locid="CAPPolicyIsNonCompliantCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="CAPPolicyIsNonCompliantCheck_Compliant"/>
            </report>
        </rule>
    </pattern>  

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:MaxConnectionsAllowed">
            <assert
                mssmlbpa:helpID="NONewConnectinsAllowedCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="NONewConnectinsAllowedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="NONewConnectinsAllowedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="NONewConnectinsAllowedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="NONewConnectinsAllowedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128183 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="NONewConnectinsAllowedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="NONewConnectinsAllowedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="NONewConnectinsAllowedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>


    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:ConenctOnlytoWin7Client">
            <assert
                mssmlbpa:helpID="ConenctOnlytoWin7ClientCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) = number(0)">

                <mssmlbpa:title mssml:locid="ConenctOnlytoWin7ClientCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ConenctOnlytoWin7ClientCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="ConenctOnlytoWin7ClientCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="ConenctOnlytoWin7ClientCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128184 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="ConenctOnlytoWin7ClientCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) = number(0)">

                <mssmlbpa:title mssml:locid="ConenctOnlytoWin7ClientCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ConenctOnlytoWin7ClientCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSGateway/tns:RDGatewaySvcStarted">
            <assert
                mssmlbpa:helpID="RDGatewaySvcStartedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDGatewaySvcStartedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDGatewaySvcStartedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDGatewaySvcStartedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDGatewaySvcStartedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=128185 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDGatewaySvcStartedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDGatewaySvcStartedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDGatewaySvcStartedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSTerminalServer/tns:RemoteDesktopGroupMembersCount">
            <assert
                mssmlbpa:helpID="RDPGrpMemberCountCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <mssmlbpa:title mssml:locid="RDPGrpMemberCountCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDPGrpMemberCountCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDPGrpMemberCountCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDPGrpMemberCountCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/?LinkId=121485 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDPGrpMemberCountCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">
                
                <value-of select="."/>
                <mssmlbpa:title mssml:locid="RDPGrpMemberCountCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDPGrpMemberCountCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:TSTerminalServer/tns:RDSServiceRunning">
            <assert
                mssmlbpa:helpID="RDSHSvcStartedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDSHSvcStartedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDSHSvcStartedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDSHSvcStartedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDSHSvcStartedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/p/?LinkId=246306 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDSHSvcStartedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDSHSvcStartedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDSHSvcStartedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDConnectionBroker/tns:RDCBServiceRunning">
            <assert
                mssmlbpa:helpID="RDCBSvcStartedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDCBSvcStartedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDCBSvcStartedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDCBSvcStartedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDCBSvcStartedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/p/?LinkId=246309 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDCBSvcStartedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDCBSvcStartedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDCBSvcStartedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDWebAccess/tns:RDWebAccessServiceRunning">
            <assert
                mssmlbpa:helpID="RDWASvcStartedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDWASvcStartedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDWASvcStartedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDWASvcStartedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDWASvcStartedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/p/?LinkId=246310 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDWASvcStartedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDWASvcStartedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDWASvcStartedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:TerminalServicesComposite/tns:RDVH/tns:RDVHServiceRunning">
            <assert
                mssmlbpa:helpID="RDVHSvcStartedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:critical mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDVHSvcStartedCheck_Title"/>
                <mssmlbpa:problem mssml:locid="RDVHSvcStartedCheck_Problem"/>
                <mssmlbpa:impact mssml:locid="RDVHSvcStartedCheck_Impact"/>
                <mssmlbpa:resolution mssml:locid="RDVHSvcStartedCheck_Resolution"/>
                <mssmlbpa:helpTopic> http://go.microsoft.com/fwlink/p/?LinkId=246308 </mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="RDVHSvcStartedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:compliant mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="number(.) != number(0)">

                <mssmlbpa:title mssml:locid="RDVHSvcStartedCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="RDVHSvcStartedCheck_Compliant"/>
            </report>
        </rule>
    </pattern>

</schema>