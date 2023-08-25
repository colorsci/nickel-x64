# Copyright © 2008, Microsoft Corporation. All rights reserved.

PARAM($printerCount)
#
# Add the root cuase if no non-virtual printer existed
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_noPrinterInstalled

if($printerCount -eq $null)
{
    $printerCount = 0
}

$printers = Get-WmiObject Win32_Printer

if($printers -eq $null)
{
  Update-DiagRootCause -id "RC_NoPrinterInstalled" -Detected $true -parameter @{ "DEVICEID" = "ScanOnly"; "PRINTERCOUNT"=$printerCount}
  return
}

$htPrinter = @{}

foreach($printer in $printers)
{
    if(-not (IsVirtualPrinter $printer.DeviceID))
    {
        $htPrinter.Add($printer.Name, $printer)
    }
}

if($htPrinter.Count -lt 1 -or $htPrinter.Count -le  $printerCount)
{
    Update-DiagRootCause -id "RC_NoPrinterInstalled" -Detected $true -parameter @{ "DEVICEID" = "ScanOnly"; "PRINTERCOUNT"=$htPrinter.Count}

} else {
    Update-DiagRootCause -id "RC_NoPrinterInstalled" -Detected $false
}
