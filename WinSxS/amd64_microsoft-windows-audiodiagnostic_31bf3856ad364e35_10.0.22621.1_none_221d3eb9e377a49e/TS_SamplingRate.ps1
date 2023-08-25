# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  RC_SamplingRate checks for audio sampling rate is set to default.

	ARGUMENTS:
	 deviceID : String value of Audio device ID

	RETURNS:
	  <&true> if root cause detected otherwise <$false>
#>
#====================================================================================
PARAM($deviceID)
#====================================================================================
# Initialize
#====================================================================================
$detected = $false
#*=================================================================================
# Load Utilities
#*=================================================================================
. .\CL_Utility.ps1
#==================================================================================
# Main
#==================================================================================
[bool]$result = $true
[bool]$detected = $false
$audioSampleResetFormat = Get-AudioEndpoints 

if(-not([String]::IsNullOrEmpty($deviceID)))
{
	# Verfiy whether current sampling rate of audio device
	try
	{
		$result = $audioSampleResetFormat::verifySamplingRate($deviceID)
		if($result)
		{
			$detected = $true
		}
	}
	catch [System.Exception]
	{
		Write-ExceptionTelemetry "MAIN" $_
	}
}
Update-DiagRootCause -id "RC_SamplingRate" -Detected $detected -Parameter @{"deviceID" = $deviceID} 
return $detected

