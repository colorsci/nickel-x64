# Localized	05/07/2022 03:29 AM (GMT)	303:7.0.30723 	ClusterAwareUpdating.psd1
#---------------------------------------#
# ClusterAwareUpdating.psd1             #
# Resource file for CAU BPA             #
# Copyright (c) Microsoft Corporation.  #
#---------------------------------------#

ConvertFrom-StringData @'

###PSLOC start localizing


    # check ClusterNameResolvableCheck
ClusterNameResolvableCheck_Title=The failover cluster must be available
ClusterNameResolvableCheck_Problem=Cannot resolve the failover cluster name, or the cluster nodes cannot be accessed from this computer
ClusterNameResolvableCheck_Impact=This Best Practices Analyzer cannot validate the environment for this failover cluster.
ClusterNameResolvableCheck_Resolution=Ensure that you have correctly spelled the name of the failover cluster. Ensure that all nodes in the cluster are up and running, and cluster validation can be successfully run on this cluster from Failover Cluster Manager.
ClusterNameResolvableCheck_Compliant=Passed

    # check AdminCredentialsKnown
AdminCredentialsKnown_Title=Your account should have administrative privileges on the failover cluster
AdminCredentialsKnown_Problem=Your account does not have administrative privileges on this failover cluster to update the cluster.
AdminCredentialsKnown_Impact=Cluster-Aware Updating may not be able to update this failover cluster.
AdminCredentialsKnown_Resolution=Ensure that you have administrative privileges on the failover cluster. To avoid this Warning in the future, run this Best Practices Analyzer using an account with cluster administrative privileges.
AdminCredentialsKnown_Compliant=Passed

    # check Windows8ClusterCheck
Windows8ClusterCheck_Title=The failover cluster must be running Windows Server 2012 or a higher version of Windows Server
Windows8ClusterCheck_Problem=The failover cluster computers run a version of Windows Server that does not support Cluster-Aware Updating. The failover cluster computers must be running Windows Server 2012 or a higher version of Windows Server.
Windows8ClusterCheck_Impact=Cluster-Aware Updating will not be able to update this failover cluster.
Windows8ClusterCheck_Resolution=Ensure that you have upgraded the failover cluster to Windows Server 2012 or higher, or run the Best Practice Analyzer on a different failover cluster that is running Windows Server 2012 or a higher version of Windows Server.
Windows8ClusterCheck_Compliant=Passed

    # check ClusterupAndRunningCheck
ClusterupAndRunningCheck_Title=The Cluster service should be running on all cluster nodes
ClusterupAndRunningCheck_Problem=The Cluster service is not running on one or more nodes. These nodes cannot participate in the cluster to host roles.
ClusterupAndRunningCheck_Impact=Cluster-Aware Updating cannot update this failover cluster if the Cluster service is not running on all nodes in the cluster.
ClusterupAndRunningCheck_Resolution=Ensure that the Cluster service (clussvc) is running on all nodes in the cluster, and cluster validation can be successfully run on this cluster from Failover Cluster Manager.
ClusterupAndRunningCheck_Compliant=Passed

    # check IsWUAAgentConfiguredonFixedTimeCheck
IsWUAAgentConfiguredonFixedTimeCheck_Title=Automatic Updates must not be configured to automatically install updates on any failover cluster node
IsWUAAgentConfiguredonFixedTimeCheck_Problem=Automatic Updates on at least one failover cluster node is configured to automatically install updates on that node.
IsWUAAgentConfiguredonFixedTimeCheck_Impact=Using Cluster-Aware Updating to update this failover cluster could cause downtime, because Automatic Updates may be concurrently updating a different cluster node at the same time.
IsWUAAgentConfiguredonFixedTimeCheck_Resolution=If Automatic Updates is enabled on any node in the cluster, ensure that it is not configured to automatically install updates.
IsWUAAgentConfiguredonFixedTimeCheck_Compliant=Passed

    # check IsNodesconfiguredtoUseSameUpdateSourceCheck
