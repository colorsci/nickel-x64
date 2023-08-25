# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. .\CL_Service.ps1

# =============================================================
# Functions
# =============================================================

# Check whether the system time is accurate
# Function to parse the strip data with time server
function Parse-OffsetData($offsetData = $(throw "No offset data is specified"))
{
    if($offsetData -eq $null)
    {
        return $null
    }
    $result = @()
    [string]$pattern = "\d{2,}:\d{2}:\d{2},\W([+-]\d{2,})\.\d{7}s"
    $offsetData.GetEnumerator() | ForEach-Object {
		if(($_ -match $pattern) -and ($matches[1] -ne $null))
		{
			$result += [long]$matches[1]
		}
    }
    return $result
}

# Function to check whether the system time is accurate
function Test-Offset([int]$offset = $(throw "No offset is specified"))
{
    [int]$maxOffset = (5 * 60)
    return ([Math]::Abs($offset) -lt $maxOffset)
}

# Function to get time service status
function Get-ServiceStatus([string]$serviceName=$(throw "No service name is specified")) 
{
	[bool]$startService = $true
	[WMI]$timeService = @(Get-WmiObject -Query "Select * From Win32_Service Where Name = `"$serviceName`"")[0]
	if($null -ne $timeService) 
	{
		[ServiceProcess.ServiceControllerStatus]$timeServicesStatus = (Get-Service $serviceName).Status
		if(([ServiceProcess.ServiceControllerStatus]::Stopped -eq $timeServicesStatus) -or ([ServiceProcess.ServiceControllerStatus]::StopPending -eq $timeServicesStatus)) 
		{
			$startService = $false
		}
	}
	return $startService
}

# Function to check whether the system time is accurate
Function Check-TimeAccurateness([string]$timeServer = $(throw "No time source is specified"))
{
    [bool]$checked = $false
    if(-not[String]::IsNullOrEmpty($timeServer))
    {
        (ping.exe $timeServer /n 2) | Out-Null
        if($LASTEXITCODE -eq 0)
        {
            [int]$sampleCount = 1
            [DateTime]$accuration = [DateTime]::Now

            $offsetData = (w32tm.exe /stripchart /computer:$timeServer /dataonly /samples:$sampleCount)
            (Parse-OffsetData $offsetData) | Foreach-Object {
                if(-not(Test-Offset $_))
                {
                    $timeDifference = $_
                    $accuration = [DateTime]::Now.Add([TimeSpan]::FromSeconds($_))
                    $checked = $true
                    Update-DiagRootCause -Id "RC_DateTime" -Detected $true -Parameter @{'AccurateTime'=$accuration.ToString()}
                }
				else
				{
                    Update-DiagRootCause -Id "RC_DateTime" -Detected $false -Parameter @{'AccurateTime'=$accuration.ToString()}
                    $checked = $true
                }
            }
        }
    }
    return $checked
}

# function to get the startup type of a serivce
function GetServiceStartupType([string]$serviceName)
{
    [string]$state = "Disabled"
    [WMI]$service = @(Get-WmiObject -Query "Select * From Win32_Service Where Name = `"$serviceName`"")[0]
    if($null -ne $service) 
	{
        $state = $service.StartMode
    }
    return $state
}

# =============================================================
# Main
# =============================================================
$wmiObject = gwmi win32_computersystem
$isDomainJoined = $wmiObject.partofdomain

$startService = $true
$serviceName = 'W32time'
$service = @(Get-WmiObject -Query "Select * From Win32_Service Where Name = `"$serviceName`"")[0]
if($null -ne $service) 
{
	$serviceMode =  $service.StartMode
}

if(($serviceMode -eq 'Disabled') -and ($isDomainJoined -eq $true))
{
     return
}

[ServiceProcess.ServiceControllerStatus]$timeServicesStatus = (Get-Service $serviceName).Status
if(([ServiceProcess.ServiceControllerStatus]::Stopped -eq $timeServicesStatus) -or ([ServiceProcess.ServiceControllerStatus]::StopPending -eq $timeServicesStatus))
{
     $startService = $false
}

 try
 {
	if(-not($startService))
	{
		Set-Service w32time -StartupType Automatic -Status Running
		Start-Service "w32time"
		WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Running)
	}

	[string]$timeServerInfo = (w32tm.exe /query /source)
	if($LASTEXITCODE -ne 0)
	{
		return
	}
	[string]$timeServer = $timeServerInfo.Split(',', [StringSplitOptions]::RemoveEmptyEntries)[0].Trim()
	if(-not(Check-TimeAccurateness $timeServer))
	{
		$timeServer = "time.windows.com"
		[bool]$checked = Check-TimeAccurateness $timeServer
		if(-not($checked)) 
		{
			[DateTime]$accuration = [DateTime]::Now
			Update-DiagRootCause -Id "RC_DateTime" -Detected $false -Parameter @{'AccurateTime'=$accuration.ToString()} 
 		}
	}
} finally {
    if(-not($timeServicesStatus)) 
	{
        Stop-Service "w32time"
        WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Stopped)
    }
}
