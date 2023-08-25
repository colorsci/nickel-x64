# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
# This is the main script for Bluetooth Troubleshooter.
# This invokes several other scripts to check Bluetooth capabilities and
# several driver errors.
#
# Workflow:
#  RC_CheckBT --> Checks whether the machine has a Bluetooth device present on the system
#  RC_PendingRestart --> Checks whether any bluetooth device requires restart.
#  RC_DriverProblem --> Checks whether any driver has any known driver issue, for which the
#                       solution already exists in the machine and apply the solution.
#  RC_Disabled --> Checks whether any driver is disabled and apply the solution.
#  RC_Otherissue --> Check whether driver has any other issue (not mitigated by RC_DriverProblem
#                    and RC_Disabled) and inform the user to contact oem of the respective
#                    driver.
#  RC_BTRadioOff --> This script will toggle the radio as a last measure to fix the trouble,
#                    if there are no issues found by the above script.
#
#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData
$problemDeviceIDs = $Null

#====================================================================================
# Main
#====================================================================================
if(-not(Test-PostBack -CurrentScriptName TS_Main))
{
    Write-DiagProgress -Activity $Strings_Main.ID_PROG_MAIN_Initializing

    # Checking for root causes
    $IsBluetoothNotExist = .\RC_CheckBT
    if($IsBluetoothNotExist -eq $true)
    {
        #Get the list of unknown USB devices
        $unknownDevices = Get-PnpDevice -class USB | Where-Object ({$_.Present -eq $true -and $_.HardwareID -contains 'USB\DEVICE_DESCRIPTOR_FAILURE' -or
                                                                    $_.HardwareID -contains 'USB\SET_ADDRESS_FAILURE' -or $_.HardwareID -contains 'USB\\UNKNOWN'})
        if($unknownDevices -ne $null)
        {
            $unknownDeviceProperties = Get-DeviceNodeProperties $unknownDevices

            #Get all the Bluetooth devices matching ClassGuid NOT present in the host machine
            $btDevices = Get-PnpDevice -Class Bluetooth | Where-Object ({$_.Present -eq $false -and $_.ClassGuid -eq '{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}' -and
                                                                        ($_.HardwareID.ToUpper().StartsWith("BTH") -eq $false)})
            if($btDevices -ne $null)
            {
                $bluetoothDeviceProperties = Get-DeviceNodeProperties $btDevices

                foreach($unknownDeviceProperty in $unknownDeviceProperties)
                {
                    $foundMatch = $false
                    foreach($unknownDeviceLocationPath in $unknownDeviceProperty.LocationPaths)
                    {
                        foreach($bluetoothDeviceProperty in $bluetoothDeviceProperties)
                        {
                            if($bluetoothDeviceProperty.LocationPaths -contains $unknownDeviceLocationPath)
                            {
                                [string] $propertyValue = ($bluetoothDeviceProperty.DeviceInstanceId + ';' + $bluetoothDeviceProperty.RadioAddress + ';' + $bluetoothDeviceProperty.IsPresent + ';' +
                                                           $bluetoothDeviceProperty.InstallDate + ';' + $bluetoothDeviceProperty.HasProblem + ';' + $bluetoothDeviceProperty.ProblemCode + ';' +
                                                           $bluetoothDeviceProperty.LocationPaths)
                                Write-DiagTelemetry -Property "PossibleBluetoothRadio" -Value $propertyValue
                                $foundMatch = $true
                            }
                        }
                    }

                    if($foundMatch -eq $true)
                    {
                        [string] $propertyValue = ($unknownDeviceProperty.DeviceInstanceId + ';' + $unknownDeviceProperty.RadioAddress + ';' + $unknownDeviceProperty.IsPresent + ';' +
                                                   $unknownDeviceProperty.InstallDate + ';' + $unknownDeviceProperty.HasProblem + ';' + $unknownDeviceProperty.ProblemCode + ';' +
                                                   $unknownDeviceProperty.LocationPaths)
                        Write-DiagTelemetry -Property "UnknownDevice" -Value $propertyValue
                    }
                }
            }
        }
    }
    else
    {
        [int] $btRadioCount = (Get-RadioCount)
        Write-DiagTelemetry -Property "RadioCount" -Value $btRadioCount
        $IsRebootRequired = .\RC_PendingRestart
        if($IsRebootRequired -eq $false)
        {
            $problemDeviceIDs = Get-BluetoothRootCauses
            foreach($problemDeviceID in $problemDeviceIDs.Keys)
            {
                .\RC_DriverProblem.ps1 $problemDeviceID
                .\RC_Disabled.ps1 $problemDeviceID
                .\RC_Otherissue.ps1 $problemDeviceID
            }

            if($btRadioCount -eq 1)
            {
                [string]$deviceInstanceId = (Get-RadioInstanceId)
                GetDeviceInfoAndWriteTrace $deviceInstanceId "HostRadioInfo"

                # Toggle/Reset Bluetooth, if only one radio present.
                # If there are more than one radio present, toggling the radio
                # will make any one radio active nondeterministically.
                .\RC_BTRadioOff
            }
        }
    }
}