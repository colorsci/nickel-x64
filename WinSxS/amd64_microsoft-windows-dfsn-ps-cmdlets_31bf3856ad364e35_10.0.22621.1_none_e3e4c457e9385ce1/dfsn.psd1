<#
The cmdlets-over-objects module generated on 4/20/2011 4:06:44 PM by the Export-CimCommand cmdlet invoked with the following command: export-cimcommand DfsNamespace.xml -FormatPath dfsnamespace.format.ps1xml -TypesPath dfsnamespace.types.ps1xml -force
#>

@{
    GUID = 'd94cf4d4-f7f8-4967-8d7c-1c9ffef8da12'
    
    # Author of this module
    Author = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright = '(c) Microsoft Corporation. All rights reserved.'

    FormatsToProcess = @(
           'MSFT_DFSNamespace\DfsNamespace.format.ps1xml',
           'MSFT_DFSNamespaceFolder\DfsNamespaceFolder.format.ps1xml', 
           'MSFT_DFSNamespaceAccess\DfsNamespaceAccess.format.ps1xml',
           'MSFT_DFSNamespaceRootTarget\DfsNamespaceRootTarget.format.ps1xml',
           'MSFT_DFSNamespaceFolderTarget\DfsNamespaceFolderTarget.format.ps1xml',
           'MSFT_DFSNamespaceServerConfig\DfsNamespaceServerConfig.format.ps1xml'
    ) 

    TypesToProcess = @(
           'MSFT_DFSNamespace\DfsNamespace.types.ps1xml', 
           'MSFT_DFSNamespaceFolder\DfsNamespaceFolder.types.ps1xml', 
           'MSFT_DFSNamespaceAccess\DfsNamespaceAccess.types.ps1xml', 
           'MSFT_DFSNamespaceRootTarget\DfsNamespaceRootTarget.types.ps1xml',
           'MSFT_DFSNamespaceFolderTarget\DfsNamespaceFolderTarget.types.ps1xml'
           'MSFT_DFSNamespaceServerConfig\DfsNamespaceServerConfig.types.ps1xml'
    )

    NestedModules = @(
           'MSFT_DFSNamespace\DfsNamespace.cdxml',
           'MSFT_DFSNamespaceFolder\DfsNamespaceFolder.cdxml', 
           'MSFT_DFSNamespaceAccess\DfsNamespaceAccess.cdxml', 
           'MSFT_DFSNamespaceRootTarget\DfsNamespaceRootTarget.cdxml',
           'MSFT_DFSNamespaceFolderTarget\DfsNamespaceFolderTarget.cdxml',
           'MSFT_DFSNamespaceServerConfig\DfsNamespaceServerConfig.cdxml'
    )

    ModuleVersion = '1.0'
    

    AliasesToExport = @()
    FunctionsToExport = @(
           'Get-DfsnRoot', 'Remove-DfsnRoot', 'Set-DfsnRoot', 'New-DfsnRoot','Get-DfsnFolder', 
           'Move-DfsnFolder', 'New-DfsnFolder', 'Remove-DfsnFolder', 'Set-DfsnFolder',
           'Get-DfsnAccess', 'Grant-DfsnAccess', 'Revoke-DfsnAccess', 'Remove-DfsnAccess',
           'Get-DfsnRootTarget', 'New-DfsnRootTarget', 'Remove-DfsnRootTarget', 'Set-DfsnRootTarget',
           'Get-DfsnFolderTarget', 'New-DfsnFolderTarget', 'Remove-DfsnFolderTarget', 'Set-DfsnFolderTarget',
           'Get-DfsnServerConfiguration', 'Set-DfsnServerConfiguration'
    )

    PowerShellVersion = '5.1'
    HelpInfoUri = "https://aka.ms/winsvr-2022-pshelp"
    CompatiblePSEditions = @('Desktop', 'Core')
}
