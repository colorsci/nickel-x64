# Copyright © 2008, Microsoft Corporation. All rights reserved.

#trap {break}

## Check whether the system time is accurate

#Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
#. .\CL_Utility.ps1

## Function to parse the strip data with time server
#function Parse-OffsetData($offsetData = $(throw "No offset data is specified"))
#{
#    if($offsetData -eq $null)
#    {
#        return $null
#    }

#    $result = @()
#    [string]$pattern = "\d{2,}:\d{2}:\d{2},\W([+-]\d{2,})\.\d{7}s"
#    $offsetData.GetEnumerator() | ForEach-Object {
#        if(($_ -match $pattern) -and ($matches[1] -ne $null))
#        {
#            $result += [long]$matches[1]
#        }
#    }

#    return $result
#}

## Function to check whether the system time is accurate
#function Test-Offset([int]$offset = $(throw "No offset is specified"))
#{
#    [int]$maxOffset = (5 * 60)
#    return ([Math]::Abs($offset) -lt $maxOffset)
#}

## Function to check whether the system time is accurate
#Function Check-TimeAccurateness([string]$timeServer = $(throw "No time source is specified"))
#{

#    [bool]$checked = $false
#    if(-not[String]::IsNullOrEmpty($timeServer))
#    {
#        (ping.exe $timeServer /n 2) | Out-Null
#        if($LASTEXITCODE -eq 0)
#        {
#            [int]$sampleCount = 1
#            [DateTime]$accurateion = [DateTime]::Now

#            $offsetData = (w32tm.exe /stripchart /computer:$timeServer /dataonly /samples:$sampleCount)
#            (Parse-OffsetData $offsetData) | Foreach-Object {
#                if(-not(Test-Offset $_))
#                {
#                    $timeDifference = $_
#                    $accurateion = [DateTime]::Now.Add([TimeSpan]::FromSeconds($_))

#                    New-Object -TypeName System.Management.Automation.PSObject | Select-Object -Property @{Name=$localizationString.timeServerName;Expression={$timeServer}},@{Name=$localizationString.samplesCollected;Expression={$sampleCount}},@{Name=$localizationString.serverTime;Expression={$accurateion.ToString()}},@{Name=$localizationString.localTime;Expression={[DateTime]::Now}},@{Name=$localizationString.timeDifference;Expression={"$timeDifference" + "s"}} |
#                        ConvertTo-Xml | Update-DiagReport -id TimeServer -Name $localizationString.timeDelayAgainstTimeServer_name -Verbosity Informational -rid "RC_InaccurateSystemTime"
#                    $checked = $true

#                    Update-DiagRootCause -id "RC_InaccurateSystemTime" -Detected $true -parameter @{'AccurateTime'=$accurateion.ToString()}
#                } else {
#                    Update-DiagRootCause -id "RC_InaccurateSystemTime" -Detected $false -parameter @{'AccurateTime'=$accurateion.ToString()}
#                    $checked = $true
#                }
#            }
#        }
#    }

#    return $checked
#}

## function to get the startup type of a serivce
#function GetServiceStartupType([string]$serviceName) {
#    [string]$state = "Disabled"

#    [WMI]$service = @(Get-WmiObject -Query "Select * From Win32_Service Where Name = `"$serviceName`"")[0]
#    if($null -ne $service) {
#        $state = $service.StartMode
#    }

#    return $state
#}

#Write-DiagProgress -activity $localizationString.checkSystemTime_progress

#if("Disabled" -eq (GetServiceStartupType "W32time")) {
#    return
#}

#[bool]$timeServiceStatus = Get-ServiceStatus "w32time"
#try {
#    if(-not($timeServiceStatus)) {
#        Start-Service "w32time"
#        WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Running)
#    }

#    [string]$timeServerInfo = (w32tm.exe /query /source)
#    if($LASTEXITCODE -ne 0)
#    {
#        return
#    }

#    [string]$timeServer = $timeServerInfo.Split(',', [StringSplitOptions]::RemoveEmptyEntries)[0].Trim()
#    if(-not(Check-TimeAccurateness $timeServer))
#    {
#        $timeServer = "time.windows.com"
#        [bool]$checked = Check-TimeAccurateness $timeServer
#        if(-not($checked)) {
#            [DateTime]$accurateion = [DateTime]::Now
#            Update-DiagRootCause -id "RC_InaccurateSystemTime" -Detected $false -parameter @{'AccurateTime'=$accurateion.ToString()}
#        }
#    }
#} finally {
#    if(-not($timeServiceStatus)) {
#        Stop-Service "w32time"
#        WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Stopped)
#    }
#}