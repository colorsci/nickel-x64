# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Look for forced shutdown events fired during recovery (since those could mean we are in an unrecoverable state)

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_indexingServiceFailedRecovery

$event = get-winevent -LogName application -FilterXPath "*[System[Provider[@Name='Search'] and (EventID=7042)]]" -ErrorAction SilentlyContinue | where { $_.Message -like "*recovery*" }
if ($event -ne $null -and $event.Count -gt 0)
{
    Update-DiagRootCause -id "RC_ForcedShutdownInRecovery" -Detected $true
    $event | convertto-xml | Update-DiagReport -id IndexerEvent -name $localizationString.indexerEvent_name -description $localizationString.indexerEvent_description -verbosity Error -rid "RC_ForcedShutdownInRecovery"
} else {
    Update-DiagRootCause -id "RC_ForcedShutdownInRecovery" -Detected $false
}
