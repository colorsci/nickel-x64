# Copyright © 2008, Microsoft Corporation. All rights reserved.

#
#Localization Data
#
Import-LocalizedData -BindingVariable localizationString -FileName IEBrowseWeb_TroubleShooter

. .\TS_IEAddon.ps1

Write-DiagProgress -activity $localizationString.Check_DefectiveAddon

[bool]$result = $false
#
#Get the IE Add-on module informations from registry
#
[System.Collections.Hashtable]$ModulesHash = GetAddonModules

if($ModulesHash -ne $null -and $ModulesHash.count -gt 0)
{
    WriteIEAddonReport $ModulesHash "detectedIEAddon"
    #
    # get IE Bad Addon
    #
    [System.Collections.Hashtable]$DefectiveAddonParaHash = CheckDefectiveAddon $ModulesHash
    if($DefectiveAddonParaHash -ne $null -and $DefectiveAddonParaHash.Count -gt 0)
    {
        $result = $true
        $DefectiveAddonParaHash | Export-Clixml -path DefectiveAddonParaHash.xml
        WriteIEAddonReport $DefectiveAddonParaHash "defectiveaddon"
    }
}

if($result)
{
    Update-DiagrootCause -id RC_defectiveIEaddon -Detected $true
}
else
{
    Update-DiagrootCause -id RC_defectiveIEaddon -Detected $false
}