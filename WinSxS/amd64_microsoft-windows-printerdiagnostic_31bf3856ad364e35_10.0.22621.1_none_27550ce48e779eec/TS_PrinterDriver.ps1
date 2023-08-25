# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check whether the printer driver needs be updated
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_printerDriver

[int]$PRINTER_STATUS_DRIVER_UPDATE_NEEDED = 0x04000000

[int]$printStatus = GetPrinterStatus $printerName

if($printStatus -band $PRINTER_STATUS_DRIVER_UPDATE_NEEDED)
{
    Update-DiagRootCause -id "RC_PrinterDriver" -parameter @{ "PRINTERNAME" = $printerName } -Detected $true
} else {
    Update-DiagRootCause -id "RC_PrinterDriver" -parameter @{ "PRINTERNAME" = $printerName } -Detected $false
}
