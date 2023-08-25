﻿@{
    GUID = '69775f93-9317-4234-a558-13b6655fc41b'
    Author = 'Microsoft Corporation'
    CompanyName = 'Microsoft Corporation'
    Copyright = '© Microsoft Corporation. All rights reserved.'
    ModuleVersion = '2.0.0.0'
    PowerShellVersion = '3.0'
    CLRVersion = '4.0'
    RequiredModules = @()
    RequiredAssemblies = @()
    PrivateData = ''
    HelpInfoUri="https://aka.ms/winsvr-2022-pshelp"

    NestedModules = @(
        "IpamConfigurationEvent.cdxml",
        "IpamRange.cdxml",
        "IpamAddressSpace.cdxml",
        "IpamCustomField.cdxml",
        "IpamCustomValue.cdxml",
        "IpamBlock.cdxml",
        "IpamSubnet.cdxml",
        "IpamDiscoveryDomain.cdxml",
        "IpamCustomFieldAssociation.cdxml",
        "IpamDatabase.cdxml",
        "IpamAddress.cdxml",
        "IpamIpAuditEvent.cdxml",
        "IpamServerInventory.cdxml",
        "IpamDhcpConfigurationEvent.cdxml",
        "IpamConfiguration.cdxml",
        "IpamServer.cdxml",
        "IpamCapabilities.cdxml",
        "IpamAddressUtilizationThreshold.cdxml",
        "IpamServerProvisioning.cdxml",
        "IpamAccessScope.cdxml",
        "IpamDhcpScope.cdxml",
        "IpamDhcpSuperscope.cdxml",
        "IpamGpo.psm1",
        "IpamDnsZone.cdxml",
        "IpamDnsResourceRecord.cdxml",
	"IpamDnsConditionalForwarder.cdxml"
	"IpamDnsServer.cdxml",
	"IpamDhcpServer.cdxml",
	"IpamUtilizationData.cdxml"
        )

    TypesToProcess = @(
        "IpamConfigurationEvent.Types.ps1xml",
        "IpamRange.Types.ps1xml",
        "IpamAddressSpace.Types.ps1xml",
        "IpamBlock.Types.ps1xml",
        "IpamSubnet.Types.ps1xml",
        "IpamDiscoveryDomain.Types.ps1xml",
        "IpamCustomFieldAssociation.types.ps1xml",
        "IpamDatabase.Types.ps1xml",
        "IpamAddress.Types.ps1xml",
        "IpamIpAuditEvent.Types.ps1xml",
        "IpamServerInventory.types.ps1xml",
        "IpamDhcpConfigurationEvent.Types.ps1xml",
        "IpamConfiguration.Types.ps1xml",
        "IpamCapabilities.Types.ps1xml",
        "IpamAddressUtilizationThreshold.Types.ps1xml",
        "IpamDhcpScope.Types.ps1xml",
        "IpamDhcpSuperscope.Types.ps1xml",
        "IpamDnsZone.Types.ps1xml",
        "IpamDnsResourceRecord.Types.ps1xml",
		"IpamDnsConditionalForwarder.Types.ps1xml"
		"IpamDnsServer.Types.ps1xml",
		"IpamDhcpServer.Types.ps1xml"
        )

    FormatsToProcess = @(
        "IpamConfigurationEvent.Format.ps1xml",
        "Ipamrange.Format.ps1xml",
        "IpamAddressSpace.Format.ps1xml",
        "IpamCustomField.format.ps1xml",
        "IpamCustomValue.format.ps1xml",
        "IpamBlock.Format.ps1xml",
        "IpamSubnet.Format.ps1xml",
        "IpamDiscoveryDomain.Format.ps1xml",
        "IpamCustomFieldAssociation.format.ps1xml",
        "IpamDatabase.Format.ps1xml",
        "IpamAddress.Format.ps1xml",
        "IpamIpAuditEvent.Format.ps1xml",
        "IpamServerInventory.Format.ps1xml",
        "IpamDhcpConfigurationEvent.Format.ps1xml",
        "IpamConfiguration.Format.ps1xml",
        "IpamCapabilities.Format.ps1xml",
        "IpamAddressUtilizationThreshold.Format.ps1xml",
        "IpamDhcpScope.Format.ps1xml",
        "IpamDhcpSuperscope.Format.ps1xml",
        "IpamDnsZone.Format.ps1xml",
        "IpamDnsResourceRecord.Format.ps1xml",
		"IpamDnsConditionalForwarder.Format.ps1xml"
		"IpamDnsServer.Format.ps1xml",
		"IpamDhcpServer.Format.ps1xml"
        )

    FunctionsToExport = @(
        'Get-IpamDhcpConfigurationEvent',
        'Remove-IpamDhcpConfigurationEvent',
        'Get-IpamConfigurationEvent',
        'Remove-IpamConfigurationEvent',
        'Get-IpamIpAddressAuditEvent',
        'Remove-IpamIpAddressAuditEvent',
        'Get-IpamRange',
        'Set-IpamRange',
        'Add-IpamRange',
        'Export-IpamRange',
        'Remove-IpamRange',
        'Get-IpamAddressSpace',
        'Set-IpamAddressSpace',
        'Add-IpamAddressSpace',
        'Remove-IpamAddressSpace',
        'Get-IpamCustomField',
        'Add-IpamCustomField',
        'Remove-IpamCustomField',
        'Add-IpamCustomValue',
        'Remove-IpamCustomValue',
        'Rename-IpamCustomField',
        'Rename-IpamCustomValue',
        'Get-IpamBlock',
        'Add-IpamBlock',
        'Set-IpamBlock',
        'Remove-IpamBlock',
        'Get-IpamSubnet',
        'Set-IpamSubnet',
        'Add-IpamSubnet',
        'Remove-IpamSubnet',
        'Export-IpamSubnet',
        'Get-IpamDiscoveryDomain',
        'Add-IpamDiscoveryDomain',
        'Set-IpamDiscoveryDomain',
        'Remove-IpamDiscoveryDomain',
        'Get-IpamCustomFieldAssociation',
        'Set-IpamCustomFieldAssociation',
        'Add-IpamCustomFieldAssociation',
        'Remove-IpamCustomFieldAssociation',
        'Get-IpamDatabase',
        'Set-IpamDatabase',
        'Move-IpamDatabase',
        'Get-IpamAddress',
        'Add-IpamAddress',
        'Set-IpamAddress',
        'Import-IpamAddress',
        'Import-IpamRange',
        'Import-IpamSubnet',
        'Remove-IpamAddress',
        'Export-IpamAddress',
        'Find-IpamFreeAddress',
        'Invoke-IpamServerProvisioning',
        'Update-IpamServer',
        'Get-IpamServerInventory',
        'Add-IpamServerInventory',
        'Set-IpamServerInventory',
        'Remove-IpamServerInventory',
        'Get-IpamConfiguration',
        'Set-IpamConfiguration',
        'Get-IpamCapability',
        'Enable-IpamCapability',
        'Disable-IpamCapability',
        'Get-IpamAddressUtilizationThreshold',
        'Set-IpamAddressUtilizationThreshold',
        'Invoke-IpamGpoProvisioning',
        'Find-IpamFreeRange',
        'Find-IpamFreeSubnet',
        'Set-IpamAccessScope',
        'Get-IpamDhcpScope',
        'Get-IpamDhcpSuperscope',
        'Get-IpamDnsZone',
        'Get-IpamDnsResourceRecord',
	'Get-IpamDnsConditionalForwarder'
	'Get-IpamDnsServer',
	'Get-IpamDhcpServer',
	'Remove-IpamUtilizationData'
        )
}
