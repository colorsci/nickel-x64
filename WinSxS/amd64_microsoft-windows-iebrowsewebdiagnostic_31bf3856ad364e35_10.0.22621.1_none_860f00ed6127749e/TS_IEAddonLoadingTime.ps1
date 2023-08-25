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
    #
    # get IE enabled Addon
    #
    [System.Collections.Hashtable]$enabledAddonParaHash = GetIEEnabledAddon $ModulesHash
    if($enabledAddonParaHash -ne $null -and $enabledAddonParaHash.Count -gt 0)
    {
        [System.Collections.Hashtable]$loadingTimeHash = GetIEAddonLoadingTime $enabledAddonParaHash
        [double]$loadingTime = 0
        foreach($key in $loadingTimeHash.Keys)
        {
            $loadingTime +=  $loadingTimeHash.item($key)
        }
        if($loadingTime -gt 1000)
        {
            $result = $true
            $enabledAddonParaHash | Export-Clixml -path EnabledAddonHash.xml
            $loadingTimeHash | Export-Clixml -path EnabledAddonLoadingTimeHash.xml
        }
        WriteIEAddonReport $loadingTimeHash "loadTimeIEAddon"
    }
}

if($result)
{
    Update-DiagrootCause -id RC_IEaddonLoadingTime -Detected $true
}
else
{
    Update-DiagrootCause -id RC_IEaddonLoadingTime -Detected $false
}