# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This script is invoked from TS_Main.ps1
# If Bluetooth radio NOT found, then it rest of the scripts (like RC_BTRadioOff, RC_DriverProblem etc) will NOT be invoked.

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_CheckBT -FileName CL_LocalizationData 
$radioNotDetected = $false

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RC_CheckBT.ID_Check_Bluetooth

$findBluetooth=( Get-WmiObject -Class CIM_LogicalDevice | ? {($_.ClassGuid -eq '{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}')})
$radioNotDetected = !$findBluetooth
Write-DiagTelemetry -Property "RadioAvailable" -Value (!$radioNotDetected)
Update-DiagRootCause -ID 'RC_CheckBT' -Detected $radioNotDetected

return $radioNotDetected