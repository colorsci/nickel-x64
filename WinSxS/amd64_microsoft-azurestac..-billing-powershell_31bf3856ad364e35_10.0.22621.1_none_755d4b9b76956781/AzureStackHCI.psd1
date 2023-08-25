@{
    GUID = '9BAE6304-259A-4421-B9DC-65A66A0A6E18'
    Author = "Microsoft Corporation"
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    ModuleVersion = "1.0.0.0"
    PowerShellVersion = '5.1'
    ClrVersion = "4.0"
    RootModule = "Microsoft.AzureStack.HCI.Billing.Management.PowerShell.dll"
    FormatsToProcess = @("AzureStackHCI.format.ps1xml")
    TypesToProcess = @("AzureStackHCI.types.ps1xml")
    FunctionsToExport = @()
    CmdletsToExport = @(
        "Get-AzureStackHCIBillingRecord"
        "Get-AzureStackHCI"
        "New-AzureStackHCIRegistrationCertificate"
        "Set-AzureStackHCIRegistrationCertificate"
        "Get-AzureStackHCIRegistrationCertificate"
        "Update-AzureStackHCIRegistrationCertificate"
        "Remove-AzureStackHCIRegistrationCertificate"
        "Set-AzureStackHCIRegistration"
        "Sync-AzureStackHCI"
        "Remove-AzureStackHCIRegistration"
        "Get-AzureStackHCISubscriptionStatus"
        "Initialize-AzureStackHCIArcIntegration"
        "Clear-AzureStackHCIArcIntegration"
        "Enable-AzureStackHCIArcIntegration"
        "Disable-AzureStackHCIArcIntegration"
        "Get-AzureStackHCIArcIntegration"
        "Get-AzureStackHCIAttestation"
        "Set-AzureStackHCIAttestation"
    )
    RequiredAssemblies = @()
    AliasesToExport = @()
    HelpInfoURI = "https://aka.ms/winsvr-2022-pshelp"
    CompatiblePSEditions = @('Desktop')
}
