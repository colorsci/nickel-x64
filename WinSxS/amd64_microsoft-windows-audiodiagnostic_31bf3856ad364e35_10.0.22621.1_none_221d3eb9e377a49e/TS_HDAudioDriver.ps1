# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  TS_HDAudioDriver checks if audio driver is HD driver or not and detects two rootcause

	ARGUMENTS:
	 deviceType : Name of the device type selected
	 deviceID	: String value of Audio device ID

	RETURNS:
	  <&true> if root cause detected otherwise <$false>
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceName,$deviceID,$deviceType)

#*=================================================================================
# Load Utilities
#*=================================================================================
. .\CL_Utility.ps1
#=================================================================================
# Main
#==================================================================================

[string]$devName = ""
$detected = $false

$pnpdevname = $deviceName

$devicenm = Get-WmiObject Win32_SoundDevice -Filter "name= '$pnpdevname'"
foreach ($device in $devicenm)
{
	$devid = $device.PNPDeviceID
}
if(-not([String]::IsNullOrEmpty($devid)))
{
	$pnpSignedDriver = Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object -FilterScript {$_.DeviceID -eq $devid}
	$pnpDeviceID = $devid
	$infname = $pnpSignedDriver.InfName
	$infname = $infname.ToLower()
	if($infname.Contains("hdaudio"))
	{
		$pnpdevname | ConvertTo-Xml | Update-DiagReport -Id "TS_HDAudioDriver" -Name "TS_HDAudioDriver" -Description $devid -Verbosity Debug
		return
	}
	else
	{
		$detected = $true
		Update-DiagRootCause -id "RC_HDAudioDriver" -iid $pnpDeviceID -Detected $detected -parameter @{'DeviceType'= $deviceType; 'PNPDevName'= $pnpdevname; 'PNPDevID'= $pnpDeviceID; 'deviceID'= $deviceID}
	}
}

return $detected