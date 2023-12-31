# Copyright ?2008, Microsoft Corporation. All rights reserved.


#
# Start the spooler service 
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1
Write-DiagProgress -activity $localizationString.progress_rs_startSpoolerService

$spoolersvc = Get-WMIObject Win32_Service | Where-Object {$_.Name -eq "spooler"}

if($spoolersvc.State -ne "Running")
{
    Start-Service Spooler
    WaitFor-ServiceStatus "Spooler" ([ServiceProcess.ServiceControllerStatus]::Running)
}

#
# Start WIA
#
$stisvc = Get-WMIObject Win32_Service | Where-Object {$_.Name -eq "stisvc"}

if($stisvc.State -ne "Running")
{
    Start-Service StiSvc
    WaitFor-ServiceStatus "StiSvc" ([ServiceProcess.ServiceControllerStatus]::Running)
}
