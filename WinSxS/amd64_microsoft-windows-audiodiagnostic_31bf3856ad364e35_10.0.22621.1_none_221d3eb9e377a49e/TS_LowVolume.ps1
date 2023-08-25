# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION
	  TS_LowVolume validates whether the selected audio device is set to low volume.

	ARGUMENTS
	  deviceType : Contains string value of specific Audio device type selected.
	  deviceID : Contains string value of specific Audio device ID selected. 

	RETURNS
	  result : Boolean value $true if audio volume is low else $false  
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceType, $deviceID)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Common Library
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
[bool]$result = $false
[bool]$detected = $false
[int]$currentVolume = -1

Write-DiagProgress -Activity $localizationString.lowVolume_progress

try
{
	Get-AudioManager
	$volume = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetDeviceVolume($deviceID)

		if(($volume -le 10) -and ($volume -gt -1))
		{
			$result = $true
		}

		if([String]::IsNullOrEmpty($deviceType))
		{
			$deviceID | Select-Object -Property @{Name=$localizationString.currentVolume;Expression={[string]($volume) + "%"}} | ConvertTo-Xml | Update-DiagReport -id CurrentVolumeLevel -name $localizationString.CurrentVolumeLevel_name -description (($localizationString.CurrentVolumeLevel_description) -f (Get-DeviceName $deviceType)) -Verbosity Informational -rid "RC_LowVolume"
		}

		if($result)
		{
			$detected = $true
			Write-DiagProgress -Activity " "
			Update-DiagRootCause -id 'RC_LowVolume' -Detected $detected -Parameter @{'DeviceType' = $deviceType; 'DeviceID' = $deviceID; 'Volume' = $currentVolume}
		}
	
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "TS_LowVolume" -Name "TS_LowVolume" -Verbosity Debug
}

return $detected
