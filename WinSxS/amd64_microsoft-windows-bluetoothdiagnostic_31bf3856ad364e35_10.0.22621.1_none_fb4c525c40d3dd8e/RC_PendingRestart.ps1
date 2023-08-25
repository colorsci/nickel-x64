# Copyright © 2018, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
    DESCRIPTION:
      RC_PendingRestart checks whether system is pending restart

    ARGUMENTS:

    RETURNS:
      Bool value True if system is pending restart else False
#>
# :: ======================================================= ::

# Initialize
$detected = $false

# Checking for Pending System Reboot. 
try
{
    $isRebootRequired = Get-PnpDevice -Class Bluetooth | Get-PnpDeviceProperty -KeyName 'DEVPKEY_Device_IsRebootRequired' | Where {$_.Data -eq $true}
    if($isRebootRequired -ne $null)
    {
        # Root Cause RC_PendingRestart is detected if isRebootRequired is available.
        $detected = $True
    }
    Update-DiagRootCause -id "RC_PendingRestart" -Detected $detected
}
Catch [System.Exception]
{
    Write-ExceptionTelemetry "RC_PendingRestart" $null $_
    $errorMsg =  $_.Exception.Message
    $errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_PendingRestart" -Name "RC_PendingRestart" -Verbosity Debug
}

return $detected