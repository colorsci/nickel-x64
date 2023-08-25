# Copyright © 2008, Microsoft Corporation. All rights reserved.


#
# Please user add a non-virutal printer as default printer.
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_noPrinterInstalled


$printers = Get-WmiObject Win32_Printer

Get-DiagInput  -id "IT_AddPrinter"

$newPrinters = Get-WmiObject Win32_Printer

if($newPrinters -eq $null)
{
    return
}

foreach($newPrinter in $newPrinters)
{
    $isNewPrinter = $true
    foreach($printer in $printers)
    {
        if($newPrinter.Name -eq $printer.Name)
        {
            $isNewPrinter = $false
        }
    }
    if($isNewPrinter)
    {
        $newPrinter | select-object -Property @{Name=$localizationString.newPrinter_printerName; Expression={$_.Name}} | convertto-xml | Update-DiagReport -id NewPrinter -name $localizationString.newPrinter_name -verbosity Informational
        break
    }
}

