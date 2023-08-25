# Copyright ?2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Power Off bit of the Availability property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_printerTurnedOff

[int]$PRINTER_STATUS_OFFLINE = 0x00000080

[int]$printStatus = GetPrinterStatus $printerName

if($printStatus -band $PRINTER_STATUS_OFFLINE)
{
    Update-DiagRootCause -id "RC_PrinterTurnedOff" -Detected $true -parameter @{ "PRINTERNAME" = $printerName}

} else {
    Update-DiagRootCause -id "RC_PrinterTurnedOff" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
}
