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

Update-DiagRootCause RC_MediaLibCorrupted -Detected $true
