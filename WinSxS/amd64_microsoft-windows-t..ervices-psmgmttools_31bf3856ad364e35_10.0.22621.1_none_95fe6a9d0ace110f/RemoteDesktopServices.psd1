@{
GUID                = "9fdb63ca-68ae-4034-a9fa-78529396c689"
Author              = "Microsoft Corporation"
CompanyName         = "Microsoft Corporation"
Copyright           = "© Microsoft Corporation. All rights reserved."
ModuleVersion       = "2.0.0.0"
PowerShellVersion = '5.1'
CLRVersion          = "4.0"
NestedModules       = "TSPSProvider.dll", "TSPSCmdlets.dll"
FormatsToProcess    = "TSProvider.Format.ps1xml"
RequiredAssemblies  = "TSPSDataAccess.dll", "TSPSEngine.dll"
CmdletsToExport     = @(
                         "Convert-License"
                        )
HelpInfoURI         = "https://aka.ms/winsvr-2022-pshelp"

CompatiblePSEditions = @('Desktop')
}
