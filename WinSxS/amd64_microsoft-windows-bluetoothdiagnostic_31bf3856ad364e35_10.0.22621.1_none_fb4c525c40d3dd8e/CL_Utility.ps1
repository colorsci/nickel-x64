# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#

    DESCRIPTION
    CL_Utility.ps1 is common library for Bluetooth troubleshooter.

    ARGUMENTS:
    None

    RETURNS:
    None

    FUNCTIONS
    Write-ExceptionTelemetry
    Rescan-Devices
    Reinstall-Device
    Remove-Device
    Reset-Bluetooth
    Reload-BluetoothStack
    Test-PostBack
    Get-BluetoothRootCauses
    Get-RadioInstanceId
    GetDeviceInfoAndWriteTrace
#>

Function Pop-Msg
{
    <#
    DESCRIPTION:
      This function will pop up a message box. This will be really helpful while debugging.

    Usage: Pop-Msg "Text"
    #>
    param([string]$msg ="message",
    [string]$ttl = "Title",
    [int]$type = 64)

    $popwin = new-object -comobject wscript.shell
    $null = $popwin.popup($msg,0,$ttl,$type)
    remove-variable popwin
}

Function Write-ExceptionTelemetry($FunctionName, [System.Management.Automation.ErrorRecord] $ex)
{
    <#
    DESCRIPTION:
      Writes script error information into telemetry stream
     
    EXAMPLE:
      try
      {
         0 / 0
      }
      catch [System.Exception]
      {
         Write-ExceptionTelemetry "DivideByZeroTest" $_
      }
    #>

    $ExceptionMessage = $ex.Exception.Message
    $ScriptFullPath = $ex.InvocationInfo.ScriptName
    $ExceptionScript = [System.IO.Path]::GetFileName($ScriptFullPath)
    $ExceptionScriptLine = $ex.InvocationInfo.ScriptLineNumber
    $ExceptionScriptColumn = $ex.InvocationInfo.OffsetInLine
    
    Write-DiagTelemetry "ScriptError" "$ExceptionScript\$FunctionName\$ExceptionScriptLine\$ExceptionScriptColumn\$ExceptionMessage"
}

