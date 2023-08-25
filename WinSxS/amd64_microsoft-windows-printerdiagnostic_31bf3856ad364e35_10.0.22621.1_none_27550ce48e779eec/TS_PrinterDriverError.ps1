# Copyright © 2008, Microsoft Corporation. All rights reserved.
PARAM($printerName)

. .\CL_Utility.ps1
#
# Check whether the printer driver has encountered an error
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_ts_printerDriverError

$pName = $printerName.Replace("\","\\")
$pnpEntity = Get-WmiObject -Query "Select * from Win32_PnpEntity where Name='$pName'" -ErrorAction SilentlyContinue

if($pnpEntity -eq $null)
{
	Update-DiagRootCause -id "RC_PrinterDriverError" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
    return
}

if($pnpEntity.ConfigManagerErrorCode -ne 0)
{
    $PnPDeviceID = $pnpEntity.PNPDeviceID.Replace("&", "&amp;")
    Update-DiagRootCause -id "RC_PrinterDriverError" -Detected $true -parameter @{ "PRINTERNAME" = $printerName; "DEVICEID" = $PnPDeviceID}
} else {
    Update-DiagRootCause -id "RC_PrinterDriverError" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
}
