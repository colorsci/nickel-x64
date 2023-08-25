# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  VF_RescanAllDevices Verifier Script to check Re-Scan devices status
	ARGUMENTS:
	  
	RETURNS:
#>
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.Resolution_RescanAllDevices
$Rescan = RescanAllDevices
if($Rescan -eq "0")
{
   $detected = $false
}
else
{
	$detected = $true
}

 Update-DiagRootCause -id RC_RescanAllDevices -Detected $detected
