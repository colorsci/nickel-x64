#
# Module manifest for module 'RDmgmt'
#

@{

# Script module or binary module file associated with this manifest
# RootModule = ''

# Version number of this module.
ModuleVersion = '2.0.0.0'

# ID used to uniquely identify this module
GUID = '81d5df9c-8fe3-46d7-a9bf-2aedd60d1843'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '© Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = 'Microsoft.RemoteDesktopServices.Management.Activities.dll'

# Script files (.ps1) that are run in the caller's environment prior to importing this module
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'RDMgmt.format.ps1xml'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
                 "Common.psm1",
                 "Certificate.psm1",
                 "Deployment.psm1",
                 "DeploymentProperties.psm1",
                 "SessionDesktopCollection.psm1",
                 "VirtualDesktopCollection.psm1",
                 "SessionCollectionProperties.psm1",
                 "RemoteAppPublishing.psm1",
                 "StartMenuApplications.psm1",
                 "RemoteDesktopPublishing.psm1",
                 "VirtualDesktopCollectionProperties.psm1",
                 "WorkspaceMgmt.psm1",
                 "RemoteSessionManagement.psm1",
                 "LiveMigrate.psm1"
                 )

# Functions to export from this module
FunctionsToExport = @(
                    "Get-Certificate",
                    "Set-Certificate",
                    "New-Certificate",
                    "New-VirtualDesktopDeployment", 
                    "New-SessionDeployment", 
                    "Add-Server",
                    "Remove-Server",
                    "Get-LicenseConfiguration",
                    "Set-LicenseConfiguration",
                    "Get-SessionCollection",
                    "Remove-SessionCollection",
                    "New-SessionCollection",
                    "Get-SessionHost",
                    "Set-SessionHost",
                    "Remove-SessionHost",
                    "Add-SessionHost",
                    "New-VirtualDesktopCollection",
                    "Get-VirtualDesktopCollection",
                    "Remove-VirtualDesktopCollection",
                    "Add-VirtualDesktopToCollection",
                    "Get-VirtualDesktop",
                    "Remove-VirtualDesktopFromCollection",
                    "Update-VirtualDesktopCollection",
                    "Get-VirtualDesktopCollectionJobStatus",
                    "Stop-VirtualDesktopCollectionJob",
                    "Get-PersonalVirtualDesktopAssignment",
                    "Set-PersonalVirtualDesktopAssignment",
                    "Remove-PersonalVirtualDesktopAssignment",
                    "Export-PersonalVirtualDesktopAssignment",
                    "Import-PersonalVirtualDesktopAssignment",
                    "Enable-VirtualDesktopADMachineAccountReuse",
                    "Disable-VirtualDesktopADMachineAccountReuse",
                    "Test-VirtualDesktopADMachineAccountReuse",
                    "Get-SessionCollectionConfiguration",
                    "Set-SessionCollectionConfiguration",
                    "Get-RemoteApp",
                    "New-RemoteApp",
                    "Set-RemoteApp",
                    "Remove-RemoteApp",
                    "Get-Server",
                    "Get-FileTypeAssociation",
                    "Set-FileTypeAssociation",
                    "Get-AvailableApp",
                    "Get-Workspace",
                    "Get-RemoteDesktop",
                    "Set-RemoteDesktop",
                    "Set-ConnectionBrokerHighAvailability",
                    "Set-ActiveManagementServer",
                    "Get-VirtualDesktopCollectionConfiguration",
                    "Set-VirtualDesktopCollectionConfiguration",	
                    "Get-DeploymentGatewayConfiguration",
                    "Set-DeploymentGatewayConfiguration",
                    "Get-VirtualDesktopTemplateExportPath",
                    "Set-VirtualDesktopTemplateExportPath",
                    "Get-PersonalVirtualDesktopPatchSchedule",
                    "New-PersonalVirtualDesktopPatchSchedule",
                    "Set-PersonalVirtualDesktopPatchSchedule",
                    "Remove-PersonalVirtualDesktopPatchSchedule",
                    "Test-OUAccess",
                    "Grant-OUAccess",
                    "Set-Workspace",
                    "Get-UserSession",
                    "Send-UserMessage",
                    "Invoke-UserLogoff",
                    "Disconnect-User",
                    "Get-ConnectionBrokerHighAvailability",
                    "Move-VirtualDesktop",
                    "Set-VirtualDesktopConcurrency",
                    "Get-VirtualDesktopConcurrency",
                    "Set-VirtualDesktopIdleCount",
                    "Get-VirtualDesktopIdleCount",
                    "Set-ClientAccessName",
                    "Set-DatabaseConnectionString",
                    "Remove-DatabaseConnectionString",
                    "Set-PersonalSessionDesktopAssignment",
                    "Remove-PersonalSessionDesktopAssignment",
                    "Get-PersonalSessionDesktopAssignment",
                    "Import-PersonalSessionDesktopAssignment",
                    "Export-PersonalSessionDesktopAssignment"
                    )

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# Commands to export from this module as Workflows
# ExportAsWorkflow = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
HelpInfoURI = 'https://aka.ms/winsvr-2022-pshelp'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'RD'

CompatiblePSEditions = @('Desktop')
}
