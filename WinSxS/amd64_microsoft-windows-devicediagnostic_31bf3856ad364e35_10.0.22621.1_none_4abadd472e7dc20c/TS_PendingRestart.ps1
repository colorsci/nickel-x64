# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RC_PendingRestart checks whether system is pending restart

	ARGUMENTS:
	  
	RETURNS:
	  Bool value True if system is pending restart else False 
#>
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_DetectingDevice.ps1
. .\CL_Utility.ps1

#================================================================================
# Initialize
#==================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
$detected = $false
#================================================================================
# Checking for Pending System Reboot. 
#================================================================================
try
{
    $isrebootRequired = Get-PnpDevice | Get-PnpDeviceProperty -KeyName 'DEVPKEY_Device_IsRebootRequired' | Where {$_.Data -eq $true}
	if((CheckForReboot -eq $True) -or($isrebootRequired.Count -gt 0))
	{
	#================================================================================
	# Root Cause RC_PendingRestart is detected if CheckForReboot is true or isrebootRequired count is available.
	#===============================================================================
			$detected = $True
	}
	Update-DiagRootCause -id RC_PendingRestart -Detected $detected
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_PendingRestart" $null $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_PendingRestart" -Name "RC_PendingRestart" -Verbosity Debug
}

return $detected

