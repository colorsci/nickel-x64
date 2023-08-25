# Copyright ?2008, Microsoft Corporation. All rights reserved.

PARAM($printerName)

#
# Delete *.spl and *.shd files will remove all jobs from the printer queue first, and then delete all jobs using WMI.
#

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_deletePrintJobs

#
# Delete *.spl and *.shd files will remove all jobs from the printer queue
#
[string]$directory = GetSystemPath "\spool\printers"
[string]$dirsps = GetSystemPath "\spool\SERVERS"
[string]$directoryServer = $null
$printFiles = @(Get-ChildItem $directory | where-object -FilterScript { $_.Extension -eq ".spl" -or $_.Extension -eq ".shd" })

#
# Set the directory of print files to the SERVERS folder for network printers
#

$printer = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Name -eq $printerName }

if ($printer.Local -eq $false)
{
    $dirsvr = Get-ChildItem $dirsps | where-object -FilterScript { $printerName -like "*" + $_.Name + "*"}
    $directoryServer = $dirsvr.PSPath
    $printFiles += @(Get-ChildItem $directoryServer | where-object -FilterScript { $_.Extension -eq ".spl" -or $_.Extension -eq ".shd" })
}


if($printFiles.Count -gt 0)
{
	[string]$faxStatus = (Get-Service Fax).Status
	try
	{
		Stop-Service Spooler -Force
		WaitFor-ServiceStatus "Spooler" ([ServiceProcess.ServiceControllerStatus]::Stopped)
		$printFiles | foreach { Remove-Item $_.FullName }
	}
	finally
	{
		Start-Service Spooler
		WaitFor-ServiceStatus "Spooler" ([ServiceProcess.ServiceControllerStatus]::Running)
		if($faxStatus -eq "Running")
		{
			Start-Service Fax
			WaitFor-ServiceStatus "Fax" ([ServiceProcess.ServiceControllerStatus]::Running)
		}
	}

	#
	# update report
	#

	$notDeletedFiles = @(Get-ChildItem $directory | where-object -FilterScript { $_.Extension -eq ".spl" -or $_.Extension -eq ".shd" })


	if (($printer.Local -eq $false) -and ($directoryServer -ne $null))
	{
		$notDeletedFiles += @(Get-ChildItem $directoryServer | where-object -FilterScript { $_.Extension -eq ".spl" -or $_.Extension -eq ".shd" })
	}

	$deletedFileNames = New-Object System.Collections.ArrayList
	$notDeletedFileNames = New-Object System.Collections.ArrayList

	if($notDeletedFiles.Count -eq 0)
	{
		foreach($file in $printFiles)
		{
			$deletedFileNames += $file.Name
		}
	}
	else
	{
		foreach($file in $printFiles)
		{
			[bool]$notDeleted = $false
			foreach($notDeletedfile in $notDeletedFiles)
			{
				if($file.Name -eq $notDeletedFile.Name)
				{
					$notDeleted = $true
					break
				}
			}
			if($notDeleted)
			{
				$notDeletedFileNames += $file.Name
			}
			else
			{
				$deletedFileNames += $file.Name
			}
		}
	}

	if($deletedFileNames.Length -gt 0)
	{
		$deletedFileNames | select-object -Property @{Name=$localizationString.fileName; Expression={$_}} | convertto-xml | Update-DiagReport -id DeletedFiles -name $localizationString.deletedFiles_name -verbosity Informational
	}

	if($notDeletedFileNames.Length -gt 0)
	{
		$notDeletedFileNames | select-object -Property @{Name=$localizationString.fileName; Expression={$_}} | convertto-xml | Update-DiagReport -id CannotDeletedFiles -name $localizationString.cannotDeletedFiles_name -description $localizationString.cannotDeletedFiles_description -verbosity Informational
	}
}

#
# First try to delete current user's jobs in case that the user does not have permissions to delete all jobs, then try to delete all.
#

$printer = Get-WmiObject -Class Win32_Printer -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $printerName }
if ($printer -ne $null)
{
	try
	{
		Get-WmiObject -Class Win32_PrintJob -ErrorAction Stop | Where-Object {$_.Name.Split(",")[0] -ieq $printerName -and $_.Owner -eq $env:USERNAME } | ForEach-Object {$_.Delete()}		
		Get-WmiObject -Class Win32_PrintJob -ErrorAction Stop | Where-Object {$_.Name.Split(",")[0] -ieq $printerName} | ForEach-Object {$_.Delete()}
	}
	catch [System.Exception]
	{
		Write-ExceptionTelemetry "MAIN" $_
	}	
}


