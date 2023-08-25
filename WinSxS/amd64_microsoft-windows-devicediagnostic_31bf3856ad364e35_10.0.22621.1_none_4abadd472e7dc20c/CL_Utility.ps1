# Copyright © 2017, Microsoft Corporation. All rights reserved.


#CL_Utility

function DriverNotFound([string]$DeviceID)
{
$DriverNotFoundSource = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_DriverNotFound
    {
        private DeviceManagement_DriverNotFound()
        {
        }
        public const UInt32 ERROR_CLASS_MISMATCH = 0xE0000203;
        public const UInt32 DEVPROP_TYPE_EMPTY = 0x00000000;
        public const UInt32 DEVPROP_TYPE_STRING = 0x00000012;
        public static DEVPROPKEY DEVPKEY_Device_DriverInfPath = new DEVPROPKEY(new Guid("a8b865dd-2e3d-4094-ad97-e593a70c75d6"), 5);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiGetDeviceProperty", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiGetDeviceProperty(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, ref DEVPROPKEY PropertyKey, ref UInt32 PropertyType, IntPtr PropertyBuffer, UInt32 PropertyBufferSize, ref UInt32 RequiredSize, UInt32 Flags);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiOpenDeviceInfo", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiOpenDeviceInfo(IntPtr DeviceInfoSet, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, IntPtr Parent, UInt32 Flags, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCreateDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern IntPtr SetupDiCreateDeviceInfoList(IntPtr ClassGuid, IntPtr Parent);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiDestroyDeviceInfoList", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiDestroyDeviceInfoList(IntPtr DevInfo);

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

        public static bool DriverNotFound(string DeviceID)
        {
            UInt32 ResultCode = 0;
            IntPtr LocalMachineInstance = IntPtr.Zero;
            IntPtr DeviceInfoSet = IntPtr.Zero;
            bool noDriver = false;

            SP_DEVINFO_DATA DeviceInfoData = new SP_DEVINFO_DATA();

            ResultCode = GetDeviceInformation(DeviceID, ref DeviceInfoSet, ref DeviceInfoData);
            if(0 != ResultCode)
            {
                return noDriver;
            }

            UInt32 propertyType = 0;
            UInt32 bufferSize = 260;
            IntPtr propertyBuffer = Marshal.AllocHGlobal((int)bufferSize);
            if (0 != SetupDiGetDeviceProperty(DeviceInfoSet, ref DeviceInfoData, ref DEVPKEY_Device_DriverInfPath, ref propertyType, propertyBuffer, bufferSize, ref bufferSize, 0))
            {
                if (propertyType == DEVPROP_TYPE_STRING)
                {
                    noDriver = false;
                }
                else
                {
                    noDriver = true;
                }
            }
            else
            {
                noDriver = true;
            }

            if (IntPtr.Zero != propertyBuffer)
            {
                Marshal.FreeHGlobal(propertyBuffer);
            }

            ReleaseDeviceInfoSet(DeviceInfoSet);

            return noDriver;
        }
    }
}
"@
    Add-Type -TypeDefinition $DriverNotFoundSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_DriverNotFound]

    $noDriver = $DeviceManager::DriverNotFound($DeviceID)
    return $noDriver
}

function WaitForInstall()
{
$WaitForInstallSource = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_WaitForInstall
    {
        private DeviceManagement_WaitForInstall()
        {
        }

        public const UInt32 INFINITE = 0xFFFFFFFF;

        [DllImport("cfgmgr32.dll", SetLastError = true, EntryPoint = "CMP_WaitNoPendingInstallEvents", CharSet = CharSet.Auto)]
        static extern UInt32 CMP_WaitNoPendingInstallEvents(UInt32 TimeOut);

        public static UInt32 WaitForInstall()
        {
            return CMP_WaitNoPendingInstallEvents(INFINITE);
        }

    }
}
"@
    Add-Type -TypeDefinition $WaitForInstallSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_WaitForInstall]

    $DeviceManager::WaitForInstall()
}


function RescanAllDevices()
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

function ReinstallDevice([string]$DeviceID)
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

