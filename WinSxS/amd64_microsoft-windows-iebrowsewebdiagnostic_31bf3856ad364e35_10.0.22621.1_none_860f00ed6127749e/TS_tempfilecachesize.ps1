# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName IEBrowseWeb_TroubleShooter

. .\CL_Utility.ps1


function checktempfilecachesize
{
    Write-DiagProgress -activity $localizationString.Check_tempfilecachesize

    [bool]$result = $true

    $reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content"

    $CacheLimitproperty = GetItemPropertyValue $reg_path "CacheLimit"
    if($CacheLimitproperty -eq $null)
    {
        return $true
    }

    $cacheLimit = $CacheLimitproperty."CacheLimit"
    if($cacheLimit -eq $null)
    {
        return $true
    }

    if(($cacheLimit -lt 51200) -or ($cachelimit -gt 256000))
    {
        $result = $false
    }
    return $result
}


if((checktempfilecachesize) -eq $false)
{
    Update-DiagRootCause -id RC_Tempfilescachesize -Detected $true
} else {
    Update-DiagRootCause -id RC_Tempfilescachesize -Detected $false
}
