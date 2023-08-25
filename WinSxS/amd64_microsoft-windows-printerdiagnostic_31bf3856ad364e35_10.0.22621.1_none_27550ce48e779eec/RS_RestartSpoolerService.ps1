# Copyright © 2008, Microsoft Corporation. All rights reserved.


#
# Restart the spooler service.
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1
Write-DiagProgress -activity $localizationString.progress_rs_restartSpoolerService

[string]$faxStatus = (Get-Service Fax).Status
try
{
    Restart-Service Spooler -Force
    WaitFor-ServiceStatus "Spooler" ([ServiceProcess.ServiceControllerStatus]::Running)
}
finally
{
    if($faxStatus -eq "Running")
    {
        Start-Service Fax
        WaitFor-ServiceStatus "Fax" ([ServiceProcess.ServiceControllerStatus]::Running)
    }
}