IsNodesconfiguredtoUseSameUpdateSourceCheck_Title=The failover cluster nodes should use the same update source
IsNodesconfiguredtoUseSameUpdateSourceCheck_Problem=One or more failover cluster nodes are configured to use a different update source from the rest of the nodes.
IsNodesconfiguredtoUseSameUpdateSourceCheck_Impact=Cluster-Aware Updating cannot ensure that the same set of applicable updates is applied to all the cluster nodes.
IsNodesconfiguredtoUseSameUpdateSourceCheck_Resolution=Ensure that every cluster node is configured to use the same update source, for example, a Windows Server Updates Services server, or Windows Update/Microsoft Update.
IsNodesconfiguredtoUseSameUpdateSourceCheck_Compliant=Passed

    # check IsPowershellRemotingEnabledCheck
IsPowershellRemotingEnabledCheck_Title=Windows PowerShell remoting should be enabled on each failover cluster node
IsPowershellRemotingEnabledCheck_Problem=Windows PowerShell is not installed or is not enabled for remoting on one or more failover cluster nodes.
IsPowershellRemotingEnabledCheck_Impact=Cluster-Aware Updating cannot perform one or more of the following actions on this failover cluster: 1)Use pre-update or post-update Windows PowerShell scripts in Updating Runs. 2) Use Save-CauDebugTrace on the cluster to collect the debug logs. (However, manual collection is still possible.)
IsPowershellRemotingEnabledCheck_Resolution=Ensure that Windows PowerShell is installed and is enabled for remoting on every cluster node. To enable Windows PowerShell remoting, use the Enable-PSRemoting cmdlet.
IsPowershellRemotingEnabledCheck_Compliant=Passed


    # check IsWMIv2ConfiguredCheck
IsWMIv2ConfiguredCheck_Title=The failover cluster nodes must be enabled for remote management via WMIv2
IsWMIv2ConfiguredCheck_Problem=One or more of the failover cluster nodes are not enabled for remote management via Windows Management Instrumentation (WMIv2).
IsWMIv2ConfiguredCheck_Impact=Cluster-Aware Updating cannot update this failover cluster.
IsWMIv2ConfiguredCheck_Resolution=Ensure that every cluster node is enabled for remote management via WMIv2, using the "WINRM QUICKCONFIG –q" command.
IsWMIv2ConfiguredCheck_Compliant=Passed

    # check IsMachineProxySettoDataCenterLocalProxy
IsMachineProxySettoDataCenterLocalProxy_Title=The machine proxy on each failover cluster node should be set to a local proxy server
IsMachineProxySettoDataCenterLocalProxy_Problem=One or more failover cluster nodes have an incorrect machine proxy server configuration.
IsMachineProxySettoDataCenterLocalProxy_Impact=Cluster-Aware Updating cannot update this failover cluster in a deployment scenario where the failover cluster must directly access Windows Update/Microsoft Update or the local Windows Server Update Services server for downloading updates.
IsMachineProxySettoDataCenterLocalProxy_Resolution=Ensure that the machine proxy on each cluster node is appropriately set to a local proxy server.
IsMachineProxySettoDataCenterLocalProxy_Compliant=Passed


    # check CauRoleInstalledCheck
CauRoleInstalledCheck_Title=The CAU clustered role should be installed on the failover cluster to enable self-updating mode
CauRoleInstalledCheck_Problem=The CAU clustered role is not installed on this failover cluster. This role is required for cluster self-updating.
CauRoleInstalledCheck_Impact=This failover cluster cannot self-update using Cluster-Aware Updating. However, you can use the remote-updating mode of Cluster-Aware Updating.
CauRoleInstalledCheck_Resolution=If you want this failover cluster to be self-updating, add the CAU clustered role on this failover cluster in one of two ways: run the Add-CauClusterRole Windows PowerShell cmdlet, or select the "Configure cluster self-updating options" action on the main console in the Cluster-Aware Updating tool.
CauRoleInstalledCheck_Compliant=Passed

    # check CauRoleEnabledCheck
