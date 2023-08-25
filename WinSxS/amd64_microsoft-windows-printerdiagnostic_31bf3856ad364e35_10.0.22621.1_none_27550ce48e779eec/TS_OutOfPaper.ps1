# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Low Paper bit of the DetectedErrorState property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_outOfPaper

[int]$PRINTER_STATUS_PAPER_OUT = 0x00000010

[int]$printStatus = GetPrinterStatus $printerName

if($printStatus -band $PRINTER_STATUS_PAPER_OUT)
{
    Update-DiagRootCause -id "RC_OutOfPaper" -Detected $true
} else {
    Update-DiagRootCause -id "RC_OutOfPaper" -Detected $false
}
