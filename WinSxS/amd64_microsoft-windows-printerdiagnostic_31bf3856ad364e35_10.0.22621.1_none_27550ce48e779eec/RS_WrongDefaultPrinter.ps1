# Copyright © 2008, Microsoft Corporation. All rights reserved.

PARAM($printerName)
#
# Set the printer of user selected as the default printer
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_wrongDefaultPrinter

$oldDefaultPrinter = Get-WmiObject -query "Select * From Win32_Printer Where default=true"

$printerSelected = GetPrinterFromPrinterName $printerName
$printerSelected.SetDefaultPrinter()

$newDefaultPrinter = Get-WmiObject -query "Select * From Win32_Printer Where default=true"


$oldDefaultPrinterName = ""
if($oldDefaultPrinter -ne $null)
{
    $oldDefaultPrinterName = $oldDefaultPrinter.Name
}

$obj = New-Object -TypeName System.Management.Automation.PSObject
Add-Member -InputObject $obj -MemberType NoteProperty -Name "oldDefaultPrinter" -Value $oldDefaultPrinterName
Add-Member -InputObject $obj -MemberType NoteProperty -Name "newDefaultPrinter" -Value $newDefaultPrinter.Name
$obj | select-object -Property @{Name=$localizationString.defaultPrinter_oldDefaultPrinter; Expression={$_.oldDefaultPrinter}}, @{Name=$localizationString.defaultPrinter_newDefaultPrinter; Expression={$_.newDefaultPrinter}} | convertto-xml | Update-DiagReport -id DefaultPrinter -name $localizationString.defaultPrinter_name -verbosity Informational
