# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

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
Write-DiagProgress -activity $localizationString.mute_progress

try 
{
	Get-AudioManager
	$muteValue = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetDeviceMuteStatus($deviceID)
	if($muteValue -eq $true)
	{
		$detected = $true
	}
	
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "TS_Mute" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "TS_Mute" -Name "TS_Mute" -Verbosity Debug
}

Update-DiagRootCause -id 'RC_Mute' -detected $detected -parameter @{'DeviceID'=$deviceID; 'DeviceType'= $deviceType}
Write-DiagProgress -activity " "
return $detected