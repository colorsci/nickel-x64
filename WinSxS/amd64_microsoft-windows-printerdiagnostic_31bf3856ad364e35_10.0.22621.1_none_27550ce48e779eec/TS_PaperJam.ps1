# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Jammed bit of the DetectedErrorState property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_paperJam

[int]$PRINTER_STATUS_PAPER_JAM = 0x00000008

[int]$printStatus = GetPrinterStatus $printerName

if($printStatus -band $PRINTER_STATUS_PAPER_JAM)
{
    Update-DiagRootCause -id "RC_PaperJam" -Detected $true
} else {
    Update-DiagRootCause -id "RC_PaperJam" -Detected $false
}
