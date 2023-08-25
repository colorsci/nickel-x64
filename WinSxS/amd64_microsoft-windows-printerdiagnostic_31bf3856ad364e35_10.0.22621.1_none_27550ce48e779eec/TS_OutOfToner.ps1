# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Low Toner bit of the DetectedErrorState property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_outOfToner

[int]$PRINTER_STATUS_TONER_LOW = 0x00020000
[int]$PRINTER_STATUS_NO_TONER = 0x00040000

[int]$printStatus = GetPrinterStatus $printerName

if($printStatus -band $PRINTER_STATUS_TONER_LOW -or $printStatus -band $PRINTER_STATUS_NO_TONER)
{
    Update-DiagRootCause -id "RC_OutOfToner" -Detected $true

} else {
    Update-DiagRootCause -id "RC_OutOfToner" -Detected $false
}
