# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:
		RC_RescanAllDevices check Re-Scan devices 
	ARGUMENTS:
	  
	RETURNS:
	  None
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
try
{
	[int]$devicesCount = GetPnPDeviceCount
	$detected = $false
	$Rescan = RescanAllDevices
	if($Rescan -eq "0")
	{
		[int]$countAfterScan = GetPnPDeviceCount
		if($countAfterScan -gt $devicesCount)
		{
			$detected = $true
		}
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_RescanAllDevices" $null $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_RescanAllDevices" -Name "RC_RescanAllDevices" -Verbosity Debug
}

Update-DiagRootCause -id RC_RescanAllDevices -Detected $detected