function ShowUpdateDriverWizard([string]$DeviceID, [string]$ParentName)
{
$ShowUpdateDriverWizardSource = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_Update
    {
        public const UInt32 ERROR_CLASS_MISMATCH = 0xE0000203;

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, IntPtr lpszClass, [MarshalAs(UnmanagedType.LPWStr)] string lpszWindow);

        [DllImport("newdev.dll", SetLastError = true, EntryPoint = "DiShowUpdateDevice", CharSet = CharSet.Auto)]
        static extern UInt32 DiShowUpdateDevice(IntPtr Parent, IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, UInt32 Flags, ref UInt32 NeedReboot);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiOpenDeviceInfo", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiOpenDeviceInfo(IntPtr DeviceInfoSet, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, IntPtr Parent, UInt32 Flags, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCreateDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern IntPtr SetupDiCreateDeviceInfoList(IntPtr ClassGuid, IntPtr Parent);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiDestroyDeviceInfoList", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiDestroyDeviceInfoList(IntPtr DevInfo);

        [StructLayout(LayoutKind.Sequential)]
        public struct SP_DEVINFO_DATA
        {
            public UInt32 Size;
            public Guid ClassGuid;
            public UInt32 DevInst;
            public IntPtr Reserved;
        }

        private DeviceManagement_Update()
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

        public static UInt32 ShowUpdateWizardForDevice(string DeviceID, string ParentWindowName)
        {
            UInt32 ResultCode = 0;
            UInt32 NeedReboot = 0;
            IntPtr DevInfoSet = IntPtr.Zero;
            SP_DEVINFO_DATA DevInfo = new SP_DEVINFO_DATA();

            ResultCode = GetDeviceInformation(DeviceID, ref DevInfoSet, ref DevInfo);

            if (0 == ResultCode)
            {
                IntPtr ParentHandle = IntPtr.Zero;
                ParentHandle = FindWindowEx(IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, ParentWindowName);
                if (IntPtr.Zero == ParentHandle)
                {
                    ResultCode = (UInt32)Marshal.GetLastWin32Error();
                }
                else
                {
                    if (DiShowUpdateDevice(ParentHandle, DevInfoSet, ref DevInfo, 0, ref NeedReboot) != 1)
                    {
                        ResultCode = (UInt32)Marshal.GetLastWin32Error();
                    }
                }
                ReleaseDeviceInfoSet(DevInfoSet);
            }

            return ResultCode;
        }
    }
}
"@

    Add-Type -TypeDefinition $ShowUpdateDriverWizardSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_Update]

    $ErrorCode = $DeviceManager::ShowUpdateWizardForDevice($DeviceID, $ParentName)
    return $ErrorCode
}

function RemoveDevice([string]$DeviceID)
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

