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
. .\CL_Invocation.ps1
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
try
{
	Get-AudioManager
	$is_DefaultID = [Microsoft.Windows.Diagnosis.AudioConfigManager]::IsEndPointDefault($deviceID, $deviceType)
    [string]$id = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetDefaultID($deviceType)
	$volume = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetDeviceVolume($deviceID)

		if($deviceType -eq "Render")
		{
			$input = Get-DiagInput -id "IT_ChangeVolumeSH" -Parameter @{'ID' = $id}
		}

		if($deviceType -eq "Capture")
		{
			$input = Get-DiagInput -id "IT_ChangeVolumeM"  -Parameter @{'ID' = $id}
		}

	$deviceID | Select-Object -Property @{Name=$localizationString.modifiedVolume;Expression={[string]($volume) + "%"}} | ConvertTo-Xml | Update-DiagReport -id CurrentVolumeLevel -name $localizationString.CurrentVolumeLevel_name -description (($localizationString.ModifiedVolumeLevel_description) -f (Get-DeviceName $deviceType)) -Verbosity Informational
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_ChangeVolume" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_ChangeVolume" -Name "RS_ChangeVolume" -Verbosity Debug
}
