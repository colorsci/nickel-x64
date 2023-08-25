# Copyright ?2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Check the Power Off bit of the Availability property of the printer user selected
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Get-DiagInput  -id "IT_PrinterTurnedOff" -Parameter @{ "PRINTERNAME" = $printerName}