function EnableDevice([string]$DeviceID, [bool]$Enable, [bool]$IsGlobal)
{
$EnableDeviceSource = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
namespace Microsoft.Windows.Diagnosis
{
    public sealed class DeviceManagement_Enable
    {
        public const UInt32 DIF_PROPERTYCHANGE = 0x00000012;
        public const UInt32 DICS_ENABLE = 1;
        public const UInt32 DICS_DISABLE = 2;
        public const UInt32 DICS_FLAG_GLOBAL = 1;
        public const UInt32 DICS_FLAG_CONFIGSPECIFIC = 0x00000002;
        public const UInt32 ERROR_CLASS_MISMATCH = 0xE0000203;

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiOpenDeviceInfo", CharSet = CharSet.Auto)]
        static extern UInt32 SetupDiOpenDeviceInfo(IntPtr DeviceInfoSet, [MarshalAs(UnmanagedType.LPWStr)]string DeviceID, IntPtr Parent, UInt32 Flags, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCreateDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern IntPtr SetupDiCreateDeviceInfoList(IntPtr ClassGuid, IntPtr Parent);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiDestroyDeviceInfoList", CharSet = CharSet.Unicode)]
        static extern UInt32 SetupDiDestroyDeviceInfoList(IntPtr DevInfo);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiSetClassInstallParams", CharSet = CharSet.Auto)]
        public static extern int SetupDiSetClassInstallParams(IntPtr DeviceInfoSet, IntPtr DeviceInfoData, IntPtr ClassInstallParams, int ClassInstallparamsSize);

        [DllImport("setupapi.dll", SetLastError = true, EntryPoint = "SetupDiCallClassInstaller", CharSet = CharSet.Auto)]
        public static extern int SetupDiCallClassInstaller(UInt32 InstallFunction, IntPtr DeviceInfoSet, IntPtr DeviceInfoData);

        [StructLayout(LayoutKind.Sequential)]
        public struct SP_DEVINFO_DATA
        {
            public UInt32 Size;
            public Guid ClassGuid;
            public UInt32 DevInst;
            public IntPtr Reserved;
        }

        public struct SP_CLASSINSTALL_HEADER
        {
            public int Size;
            public int InstallFunction;
        }

        public struct SP_PROPCHANGE_PARAMS
        {
            public SP_CLASSINSTALL_HEADER ClassInstallHeader;
            public UInt32 StateChange;
            public UInt32 Scope;
            public UInt32 Profile;
        }

        private DeviceManagement_Enable()
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

        public static UInt32 EnableDevice(string DeviceID, bool Enable, bool IsGlobal)
        {
            UInt32 ResultCode = 0;
            IntPtr DevInfoSet = IntPtr.Zero;
            SP_DEVINFO_DATA DevInfo = new SP_DEVINFO_DATA();

            ResultCode = GetDeviceInformation(DeviceID, ref DevInfoSet, ref DevInfo);

            if (0 == ResultCode)
            {
                SP_PROPCHANGE_PARAMS Params = new SP_PROPCHANGE_PARAMS();
                Params.ClassInstallHeader.Size = Marshal.SizeOf(typeof(SP_CLASSINSTALL_HEADER));
                Params.ClassInstallHeader.InstallFunction = (int)DIF_PROPERTYCHANGE;
                Params.StateChange = Enable ? DICS_ENABLE : DICS_DISABLE;
                Params.Scope = IsGlobal ? DICS_FLAG_GLOBAL : DICS_FLAG_CONFIGSPECIFIC;
                Params.Profile = 0;

                IntPtr ChangeParams = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(SP_PROPCHANGE_PARAMS)));
                Marshal.StructureToPtr(Params, ChangeParams, true);
                IntPtr ptrDevInfo = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(SP_DEVINFO_DATA)));
                Marshal.StructureToPtr(DevInfo, ptrDevInfo, true);

                if (1 != SetupDiSetClassInstallParams(DevInfoSet, ptrDevInfo, ChangeParams, Marshal.SizeOf(typeof(SP_PROPCHANGE_PARAMS))))
                {
                    ResultCode = (UInt32)Marshal.GetLastWin32Error();
                }
                else
                {
                    if (1 != SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, DevInfoSet, ptrDevInfo))
                    {
                        ResultCode = (UInt32)Marshal.GetLastWin32Error();
                    }
                }

                if (IntPtr.Zero != ChangeParams)
                {
                    Marshal.FreeHGlobal(ChangeParams);
                }
                if (IntPtr.Zero != ptrDevInfo)
                {
                    Marshal.FreeHGlobal(ptrDevInfo);
                }
                ReleaseDeviceInfoSet(DevInfoSet);
            }
            return ResultCode;
        }
    }
}
"@

    Add-Type -TypeDefinition $EnableDeviceSource

    $DeviceManager = [Microsoft.Windows.Diagnosis.DeviceManagement_Enable]

    $ErrorCode = $DeviceManager::EnableDevice($DeviceID, $Enable, $IsGlobal)
    return $ErrorCode
}

function GetEvent([string]$logName,[string]$providerName,[string]$ID, [string]$data, [int]$days = 0)
{
    $parahash = @{}
    if(-not[String]::IsNullOrEmpty($logname))
    {
        $paraHash.Add("LogName", $logName)
    }
    if(-not[String]::IsNullOrEmpty($providerName))
    {
        $paraHash.Add("ProviderName", $providerName)
    }
    if(-not[String]::IsNullOrEmpty($ID))
    {
        $paraHash.Add("ID", $ID)
    }
    if(-not[String]::IsNullOrEmpty($data))
    {
        $paraHash.Add("Data", $data)
    }
    if($days -ne 0)
    {
        $startTime = (Get-Date).AddDays(-$days)
        $paraHash.Add("StartTime", $startTime)
    }

    return Get-WinEvent -FilterHashTable $paraHash
}

