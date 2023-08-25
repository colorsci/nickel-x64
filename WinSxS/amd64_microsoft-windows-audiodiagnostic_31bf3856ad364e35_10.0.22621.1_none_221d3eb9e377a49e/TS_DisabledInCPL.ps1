# Copyright © 2008, Microsoft Corporation. All rights reserved.
#*=================================================================================

<#
	DESCRIPTION
	  TS_DisabledInCPL verifies the audio device selected is currently disabled or not.

	ARGUMENTS
	  $deviceID: Contains string value of specific Audio device ID selected. 

	RETURNS
	  $result : Boolean value $true if audio device is disabled else $false 
#>

# =================================================================================
# Initialize
# =================================================================================
PARAM($deviceType,$deviceID)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# =================================================================================
# Load Utilities
# =================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
[bool]$result = $false
[bool]$detected = $false

Write-DiagProgress -activity $localizationString.disabledInCPL_progress

try {
	$AudioMethods = Get-AudioEndpoints
	$EndPointList = @()
	$EndPointList = $AudioMethods::GetAudioEndPointsbyType($deviceType)
 
	foreach($device in $EndPointList)
	{
	 if($device.DeviceId -eq $deviceID)
	 {
		$device | Select-Object -Property @{Name=$localizationString.state;Expression={Get-DeviceStateName ($_.State)}},@{Name=$localizationString.statusCode;Expression={$_.State}},@{Name=$localizationString.helpLink;Expression={"https://msdn.microsoft.com/en-us/library/aa363230(VS.85).aspx"}} | convertto-xml | Update-DiagReport -id AudioDeviceDisabled -name $localizationString.disabledInCPL_name -description $localizationString.disabledInCPL_description -Verbosity Informational -rid "RC_DisabledInCPL"
		# Get device State and check whether is value is equal to 2.
		$result = -not(($device.State -band 2) -eq 2)
		if(-not($result))
		{
			$detected = $true
		}
	 }
   }
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "TS_DisabledInCPL" -Name "TS_DisabledInCPL" -Verbosity Debug
} 

Update-DiagRootCause -id 'RC_DisabledInCPL' -Detected $detected -parameter @{'DeviceID' = $deviceID}
Write-DiagProgress -activity " "
return $result