# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  RS_APOLoadFailure resolves the audio device issues caused by 3rd party enhancement.

	ARGUMENTS:
	  deviceID: String value contains audio device ID 
	  deviceCount: Integer value contains count of audio devices

	RETURNS:
	  None
#>

#====================================================================================
# Initialize
#====================================================================================
Param($deviceIDs, $deviceCount)

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_AudioDiagnosticSnapIn.ps1
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -activity " "
$PNPDeviceArray = $deviceIDs.Split('|')
foreach($PNPDevice in $PNPDeviceArray)
{
	if(!([String]::IsNullOrEmpty($PNPDevice)))
	{
		# Applicable if two or more identical devices are installed.
		$PNPDeviceIDs = $PNPDevice.Split(' ')
		foreach($PNPDeviceID in $PNPDeviceIDs)	
		{
			RemoveDevice $PNPDeviceID | Out-Null
			ReinstallDevice $PNPDeviceID | Out-Null
		}
	}
}

RescanAllDevices | Out-Null

[int]$audioCount = Get-AudioDeviceCount
if(!($audioCount -eq $deviceCount))
{
	get-diaginput -id "INT_RebootSystem"
	return
}