CauRoleEnabledCheck_Title=The CAU clustered role should be enabled on the failover cluster
CauRoleEnabledCheck_Problem=The CAU clustered role on this failover cluster is disabled.
CauRoleEnabledCheck_Impact=This failover cluster cannot self-update using Cluster-Aware Updating.
CauRoleEnabledCheck_Resolution=Enable the CAU clustered role on this failover cluster in one of two ways: run the Enable-CauClusterRole Windows PowerShell cmdlet, or select the "Configure cluster self-updating options" action on the main console in the Cluster-Aware Updating tool.
CauRoleEnabledCheck_Compliant=Passed

    # check IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck
IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Title=The configured CAU plug-in must be registered on all failover cluster nodes
IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Problem=The CAU clustered role on this failover cluster cannot access the CAU plug-in module configured in the self-updating mode options.
IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating will fail if the CAU clustered role runs on a node that does not have the configured CAU plug-in installed.
IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Resolution=Ensure that the configured CAU plug-in is installed on all cluster nodes by following the installation procedure for the product that supplies the CAU plug-in, or by running the Register-CauPlugin Windows PowerShell cmdlet on the required cluster nodes.
IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Compliant=Passed

    # check IsSameSetofPluginPresentonAllNodesCheck
IsSameSetofPluginPresentonAllNodesCheck_Title=All failover cluster nodes should have the same set of registered CAU plug-ins
IsSameSetofPluginPresentonAllNodesCheck_Problem=The CAU clustered role on this failover cluster cannot access the same set of Cluster-Aware Updating plug-in modules on all cluster nodes.
IsSameSetofPluginPresentonAllNodesCheck_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating may fail if the plug-in configured to be used in an Updating Run is changed to one that that is not available on all cluster nodes.
IsSameSetofPluginPresentonAllNodesCheck_Resolution=Ensure that the same set of CAU plug-ins is installed on all cluster nodes by following the installation procedure for the product that supplies the CAU plug-in, or by running the Register-CauPlugin Windows PowerShell cmdlet on the required cluster nodes. Alternatively, uninstall CAU plug-ins from the nodes that are no longer required for updating.
IsSameSetofPluginPresentonAllNodesCheck_Compliant=Passed

    # check AllNodesHaveNetandPSInstalledCheck
AllNodesHaveNetandPSInstalledCheck_Title=The required versions of .NET Framework and Windows PowerShell must be installed on all failover cluster nodes
AllNodesHaveNetandPSInstalledCheck_Problem=The required version of .NET Framework or Windows PowerShell is not installed on one or more cluster nodes.
AllNodesHaveNetandPSInstalledCheck_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating will fail because the required version of .NET Framework or Windows PowerShell is not available on all cluster nodes.
AllNodesHaveNetandPSInstalledCheck_Resolution=Ensure that .NET Framework 4.5 and Windows PowerShell 3.0 are installed on all cluster nodes.
AllNodesHaveNetandPSInstalledCheck_Compliant=Passed

    # check SelfUpdatingOptionsScheduleExpected
SelfUpdatingOptionsScheduleExpected_Title=The configured Updating Run options must be valid
SelfUpdatingOptionsScheduleExpected_Problem=The self-updating schedule and Updating Run options configured for this failover cluster are invalid.
SelfUpdatingOptionsScheduleExpected_Impact=An Updating Run launched in self-updating mode will fail because of invalid option selection.
SelfUpdatingOptionsScheduleExpected_Resolution=Configure a valid set of self-updating schedule and Updating Run options. For more information, see the CAU online help or the CAU Windows PowerShell online help.
SelfUpdatingOptionsScheduleExpected_Compliant=Passed

    # check OwnersPresentForCAURoleCheck
