# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================

###########################################################################
$Global:RootPath = $(Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Global:RootPath
. .\CL_WindowsUpdate.ps1
. .\CL_Utility.ps1

###########################################################################

$PackageName = "WindowsUpdate"
$PackageType = "ScriptedDiagnostic"

$SupportWaaSMedic = [System.Environment]::OSVersion.Version.Build -gt 17600

# =====================================================================
# Main
# =====================================================================

"IsPostback: $(Test-PostBack -S 'TS_Main')" | ConvertTo-Xml | Update-Diagreport -Id TS_Main -Name IsPostback_RC_PendingUpdates -Verbosity informational

# Start the windows update service if it is stopped
$wuService = Get-Service -name wuauserv -ErrorAction SilentlyContinue
if($wuService.Status -ne "Running")
{
    Set-Service -Name wuauserv -StartupType Automatic -Status Running -ErrorAction SilentlyContinue
    Get-Service -name wuauserv | ? {$_.StartType -eq 'Disabled'} | Set-Service -StartupType Automatic -Status Running
}

# Check for network connection. If no network then call the network pack
if (-not (Test-ConnectedToInternet))
{
    if([System.Environment]::OSVersion.Version.Build -gt 15000)
    {
        Write-DiagTelemetry -Property "WU:NetworkFailureDetected" -Value "Yes"
    }
    else
    {
        "WU:NetworkFailureDetected - Yes" | ConvertTo-Xml | Update-Diagreport -Id TS_Main -Name NetworkFailure -Verbosity informational
    }
    Update-DiagRootCause -Id RC_PendingUpdates -Parameter @{'ScanFailure' = $true} -Detected $true
} 
else
{
    if([System.Environment]::OSVersion.Version.Build -gt 15000)
    {
        Write-DiagTelemetry -Property "WU:NetworkFailureDetected" -Value "No"
    }
    else
    {
        "WU:NetworkFailureDetected - No" | ConvertTo-Xml | Update-Diagreport -Id TS_Main -Name NetworkFailure -Verbosity informational
    }
    $restartDetected = $false
    if((Check-WindowsVersion) -ge 100)
    {
        # Check if there is pending restart only in machines with Win10 and above
        $restartDetected = ./RC_PendingRestart.ps1
    }

    # If there is no pending restart and if connected to internet, check for updates
    if(!$restartDetected -and !$SupportWaaSMedic)
    {
        # Run this when WaaSMedic is not available.
        ./RC_PendingUpdates.ps1
    }
}

if((Test-PostBack -CurrentScriptName 'RC_TS_Main') -eq $true)
{
    # This is called 2nd time after remediation.  Do not run detection logic again.
    return;
}

# ======================================================================
# It will use WaaSMedic, if WaaSMedic support COM interface to fix update issue.
if ($SupportWaaSMedic)
{
    ./RC_WaaSMedic.ps1
    return;
}

# ======================================================================
# If WaaSMedic does not have COM interface support, use previous logics.

# Checking the system date and time
./RC_DateTime.ps1

# Checking the default registry path
./RC_AppData.ps1

# Check for the errorcodes
$allError = Get-AllErrorCodes

if($allError.Count -gt 0)
{
    if(![string]::IsNullOrEmpty($allError.Values))
    {
        $errorCodes = $allError.Values -join ';'
        ./RC_GenWUError.ps1 $errorCodes

        # Collection of files for the errorcodes
        ./RC_DataStore.ps1 $allError
    }
}
