@{
    GUID="{18cd46da-e6a6-47f6-84b3-d4edd6e3eccf}"
    Author="Microsoft Corporation"
    CompanyName="Microsoft Corporation"
    Copyright="© Microsoft Corporation. All rights reserved."
    HelpInfoUri = "https://aka.ms/winsvr-2022-pshelp"
    ModuleVersion = "1.0.0.0"
    NestedModules = @('Policy.cdxml', 'Policy.psm1', 'QosVolume.cdxml', 'PolicyStore.cdxml')
    FormatsToProcess = 'Qos.Formats.ps1xml'
    TypesToProcess = 'Qos.Types.ps1xml'
    FunctionsToExport = @(
        'Get-StorageQoSPolicy',
        'Get-StorageQoSPolicyStore',
        'Set-StorageQoSPolicyStore',
        'Remove-StorageQoSPolicy',
        'Set-StorageQoSPolicy',
        'New-StorageQoSPolicy',
        'Get-StorageQoSVolume',
        'Get-StorageQoSFlow')
    CompatiblePSEditions = @('Desktop','Core')
}