#====================================================================================
# Initialize
#====================================================================================
Add-Type -TypeDefinition @"
    namespace BluetoothDiagnostics
    {
        using System;
        using System.Diagnostics;
        using System.Runtime.InteropServices;

        /// <summary>
        /// Bluetooth Config manager class
        /// </summary>
        public static class BluetoothConfigManager
        {
            /// <summary>
            /// Return Enums for the Bluetooth State
            /// </summary>
            private enum BluetoothState
            {
                RadioState_Unknown = 0,
                RadioState_On = 1,
                RadioState_Off = 2,
                RadioState_Disabled = 3
            }

            /// <summary>
            /// Method to set the Bluetooth state
            /// </summary>
            /// <param name="bSetbluetoothState"></param>
            /// <returns>S_OK  or 0 if successful, otherwise an error code </returns>
            /// Set the param to either true to turn ON the Bluetooth and false to turn it OFF
            [DllImport("BluetoothDiagnosticUtil.dll", CharSet = CharSet.Auto)]
            private static extern int SetBluetoothRadio(bool bSetbluetoothState);

            /// <summary>
            /// Method to query they Bluetooth state
            /// </summary>
            /// <param name="bGetbluetoothState"></param>
            /// <returns>Enum values of BluetoothState</returns>
            [DllImport("BluetoothDiagnosticUtil.dll", CharSet = CharSet.Auto)]
            private static extern int GetBluetoothState(ref BluetoothState bGetbluetoothState);

            /// <summary>
            /// Method to get the number of Bluetooth Radio currently present in the host machine
            /// </summary>
            /// <param name="radioCount"></param>
            /// <returns>Number of Bluetooth Radio currently present in the host machine</returns>
            [DllImport("BluetoothDiagnosticUtil.dll", CharSet = CharSet.Auto)]
            private static extern int GetBluetoothRadioCount(ref int radioCount);

            /// <summary>
            /// Method to get the device instance Id of Bluetooth Radio
            /// </summary>
            /// <param name="deviceInstanceId"></param>
            /// <returns>Device Instance Id corresponds to Bluetooth Radio</returns>
            /// <remarks>Returns the Bluetooth device instance id nondeterministically, if more than one Bluetooth radios are present.
            /// So call this api only if one Bluetooth radio is present.
            /// </remarks>
            [DllImport("BluetoothDiagnosticUtil.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
            private static extern int GetBluetoothInstanceId([MarshalAsAttribute(UnmanagedType.HString)] ref String deviceInstanceId);

            /// <summary>
            /// Sets the Bluetooth radio to the given state.
            /// </summary>
            /// <param name="SetBTOn">
            /// true, Sets radio state to On.
            /// false, Sets the radio state to Off.</param>
            /// <returns>S_OK  or 0 if successful, otherwise an error code</returns>
            public static int SetBluetoothState(bool SetBTOn)
            {
                return BluetoothConfigManager.SetBluetoothRadio(SetBTOn);
            }

            /// <summary>
            /// Returns the current Bluetooth radio state.
            /// </summary>
            /// <returns>RadioState_On, if the state is On.
            /// RadioState_Off, if the state is Off.
            /// Return value of GetBluetoothState() as string, in case of error.
            /// </returns>
            public static string GetBluetoothState()
            {
                BluetoothState Val = new BluetoothState();
                int result = BluetoothConfigManager.GetBluetoothState(ref Val);
                if(result == 0)
                {
                    Debug.WriteLine(Val.ToString());
                    return Val.ToString();
                }
                Debug.WriteLine(result.ToString());
                return result.ToString();
            }

            /// <summary>
            /// Returns the number of Bluetooth radio present in the machine
            /// </summary>
            /// <returns>
            /// Number of Bluetooth radios present.
            /// </returns>
            public static int GetBTRadioCount(ref int btRadioCount)
            {
                return BluetoothConfigManager.GetBluetoothRadioCount(ref btRadioCount);
            }

            /// <summary>
            /// Gets the device instance id of the Bluetooth radio present in the machine
            /// </summary>
            /// <param name="btDevIID">Bluetooth radio device instance Id</param>
            /// <returns>
            /// 0 for success, otherwise an error code.
            /// </returns>
            public static int GetBluetoothIId(ref String btDevIId)
            {
                String deviceInstanceId = String.Empty;
                int result = BluetoothConfigManager.GetBluetoothInstanceId(ref deviceInstanceId);
                if(result == 0)
                {
                    btDevIId = deviceInstanceId;
                }

                return result;
            }
        }
    }
"@

#Bluetooth Radio Status
try
{
    $bluetoothRadioState = [BluetoothDiagnostics.BluetoothConfigManager]::GetBluetoothState()
}
catch [System.Exception]
{
    Write-ExceptionTelemetry "MAIN" $_
    $_ | ConvertTo-Xml | Update-DiagReport -ID 'CL_Utility' -Name 'CL_Utility' -Verbosity Debug
}

#Driver Error Codes
$knownErrorCodes = New-Object System.Collections.HashTable
$knownErrorCodes.Add('1', '1')
$knownErrorCodes.Add('3', '3')
$knownErrorCodes.Add('10', '10')
$knownErrorCodes.Add('18', '18')
$knownErrorCodes.Add('19', '19')
$knownErrorCodes.Add('28', '28')
$knownErrorCodes.Add('31', '31')
$knownErrorCodes.Add('32', '32')
$knownErrorCodes.Add('37', '37')
$knownErrorCodes.Add('39', '39')
$knownErrorCodes.Add('40', '40')
$knownErrorCodes.Add('41', '41')
$knownErrorCodes.Add('43', '43')
$knownErrorCodes.Add('48', '48')
$knownErrorCodes.Add('50', '50')

#====================================================================================
# Functions
#====================================================================================

function Rescan-Devices()
{
$RescanAllDevicesSource = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_Rescan
    {
        private DeviceManagement_Rescan()
        {
        }

        public const UInt32 CR_SUCCESS = 0;
        public const UInt32 CM_REENUMERATE_SYNCHRONOUS = 1;
        public const UInt32 CM_LOCATE_DEVNODE_NORMAL = 0;
        public const UInt32 WAIT_OBJECT_0 = 0;
        public const UInt32 INFINITE = 0xFFFFFFFF;

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CM_Locate_DevNode_Ex", CharSet = CharSet.Auto)]
        static extern UInt32 CM_Locate_DevNode_Ex(ref UInt32 DevInst, IntPtr DeviceID, UInt32 Flags, IntPtr Machine);

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CM_Reenumerate_DevNode_Ex", CharSet = CharSet.Auto)]
        static extern UInt32 CM_Reenumerate_DevNode_Ex(UInt32 DevInst, UInt32 Flags, IntPtr Machine);

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CMP_WaitNoPendingInstallEvents", CharSet = CharSet.Auto)]
        static extern UInt32 CMP_WaitNoPendingInstallEvents(UInt32 TimeOut);

        public static UInt32 RescanAllDevices()
        {
            //only connect to local device nodes
            UInt32 ResultCode = 0;
            IntPtr LocalMachineInstance = IntPtr.Zero;
            UInt32 DeviceInstance = 0;
            UInt32 PendingTime = INFINITE;
            UInt32 PendingTimeDetecting = 100;
            UInt32 MaxTimes = 100;

            ResultCode = CM_Locate_DevNode_Ex(ref DeviceInstance, IntPtr.Zero, CM_LOCATE_DEVNODE_NORMAL, LocalMachineInstance);
            if (CR_SUCCESS == ResultCode)
            {
                ResultCode = CM_Reenumerate_DevNode_Ex(DeviceInstance, CM_REENUMERATE_SYNCHRONOUS, LocalMachineInstance);

                UInt32 Wait = 0;
                ResultCode = CMP_WaitNoPendingInstallEvents(PendingTimeDetecting);
                while (WAIT_OBJECT_0 == ResultCode)
                {
                    Wait++;
                    if (MaxTimes <= Wait)
                    {
                        break;
                    }

                    Thread.Sleep((int)PendingTimeDetecting);

                    ResultCode = CMP_WaitNoPendingInstallEvents(PendingTimeDetecting);
                }

                ResultCode = CMP_WaitNoPendingInstallEvents(PendingTime);
            }

            return ResultCode;
        }

    }
}
"@
    Add-Type -TypeDefinition $RescanAllDevicesSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_Rescan]

    $ErrorCode = $DeviceManager::RescanAllDevices()
    return $ErrorCode
}

