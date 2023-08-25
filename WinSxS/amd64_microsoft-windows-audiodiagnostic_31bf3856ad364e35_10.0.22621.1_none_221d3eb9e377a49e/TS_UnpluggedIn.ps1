# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  TS_UnpluggedIn.ps1 checks whether audio device is plugged in on not.

	ARGUMENTS:
	  $deviceType: Type of the audio device which needs to be verified.
	  $deviceID: ID of the audio device which needs to be verified.

	RETURNS:
	  <&true> if audio device is plugged in otherwise <$false>
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceType, $deviceID)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
$result = $false

Write-DiagProgress -Activity $localizationString.unpluggedIn_progress

try 
{
	$AudioMethods = Get-AudioEndpoints
	$EndPointList = @()
	$EndPointList = $AudioMethods::GetAudioEndPointsbyType($deviceType)
	foreach($device in $EndPointList)
	{
	 if($device.DeviceId -eq $deviceID)
	 {
		$result = -not(($device.State -band 8) -eq 8)
	 }
	}
	
} 
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
}


[string]$deviceTypeName = Get-DeviceTypeName $deviceType

if(-not($result))
{
	Update-DiagRootCause -ID 'RC_UnpluggedIn' -Detected $true -Parameter @{'DeviceType' = $deviceTypeName; 'DeviceID' = $deviceID}
} 
else 
{
	Update-DiagRootCause -ID 'RC_UnpluggedIn' -Detected $false -Parameter @{'DeviceType' = $deviceTypeName; 'DeviceID' = $deviceID}
}

return $result