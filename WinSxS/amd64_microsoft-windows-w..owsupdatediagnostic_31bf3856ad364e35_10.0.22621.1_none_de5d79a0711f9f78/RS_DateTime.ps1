# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. .\CL_Service.ps1
. .\CL_SetupEnv.ps1

# =============================================================
# Functions
# =============================================================

# function to get time synchronization type
function GetTimeSyncType 
{
    [string]$result = ""
    [string]$registryKey = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
    [string]$registryKeyName = "Type"

    if(Test-Path $registryKey) 
	{
        $registryEntry = Get-Item -Path $registryKey
        if($null -ne $registryEntry) 
		{
            $result = $registryEntry.GetValue($registryKeyName)
        }
    }
    return $result
}

# function to update time synchronization type
function UpdateTimeSyncType([string]$type) 
{
    [string]$registryKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
    [string]$registryKeyName = "Type"

    [Microsoft.Win32.Registry]::SetValue($registryKey, $registryKeyName, $type)
}

# function to restart w32time service
function RestartW32timeService 
{
    try 
	{
        Stop-Service w32time
        WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Stopped)
    } finally {
        Start-Service w32time
        WaitFor-ServiceStatus "w32time" ([ServiceProcess.ServiceControllerStatus]::Running)
    }
}

# ==============================================================
# Main
# ==============================================================

# Time sync (time.windows.com is the default Windows time server)
if(Test-DomainJoined)
{
	if("NoSync" -eq (GetTimeSyncType)) {
        UpdateTimeSyncType "NT5DS"
    }
    RestartW32timeService

    w32tm.exe /resync /rediscover
}
else
{
	if("NoSync" -eq (GetTimeSyncType)) {
        UpdateTimeSyncType "NTP"
    }
    RestartW32timeService

    Update-TimeSource "time.windows.com"
    w32tm.exe /resync /force
}