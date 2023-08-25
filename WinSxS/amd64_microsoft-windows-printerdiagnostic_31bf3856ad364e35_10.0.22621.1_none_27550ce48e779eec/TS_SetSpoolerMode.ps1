# Copyright ?2008, Microsoft Corporation. All rights reserved.


#
# Check the status of the spooler service. If the start mode of the service is not set to Auto, add the root cause.
#

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_ts_SpoolerService

$spoolersvc = Get-WMIObject Win32_Service | Where-Object {$_.Name -eq "spooler"}

if($spoolersvc.StartMode -ne "Disabled")
{
    #
    # Restart the spooler service
    #
    Restart-Service -name Spooler -Force
}

if($spoolersvc.StartMode -ne "Auto")
{
    Update-DiagRootCause -id "RC_SpoolerStartMode" -Detected $true
}
else
{
    Update-DiagRootCause -id "RC_SpoolerStartMode" -Detected $false
}

#
# Check WIA as well.
#
$stisvc = Get-WMIObject Win32_Service | Where-Object {$_.Name -eq "stisvc"}

if($stisvc.StartMode -ne "Disabled")
{
    Restart-Service -name StiSvc -Force
}
