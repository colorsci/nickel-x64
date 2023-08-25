# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceID, $deviceType)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Common Library
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $localizationString.unmute_progress

try
{
	Get-AudioManager
	$UnMute = [Microsoft.Windows.Diagnosis.AudioConfigManager]::SetDeviceMuteStatus($deviceID, $false)

}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_Unmute" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_Unmute" -Name "RS_Unmute" -Verbosity Debug
}