function Reinstall-Device([string]$DeviceID)
{
$ReinstallDeviceSource = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_ReinstallSingleDevice
    {
        private DeviceManagement_ReinstallSingleDevice()
        {
        }

        public const UInt32 CR_SUCCESS = 0;
        public const UInt32 CM_REENUMERATE_SYNCHRONOUS = 1;
        public const UInt32 CM_REENUMERATE_RETRY_INSTALLATION = 2;
        public const UInt32 CM_LOCATE_DEVNODE_NORMAL = 0;
        public const UInt32 WAIT_OBJECT_0 = 0;
        public const UInt32 INFINITE = 0xFFFFFFFF;

        public const UInt32 CONFIGFLAG_REINSTALL = 32;
        public const UInt32 ERROR_CLASS_MISMATCH = 0xE0000203;
        public const UInt32 DEVPROP_TYPE_UINT32 = 0x00000007;
        public static DEVPROPKEY DEVPKEY_Device_ConfigFlags = new DEVPROPKEY(new Guid("a45c254e-df1c-4efd-8020-67d146a850e0"), 12);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiGetDeviceProperty", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiGetDeviceProperty(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, ref DEVPROPKEY PropertyKey, ref UInt32 PropertyType, IntPtr PropertyBuffer, UInt32 PropertyBufferSize, ref UInt32 RequiredSize, UInt32 Flags);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiSetDeviceProperty", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiSetDeviceProperty(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, ref DEVPROPKEY PropertyKey, UInt32 PropertyType, IntPtr PropertyBuffer, UInt32 PropertyBufferSize, UInt32 Flags);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiOpenDeviceInfo", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiOpenDeviceInfo(IntPtr DeviceInfoSet, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, IntPtr Parent, UInt32 Flags, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCreateDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern IntPtr SetupDiCreateDeviceInfoList(IntPtr ClassGuid, IntPtr Parent);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiDestroyDeviceInfoList", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiDestroyDeviceInfoList(IntPtr DevInfo);

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CM_Locate_DevNode_Ex", CharSet = CharSet.Auto)]
        static extern UInt32 CM_Locate_DevNode_Ex(ref UInt32 DevInst, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, UInt32 Flags, IntPtr Machine);

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CM_Reenumerate_DevNode_Ex", CharSet = CharSet.Auto)]
        static extern UInt32 CM_Reenumerate_DevNode_Ex(UInt32 DevInst, UInt32 Flags, IntPtr Machine);

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CMP_WaitNoPendingInstallEvents", CharSet = CharSet.Auto)]
        static extern UInt32 CMP_WaitNoPendingInstallEvents(UInt32 TimeOut);

        public struct DEVPROPKEY
        {
            public DEVPROPKEY(Guid InputId, UInt32 InputDevId)
            {
                DEVPROPGUID = InputId;
                DEVID = InputDevId;
            }
            public Guid DEVPROPGUID;
            public UInt32 DEVID;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct SP_DEVINFO_DATA
        {
            public UInt32 Size;
            public Guid ClassGuid;
            public UInt32 DevInst;
            public IntPtr Reserved;
        }

        public static UInt32 GetDeviceInformation(string DeviceID, ref IntPtr DevInfoSet, ref SP_DEVINFO_DATA DevInfo)
        {
            DevInfoSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            if (DevInfoSet == IntPtr.Zero)
            {
                return (UInt32)Marshal.GetLastWin32Error();
            }

            DevInfo.Size = (UInt32)Marshal.SizeOf(DevInfo);

            if(0 == SetupDiOpenDeviceInfo(DevInfoSet, DeviceID, IntPtr.Zero, 0, ref DevInfo))
            {
                SetupDiDestroyDeviceInfoList(DevInfoSet);
                return ERROR_CLASS_MISMATCH;
            }
            return 0;
        }

        public static void ReleaseDeviceInfoSet(IntPtr DevInfoSet)
        {
            SetupDiDestroyDeviceInfoList(DevInfoSet);
        }

        public static UInt32 ReinstallDevice(string DeviceID)
        {
            UInt32 ResultCode = 0;
            IntPtr LocalMachineInstance = IntPtr.Zero;
            UInt32 DeviceInstance = 0;
            UInt32 PendingTime = INFINITE;
            UInt32 PendingTimeDetecting = 100;
            UInt32 MaxTimes = 100;
            IntPtr DeviceInfoSet = IntPtr.Zero;

            SP_DEVINFO_DATA DeviceInfoData = new SP_DEVINFO_DATA();

            ResultCode = GetDeviceInformation(DeviceID, ref DeviceInfoSet, ref DeviceInfoData);
            if(0 != ResultCode)
            {
                return ResultCode;
            }

            UInt32 propertyType = 0;
            UInt32 bufferSize = 4;
            IntPtr propertyBuffer = Marshal.AllocHGlobal((int)bufferSize);
            if (0 != SetupDiGetDeviceProperty(DeviceInfoSet, ref DeviceInfoData, ref DEVPKEY_Device_ConfigFlags, ref propertyType, propertyBuffer, bufferSize, ref bufferSize, 0))
            {
                if (propertyType == DEVPROP_TYPE_UINT32)
                {
                    UInt32 propertyValue = (UInt32)Marshal.ReadInt32(propertyBuffer);
                    propertyValue = propertyValue | CONFIGFLAG_REINSTALL;

                    Marshal.WriteInt32(propertyBuffer, (int)propertyValue);

                    if (0 == SetupDiSetDeviceProperty(DeviceInfoSet, ref DeviceInfoData, ref DEVPKEY_Device_ConfigFlags, propertyType, propertyBuffer, bufferSize, 0))
                    {
                        ResultCode = (UInt32)Marshal.GetLastWin32Error();
                    }
                }
            }
            else
            {
                ResultCode = (UInt32)Marshal.GetLastWin32Error();
            }

            if (IntPtr.Zero != propertyBuffer)
            {
                Marshal.FreeHGlobal(propertyBuffer);
            }

            ResultCode = CM_Locate_DevNode_Ex(ref DeviceInstance, DeviceID, CM_LOCATE_DEVNODE_NORMAL, LocalMachineInstance);
            if (CR_SUCCESS == ResultCode)
            {
                ResultCode = CM_Reenumerate_DevNode_Ex(DeviceInstance, CM_REENUMERATE_SYNCHRONOUS | CM_REENUMERATE_RETRY_INSTALLATION, LocalMachineInstance);

                if (CR_SUCCESS == ResultCode) {
                    UInt32 Wait = 0;
                    ResultCode = CMP_WaitNoPendingInstallEvents(PendingTimeDetecting);
                    while (WAIT_OBJECT_0 == ResultCode)
                    {
                        Wait++;
                        if (MaxTimes <= Wait)
                        {
                            break;
                        }

                        Thread.Sleep((int)PendingTimeDetecting);

                        ResultCode = CMP_WaitNoPendingInstallEvents(PendingTimeDetecting);
                    }

                    ResultCode = CMP_WaitNoPendingInstallEvents(PendingTime);
                }
            }

            ReleaseDeviceInfoSet(DeviceInfoSet);

            return ResultCode;
        }
    }
}
"@
    Add-Type -TypeDefinition $ReinstallDeviceSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_ReinstallSingleDevice]

    $ErrorCode = $DeviceManager::ReinstallDevice($DeviceID)
    return $ErrorCode
}

