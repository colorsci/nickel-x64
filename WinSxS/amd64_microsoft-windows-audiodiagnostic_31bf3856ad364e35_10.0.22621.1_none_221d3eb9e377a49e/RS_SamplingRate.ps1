# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_SamplingRate reset for audio sampling rate to default.

	ARGUMENTS:
	 deviceIDs : String value of Audio device ID

	RETURNS:
	  <&true> if root cause detected otherwise <$false>
#>
#====================================================================================
PARAM($deviceID)
#====================================================================================
# Initialize
#====================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. .\CL_Utility.ps1
#==================================================================================
# Main
#==================================================================================

$audioSampleResetFormat = Get-AudioEndpoints

# Verfiy whether current sampling rate of audio device

if(-not([String]::IsNullOrEmpty($deviceID)))
{	
	$temp = $audioSampleResetFormat::verifySamplingRate($deviceID)
	$result = $audioSampleResetFormat::resetSamplingRate($deviceID)
}