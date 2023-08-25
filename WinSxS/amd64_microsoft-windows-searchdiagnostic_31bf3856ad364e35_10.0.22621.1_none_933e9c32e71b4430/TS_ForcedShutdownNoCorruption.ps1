# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Look for forced shutdown events that do not involve corruption (since those do not automatically force Restore Defaults)

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_indexingServiceForcedShutdown

$event = get-winevent -LogName application -FilterXPath "*[System[Provider[@Name='Search'] and (EventID=7042)]]" -ErrorAction SilentlyContinue | where { $_.Message -notlike "*corrupt*" }
if ($event -ne $null -and $event.Count -gt 0)
{
    Update-DiagRootCause -id "RC_ForcedShutdownNoCorruption" -Detected $true
    $event | convertto-xml | Update-DiagReport -id IndexerEvent -name $localizationString.indexerEvent_name -description $localizationString.indexerEvent_description -verbosity Error -rid "RC_ForcedShutdownNoCorruption"
} else {
    Update-DiagRootCause -id "RC_ForcedShutdownNoCorruption" -Detected $false
}
