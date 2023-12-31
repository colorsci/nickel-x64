@{

#
# Module manifest for module 'ServerManagerTasks'
#

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '{BF4656AC-2663-4636-8B38-7D78FD587D0B}'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '© Microsoft Corporation. All rights reserved.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Script module or binary module file associated with this manifest
RootModule = 'ServerManagerTasks.cdxml'

# Functions to export from this module
FunctionsToExport = @(
    'Get-CounterSample',
    'Get-PerformanceCollector',
    'Get-ServerBpaResult',
    'Get-ServerClusterName',
    'Get-ServerEvent',
    'Get-ServerFeature',
    'Get-ServerInventory',
    'Get-ServerService',
    'Remove-ServerPerformanceLog',
    'Start-PerformanceCollector',
    'Stop-PerformanceCollector'
)

# HelpInfo URI of this module
HelpInfoURI = 'https://aka.ms/winsvr-2022-pshelp'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'SM'

}
