@{
    GUID = "{AEEF2BEF-EBA9-4A1D-A3D2-D0B52DF76DEB}"
    HelpInfoUri="https://aka.ms/winsvr-2022-pshelp"
    AliasesToExport = @(
        'Add-AppPackage',
        'Get-AppPackage',
        'Get-AppPackageAutoUpdateSettings'
        'Get-AppPackageManifest',
        'Remove-AppPackage',
        'Remove-AppPackageAutoUpdateSettings',
        'Reset-AppPackage',
        'Get-AppPackageVolume',
        'Add-AppPackageVolume',
        'Remove-AppPackageVolume',
        'Mount-AppPackageVolume',
        'Dismount-AppPackageVolume',
        'Move-AppPackage',
        'Get-AppPackageDefaultVolume',
        'Set-AppPackageDefaultVolume',
        'Get-AppPackageLastError',
        'Get-AppPackageLog',
        'Set-AppPackageAutoUpdateSettings'
    )
    Author = "Microsoft Corporation"
    CmdletsToExport = 'Add-AppxPackage', 'Get-AppxPackage', 'Get-AppxPackageAutoUpdateSettings', 'Get-AppxPackageManifest', 'Remove-AppxPackage', 'Remove-AppxPackageAutoUpdateSettings', 'Reset-AppxPackage', 'Get-AppxVolume', 'Add-AppxVolume', 'Remove-AppxVolume', 'Mount-AppxVolume', 'Dismount-AppxVolume', 'Move-AppxPackage', 'Get-AppxDefaultVolume', 'Set-AppxDefaultVolume', 'Invoke-CommandInDesktopPackage', 'Add-AppSharedPackageContainer', 'Get-AppSharedPackageContainer', 'Remove-AppSharedPackageContainer', 'Reset-AppSharedPackageContainer', 'Set-AppxPackageAutoUpdateSettings'
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    FunctionsToExport = 'Get-AppxLastError', 'Get-AppxLog'    
    ModuleVersion = "2.0.1.0"
    ModuleToProcess = 'Microsoft.Windows.Appx.PackageManager.Commands'
    FormatsToProcess = 'Appx.format.ps1xml'
    NestedModules = 'Appx.psm1'
    CompatiblePSEditions = @('Desktop')
    PowerShellVersion="5.1"
}