function Remove-Device([string]$DeviceID)
{

$RemoveDeviceSource = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_Remove
    {
        public const UInt32 ERROR_CLASS_MISMATCH = 0xE0000203;

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiOpenDeviceInfo", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiOpenDeviceInfo(IntPtr DeviceInfoSet, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, IntPtr Parent, UInt32 Flags, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCreateDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern IntPtr SetupDiCreateDeviceInfoList(IntPtr ClassGuid, IntPtr Parent);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiDestroyDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern UInt32 SetupDiDestroyDeviceInfoList(IntPtr DevInfo);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiRemoveDevice", CharSet = CharSet.Auto)]
        public static extern int SetupDiRemoveDevice(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData);

        [StructLayout(LayoutKind.Sequential)]
        public struct SP_DEVINFO_DATA
        {
            public UInt32 Size;
            public Guid ClassGuid;
            public UInt32 DevInst;
            public IntPtr Reserved;
        }

        private DeviceManagement_Remove()
        {
        }

        public static UInt32 GetDeviceInformation(string DeviceID, ref IntPtr DevInfoSet, ref SP_DEVINFO_DATA DevInfo)
        {
            DevInfoSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            if (DevInfoSet == IntPtr.Zero)
            {
                return (UInt32)Marshal.GetLastWin32Error();
            }

            DevInfo.Size = (UInt32)Marshal.SizeOf(DevInfo);

            if(0 == SetupDiOpenDeviceInfo(DevInfoSet, DeviceID, IntPtr.Zero, 0, ref DevInfo))
            {
                SetupDiDestroyDeviceInfoList(DevInfoSet);
                return ERROR_CLASS_MISMATCH;
            }
            return 0;
        }

        public static void ReleaseDeviceInfoSet(IntPtr DevInfoSet)
        {
            SetupDiDestroyDeviceInfoList(DevInfoSet);
        }

        public static UInt32 RemoveDevice(string DeviceID)
        {
            UInt32 ResultCode = 0;
            IntPtr DevInfoSet = IntPtr.Zero;
            SP_DEVINFO_DATA DevInfo = new SP_DEVINFO_DATA();

            ResultCode = GetDeviceInformation(DeviceID, ref DevInfoSet, ref DevInfo);

            if (0 == ResultCode)
            {
                if (1 != SetupDiRemoveDevice(DevInfoSet, ref DevInfo))
                {
                    ResultCode = (UInt32)Marshal.GetLastWin32Error();
                }
                ReleaseDeviceInfoSet(DevInfoSet);
            }

            return ResultCode;
        }
    }
}
"@

    Add-Type -TypeDefinition $RemoveDeviceSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_Remove]

    $ErrorCode = $DeviceManager::RemoveDevice($DeviceID)
    return $ErrorCode
}

