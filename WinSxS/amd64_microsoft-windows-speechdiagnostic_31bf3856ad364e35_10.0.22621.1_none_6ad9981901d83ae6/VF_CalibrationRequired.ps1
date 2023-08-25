# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
    DESCRIPTION:
    VF_CalibrationRequired.ps1 verifies whether the device is calibrated.

    ARGUMENTS:
    AdapterName: The name of the device which is being calibrated

    RETURNS:
    None
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($adapterName)

#====================================================================================
# Main
#====================================================================================
$detected = $false
if(test-path 'calibrationresult.log')
{
    $detected = ((Get-Content 'CalibrationResult.log' | ?{ $_ -match 'MicDiagnosticPass'}).Count -eq 0)
}
else
{
    $detected = $true
}

Update-DiagRootCause -ID 'RC_CalibrationRequired' -InstanceId ($adapterName) -Detected $detected