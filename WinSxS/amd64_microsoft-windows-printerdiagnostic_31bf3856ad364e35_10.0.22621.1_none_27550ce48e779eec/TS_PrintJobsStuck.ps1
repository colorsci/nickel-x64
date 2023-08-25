# Copyright © 2008, Microsoft Corporation. All rights reserved.
PARAM($printerName)

. .\CL_Utility.ps1

#
# check the current user's print jobs of the printer user selected. If these jobs exists, print jobs are stuck
#

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_ts_printJobsStuck

#
# Opens the printer and gets the jobs
#
$JOB_STATUS_PAUSED = 1
$JOB_STATUS_ERROR = 2
$JOB_STATUS_DELETING = 4
$JOB_STATUS_BLOCKED_DEVQ = 512
$JOB_STATUS_USER_INTERVENTION = 1024
$reportJobs = @{}

try
{

	$printer = Get-WmiObject -Class Win32_Printer -ErrorAction Stop | Where-Object {$_.Name -eq $printerName }

	if ($printer -ne $null)
	{
		$reportJobs = @(Get-WmiObject -Class Win32_PrintJob -ErrorAction Stop | Where-Object {$_.Name.Split(",")[0] -ieq $printerName -and `
				($_.StatusMask -band $JOB_STATUS_PAUSED -or $_.StatusMask -band $JOB_STATUS_ERROR -or $_.StatusMask -band `
				$JOB_STATUS_DELETING -or $_.StatusMask -band $JOB_STATUS_BLOCKED_DEVQ -or $_.StatusMask -band $JOB_STATUS_USER_INTERVENTION)})
	}

	if($reportJobs.Count -gt 0)
	{
		Update-DiagRootCause -id "RC_PrintJobsStuck" -Detected $true -parameter @{ "PRINTERNAME" = $printerName}
		$reportJobs | select-object -Property @{Name=$localizationString.printJobs_printerName; Expression={$printerName}}, @{Name=$localizationString.printJobs_userName; Expression={$_.Owner}}, @{Name=$localizationString.fileName; Expression={$_.Document}}, @{Name=$localizationString.printJobs_status; Expression={$_.JobStatus}} | convertto-xml | Update-DiagReport -id PrintJobs -name $localizationString.printJobs_name -verbosity Informational -rid "RC_PrintJobsStuck"
	} else {
		Update-DiagRootCause -id "RC_PrintJobsStuck" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
	}

}
catch [System.Exception]
{
	# Failed to query jobs 
	Write-ExceptionTelemetry "MAIN" $_
	Update-DiagRootCause -id "RC_PrintJobsStuck" -Detected $false -parameter @{ "PRINTERNAME" = $printerName}
}