Function Reset-Bluetooth($bluetoothRadioState)
{
    [int] $resetResult = 0
    $bluetoothDiagnostics = [BluetoothDiagnostics.BluetoothConfigManager]
    if($bluetoothRadioState -eq 'RadioState_On')
    {
        $resetResult = $bluetoothDiagnostics::SetBluetoothState($false)
        if($resetResult -ne 0)
        {
            # If error encountered while turning Off the radio, then try to reload the stack
            return Reload-BluetoothStack
        }

        # Sleep for 1 seconds for the radio to turn Off
        Sleep 1
        $bluetoothRadioState = $bluetoothDiagnostics::GetBluetoothState()
    }

    if ($bluetoothRadioState -eq "RadioState_Off")
    {
        $resetResult = $bluetoothDiagnostics::SetBluetoothState($true)
        if($resetResult -ne 0)
        {
            # If error encountered while turning On the radio, then try to reload the stack
            return Reload-BluetoothStack
        }
    }

    if($bluetoothRadioState -eq "RadioState_Unknown")
    {
        [String] $deviceInstanceId = ""
        [int]$result = $bluetoothDiagnostics::GetBluetoothIId([ref]$deviceInstanceId)
        if($result -ne 0)
        {
            return $result
        }

        [string] $deviceParameterKeyName = "Device Parameters"
        [string] $radioStateOn = "2"
        [string] $radioStateOff = "4"

        [string] $deviceInstanceRegKeyRootPath = Join-Path Registry::HKLM\System\CurrentControlSet\Enum $deviceInstanceId
        [string] $deviceParameterPath = Join-Path ($deviceInstanceRegKeyRootPath) $deviceParameterKeyName
        [string] $currentRadioState = Get-ItemPropertyValue -Path ($deviceParameterPath) -Name "RadioState"

        Write-DiagTelemetry -Property "UnknownRadioStateRegistryValue" -Value $currentRadioState

        # This solution known to work only if the current RadioState is Off.
        if($currentRadioState -eq $RadioStateOff)
        {
            # Set the RadioState to 'On (2)'
            Set-ItemProperty -Path ($deviceParameterPath) -Name "RadioState" -Value $RadioStateOn -Force

            # Reload the Stack
            return Reload-BluetoothStack
        }
    }

    # Sleep for 2 seconds for the radio to turn On
    Sleep 2
    return $resetResult
}

