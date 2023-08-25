# Copyright ?2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Power Off bit of the Availability property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

#
# Restart the spooler service to sync up with the latest printer status.
#
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

try
{
	# Wait 5 seconds so that the Spooler service can sync up the latest printer status.
	Start-Sleep -Seconds 5
	[int]$PRINTER_STATUS_OFFLINE = 0x00000080

	[int]$printStatus = GetPrinterStatus $printerName

	if($printStatus -band $PRINTER_STATUS_OFFLINE)
	{
		Update-DiagRootCause -id "RC_PrinterTurnedOff" -Detected $true -parameter @{ "PRINTERNAME" = $printerName}

	} else {
		Update-DiagRootCause -id "RC_PrinterTurnedOff" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
	}
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
}