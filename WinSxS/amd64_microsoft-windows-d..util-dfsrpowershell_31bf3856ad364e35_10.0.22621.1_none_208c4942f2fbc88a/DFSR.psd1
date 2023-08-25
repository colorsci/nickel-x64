#
# Module manifest for module 'DFSR'
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'DfsrPowerShell.dll'

# Version number of this module.
ModuleVersion = '2.0.0.0'

# ID used to uniquely identify this module
GUID = 'C3F81F5F-6555-43CB-802A-AEF7AA5A11CB'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('DFSR.Format.ps1xml')

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = @(
    'New-DfsReplicationGroup', 'Get-DfsReplicationGroup', 'Set-DfsReplicationGroup', 'Remove-DfsReplicationGroup',
    'Sync-DfsReplicationGroup', 'Suspend-DfsReplicationGroup',
    'New-DfsReplicatedFolder', 'Get-DfsReplicatedFolder', 'Set-DfsReplicatedFolder', 'Remove-DfsReplicatedFolder',
    'Add-DfsrMember', 'Get-DfsrMember', 'Set-DfsrMember', 'Remove-DfsrMember',
    'Add-DfsrConnection', 'Get-DfsrConnection', 'Set-DfsrConnection', 'Remove-DfsrConnection',
    'Get-DfsrMembership', 'Set-DfsrMembership',
    'Get-DfsrGroupSchedule', 'Set-DfsrGroupSchedule', 'Get-DfsrConnectionSchedule', 'Set-DfsrConnectionSchedule',
    'Get-DfsrDelegation', 'Grant-DfsrDelegation', 'Revoke-DfsrDelegation',
    'Get-DfsrServiceConfiguration', 'Set-DfsrServiceConfiguration', 'Update-DfsrConfigurationFromAD',
    'ConvertFrom-DfsrGuid', 'Get-DfsrBacklog', 'Get-DfsrState', 'Get-DfsrIdRecord', 'Get-DfsrFileHash',
    'Write-DfsrHealthReport', 'Start-DfsrPropagationTest', 'Write-DfsrPropagationReport', 'Remove-DfsrPropagationTestFile',
    'Get-DfsrPreservedFiles', 'Restore-DfsrPreservedFiles',
    'Export-DfsrClone', 'Import-DfsrClone', 'Get-DfsrCloneState', 'Reset-DfsrCloneState')

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in ModuleToProcess
PrivateData = ''

# HelpInfo URI of this module
HelpInfoURI = '"https://aka.ms/winsvr-2022-pshelp'

}

