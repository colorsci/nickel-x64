@{
    GUID = 'de3e9b0f-0845-4b05-8cb1-65669405130c'
    Author = "Microsoft Corporation"
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    NestedModules = @('MSFT_HgsClientConfiguration_v1.0.cdxml',
                      'MSFT_HgsGuardian_v1.0.cdxml',
                      'MSFT_HgsKeyProtector_v1.0.cdxml',
                      'Microsoft.Windows.RemoteAttestation.Client.PowerShell.dll',
                      'HgsClient.psm1')
    CmdletsToExport = @('Get-HgsAttestationBaselinePolicy')
    FormatsToProcess = @('HgsClient.format.ps1xml')
    TypesToProcess = @('HgsClient.types.ps1xml')
    ModuleVersion = '1.0.0.0'
    AliasesToExport = @()
    FunctionsToExport = @('Get-HgsClientConfiguration',
                          'Test-HgsClientConfiguration',
                          'Set-HgsClientConfiguration',
                          'New-HgsGuardian',
                          'Get-HgsGuardian',
                          'Remove-HgsGuardian',
                          'Export-HgsGuardian',
                          'Import-HgsGuardian',
                          'New-HgsKeyProtector',
                          'ConvertTo-HgsKeyProtector',
                          'Grant-HgsKeyProtectorAccess',
                          'Revoke-HgsKeyProtectorAccess',
                          'Set-HgsClientHostKey',
                          'Get-HgsClientHostKey',
                          'Remove-HgsClientHostKey')
    PowerShellVersion = '5.1'
    HelpInfoUri = "https://go.microsoft.com/fwlink/?linkid=519076"
    CompatiblePSEditions = @('Desktop', 'Core')
}
