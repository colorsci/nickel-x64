# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
#====================================================================================

# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -activity $localizationString.audioDeviceDriver_progress

try 
{
	$devices = Get-WmiObject Win32_SoundDevice
} 
catch [System.Exception]
{
	Write-ExceptionTelemetry "TS_AudioDeviceDriver_MAIN" $_
	$_
}

if ($devices -eq $null) 
{
	Update-DiagRootCause -ID 'RC_AudioDevice' -Detected $true -Parameter @{'DEVICEID' = 'ScanOnly'}
	return $false
}

[int]$errDeviceCount = 0
# $deviceCount contains total number of audio devices in system
[int]$deviceCount = ($devices.Name).Count
$found = $true

foreach ($device in $devices) 
{
	if ($device.ConfigManagerErrorCode -ne 0) {
		$deviceID = $device.PNPDeviceID.Replace("&", "&amp;");
		$allDevices = $allDevices + "#" + $deviceID 
		$detected = $true
		$errDeviceCount++
	}
}

if($detected)
{
	Update-DiagRootcause -ID 'RC_AudioDevice' -IID $deviceID -Detected $true -Parameter @{'DEVICEID' = $allDevices}
}

if($errDeviceCount -eq $deviceCount)
{
	$found =  $false
}
Write-DiagProgress -activity " "
return $found