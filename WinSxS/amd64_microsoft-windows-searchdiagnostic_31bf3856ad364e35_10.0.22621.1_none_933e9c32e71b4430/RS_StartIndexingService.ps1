# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Start the indexing service and set the mode as automatic

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_startIndexingService

[string]$startupType = (Get-WmiObject -query "select * from win32_baseService where Name='WSearch'").StartMode


if($startupType -ne "auto")
{
    (Get-WmiObject -query "select * from win32_baseService where Name='WSearch'").changeStartMode("automatic")
}

Start-Service WSearch
