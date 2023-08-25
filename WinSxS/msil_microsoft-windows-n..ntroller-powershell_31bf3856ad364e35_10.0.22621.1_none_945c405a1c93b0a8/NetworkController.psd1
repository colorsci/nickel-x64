@{

# Script module or binary module file associated with this manifest.
RootModule = 'Microsoft.NetworkController.Powershell'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '05718206-c147-47b6-83f5-92f52af61c6e'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2014 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Powershell cmdlets to manage a NetworkController deployment'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.5'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @() 

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('ComplexTypeDefinitions.psm1', 
               'NetworkControllerCredential.cdxml',
               'NetworkControllerIpPool.cdxml',
               'NetworkControllerMacPool.cdxml',
               'NetworkControllerPublicIpAddress.cdxml',
               'NetworkControllerFabricRoute.cdxml',
               'NetworkControllerLogicalNetwork.cdxml',
               'NetworkControllerLogicalSubnet.cdxml',     
               'NetworkControllerServer.cdxml',
               'NetworkControllerVirtualServer.cdxml',
               'NetworkControllerServerInterface.cdxml',
               'NetworkControllerGateway.cdxml',
               'NetworkControllerGatewayPool.cdxml',
               'NetworkControllerVirtualGateway.cdxml',
               'NetworkControllerVirtualGatewayBgpPeer.cdxml',
               'NetworkControllerVirtualGatewayBgpRouter.cdxml',
               'NetworkControllerVirtualGatewayNetworkConnection.cdxml',
               'NetworkControllerVirtualGatewayPolicyMap.cdxml'
               'NetworkControllerVirtualNetwork.cdxml',               
               'NetworkControllerAccessControlList.cdxml',
               'NetworkControllerAccessControlListRule.cdxml',
               'NetworkControllerSecurityTag.cdxml',
               'NetworkControllerInternalResourceInstances.cdxml',
               'NetworkControllerState.cdxml',
               'NetworkControllerStatistics.cdxml',
               'NetworkControllerVirtualNetworkConfiguration.cdxml',
               'NetworkControllerVirtualSwitchConfiguration.cdxml',
               'NetworkControllerAuditingSettingsConfiguration.cdxml',
               'NetworkControllerRoute.cdxml',
               'NetworkControllerRouteTable.cdxml',
               'NetworkControllerServiceInsertion.cdxml',
               'NetworkControllerLoadBalancer.cdxml',
               'NetworkControllerLoadBalancerBackendAddressPool.cdxml',
               'NetworkControllerLoadBalancerConfiguration.cdxml',
               'NetworkControllerLoadBalancerFrontendIpConfiguration.cdxml',
               'NetworkControllerLoadBalancerInboundNatRule.cdxml',
               'NetworkControllerLoadBalancerMux.cdxml',
               'NetworkControllerLoadBalancerOutboundNatRule.cdxml',
               'NetworkControllerLoadBalancerProbe.cdxml',
               'NetworkControllerLoadBalancingRule.cdxml',
               'NetworkControllerNetworkInterface.cdxml',
               'NetworkControllerNetworkInterfaceIpConfiguration.cdxml',
               'NetworkControllerVirtualSubnet.cdxml',
               'NetworkcontrollerConnectivityCheck.cdxml',
               'NetworkcontrollerConnectivityCheckResult.cdxml',
               'NetworkcontrollerBackup.cdxml',
               'NetworkcontrollerRestore.cdxml',
               'NetworkcontrollerSubnetEgressReset.cdxml',
               'NetworkControllerIpReservation.cdxml',
               'NetworkControllerVirtualNetworkPeering.cdxml',
               'NetworkControllerIDnsServerConfiguration.cdxml',
               'NetworkControllerDiscovery.cdxml',
               'NetworkControllerLearnedIpAddress.cdxml'
)

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module.
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
HelpInfoURI = 'https://aka.ms/winsvr-2022-pshelp'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
