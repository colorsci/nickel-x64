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

Write-DiagProgress -Activity $Strings_Main.ID_Check_HEVCCodec

$isRootCauseDetected = $false

$hevc  = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*hevc media extension*" } | select DisplayName
$hevc1 = Get-AppxPackage *hevc* | select Name
$hevc2 = get-appxprovisionedpackage -online | Where { $_.DisplayName -like "*hevc*" } | select DisplayName

if (!$hevc -and !$hevc1 -and !$hevc2)
{
	$isRootCauseDetected = $true
}
		
if($isRootCauseDetected -eq $false)
{
	update-diagrootcause -id "RC_HevcCodecNotInstalled" -detected $false
}
else
{
	update-diagrootcause -id "RC_HevcCodecNotInstalled" -detected $true
}



