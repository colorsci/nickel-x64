<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

    <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/CAU/2011/04" />


    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="ClusterNameResolvableCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsClusterNameResolvable = 'false'"
                >
                <mssmlbpa:title mssml:locid="ClusterNameResolvableCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ClusterNameResolvableCheck_Problem" />
                <mssmlbpa:impact mssml:locid="ClusterNameResolvableCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="ClusterNameResolvableCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245506</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="ClusterNameResolvableCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsClusterNameResolvable = 'true'"
                >
                <mssmlbpa:title mssml:locid="ClusterNameResolvableCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ClusterNameResolvableCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsWMIv2ConfiguredCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsWMIv2Configured = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsWMIv2ConfiguredCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsWMIv2ConfiguredCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsWMIv2ConfiguredCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsWMIv2ConfiguredCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245513</mssmlbpa:helpTopic>
            </report>
            <report
                mssmlbpa:helpID="IsWMIv2ConfiguredCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsWMIv2Configured = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsWMIv2ConfiguredCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsWMIv2ConfiguredCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsPowershellRemotingEnabledCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsPowershellRemotingEnabledCheck = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsPowershellRemotingEnabledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsPowershellRemotingEnabledCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsPowershellRemotingEnabledCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsPowershellRemotingEnabledCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245512</mssmlbpa:helpTopic>
            </report>
            <report
                mssmlbpa:helpID="IsPowershellRemotingEnabledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsPowershellRemotingEnabledCheck = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsPowershellRemotingEnabledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsPowershellRemotingEnabledCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="Windows8ClusterCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsWindows8Cluster = 'false'"
                >
                <mssmlbpa:title mssml:locid="Windows8ClusterCheck_Title"/>
                <mssmlbpa:problem mssml:locid="Windows8ClusterCheck_Problem" />
                <mssmlbpa:impact mssml:locid="Windows8ClusterCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="Windows8ClusterCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245508</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="Windows8ClusterCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsWindows8Cluster = 'true'"
                >
                <mssmlbpa:title mssml:locid="Windows8ClusterCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="Windows8ClusterCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="AllNodesHaveNetandPSInstalledCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:AllNodesHaveNetandPSInstalled = 'false'"
                >
                <mssmlbpa:title mssml:locid="AllNodesHaveNetandPSInstalledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="AllNodesHaveNetandPSInstalledCheck_Problem" />
                <mssmlbpa:impact mssml:locid="AllNodesHaveNetandPSInstalledCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="AllNodesHaveNetandPSInstalledCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245519</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="AllNodesHaveNetandPSInstalledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:AllNodesHaveNetandPSInstalled = 'true'"
                >
                <mssmlbpa:title mssml:locid="AllNodesHaveNetandPSInstalledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="AllNodesHaveNetandPSInstalledCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="ClusterupAndRunningCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsClusterupAndRunning = 'false'"
                >
                <mssmlbpa:title mssml:locid="ClusterupAndRunningCheck_Title"/>
                <mssmlbpa:problem mssml:locid="ClusterupAndRunningCheck_Problem" />
                <mssmlbpa:impact mssml:locid="ClusterupAndRunningCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="ClusterupAndRunningCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245509</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="ClusterupAndRunningCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsClusterupAndRunning = 'true'"
                >
                <mssmlbpa:title mssml:locid="ClusterupAndRunningCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="ClusterupAndRunningCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsWUAAgentConfiguredonFixedTimeCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsWUAAgentConfiguredonFixedTime = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245510</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsWUAAgentConfiguredonFixedTimeCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsWUAAgentConfiguredonFixedTime = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsWUAAgentConfiguredonFixedTimeCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsNodesconfiguredtoUseSameUpdateSourceCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsNodesconfiguredtoUseSameUpdateSource = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245511</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsNodesconfiguredtoUseSameUpdateSourceCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsNodesconfiguredtoUseSameUpdateSource = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsNodesconfiguredtoUseSameUpdateSourceCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsFirewallRuleforRemoteShutdownPresentonNodesCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsFirewallRuleforRemoteShutdownPresentonNodes = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Title"/>
                <mssmlbpa:problem mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Problem" />
                <mssmlbpa:impact mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Impact" />
                <mssmlbpa:resolution mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245525</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsFirewallRuleforRemoteShutdownPresentonNodesCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsFirewallRuleforRemoteShutdownPresentonNodes = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Title"/>
                <mssmlbpa:compliant mssml:locid="IsFirewallRuleforRemoteShutdownPresentonNodes_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsMachineProxySettoDataCenterLocalProxyCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsMachineProxy = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Title"/>
                <mssmlbpa:problem mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Problem" />
                <mssmlbpa:impact mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Impact" />
                <mssmlbpa:resolution mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245514</mssmlbpa:helpTopic>

            </report>
            <report
                mssmlbpa:helpID="IsMachineProxySettoDataCenterLocalProxyCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsMachineProxy = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Title"/>
                <mssmlbpa:compliant mssml:locid="IsMachineProxySettoDataCenterLocalProxy_Compliant" />
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="CauRoleInstalledCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsCauRoleInstalled = 'false'"
                >
                <mssmlbpa:title mssml:locid="CauRoleInstalledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="CauRoleInstalledCheck_Problem" />
                <mssmlbpa:impact mssml:locid="CauRoleInstalledCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="CauRoleInstalledCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245515</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="CauRoleInstalledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsCauRoleInstalled = 'true'"
                >
                <mssmlbpa:title mssml:locid="CauRoleInstalledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="CauRoleInstalledCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="CauRoleEnabledCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsCauRoleEnabled = 'false'"
                >
                <mssmlbpa:title mssml:locid="CauRoleEnabledCheck_Title"/>
                <mssmlbpa:problem mssml:locid="CauRoleEnabledCheck_Problem" />
                <mssmlbpa:impact mssml:locid="CauRoleEnabledCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="CauRoleEnabledCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245516</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="CauRoleEnabledCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsCauRoleEnabled = 'true'"
                >
                <mssmlbpa:title mssml:locid="CauRoleEnabledCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="CauRoleEnabledCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsCauPluginregisteredonAllNodesinSelfUpdatingMode = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsCauPluginPresentonCurrentMachineCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245517</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsCauPluginregisteredonAllNodesinSelfUpdatingMode = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsSameSetofPluginPresentonAllNodesCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsSameSetofPluginPresentonAllNodes = 'false'"
                >
                <mssmlbpa:title mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Title"/>
                <mssmlbpa:problem mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Problem" />
                <mssmlbpa:impact mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245518</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsSameSetofPluginPresentonAllNodesCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsSameSetofPluginPresentonAllNodes = 'true'"
                >
                <mssmlbpa:title mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="IsSameSetofPluginPresentonAllNodesCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="IsSelfUpdatingOptionsScheduleExpectedCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsSelfUpdatingOptionsScheduleExpected = 'false'"
                >
                <mssmlbpa:title mssml:locid="SelfUpdatingOptionsScheduleExpected_Title"/>
                <mssmlbpa:problem mssml:locid="SelfUpdatingOptionsScheduleExpected_Problem" />
                <mssmlbpa:impact mssml:locid="SelfUpdatingOptionsScheduleExpected_Impact" />
                <mssmlbpa:resolution mssml:locid="SelfUpdatingOptionsScheduleExpected_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245520</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="IsSelfUpdatingOptionsScheduleExpectedCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsSelfUpdatingOptionsScheduleExpected = 'true'"
                >
                <mssmlbpa:title mssml:locid="SelfUpdatingOptionsScheduleExpected_Title"/>
                <mssmlbpa:compliant mssml:locid="SelfUpdatingOptionsScheduleExpected_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="OwnersPresentForCAURoleCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsOwnersPresentForCAURole = 'false'"
                >
                <mssmlbpa:title mssml:locid="OwnersPresentForCAURoleCheck_Title"/>
                <mssmlbpa:problem mssml:locid="OwnersPresentForCAURoleCheck_Problem" />
                <mssmlbpa:impact mssml:locid="OwnersPresentForCAURoleCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="OwnersPresentForCAURoleCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245521</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="OwnersPresentForCAURoleCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsOwnersPresentForCAURole = 'true'"
                >
                <mssmlbpa:title mssml:locid="OwnersPresentForCAURoleCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="OwnersPresentForCAURoleCheck_Compliant" />
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="PreandPostUpdateScriptsAccessibleFromOwnersCheck"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsPreandPostUpdateScriptsAccessibleFromOwners = 'false'"
                >
                <mssmlbpa:title mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Title"/>
                <mssmlbpa:problem mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Problem" />
                <mssmlbpa:impact mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245522</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="PreandPostUpdateScriptsAccessibleFromOwnersCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsPreandPostUpdateScriptsAccessibleFromOwners = 'true'"
                >
                <mssmlbpa:title mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="PreandPostUpdateScriptsAccessibleFromOwnersCheck_Compliant" />
            </report>
        </rule>
    </pattern>
    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="PreandPostUpdateScriptsSameonNodes"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsPreandPostUpdateScriptsSameonNodes = 'false'"
                >
                <mssmlbpa:title mssml:locid="PreandPostUpdateScriptsSameonNodes_Title"/>
                <mssmlbpa:problem mssml:locid="PreandPostUpdateScriptsSameonNodes_Problem" />
                <mssmlbpa:impact mssml:locid="PreandPostUpdateScriptsSameonNodes_Impact" />
                <mssmlbpa:resolution mssml:locid="PreandPostUpdateScriptsSameonNodes_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245523</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="PreandPostUpdateScriptsSameonNodes"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsPreandPostUpdateScriptsSameonNodes = 'true'"
                >
                <mssmlbpa:title mssml:locid="PreandPostUpdateScriptsSameonNodes_Title"/>
                <mssmlbpa:compliant mssml:locid="PreandPostUpdateScriptsSameonNodes_Compliant" />
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:CAUComposite/tns:CAU">
            <report
                mssmlbpa:helpID="WarnAfterLessThanStopAfterCheck"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:critical mssmlbpa:markupv2"
                test="tns:IsWarnAfterLessThanStopAfter = 'false'"
                >
                <mssmlbpa:title mssml:locid="WarnAfterLessThanStopAfterCheck_Title"/>
                <mssmlbpa:problem mssml:locid="WarnAfterLessThanStopAfterCheck_Problem" />
                <mssmlbpa:impact mssml:locid="WarnAfterLessThanStopAfterCheck_Impact" />
                <mssmlbpa:resolution mssml:locid="WarnAfterLessThanStopAfterCheck_Resolution" />
                <mssmlbpa:helpTopic>https://go.microsoft.com/fwlink/p/?LinkId=245524</mssmlbpa:helpTopic>                
            </report>
            <report
                mssmlbpa:helpID="WarnAfterLessThanStopAfterCheck"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="tns:IsWarnAfterLessThanStopAfter = 'true'"
                >
                <mssmlbpa:title mssml:locid="WarnAfterLessThanStopAfterCheck_Title"/>
                <mssmlbpa:compliant mssml:locid="WarnAfterLessThanStopAfterCheck_Compliant" />
            </report>
        </rule>
    </pattern>

</schema>