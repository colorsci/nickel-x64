# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
# Parameters
#*=================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
# Run detection logic
#*=================================================================================

Write-DiagProgress -Activity $Strings_Main.ID_Check_HWDRM

$isRootCauseDetected = $false
$pfHWDRMSupported    = 0;

$hr = [VideoDiagnostic.VideoConfigManager]::IsHWDRMSupported([ref]$pfHWDRMSupported)

if (!$pfHWDRMSupported -or $hr)
{
	$isRootCauseDetected = $true
}
		
if($isRootCauseDetected -eq $false)
{
	update-diagrootcause -id "RC_HWDRMNotSupported" -detected $false
}
else
{
	update-diagrootcause -id "RC_HWDRMNotSupported" -detected $true
}