Function Reload-BluetoothStack()
{
    $bluetoothDiagnostics = [BluetoothDiagnostics.BluetoothConfigManager]
    [String] $deviceInstanceId = ""
    [int]$result = $bluetoothDiagnostics::GetBluetoothIId([ref]$deviceInstanceId)
    if($result -ne 0)
    {
        return $result
    }

    Write-DiagTelemetry -Property "StackReload" -Value $deviceInstanceId

    $result = Disable-PnpDevice "$deviceInstanceId" -Confirm:$false
    if($result -ne 0)
    {
        return $result
    }

    # Sleep for 2 seconds for the device node to get disabled
    Sleep 2
    $result = Enable-PnpDevice "$deviceInstanceId" -Confirm:$false
    if($result -ne 0)
    {
        return $result
    }

    # Sleep for 2 seconds for the device node to get enabled
    Sleep 2
    $bluetoothRadioState = $bluetoothDiagnostics::GetBluetoothState()
    if ($bluetoothRadioState -eq "RadioState_Off")
    {
        $result = $bluetoothDiagnostics::SetBluetoothState($true)
        Sleep 2
    }

    return $result
}

Function Get-RadioCount()
{
    [int]$radioCount = 0
    [BluetoothDiagnostics.BluetoothConfigManager]::GetBTRadioCount([ref]$radioCount) | Out-Null
    return $radioCount
}

