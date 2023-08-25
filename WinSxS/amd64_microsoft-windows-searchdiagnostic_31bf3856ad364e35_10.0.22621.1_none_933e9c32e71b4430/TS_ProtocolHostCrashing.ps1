# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Search Protocol Host process has crashed at least once in the last 24 hours

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_protocolHostCrashing

$date = Date
$date = $date.AddDays(-1)
$event = get-winevent -FilterHashTable @{ ProviderName = 'Application Error'; StartTime = $date; Data="SearchProtocolHost.exe"; Id = 1000 } -ErrorAction SilentlyContinue

if ($event -ne $null -and $event.Count -gt 0)
{
    Update-DiagRootCause -id "RC_ProtocolHostCrashing" -Detected $true
    $event | convertto-xml | Update-DiagReport -id ProtocolHostEvent -name $localizationString.protocolHostEvent_name -description $localizationString.protocolHostEvent_description -verbosity Error -rid "RC_ProtocolHostCrashing"
} else {
    Update-DiagRootCause -id "RC_ProtocolHostCrashing" -Detected $false
}
