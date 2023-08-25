# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData  -BindingVariable localizationString -FileName IEBrowseWeb_TroubleShooter

. .\CL_Utility.ps1

function checkPagecachesyncsettings
{
    Write-DiagProgress -activity $localizationString.Check_Pagecachesyncsettings

    [bool]$result = $true
    $reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    $Syncmode5property = GetItemPropertyValue $reg_path "SyncMode5"
    if($Syncmode5property -ne $null)
    {
        $syncmode5 = $Syncmode5property."SyncMode5"
        if($syncmode5 -ne "4")
        {
            $result = $false
        }
    }
    return $result
}

if((checkPagecachesyncsettings) -eq $false)
{
    Update-DiagRootCause -id RC_cachesyncsettings -Detected $true
} else {
    Update-DiagRootCause -id RC_cachesyncsettings -Detected $false
}
