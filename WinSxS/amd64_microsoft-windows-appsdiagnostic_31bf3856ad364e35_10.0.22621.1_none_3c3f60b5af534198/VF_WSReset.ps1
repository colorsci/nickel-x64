# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

PARAM($DateProblemDetected)

#====================================================================================
# Initialize
#====================================================================================
$APP_DELETE_EVENT_ID = 41
$APP_CREATE_EVENT_ID = 39
$APP_STATUS_EVENT_ID = 70
$PACKAGE_STATUS_MASK_BAD = @{0x00000001 = "LICENSE_ISSUE"; 0x00000002 = "MODIFIED_PACKAGE"; 0x00000100 = "MODIFIED_STATE"; 0x00000200 = "MODIFIED_DATA"; 0x00000004 = "TAMPERED"}

function Get-AppContainerEvents([System.DateTime]$StartDate)
{ 
    return Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-AppModel-Runtime/Admin';id=$APP_DELETE_EVENT_ID,$APP_CREATE_EVENT_ID,$APP_STATUS_EVENT_ID;StartTime=$StartDate} -ErrorAction SilentlyContinue
}

function Get-UniqueAppNames($Events)
{
    $faultyApps = New-Object System.Collections.ArrayList

    if ($Events.Count -gt 0)
    {
        $i = 0
        foreach ($event in $Events)
        {
            $i++
            if ($event.Message -match ".*[ ](.*?)[.](.*?)_")
            {
                $faultyApps += "$($Matches[2])"
            }
        }
    }

    $faultyApps = $faultyApps | Select -Unique
    $faultyApps
}

function Get-AppResetComplete($Events, $AppName)
{
    $AppDeleteEvent = $Events | Where-Object {$_.message.contains("$AppName") -eq $true -and $_.id -eq $APP_DELETE_EVENT_ID}
    $AppCreateEvent = $Events | Where-Object {$_.message.contains("$AppName") -eq $true -and $_.id -eq $APP_CREATE_EVENT_ID}
    $AppStatusEvent = $Events | Where-Object {$_.message.contains("$AppName") -eq $true -and $_.id -eq $APP_STATUS_EVENT_ID} | Sort-Object TimeCreated -Descending | Select-Object -first 1
    
    # Compare current package status against bitmask
    $IsPackageDamaged = ($PACKAGE_STATUS_MASK_BAD.Keys | where { $_ -band $AppStatusEvent.Properties[2].value}).Count -gt 0

    return ($AppDeleteEvent -ne $null -and $AppCreateEvent -ne $null -and $IsPackageDamaged -eq $false)
}

#====================================================================================
# Main
#====================================================================================

$AppContainerEvents = Get-AppContainerEvents -StartDate $DateProblemDetected
$UniqueAppNames = Get-UniqueAppNames $AppContainerEvents

$AppRepairComplete = $false

foreach ($AppName in $UniqueAppNames)
{
    $AppRepairStatus = Get-AppResetComplete $AppContainerEvents $AppName
    if ($AppRepairStatus -eq $true)
    {
        $AppRepairComplete = $true
        break
    }
}

Update-DiagRootCause -Id 'RC_WSReset' -Detected (-not $AppRepairComplete)