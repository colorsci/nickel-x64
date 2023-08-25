# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This script is invoked either from TS_Main.ps1 or from Troubleshooter (msdt.exe)
# TS_Main.ps1 passes only $problemDeviceID parameter whereas msdt will pass both $problemDeviceID and $action (as 'Verify')
# This script is to detect Known error codes defined in CL_Utility.ps1

Param($problemDeviceID, $action)
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_DriverProblem -FileName CL_LocalizationData
[bool]$detected = $false
#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RC_DriverProblem.ID_PROG_DriverProblems

if(![string]::IsNullOrWhiteSpace($problemDeviceID))
{
    $problemDevice = (Get-WmiObject -Class CIM_LogicalDevice | ? {($_.DeviceID  -eq $problemDeviceID)})
    $problemDeviceName = $problemDevice.Name
    $errorCode =  $problemDevice.ConfigManagerErrorCode
    if($knownErrorCodes.Keys -contains $errorCode)
    {
        $detected = $true
    }
}

[string]$propertyName = ''

if($detected)
{
    Update-DiagRootCause -ID 'RC_DriverProblem' -IID $problemDeviceID -Detected $detected -Parameter @{'ProblemDeviceID'= $problemDeviceID; 'ProblemDeviceName'= $problemDeviceName}
    $propertyName = "DetectedDeviceError"
}
else
{
    if ($action -eq 'Verify')
    {
        Update-DiagRootCause -ID 'RC_DriverProblem' -IID $problemDeviceID -Detected $detected -Parameter @{'ProblemDeviceID'= $problemDeviceID; 'ProblemDeviceName'= $problemDeviceName}
        $propertyName = "VerifyDeviceError"
    }
}

if($propertyName.Length -gt 0)
{
    GetDeviceInfoAndWriteTrace $problemDeviceID $propertyName
}

return $detected