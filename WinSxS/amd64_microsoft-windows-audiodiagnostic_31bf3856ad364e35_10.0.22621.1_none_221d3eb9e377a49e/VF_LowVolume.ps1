# Copyright © 2015, Microsoft Corporation. All rights reserved.
#*=================================================================================

<#
	DESCRIPTION
	  VF_LowVolume validates whether the low volume of audio device is fixed or not.

	ARGUMENTS
	  deviceType : Contains string value of specific Audio device type selected.
	  deviceID : Contains string value of specific Audio device ID selected. 
	  volume : Contains integer value of old percentage of volume of audio device.

	RETURNS
	  None 
#> 

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceType, $deviceID, $volume)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Common Library
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
[bool]$result = $true

Write-DiagProgress -activity $localizationString.lowVolume_progress

try 
{

	Get-AudioManager
	$volume = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetDeviceVolume($deviceID)

	if($volume -ge 10)
	{
		$result = $false
	}
	
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "VF_HDAudioDriver" $_
	$result = $true
} 

Write-DiagProgress -Activity " "
Update-DiagRootCause -ID "RC_LowVolume" -Detected $result 