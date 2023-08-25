#
# Module manifest for the persistent memory management module.
#
# Generated by: Microsoft Corporation
#

@{

# Script module or binary module file associated with this manifest
RootModule = 'Microsoft.Storage.PersistentMemory.Management.Commands.dll'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = 'E5905ED9-12BC-4765-B20D-40A37D69C3DD'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @(
    'PmemPhysicalDevice.ps1xml',
    'PmemDisk.ps1xml',
    'PmemDedicatedMemory.ps1xml'
    )

# Cmdlets to export from this module
CmdletsToExport = @(
    'Get-PmemDisk',
    'Get-PmemPhysicalDevice',
    'Get-PmemUnusedRegion',
    'New-PmemDisk',
    'Remove-PmemDisk',
    'Initialize-PmemPhysicalDevice',
    'Get-PmemDedicatedMemory',
    'New-PmemDedicatedMemory',
    'Remove-PmemDedicatedMemory'
    )

# HelpInfo - TBD
HelpInfoUri = "https://aka.ms/winsvr-2022-pshelp"

CompatiblePSEditions = @('Desktop')
}
