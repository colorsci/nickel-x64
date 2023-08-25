# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_WindowsMediaPlayer

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

$IsWMPInstalled = .\TS_IsWMPUnavailable.ps1
if ($IsWMPInstalled -eq $False)
{
    return $False
}

$WMplayer = Get-Process -name wmplayer
if ($WMplayer -ne $Null)
{
    $CloseWMP = Get-DiagInput -id "IT_WMPRuning"
}

Update-DiagRootCause -id RC_ConfigurationErrors -Detected $true

#
#Detecting NetworkCache
#
Write-DiagProgress -activity $localizationString.Troubleshoot_DetectNetworkCache

$IsNetworkError = .\TS_NetworkCacheCorrupted.ps1
if ($IsNetworkError -eq $False)
{
    Update-DiagRootCause -id RC_NetworkCacheCorrupted -Detected $true
} else {
    Update-DiagRootCause -id RC_NetworkCacheCorrupted -Detected $false
}
