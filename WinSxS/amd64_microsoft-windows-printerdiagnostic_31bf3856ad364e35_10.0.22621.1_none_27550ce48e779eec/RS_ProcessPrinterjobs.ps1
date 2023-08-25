# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# Resume or cancel the print jobs of printer user selected
#

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_ProcessCurrentPrintJobs

$JOB_STATUS_PAUSED = 1
$JOB_STATUS_ERROR = 2
$JOB_STATUS_DELETING = 4
$JOB_STATUS_BLOCKED_DEVQ = 512
$JOB_STATUS_USER_INTERVENTION = 1024

$printJobs = @()

try
{
	$printJobs = @(Get-WmiObject -Class Win32_PrintJob -ErrorAction Stop | Where-Object {$_.Name.Split(",")[0] -ieq $printerName -and `
				($_.StatusMask -band $JOB_STATUS_PAUSED -or $_.StatusMask -band $JOB_STATUS_ERROR -or $_.StatusMask -band `
				$JOB_STATUS_DELETING -or $_.StatusMask -band $JOB_STATUS_BLOCKED_DEVQ -or $_.StatusMask -band $JOB_STATUS_USER_INTERVENTION)})

	if($printJobs.Count -gt 0)
	{
		#
		# Resume the print jobs if it's paused, delete the rest of jobs 
		#
	
		foreach ($job in $printJobs)
		{
			if ($job.StatusMask -band $JOB_STATUS_PAUSED)
			{
				$job.Resume()
			}
			else
			{
				$job.Delete()
			}
		}
	}
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
} 



