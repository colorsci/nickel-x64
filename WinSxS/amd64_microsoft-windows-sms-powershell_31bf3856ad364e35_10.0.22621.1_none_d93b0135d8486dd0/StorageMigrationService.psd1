@{
    GUID = '2e8f70fe-6df9-468b-922a-f83e5380bf63'
    Author = "Microsoft Corporation"
    CompanyName ="Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    ModuleVersion = "1.0.0.0"
    PowerShellVersion = "3.0"
    ClrVersion = "4.0"
    RootModule = "Microsoft.StorageMigration.Commands.dll"
    FormatsToProcess = @("StorageMigrationService.format.ps1xml")
    TypesToProcess = @()
    FunctionsToExport = @()
    CmdletsToExport = @(
        "New-SmsNasPrescan"
        "Get-SmsNasPrescan"
        "Start-SmsNasPrescan"
        "Get-SmsInventory"
        "New-SmsInventory"
        "Remove-SmsInventory"
        "Set-SmsInventory"
        "Start-SmsInventory"
        "Stop-SmsInventory"
        "Get-SmsProxy"
        "Register-SmsProxy"
        "Unregister-SmsProxy"
        "Get-SmsState"
        "Get-SmsTransfer"
        "New-SmsTransfer"
        "Remove-SmsTransfer"
        "Set-SmsTransfer"
        "Start-SmsTransfer"
        "Stop-SmsTransfer"
        "Get-SmsTransferPairing"
        "Remove-SmsTransferPairing"
        "Set-SmsTransferPairing"
        "Get-SmsCutover"
        "Get-SmsCutoverPairing"
        "New-SmsCutover"
        "Remove-SmsCutover"
        "Remove-SmsCutoverPairing"
        "Resume-SmsCutover"
        "Set-SmsCutover"
        "Set-SmsCutoverPairing"
        "Start-SmsCutover"
        "Stop-SmsCutover"
        "Get-SmsDestinationConfig"
        "Test-SmsMigration"
        "Get-SmsVersion"
        "Get-SmsCutoverStages"
    )
    RequiredAssemblies = @()
    AliasesToExport = @()
    HelpInfoURI = "https://aka.ms/winsvr-2022-pshelp"
}
