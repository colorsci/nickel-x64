# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
function Get-FaultyAppsFromEventLogs([System.DateTime]$StartDate)
{
    $events = Get-Eventlog -LogName Application -Source Microsoft-Windows-Immersive-Shell,"Application Error","Application Hang" -EntryType Error,Warning -After $StartDate `
                | Select-Object TimeGenerated,EntryType,Source,Message `
                | Sort-Object TimeGenerated

    $faultyApps = New-Object System.Collections.ArrayList

    if ($events.Count -gt 0)
    {
        $i = 0
        foreach ($event in $events)
        {
            $i++
            if ($event.Message -match ".*[ ](.*?)[.](.*?)_")
            {
                $faultyApps += "$($Matches[2])"
            }
        }
    }

    $faultyApps = $faultyApps | Select -Unique
    foreach ($App in $faultyApps)
    {
        Write-DiagTelemetry -Property "FaultyAppName" -Value $App
    }

    return $faultyApps.count
}

function Get-CompletedTroubleshooterSessions()
{ 
    return Get-WinEvent -FilterHashtable @{logname='microsoft-windows-diagnosis-scripted/operational';id=104} -ErrorAction SilentlyContinue
}

#====================================================================================
# Main
#====================================================================================

# Find MSDT session for AppsDiagnostic
$AppsDiagnosticSessions = Get-CompletedTroubleshooterSessions `
    | Where-Object {$_.message.contains("AppsDiagnostic") -eq $true} `
    | Sort-Object TimeCreated -Descending

$MostRecentAppsDiagnosticSession = $null
$CountAppFailuresSinceLastDiagnosticSession = 0

# Get the most recent session
if ($AppsDiagnosticSessions.Count -gt 0)
{
    # Apps troubleshooter has been run, filter app events to those since the last troubleshooter session
    $MostRecentAppsDiagnosticSession = $AppsDiagnosticSessions[0]
    $CountAppFailuresSinceLastDiagnosticSession = Get-FaultyAppsFromEventLogs -StartDate $MostRecentAppsDiagnosticSession.TimeCreated
}
else
{
    # First run of apps troubleshooter, filter app events to those within the last 30 days
    $CountAppFailuresSinceLastDiagnosticSession = Get-FaultyAppsFromEventLogs -StartDate ([System.DateTime]::Now).AddDays(-30)
}

if ($CountAppFailuresSinceLastDiagnosticSession -gt 0)
{
    $RootCauseDetectedTime = [System.DateTime]::Now
    Update-DiagRootCause -Id 'RC_WSReset' -Detected $true -param @{'DateProblemDetected'="$RootCauseDetectedTime"}
}
else
{
    Update-DiagRootCause -Id 'RC_WSReset' -Detected $false
}