
# Copyright © 2018, Microsoft Corporation. All rights reserved.
# ============================================================= 

#.... Load Utilities

. ./utils_SetupEnv.ps1

Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData

Write-DiagProgress -Activity $Strings_Main.ID_PROG_MAIN_Initializing

$Response = Get-DiagInput -Id "IT_VideoSettings"

if ($Response -eq 0)
{
	if(-not(Test-PostBack -CurrentScriptName TS_Main))
	{
		.\RC_viddrv_unsigned.ps1 
		.\RC_viddrv_msvideo.ps1
		.\RC_viddrv_displaytopology.ps1
		.\RC_viddrv_driverblocklist.ps1
		.\RC_viddrv_hwdrmcheck.ps1
		.\RC_viddrv_hevccodeccheck.ps1
		.\RC_aud_reg_settings.ps1
	}
}
else
{
	#send telemetry event
	Write-DiagTelemetry -Property "SkipTroubleshooter" -Value $Response
	start ms-settings:$Response
}
