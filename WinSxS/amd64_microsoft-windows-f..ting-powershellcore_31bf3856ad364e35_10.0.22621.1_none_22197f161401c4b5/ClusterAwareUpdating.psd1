#
# Module manifest for module 'ClusterAwareUpdating'
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'ClusterAwareUpdating.dll'

# Version number of this module.
ModuleVersion = '2.0.0.0'

# ID used to uniquely identify this module
GUID = '4E804861-1DCE-46C1-868D-C8F2AB9D220A'

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
FormatsToProcess = "ClusterAwareUpdating.Format.ps1xml"

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = @('Get-CauPlugin', 'Register-CauPlugin', 'Unregister-CauPlugin', 'Invoke-CauScan', 'Invoke-CauRun', 'Get-CauReport', 'Export-CauReport', 'Save-CauDebugTrace', 'Add-CauClusterRole', 'Remove-CauClusterRole', 'Get-CauRun', 'Set-CauClusterRole', 'Get-CauClusterRole', 'Enable-CauClusterRole', 'Disable-CauClusterRole', 'Stop-CauRun', 'Test-CauSetup', 'Get-CauDeviceInfoForFeatureUpdates')

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
HelpInfoURI = 'https://aka.ms/winsvr-2022-pshelp'

}

