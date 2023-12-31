@{
    GUID="A1DA990A-4DC2-4f7e-BEB4-046A89B9D473"
    Author="Microsoft Corporation"
    CompanyName="Microsoft Corporation"
    Copyright="© Microsoft Corporation. All rights reserved."
    ModuleVersion = "2.0.0.0"
    PowerShellVersion = "3.0"
    ClrVersion = "4.0"
    TypesToProcess="Microsoft.Iscsi.Target.Commands.Types.ps1xml"
    RootModule="Microsoft.Iscsi.Target.Commands"
    NestedModules = @("ImportExportIscsiTargetConfiguration.psm1")
    CmdletsToExport = @(
    "Add-ClusteriSCSITargetServerRole",
    "Add-IscsiVirtualDiskTargetMapping",
    "Checkpoint-IscsiVirtualDisk",
    "Convert-IscsiVirtualDisk",
    "Dismount-IscsiVirtualDiskSnapshot",
    "Export-IscsiVirtualDiskSnapshot",
    "Get-IscsiServerTarget",
    "Get-IscsiTargetServerSetting",
    "Get-IscsiVirtualDisk",
    "Get-IscsiVirtualDiskSnapshot",
    "Import-IscsiVirtualDisk",
    "Mount-IscsiVirtualDiskSnapshot",
    "New-IscsiServerTarget",
    "New-IscsiVirtualDisk",
    "Remove-IscsiServerTarget",
    "Remove-IscsiVirtualDisk",
    "Remove-IscsiVirtualDiskSnapshot",
    "Remove-IscsiVirtualDiskTargetMapping",
    "Resize-IscsiVirtualDisk",
    "Restore-IscsiVirtualDisk",
    "Set-IscsiServerTarget",
    "Set-IscsiTargetServerSetting",
    "Set-IscsiVirtualDisk",
    "Set-IscsiVirtualDiskSnapshot",
    "Stop-IscsiVirtualDiskOperation")
    FunctionsToExport = ("Import-IscsiTargetServerConfiguration",
    "Export-IscsiTargetServerConfiguration")
    AliasesToExport = "Expand-IscsiVirtualDisk"    
    HelpInfoUri="https://aka.ms/winsvr-2022-pshelp"
 }
