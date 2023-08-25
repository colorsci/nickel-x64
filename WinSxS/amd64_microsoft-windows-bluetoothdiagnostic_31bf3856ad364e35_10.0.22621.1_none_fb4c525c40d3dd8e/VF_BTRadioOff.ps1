# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This script is invoked from Troubleshooter (msdt.exe)
# This script is to verify the radio state after resetting it.
# Bluetooth radio state ($bluetoothRadioState) is updated in CL_Utility.ps1

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_VF_BTRadioOff -FileName CL_LocalizationData
$detected = $false
#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
# Apply the Resolution if the Radio state is either Off or Unknown.
$detected = $bluetoothRadioState -ne 'RadioState_On'

Update-DiagRootCause -ID 'RC_BTRadioOff' -Detected $detected -Parameter @{'BluetoothRadioState'= $bluetoothRadioState}
Write-DiagTelemetry -Property "VerifyRadioState" -Value $bluetoothRadioState

return $detected