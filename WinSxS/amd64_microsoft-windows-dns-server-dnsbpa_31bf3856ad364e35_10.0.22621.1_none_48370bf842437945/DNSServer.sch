<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03" xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">
    <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/DNSServer/DNSServerComposite/2010/01" />
    <!-- note: declare prefix for special comparison functions -->
    <ns prefix="mssmltrans" uri="http://schemas.microsoft.com/sml/functions/transform/2007/03" />
    <pattern>
        <rule context = "tns:Evaluation/tns:BindingOrder">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "BindingOrder_helpTopic"/>
                <mssmlbpa:title mssml:locid = "BindingOrder_title"/>
                <mssmlbpa:problem mssml:locid = "BindingOrder_problem"/>
                <mssmlbpa:impact mssml:locid = "BindingOrder_impact"/>
                <mssmlbpa:resolution mssml:locid = "BindingOrder_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "BindingOrder_helpTopic"/>
                <mssmlbpa:title mssml:locid = "BindingOrder_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:DNSAutoConfig">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSAutoConfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSAutoConfig_title"/>
                <mssmlbpa:problem mssml:locid = "DNSAutoConfig_problem"/>
                <mssmlbpa:impact mssml:locid = "DNSAutoConfig_impact"/>
                <mssmlbpa:resolution mssml:locid = "DNSAutoConfig_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSAutoConfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSAutoConfig_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:DNSLoopback">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSLoopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSLoopback_title"/>
                <mssmlbpa:problem mssml:locid = "DNSLoopback_problem"/>
                <mssmlbpa:impact mssml:locid = "DNSLoopback_impact"/>
                <mssmlbpa:resolution mssml:locid = "DNSLoopback_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSLoopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSLoopback_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:DNSLoopbackFirst">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSLoopbackFirst_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSLoopbackFirst_title"/>
                <mssmlbpa:problem mssml:locid = "DNSLoopbackFirst_problem"/>
                <mssmlbpa:impact mssml:locid = "DNSLoopbackFirst_impact"/>
                <mssmlbpa:resolution mssml:locid = "DNSLoopbackFirst_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSLoopbackFirst_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSLoopbackFirst_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:DNSServerConfigured">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSServerConfigured_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSServerConfigured_title"/>
                <mssmlbpa:problem mssml:locid = "DNSServerConfigured_problem"/>
                <mssmlbpa:impact mssml:locid = "DNSServerConfigured_impact"/>
                <mssmlbpa:resolution mssml:locid = "DNSServerConfigured_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "DNSServerConfigured_helpTopic"/>
                <mssmlbpa:title mssml:locid = "DNSServerConfigured_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:IPAutoConfiguration">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "IPAutoConfiguration_helpTopic"/>
                <mssmlbpa:title mssml:locid = "IPAutoConfiguration_title"/>
                <mssmlbpa:problem mssml:locid = "IPAutoConfiguration_problem"/>
                <mssmlbpa:impact mssml:locid = "IPAutoConfiguration_impact"/>
                <mssmlbpa:resolution mssml:locid = "IPAutoConfiguration_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "IPAutoConfiguration_helpTopic"/>
                <mssmlbpa:title mssml:locid = "IPAutoConfiguration_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:IPv4DHCPConfiguration">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "IPv4DHCPConfiguration_helpTopic"/>
                <mssmlbpa:title mssml:locid = "IPv4DHCPConfiguration_title"/>
                <mssmlbpa:problem mssml:locid = "IPv4DHCPConfiguration_problem"/>
                <mssmlbpa:impact mssml:locid = "IPv4DHCPConfiguration_impact"/>
                <mssmlbpa:resolution mssml:locid = "IPv4DHCPConfiguration_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "IPv4DHCPConfiguration_helpTopic"/>
                <mssmlbpa:title mssml:locid = "IPv4DHCPConfiguration_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:NoDNSServerConfigured">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "NoDNSServerConfigured_helpTopic"/>
                <mssmlbpa:title mssml:locid = "NoDNSServerConfigured_title"/>
                <mssmlbpa:problem mssml:locid = "NoDNSServerConfigured_problem"/>
                <mssmlbpa:impact mssml:locid = "NoDNSServerConfigured_impact"/>
                <mssmlbpa:resolution mssml:locid = "NoDNSServerConfigured_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "NoDNSServerConfigured_helpTopic"/>
                <mssmlbpa:title mssml:locid = "NoDNSServerConfigured_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:NoIPAddressesExist">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "NoIPAddressesExist_helpTopic"/>
                <mssmlbpa:title mssml:locid = "NoIPAddressesExist_title"/>
                <mssmlbpa:problem mssml:locid = "NoIPAddressesExist_problem"/>
                <mssmlbpa:impact mssml:locid = "NoIPAddressesExist_impact"/>
                <mssmlbpa:resolution mssml:locid = "NoIPAddressesExist_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "NoIPAddressesExist_helpTopic"/>
                <mssmlbpa:title mssml:locid = "NoIPAddressesExist_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_Blocklist">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_Blocklist_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_Blocklist_title"/>
                <mssmlbpa:problem mssml:locid = "Param_Blocklist_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_Blocklist_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_Blocklist_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_Blocklist_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_Blocklist_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_CacheLockingOff">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_CacheLockingOff_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_CacheLockingOff_title"/>
                <mssmlbpa:problem mssml:locid = "Param_CacheLockingOff_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_CacheLockingOff_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_CacheLockingOff_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_CacheLockingOff_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_CacheLockingOff_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ForwardingTimeout">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ForwardingTimeout_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ForwardingTimeout_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ForwardingTimeout_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ForwardingTimeout_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ForwardingTimeout_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ForwardingTimeout_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ForwardingTimeout_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_Hosts">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_Hosts_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_Hosts_title"/>
                <mssmlbpa:problem mssml:locid = "Param_Hosts_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_Hosts_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_Hosts_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_Hosts_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_Hosts_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_RegistrationEnabled">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_RegistrationEnabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_RegistrationEnabled_title"/>
                <mssmlbpa:problem mssml:locid = "Param_RegistrationEnabled_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_RegistrationEnabled_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_RegistrationEnabled_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_RegistrationEnabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_RegistrationEnabled_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_RootHints">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_RootHints_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_RootHints_title"/>
                <mssmlbpa:problem mssml:locid = "Param_RootHints_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_RootHints_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_RootHints_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_RootHints_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_RootHints_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingServer">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingServer_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingServer_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingServer_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_title"/>
                <mssmlbpa:compliant mssml:locid = "Param_ScavengingServer_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingServer_AgingDisabled">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_AgingDisabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_AgingDisabled_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingServer_AgingDisabled_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingServer_AgingDisabled_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingServer_AgingDisabled_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_AgingDisabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_AgingDisabled_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingServer_IntervalRange">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_IntervalRange_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_IntervalRange_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingServer_IntervalRange_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingServer_IntervalRange_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingServer_IntervalRange_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingServer_IntervalRange_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingServer_IntervalRange_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingZone">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingZone_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingZone_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingZone_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingZone_AgingDisabled">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_AgingDisabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_AgingDisabled_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingZone_AgingDisabled_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingZone_AgingDisabled_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingZone_AgingDisabled_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_AgingDisabled_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_AgingDisabled_title"/>
                <mssmlbpa:compliant mssml:locid = "Param_ScavengingZone_AgingDisabled_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingZone_NoScavengeServers">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_NoScavengeServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_NoScavengeServers_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingZone_NoScavengeServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingZone_NoScavengeServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingZone_NoScavengeServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_NoScavengeServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_NoScavengeServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Param_ScavengingZone_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_ScavengingZone_RefreshNonDefault">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_RefreshNonDefault_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_RefreshNonDefault_title"/>
                <mssmlbpa:problem mssml:locid = "Param_ScavengingZone_RefreshNonDefault_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_ScavengingZone_RefreshNonDefault_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_ScavengingZone_RefreshNonDefault_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_ScavengingZone_RefreshNonDefault_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_ScavengingZone_RefreshNonDefault_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_SocketPoolOff">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_SocketPoolOff_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_SocketPoolOff_title"/>
                <mssmlbpa:problem mssml:locid = "Param_SocketPoolOff_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_SocketPoolOff_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_SocketPoolOff_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_SocketPoolOff_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_SocketPoolOff_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Param_TimeoutOffset">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_TimeoutOffset_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_TimeoutOffset_title"/>
                <mssmlbpa:problem mssml:locid = "Param_TimeoutOffset_problem"/>
                <mssmlbpa:impact mssml:locid = "Param_TimeoutOffset_impact"/>
                <mssmlbpa:resolution mssml:locid = "Param_TimeoutOffset_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Param_TimeoutOffset_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Param_TimeoutOffset_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Forwarders">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Forwarders_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Forwarders_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Forwarders_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Forwarders_AllFail">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_AllFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_AllFail_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Forwarders_AllFail_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Forwarders_AllFail_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Forwarders_AllFail_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_AllFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_AllFail_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Forwarders_Autoconfig">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_Autoconfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_Autoconfig_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Forwarders_Autoconfig_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Forwarders_Autoconfig_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Forwarders_Autoconfig_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_Autoconfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_Autoconfig_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Forwarders_Loopback">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_Loopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_Loopback_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Forwarders_Loopback_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Forwarders_Loopback_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Forwarders_Loopback_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_Loopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_Loopback_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Forwarders_OnlyOne">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_OnlyOne_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_OnlyOne_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Forwarders_OnlyOne_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Forwarders_OnlyOne_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Forwarders_OnlyOne_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Forwarders_OnlyOne_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Forwarders_OnlyOne_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Mismatch">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Mismatch_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Mismatch_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Mismatch_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Mismatch_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Mismatch_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Mismatch_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Mismatch_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_AllMasterServersFail">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_AllMasterServersFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_AllMasterServersFail_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_AllMasterServersFail_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_AllMasterServersFail_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_AllMasterServersFail_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_AllMasterServersFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_AllMasterServersFail_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_AllSecondaryServersFail">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_AllSecondaryServersFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_AllSecondaryServersFail_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_AllSecondaryServersFail_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_AllSecondaryServersFail_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_AllSecondaryServersFail_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_AllSecondaryServersFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_AllSecondaryServersFail_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_MasterServers">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MasterServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MasterServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_MasterServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_MasterServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_MasterServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MasterServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MasterServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_MissingMasterServers">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingMasterServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingMasterServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_MissingMasterServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_MissingMasterServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_MissingMasterServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingMasterServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingMasterServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_MissingNotifyServers">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingNotifyServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingNotifyServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_MissingNotifyServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_MissingNotifyServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_MissingNotifyServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingNotifyServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingNotifyServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_MissingSecondaryServers">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingSecondaryServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingSecondaryServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_MissingSecondaryServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_MissingSecondaryServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_MissingSecondaryServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_MissingSecondaryServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_MissingSecondaryServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_NotifyServers">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_NotifyServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_NotifyServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_NotifyServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_NotifyServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_NotifyServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_NotifyServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_NotifyServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_ScavengeServers">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_ScavengeServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_ScavengeServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_ScavengeServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_ScavengeServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_ScavengeServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_ScavengeServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_ScavengeServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Peers_SecondaryServers">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_SecondaryServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_SecondaryServers_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Peers_SecondaryServers_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Peers_SecondaryServers_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Peers_SecondaryServers_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Peers_SecondaryServers_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Peers_SecondaryServers_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_RootHints">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_RootHints_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_RootHints_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_RootHints_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_RootHints_AllFail">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_AllFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_AllFail_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_RootHints_AllFail_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_RootHints_AllFail_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_RootHints_AllFail_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_AllFail_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_AllFail_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_RootHints_Autoconfig">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_Autoconfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_Autoconfig_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_RootHints_Autoconfig_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_RootHints_Autoconfig_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_RootHints_Autoconfig_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_Autoconfig_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_Autoconfig_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_RootHints_Loopback">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_Loopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_Loopback_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_RootHints_Loopback_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_RootHints_Loopback_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_RootHints_Loopback_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_Loopback_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_Loopback_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_RootHints_OnlyOne">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_OnlyOne_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_OnlyOne_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_RootHints_OnlyOne_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_RootHints_OnlyOne_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_RootHints_OnlyOne_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_RootHints_OnlyOne_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_RootHints_OnlyOne_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_GC">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_GC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_GC_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_GC_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_GC_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_GC_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_GC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_GC_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_HOST_A">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_HOST_A_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_HOST_A_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_HOST_A_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_HOST_A_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_HOST_A_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_HOST_A_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_HOST_A_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_HOST_AAAA">
            <assert mssml:severity = "warning" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_HOST_AAAA_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_HOST_AAAA_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_HOST_AAAA_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_HOST_AAAA_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_HOST_AAAA_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_HOST_AAAA_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_HOST_AAAA_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_KDC">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_KDC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_KDC_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_KDC_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_KDC_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_KDC_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_KDC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_KDC_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_LDAP">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_LDAP_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_LDAP_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_LDAP_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_LDAP_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_LDAP_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_LDAP_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_LDAP_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNS_PDC">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_PDC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_PDC_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNS_PDC_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNS_PDC_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNS_PDC_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNS_PDC_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNS_PDC_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNSForest">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNSForest_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNSForest_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNSForest_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNSForest_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNSForest_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNSForest_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNSForest_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Resolve_Status_DNSSuffix">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNSSuffix_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNSSuffix_title"/>
                <mssmlbpa:problem mssml:locid = "Resolve_Status_DNSSuffix_problem"/>
                <mssmlbpa:impact mssml:locid = "Resolve_Status_DNSSuffix_impact"/>
                <mssmlbpa:resolution mssml:locid = "Resolve_Status_DNSSuffix_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Resolve_Status_DNSSuffix_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Resolve_Status_DNSSuffix_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Zone_Status_AD">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_title"/>
                <mssmlbpa:problem mssml:locid = "Zone_Status_AD_problem"/>
                <mssmlbpa:impact mssml:locid = "Zone_Status_AD_impact"/>
                <mssmlbpa:resolution mssml:locid = "Zone_Status_AD_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Zone_Status_AD_NotPresent">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotPresent_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotPresent_title"/>
                <mssmlbpa:problem mssml:locid = "Zone_Status_AD_NotPresent_problem"/>
                <mssmlbpa:impact mssml:locid = "Zone_Status_AD_NotPresent_impact"/>
                <mssmlbpa:resolution mssml:locid = "Zone_Status_AD_NotPresent_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotPresent_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotPresent_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Zone_Status_AD_NotPrimary">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotPrimary_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotPrimary_title"/>
                <mssmlbpa:problem mssml:locid = "Zone_Status_AD_NotPrimary_problem"/>
                <mssmlbpa:impact mssml:locid = "Zone_Status_AD_NotPrimary_impact"/>
                <mssmlbpa:resolution mssml:locid = "Zone_Status_AD_NotPrimary_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotPrimary_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotPrimary_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Zone_Status_AD_NotRunning">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotRunning_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotRunning_title"/>
                <mssmlbpa:problem mssml:locid = "Zone_Status_AD_NotRunning_problem"/>
                <mssmlbpa:impact mssml:locid = "Zone_Status_AD_NotRunning_impact"/>
                <mssmlbpa:resolution mssml:locid = "Zone_Status_AD_NotRunning_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_AD_NotRunning_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_AD_NotRunning_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context = "tns:Evaluation/tns:Zone_Status_XFR">
            <assert mssml:severity = "error" mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_XFR_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_XFR_title"/>
                <mssmlbpa:problem mssml:locid = "Zone_Status_XFR_problem"/>
                <mssmlbpa:impact mssml:locid = "Zone_Status_XFR_impact"/>
                <mssmlbpa:resolution mssml:locid = "Zone_Status_XFR_resolution"/>
            </assert>
            <report mssml:severity = "info" mssml:category ="mssmlbpa:compliant mssmlbpa:markupv2" test = "tns:Compliant = 'true'">
                <value-of select="tns:Field0"/>
                <value-of select="tns:Field1"/>
                <value-of select="tns:Field2"/>
                <mssmlbpa:helpTopic mssml:locid = "Zone_Status_XFR_helpTopic"/>
                <mssmlbpa:title mssml:locid = "Zone_Status_XFR_title"/>
                <mssmlbpa:compliant mssml:locid = "Generic_compliant"/>
            </report>
        </rule>
    </pattern>
</schema>