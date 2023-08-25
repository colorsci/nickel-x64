# Copyright ?2008, Microsoft Corporation. All rights reserved.


#
# Check the status of the spooler service. If the service is not running, add the root cause.
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_ts_SpoolerService

$spoolersvc = Get-WMIObject Win32_Service | Where-Object {$_.Name -eq "spooler"}


if($spoolersvc.State -ne "Running")
{
    Update-DiagRootCause -id "RC_SpoolerService" -Detected $true
	return $true
}
else
{
	Update-DiagRootCause -id "RC_SpoolerService" -Detected $false
	return $false
}