function Test-PostBack
{
    [CmdletBinding()]
    PARAM
    (
        [Alias('S')]
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $CurrentScriptName
    )
    PROCESS 
    {
        # Writing the trace to current directory
        $CurrentScriptName = ("{0}.temp" -f [System.IO.Path]::GetFileNameWithoutExtension($CurrentScriptName))

        if(Test-Path($CurrentScriptName))
        {
            return $true
        }

        'Executed' >> $CurrentScriptName
        return $false
    }
}

function Get-BluetoothRootCauses()
{
    <#
        DESCRIPTION:
        Checks if Bluetooth Driver has any errors.

        ARGUMENTS:
        None

        RETURNS:
        Device ID which has errors
    #>
    $HashRootCausesTable = New-Object System.Collections.HashTable
    if($HashRootCausesTable -eq $Null)
    {
        return $False
    }

    $PnPObjects = Get-WmiObject -Class CIM_LogicalDevice | ?{($_.ClassGuid -eq '{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}')}
    foreach($DeviceItem in $PnPObjects)
    {
        [string]$DeviceName = $DeviceItem.Name
        [string]$DeviceID = $DeviceItem.PNPDeviceID
        [string]$DeviceErrorCode = $DeviceItem.ConfigManagerErrorCode

        if(($DeviceName -eq $Null) -or ($DeviceID -eq $Null) -or ($DeviceErrorCode -eq $Null))
        {
            continue
        }

        if($DeviceID -eq '')
        {
            continue
        }
        # Checking Error Code 45 for not connected device for Windows 10
        if(($DeviceErrorCode -ne '0') -and ($DeviceErrorCode -ne '45'))
        {
            if($HashRootCausesTable.Contains($DeviceID) -eq $False)
            {
                $HashRootCausesTable.Add($DeviceID, $DeviceID)
            }
        }
    }
    return $HashRootCausesTable
}

Function Get-RadioInstanceId()
{
    <#
        DESCRIPTION:
        Returns the Bluetooth Radio instance Id

        ARGUMENTS:
        None

        RETURNS:
        Bluetooth Radio Instance Id

        NOTES: Should be called When only one radio is present
    #>
    [String] $deviceInstanceId = ""
    [BluetoothDiagnostics.BluetoothConfigManager]::GetBluetoothIId([ref]$deviceInstanceId) | Out-Null
    return $deviceInstanceId
}

