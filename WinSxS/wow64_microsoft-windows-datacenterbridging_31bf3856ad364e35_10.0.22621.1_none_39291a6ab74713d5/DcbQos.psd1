@{
    GUID = 'B57D41F8-8B6B-4012-912F-B08109101281'
    Author = "Microsoft Corporation"
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    ModuleVersion = '2.0.0.0'
    PowerShellVersion = '5.1'
    HelpInfoUri = "https://aka.ms/winsvr-2022-pshelp"
    NestedModules = @(
        'MSFT_NetQosFlowControl.cdxml',
        'MSFT_NetQosTrafficClass.cdxml',
        'MSFT_NetQosDcbxSetting.cdxml')
    FormatsToProcess = @(
        'MSFT_NetQosFlowControl.format.ps1xml',
        'MSFT_NetQosTrafficClass.format.ps1xml',
        'MSFT_NetQosDcbxSetting.format.ps1xml')
    TypesToProcess = @(
        'MSFT_NetQosFlowControl.types.ps1xml',
        'MSFT_NetQosTrafficClass.types.ps1xml'
        'MSFT_NetQosDcbxSetting.types.ps1xml')
    FunctionsToExport = @(
        'Get-NetQosFlowControl',
        'Set-NetQosFlowControl',
        'Enable-NetQosFlowControl',
        'Disable-NetQosFlowControl',
        'Get-NetQosTrafficClass',
        'Set-NetQosTrafficClass',
        'Remove-NetQosTrafficClass',
        'New-NetQosTrafficClass',
        'Get-NetQosDcbxSetting',
        'Set-NetQosDcbxSetting',
        'Switch-NetQosTrafficClass',
        'Switch-NetQosFlowControl',
        'Switch-NetQosDcbxSetting')
    CompatiblePSEditions = @('Desktop', 'Core')
}
