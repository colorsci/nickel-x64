# Copyright ?2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Cancel all print jobs
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_cancelAllJobs

try
{
	$printerSelected = GetPrinterFromPrinterName $printerName
	if($printerSelected -eq $null)
	{
		return
	}

	#
	# Cancel the current print jobs of the printer user selected
	#

	$printerSelected.CancelAllJobs()
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
}