Function GetDeviceInfoAndWriteTrace
{
    <#
        DESCRIPTION:
        Gets the PNPDeviceProperty matching in the given device instance id and
        writes them in telemetry

        ARGUMENTS:
        $deviceID --> Instance Id of the Device or Radio
        $propertyName --> Property name to be used while writing the telemetry

        RETURNS:
        NONE
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$deviceInstanceId,
        [Parameter(Mandatory=$true)]
        [string]$propertyName
    )

    #--------------------------------------------------------------------------------------
    # Index | Field Description
    #-------|------------------------------------------------------------------------------
    #   0   | Bluetooth Radio Address (This fields will be empty for Peripheral devices)
    #   1   | Bluetooth Peripheral Address (This fields will be empty for Host radios)
    #   2   | Presence of the Device
    #   3   | Install Date
    #   4   | Has Problem
    #   5   | Device Problem Code
    $deviceProperty = Get-PnpDeviceProperty -InstanceId $deviceInstanceId -KeyName 'DEVPKEY_Bluetooth_RadioAddress', 'DEVPKEY_Bluetooth_DeviceAddress',
                                                                                   'DEVPKEY_Device_IsPresent', 'DEVPKEY_Device_InstallDate',
                                                                                   'DEVPKEY_Device_HasProblem', 'DEVPKEY_Device_ProblemCode'

    [string]$hostRadioAddress = $deviceProperty[0].Data

    #Convert Peripheral address from Hex string to UInt64 string.
    [string]$peripheralAddress = ''
    if($deviceProperty[1].Data -ne $null)
    {
        try
        {
            $peripheralAddress = ([System.Convert]::ToUInt64($deviceProperty[1].Data, 16)).ToString()
        }
        catch
        {
            # do nothing
        }
    }
    [string]$isPresent = $deviceProperty[2].Data
    [string]$installDate = $deviceProperty[3].Data
    [string]$hasProblem = $deviceProperty[4].Data
    [string]$problemCode = $deviceProperty[5].Data

    #--------------------------------------------------------------------------------------
    # Index | Field Description
    #-------|------------------------------------------------------------------------------
    #   0   | DeviceInstanceId
    #   1   | Bluetooth Radio Address (This fields will be empty for Peripheral devices)
    #   2   | Bluetooth Peripheral Address (This fields will be empty for Host radios)
    #   3   | Presence of the Device
    #   4   | Install Date
    #   5   | Has Problem
    #   6   | Device Problem Code
    Write-DiagTelemetry -Property $propertyName -Value "$deviceInstanceId;$hostRadioAddress;$peripheralAddress;$isPresent;$installDate;$hasProblem;$problemCode"
}

class DeviceNodeProperty
{
    <#
        DESCRIPTION: Class containing the properties of Device node.
        This is used to get the properties of the device node matching the device instance id.

        Note: Currently only the following the properties are added which can be extended later.
    #>
    [string]$DeviceInstanceId
    [string]$RadioAddress
    [string]$IsPresent
    [string]$InstallDate
    [string]$HasProblem
    [string]$ProblemCode
    [System.Collections.ArrayList]$LocationPaths
}

Function Get-DeviceNodeProperties
{
    <#
        DESCRIPTION:
        Returns the list of DeviceNodeProperty of the host radio matching the instance ids

        ARGUMENTS:
        devices : Array of device instance Ids

        RETURNS:
        DeviceNodeProperty

        NOTE: If the LocationPaths for a device instance id is NULL (Eg, Remote device or Enumerators etc),
        then the device node properties for that device will NOT be added in the return list.

    #>
    param(
        [Parameter(Mandatory=$true)]
        [System.Array]$devices
    )

    $devNodeProperties = New-Object System.Collections.ArrayList
    foreach($device in $devices)
    {
        $deviceProperties = (Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_LocationPaths', 'DEVPKEY_Bluetooth_RadioAddress',
                                                                                           'DEVPKEY_Device_IsPresent', 'DEVPKEY_Device_InstallDate',
                                                                                           'DEVPKEY_Device_HasProblem', 'DEVPKEY_Device_ProblemCode')

        # We use LocationPaths to identify the possible Bluetooth device.
        # If Data in LocationPath is $null, then skip to next device.
        if($deviceProperties[0].Data -eq $null)
        {
            continue
        }

        $devNodeProperty = [DeviceNodeProperty]::New()
        $devNodeProperty.DeviceInstanceId = $device.InstanceId
        $devNodeProperty.RadioAddress = $deviceProperties[1].Data
        $devNodeProperty.IsPresent = $deviceProperties[2].Data
        $devNodeProperty.InstallDate = $deviceProperties[3].Data
        $devNodeProperty.HasProblem = $deviceProperties[4].Data
        $devNodeProperty.ProblemCode = $deviceProperties[5].Data
        $devNodeProperty.LocationPaths = New-Object System.Collections.ArrayList

        foreach($lp in $deviceProperties[0].Data)
        {
            $devNodeProperty.LocationPaths.Add($lp)
        }

        $devNodeProperties.Add($devNodeProperty)
    }

    return $devNodeProperties
}