# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This script is invoked either from TS_Main.ps1 or from Troubleshooter (msdt.exe)
# TS_Main.ps1 passes only $problemDeviceID parameter whereas msdt will pass both $problemDeviceID and $action (as 'Verify')
# This script is to detect only error code 22 (DISABLED)
# This script will be invoked even if a Known driver error is detected and resolution applied already.

Param($problemDeviceID, $action)
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_Disabled -FileName CL_LocalizationData
[bool]$detected = $false
#====================================================================================
# Main
#====================================================================================
. .\CL_Utility.ps1

if(![string]::IsNullOrWhiteSpace($problemDeviceID))
{
    $problemDevice = (Get-WmiObject -Class CIM_LogicalDevice | ?{($_.DeviceID -eq $problemDeviceID)})
    $problemDeviceName = $problemDevice.Name
    $errorCode = $problemDevice.ConfigManagerErrorCode
    if($errorCode -eq 22)
    {
        $detected = $true
    }
}

[string]$propertyName = ''

if($detected)
{
    Update-DiagRootCause -ID 'RC_Disabled' -IID $problemDeviceID -Detected $detected -Parameter @{'ProblemDeviceID' = $problemDeviceID; 'ProblemDeviceName' = $problemDeviceName}
    $propertyName = "DetectedDeviceDisabled"
}
else
{
    if ($action -eq 'Verify')
    {
        Update-DiagRootCause -id RC_Disabled -IID $problemDeviceID -Detected $false -Parameter @{'ProblemDeviceID'= $problemDeviceID; 'ProblemDeviceName'= $problemDeviceName}
        $propertyName = "VerifyDeviceDisabled"
    }
}

if($propertyName.Length -gt 0)
{
    GetDeviceInfoAndWriteTrace $problemDeviceID $propertyName
}

return $detected