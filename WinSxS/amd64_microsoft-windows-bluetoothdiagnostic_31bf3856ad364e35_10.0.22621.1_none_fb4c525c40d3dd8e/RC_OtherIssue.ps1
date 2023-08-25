# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This script is invoked from TS_Main.ps1
# TS_Main.ps1 passes only $problemDeviceID parameter
# This script is to detect error codes NOT defined in CL_Utility.ps1 and !errorCode22

Param($problemDeviceID)
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_OtherIssue -FileName CL_LocalizationData
[bool]$detected = $false

#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================

if(![string]::IsNullOrWhiteSpace($problemDeviceID))
{
    $problemDevice = (Get-WmiObject -Class CIM_LogicalDevice | ? {($_.DeviceID  -eq $problemDeviceID)})
    $problemDeviceName = $problemDevice.Name
    $errorCode = $problemDevice.ConfigManagerErrorCode
    if(($knownErrorCodes.Keys -notcontains $errorCode) -and ($errorCode -ne 22))
    {
        $detected = $true
        GetDeviceInfoAndWriteTrace $problemDeviceID "DetectedDeviceOtherError"
    }
}

Update-DiagRootCause -ID 'RC_OtherIssue' -IID $problemDeviceID -Detected $detected -Parameter @{'ProblemDeviceID'= $problemDeviceID;'ProblemDeviceName'=$problemDeviceName;'ErrorCode'=$errorCode}

return $detected