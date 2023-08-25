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
#
#detecting dvd device and dvd decoders
#
Write-DiagProgress -activity $localizationString.Troubleshoot_DetectDVDDevice

[HashTable]$DVDDevices = .\TS_DVDDevice.ps1

if ($DVDDevices.Count -le 0)
{
    Update-DiagRootCause -id RC_MissingDVDDevice -Detected $true
}
else
{
    Update-DiagRootCause -id RC_MissingDVDDevice -Detected $false
}

[string]$MultiDeviceID = ""
[string]$DeviceID = ""
foreach($DeviceID in $DVDDevices.Keys)
{
    $DeviceErrorCode = $DVDDevices.Item($DeviceID)
    if($DeviceErrorCode -ne 0)
    {

        $MultiDeviceID += $DeviceID
        $MultiDeviceID += "#"
    }
}

if([String]::IsNullOrEmpty($MultiDeviceID) -ne $True)
{
    $MultiDeviceID = $MultiDeviceID.Replace("&", "&amp;")
    Update-DiagRootCause -id RC_ProblematicDVDDevice -iid $DeviceID -Detected $true -p @{"DEVICEID" = $MultiDeviceID}
}
else
{
    Update-DiagRootCause -id RC_ProblematicDVDDevice -iid $DeviceID -Detected $False -p @{"DEVICEID" = $MultiDeviceID}
}

Write-DiagProgress -activity $localizationString.Troubleshoot_DetectDVDvideoDecoder

$IsDvdVideoDecoderProblem = .\TS_DVDVideoDecoder.ps1

Write-DiagProgress -activity $localizationString.Troubleshoot_DetectDVDAudioDecoder

$IsDvdAudioDecoderProblem = .\TS_DVDAudioDecoder.ps1

if (($IsDvdVideoDecoderProblem -eq $False) -or ($IsDvdAudioDecoderProblem -eq $False))
{
    Update-DiagRootCause RC_MissingDVDDecoder -Detected $true
}
else
{
    Update-DiagRootCause RC_MissingDVDDecoder -Detected $false
}