function QueryWERResponse([string]$Platform, [string]$PnPDeviceID)
{
$WERQuerySource = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Collections;
namespace Microsoft.Windows.Diagnosis
{
    public class QueryResult
    {
        public string responseUrl;
        public string reportStoreLocation;
        public string reportStoreType;
        public bool isResponseApplicable;
    }

    public class WERReportManager
    {
        //Callback class to recieve reponse inforamtion
        private class WERResponseCallback
        {
            public string responseUrl = string.Empty;

            public virtual UInt32 WERResponseCallbackFunc(IntPtr context, ref WER_CALLBACK_INPUT callbackInput)
            {
                if (callbackInput.CallbackType == (UInt32)CALLBACKTYPE.WerCallbackResponseAvailable)
                {
                    responseUrl = Marshal.PtrToStringUni(callbackInput.response.pwzResponse);
                    return 1;
                }

                return 0;
            }
        }

        //const values
        #region
        public const UInt32 MAX_PATH = 260;
        public const UInt32 WER_P0 = 0;
        public const UInt32 WER_P1 = 1;
        public const UInt32  WER_SUBMIT_NO_QUEUE                 = 128;     // Do not queue the report
        public const UInt32  WER_SUBMIT_NO_ARCHIVE               = 256;     // Do not archive the report

        public const string reportName = "PnPDriverNotFound";
        #endregion

        //enumerations and structures
        #region
        public enum WER_REPORT_TYPE
        {
            WerReportNonCritical = 0,
            WerReportCritical = 1,
            WerReportApplicationCrash = 2,
            WerReportApplicationHang = 3,
            WerReportKernel = 4,
            WerReportInvalid
        }

        public enum WER_CONSENT
        {
            WerConsentNotAsked = 1,
            WerConsentApproved = 2,
            WerConsentDenied = 3,
            WerConsentMax
        }

        public enum WER_SUBMIT_RESULT
        {
            WerReportQueued = 1,
            WerReportUploaded = 2,
            WerReportDebug = 3,
            WerReportFailed = 4,
            WerDisabled = 5,
            WerReportCancelled = 6,
            WerDisabledQueue = 7,
            WerReportAsync = 8
        }

        public enum CALLBACKTYPE
        {
            WerCallbackDataRequestBegin,
            WerCallbackDataRequest,
            WerCallbackDataRequestEnd,
            WerCallbackResponseAvailable,
            WerCallbackRecoveryNotification,
            WerCallbackRestartNotification,
            WerCallbackBeforeQueue,
            WerCallbackUploadFinished,
            WerCallbackUploadBegin,
            WerCallbackUI,
            WerCallbackRecoveryResult,
            WerCallbackRestartResult,
            WerCallbackReportingStart,
            WerCallbackControlRequestBegin,
            WerCallbackControlRequest,
            WerCallbackControlRequestEnd,
        }

        public enum REPORT_STORE_TYPES
        {
            E_STORE_USER_ARCHIVE = 0,
            E_STORE_USER_QUEUE = 1,
            E_STORE_MACHINE_ARCHIVE = 2,
            E_STORE_MACHINE_QUEUE = 3,
            E_STORE_INVALID = 4
        }

        public struct RESPONSE
        {
            public IntPtr pwzResponse;
            public UInt32 dwBucketID;
        }

        public struct WER_CALLBACK_INPUT
        {
            public IntPtr hReportHandle;
            public UInt32 CallbackType;
            public IntPtr hCancelEvent;
            public RESPONSE response;
        }
        #endregion

        public delegate UInt32 WERCallBackDelegate(IntPtr context, ref WER_CALLBACK_INPUT callbackInput);

        [DllImport("Wer.dll", EntryPoint = "WerReportCreate", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerReportCreate([MarshalAs(UnmanagedType.LPWStr)] string eventType, WER_REPORT_TYPE type, IntPtr reportInformation, ref IntPtr reportHandle);

        [DllImport("Wer.dll", EntryPoint = "WerReportSetParameter", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerReportSetParameter(IntPtr reportHandle, UInt32 paramID, [MarshalAs(UnmanagedType.LPWStr)] string paramName, [MarshalAs(UnmanagedType.LPWStr)] string paramValue);

        [DllImport("Wer.dll", EntryPoint = "WerReportSubmit", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerReportSubmit(IntPtr reportHandle, WER_CONSENT consent, UInt32 flags, ref WER_SUBMIT_RESULT submitResult);

        [DllImport("Wer.dll", EntryPoint = "WerpSetCallBack", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerpSetCallBack(IntPtr reportHandle, WERCallBackDelegate callbackDelegate, IntPtr handle);

        [DllImport("Wer.dll", EntryPoint = "WerReportCloseHandle", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerReportCloseHandle(IntPtr reportHandle);

        [DllImport("Wer.dll", EntryPoint = "WerpGetStoreLocation", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerpGetStoreLocation(IntPtr reportHandle, IntPtr storePath, ref UInt32 pathLength);

        [DllImport("Wer.dll", EntryPoint = "WerpGetStoreType", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerpGetStoreType(IntPtr reportHandle, ref REPORT_STORE_TYPES storeType);

        [DllImport("werconcpl.dll", EntryPoint = "WerpIsResponseApplicable", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern UInt32 WerpIsResponseApplicable([MarshalAs(UnmanagedType.LPWStr)] string reportPath, UInt32 reportType, UInt32 responseAction, ref int isApplicable, ref int isAutoLaunch);


        public static QueryResult QueryWERResponse(string Platform, string PNPDeviceID)
        {
            UInt32 resultCode = 0;
            UInt32 length = MAX_PATH;

            IntPtr reporthandle = IntPtr.Zero;
            IntPtr reportStorePathPtr = IntPtr.Zero;
            string reportStorePath = string.Empty;

            REPORT_STORE_TYPES storeType = REPORT_STORE_TYPES.E_STORE_INVALID;

            WER_SUBMIT_RESULT werResult = WER_SUBMIT_RESULT.WerReportFailed;
            QueryResult queryResult = new QueryResult();

            resultCode = WerReportCreate(reportName, WER_REPORT_TYPE.WerReportNonCritical, IntPtr.Zero, ref reporthandle);
            if (0 != resultCode)
            {
                if (reporthandle != IntPtr.Zero)
                {
                    WerReportCloseHandle(reporthandle);
                }
                return queryResult;
            }

            resultCode = WerReportSetParameter(reporthandle, WER_P0, "", Platform);
            if (0 != resultCode)
            {
                if (reporthandle != IntPtr.Zero)
                {
                    WerReportCloseHandle(reporthandle);
                }
                return queryResult;
            }

            resultCode = WerReportSetParameter(reporthandle, WER_P1, "", PNPDeviceID);
            if (0 != resultCode)
            {
                if (reporthandle != IntPtr.Zero)
                {
                    WerReportCloseHandle(reporthandle);
                }
                return queryResult;
            }

            WERResponseCallback responseCallback = new WERResponseCallback();
            WERCallBackDelegate delegateCallback = new WERCallBackDelegate(responseCallback.WERResponseCallbackFunc);

            resultCode = WerpSetCallBack(reporthandle, delegateCallback, reporthandle);
            if (0 != resultCode)
            {
                if (reporthandle != IntPtr.Zero)
                {
                    WerReportCloseHandle(reporthandle);
                }
                return queryResult;
            }

            resultCode = WerReportSubmit(reporthandle, WER_CONSENT.WerConsentNotAsked, WER_SUBMIT_NO_QUEUE, ref werResult);
            if (0 != resultCode)
            {
                if (reporthandle != IntPtr.Zero)
                {
                    WerReportCloseHandle(reporthandle);
                }
                return queryResult;
            }

            //Get store location on local machine for availabe response
            if (werResult == WER_SUBMIT_RESULT.WerReportUploaded)
            {
                queryResult.responseUrl = responseCallback.responseUrl;

                reportStorePathPtr = Marshal.AllocHGlobal((int)length * 2);
                resultCode = WerpGetStoreLocation(reporthandle, reportStorePathPtr, ref length);
                if (0 == resultCode)
                {
                    reportStorePath = Marshal.PtrToStringUni(reportStorePathPtr);
                    queryResult.reportStoreLocation = reportStorePath;
                }
                Marshal.FreeHGlobal(reportStorePathPtr);

                resultCode = WerpGetStoreType(reporthandle, ref storeType);
                if (0 == resultCode)
                {
                    if (storeType == REPORT_STORE_TYPES.E_STORE_MACHINE_ARCHIVE)
                    {
                        queryResult.reportStoreType = "-adminarchive";
                    }
                    else
                    {
                        queryResult.reportStoreType = "";
                    }
                }

                if (!String.IsNullOrEmpty(queryResult.reportStoreLocation))
                {
                    int isResponseApplicable = 0;
                    int isAutoLaunch = 0;
                    resultCode = WerpIsResponseApplicable(queryResult.reportStoreLocation, (UInt32)(storeType), 0, ref isResponseApplicable, ref isAutoLaunch);
                    if (0 == resultCode)
                    {
                        queryResult.isResponseApplicable = (isResponseApplicable == 1) ? true : false;
                    }
                }
            }

            if (reporthandle != IntPtr.Zero)
            {
                WerReportCloseHandle(reporthandle);
            }

            return queryResult;
        }
    }
}
"@
    Add-Type -TypeDefinition $WERQuerySource

    $Mgr = [Microsoft.Windows.Diagnosis.WERReportManager]

    return $Mgr::QueryWERResponse($Platform, $PnPDeviceID)
}
# Function to return the count of PNP Devices
function GetPnPDeviceCount()
{
    $PnPDevices = Get-WmiObject -Class Win32_PnPEntity
    if($PnPDevices -ne $Null)
    {
        [int]$PnPDeviceCount = $PnPDevices.Count
        return $PnPDeviceCount
    }
}

# Function to check System reboot required.
Function CheckForReboot
{ 
# Registry list to check for system reboot only related to drivers.
$ArrayRegistryList = @('Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager,PendingFileRenameOperations')

for($i = 0; $i -lt $ArrayRegistryList.Count; $i++)
{
       if($ArrayRegistryList[$i].Contains(','))
       {
       $items = $ArrayRegistryList[$i].Split(',')
       $GetRegKeyName = $items[0].Contains("Session Manager")
       $ReturnValueDword = CheckRegistry $items[0] $items[1] "Session Manager"
        if($ReturnValueDword -eq $True)
        {
          break
        }
       }
       else
       {
         $ReturnValue = CheckRegistry $ArrayRegistryList[$i] $null $null
         if($ReturnValue -eq $True)
         {
           break
         }
       }
}

if(($ReturnValue -eq $True) -or ($ReturnValueDword -eq $True))
{
      return $True
}
}

Function CheckRegistry($RegKey, $RegKeyDword, $RegKeyName)
{
  $flag = $false
  $CheckifPresent = Test-Path -Path $RegKey
  if($CheckifPresent)
  {
   if($RegKeyName -eq "Session Manager")
   {
    $KeySessionManager = Get-Item -LiteralPath $RegKey
    if($KeySessionManager.Property.Contains($RegKeyDword))
    {
     $flag = $true
    }
    }
    else
    {
      $Key = Get-Item -LiteralPath $RegKey
      if($Key.Property.Count -gt 0)
      {
        $flag = $true
      }
    }
  }
  return $flag
}

# Check whether TS_Main is running or Detecting Additional Problems on Windows 8.1 and above
Function Test-PostBack
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

Function Check-UnknownDevice($deviceID)
{
	$found = $false
	$ProblemDevice = $null
	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $deviceID}
	if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
	{
		[string]$DeviceName = $ProblemDevice.Name
		[string]$ErrorCode = $ProblemDevice.ConfigManagerErrorCode

		if ([String]::IsNullOrEmpty($DeviceName))
		{
			$found = $true
		}
	}

	return $found
}

Function Write-ExceptionTelemetry($FunctionName, [string]$writeErrorCode, [System.Management.Automation.ErrorRecord] $ex)
{

	if([System.Environment]::OSVersion.Version.Build -gt 15000)
	{
	    $ExceptionMessage = $ex.Exception.Message
		$ScriptFullPath = $ex.InvocationInfo.ScriptName
		$ExceptionScript = [System.IO.Path]::GetFileName($ScriptFullPath)
		$ExceptionScriptLine = $ex.InvocationInfo.ScriptLineNumber
		$ExceptionScriptColumn = $ex.InvocationInfo.OffsetInLine
		if([String]::IsNullOrEmpty($writeErrorCode))
		{
		  Write-DiagTelemetry "ScriptError" "$ExceptionScript\$FunctionName\$ExceptionScriptLine\$ExceptionScriptColumn\$ExceptionMessage"
		}
		else
		{
		  Write-DiagTelemetry "ScriptError" "$ExceptionScript\$FunctionName\$ExceptionScriptLine\$ExceptionScriptColumn\$ExceptionMessage\$writeErrorCode"
		}
	}	
}
