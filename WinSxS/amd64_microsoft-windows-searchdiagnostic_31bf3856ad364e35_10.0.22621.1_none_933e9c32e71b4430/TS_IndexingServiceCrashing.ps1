# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Windows Search service has crashed at least once in the last 24 hours

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_indexerCrashing

$date = Date
$date = $date.AddDays(-1)
$event = get-winevent -FilterHashTable @{ ProviderName = 'Application Error'; StartTime = $date; Data="SearchIndexer.exe"; Id = 1000 } -ErrorAction SilentlyContinue

if ($event -ne $null -and $event.Count -gt 0)
{
    Update-DiagRootCause -id "RC_IndexingServiceCrashing" -Detected $true
    $event | convertto-xml | Update-DiagReport -id IndexerEvent -name $localizationString.indexerEvent_name -description $localizationString.indexerEvent_description -verbosity Error -rid "RC_IndexingServiceCrashing"
} else {
    Update-DiagRootCause -id "RC_IndexingServiceCrashing" -Detected $false
}