OwnersPresentForCAURoleCheck_Title=At least two failover cluster nodes must be owners of the CAU clustered role
OwnersPresentForCAURoleCheck_Problem=The CAU clustered role does not have an adequate number of possible owner nodes to ensure a successful self-updating Run.
OwnersPresentForCAURoleCheck_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating will fail because the CAU clustered role does not have a possible owner node to move to.
OwnersPresentForCAURoleCheck_Resolution=Ensure that the CAU clustered role has all cluster nodes configured as possible owners. This is the default configuration.
OwnersPresentForCAURoleCheck_Compliant=Passed

    # check PreandPostUpdateScriptsAccessibleFromOwnersCheck
PreandPostUpdateScriptsAccessibleFromOwnersCheck_Title=All failover cluster nodes must be able to access Windows PowerShell scripts
PreandPostUpdateScriptsAccessibleFromOwnersCheck_Problem=Not all possible owner nodes of the CAU clustered role can access the configured Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsAccessibleFromOwnersCheck_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating will fail because one or more possible owner nodes cannot access the configured Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsAccessibleFromOwnersCheck_Resolution=Ensure that all possible owner nodes of the CAU clustered role have permissions to access the configured Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsAccessibleFromOwnersCheck_Compliant=Passed


    # check PreandPostUpdateScriptsSameonNodes
PreandPostUpdateScriptsSameonNodes_Title=All failover cluster nodes should use identical Windows PowerShell scripts
PreandPostUpdateScriptsSameonNodes_Problem=Not all possible owner nodes of the CAU clustered role use the same copy of the specified Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsSameonNodes_Impact=An Updating Run launched in the self-updating mode of Cluster-Aware Updating may fail or exhibit unexpected behavior because each updated cluster node potentially uses different Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsSameonNodes_Resolution=Ensure that all possible owner nodes of the CAU clustered role use the same Windows PowerShell pre-update and post-update scripts.
PreandPostUpdateScriptsSameonNodes_Compliant=Passed


    # check StopAfterLessThanWarnAfterCheck
WarnAfterLessThanStopAfterCheck_Title=The WarnAfter setting should be less than the StopAfter setting for the Updating Run
WarnAfterLessThanStopAfterCheck_Problem=The specified CAU Updating Run timeout values make the Warning timeout ineffective.
WarnAfterLessThanStopAfterCheck_Impact=The specified Warning and Stop timeout values can cause an Updating Run to be canceled before a Warning event log can be generated.
WarnAfterLessThanStopAfterCheck_Resolution=Configure a WarnAfter option value that is less than the StopAfter option value.
WarnAfterLessThanStopAfterCheck_Compliant=Passed


    # check IsFirewallRuleforRemoteShutdownPresentonNodes
IsFirewallRuleforRemoteShutdownPresentonNodes_Title=A firewall rule that allows remote shutdown should be enabled on each node in the failover cluster
IsFirewallRuleforRemoteShutdownPresentonNodes_Problem=One or more failover cluster nodes do not have a firewall rule enabled that allows remote shutdown
IsFirewallRuleforRemoteShutdownPresentonNodes_Impact=Cluster-Aware Updating may not be able to update this failover cluster. An Updating Run that applies updates that require restarting the nodes may not complete properly.
IsFirewallRuleforRemoteShutdownPresentonNodes_Resolution=If a firewall is in use on the failover cluster nodes, configure a firewall rule to allow the coordinator computer to restart the cluster nodes. To do this, if Windows Firewall is in use, enable the "Remote Shutdown" firewall rule group for the Domain profile on the failover cluster nodes, or pass the -EnableFirewallRules parameter to the Invoke-CauRun or Set-CauClusterRole Windows PowerShell cmdlet. If a non-Microsoft firewall is in use, configure and enable a firewall rule that enables inbound TCP traffic for the wininit.exe program using RPC Dynamic Ports.
IsFirewallRuleforRemoteShutdownPresentonNodes_Compliant=Passed

    # Cluster not reachable
clusternamenotpresent_message=The failover cluster name is not specified. To run the Cluster-Aware Updating Best Practices Analyzer on this computer, you must supply a non-empty value of the ClusterName parameter.


###PSLOC

'@

