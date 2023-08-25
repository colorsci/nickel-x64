@{
    GUID = 'B55FD86F-287C-470C-9AC6-647DC76C15CE'
    Author = "Microsoft Corporation"
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    ModuleVersion = "1.0.0.0"
    PowerShellVersion = '5.1'
    ClrVersion = "4.0"
    RootModule = "Microsoft.SystemInsights.Management.PowerShell.dll"
    FormatsToProcess = @("SystemInsights.format.ps1xml")
    TypesToProcess = @("SystemInsights.types.ps1xml")
    FunctionsToExport = @()
    CmdletsToExport = @(
        "Add-InsightsCapability"
        "Remove-InsightsCapability"
        "Update-InsightsCapability"
        "Get-InsightsCapability"
        "Enable-InsightsCapability"
        "Disable-InsightsCapability"
        "Get-InsightsCapabilitySchedule"
        "Enable-InsightsCapabilitySchedule"
        "Disable-InsightsCapabilitySchedule"
        "Set-InsightsCapabilitySchedule"
        "Get-InsightsCapabilityAction"
        "Remove-InsightsCapabilityAction"
        "Set-InsightsCapabilityAction"
        "Invoke-InsightsCapability"
        "Get-InsightsCapabilityResult"
    )
    RequiredAssemblies = @()
    AliasesToExport = @()
    HelpInfoURI = "https://aka.ms/winsvr-2022-pshelp"
    CompatiblePSEditions = @('Desktop')
}
