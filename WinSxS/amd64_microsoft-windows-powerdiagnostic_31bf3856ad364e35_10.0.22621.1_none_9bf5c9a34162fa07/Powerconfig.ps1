# Copyright © 2008, Microsoft Corporation. All rights reserved.


#get the power config

$methodDefinition = @"

using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;

    public sealed class PowerConfig
    {
        [Flags]
        public enum POWER_DATA_ACCESSOR
        {
            /// <summary>
            /// Check for overrides on AC power settings.
            /// </summary>
            ACCESS_AC_POWER_SETTING_INDEX = 0x0,
            /// <summary>
            /// Check for overrides on DC power settings.
            /// </summary>
            ACCESS_DC_POWER_SETTING_INDEX = 0x1,
            /// <summary>
            /// Check for restrictions on specific power schemes.
            /// </summary>
            ACCESS_SCHEME = 0x10,
            /// <summary>
            /// Check for restrictions on active power schemes.
            /// </summary>
            ACCESS_ACTIVE_SCHEME = 0x13,
            /// <summary>
            /// Check for restrictions on creating or restoring power schemes.
            /// </summary>
            ACCESS_CREATE_SCHEME = 0x14
        };

        public enum POWER_PLATFORM_ROLE
        {
            PlatformRoleUnspecified = 0,
            PlatformRoleDesktop = 1,
            PlatformRoleMobile = 2,
            PlatformRoleWorkstation = 3,
            PlatformRoleEnterpriseServer = 4,
            PlatformRoleSOHOServer = 5,
            PlatformRoleAppliancePC = 6,
            PlatformRolePerformanceServer = 7,
            PlatformRoleMaximum = 8
        };

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct SYSTEM_POWER_CAPABILITIES
        {

            /// BOOLEAN->BYTE->unsigned char
            public byte PowerButtonPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte SleepButtonPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte LidPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemS1;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemS2;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemS3;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemS4;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemS5;

            /// BOOLEAN->BYTE->unsigned char
            public byte HiberFilePresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte FullWake;

            /// BOOLEAN->BYTE->unsigned char
            public byte VideoDimPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte ApmPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte UpsPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte ThermalControl;

            /// BOOLEAN->BYTE->unsigned char
            public byte ProcessorThrottle;

            /// BYTE->unsigned char
            public byte ProcessorMinThrottle;

            /// BYTE->unsigned char
            public byte ProcessorMaxThrottle;

            /// BOOLEAN->BYTE->unsigned char
            public byte FastSystemS4;

            /// BYTE[3]
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 3, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I1)]
            public byte[] spare2;

            /// BOOLEAN->BYTE->unsigned char
            public byte DiskSpinDown;

            /// BYTE[8]
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 8, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I1)]
            public byte[] spare3;

            /// BOOLEAN->BYTE->unsigned char
            public byte SystemBatteriesPresent;

            /// BOOLEAN->BYTE->unsigned char
            public byte BatteriesAreShortTerm;

            /// BATTERY_REPORTING_SCALE[3]
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 3, ArraySubType = System.Runtime.InteropServices.UnmanagedType.Struct)]
            public BATTERY_REPORTING_SCALE[] BatteryScale;

            /// SYSTEM_POWER_STATE->_SYSTEM_POWER_STATE
            public SYSTEM_POWER_STATE AcOnLineWake;

            /// SYSTEM_POWER_STATE->_SYSTEM_POWER_STATE
            public SYSTEM_POWER_STATE SoftLidWake;

            /// SYSTEM_POWER_STATE->_SYSTEM_POWER_STATE
            public SYSTEM_POWER_STATE RtcWake;

            /// SYSTEM_POWER_STATE->_SYSTEM_POWER_STATE
            public SYSTEM_POWER_STATE MinDeviceWakeState;

            /// SYSTEM_POWER_STATE->_SYSTEM_POWER_STATE
            public SYSTEM_POWER_STATE DefaultLowLatencyWake;
        }

        public enum SYSTEM_POWER_STATE
        {

            /// PowerSystemUnspecified -> 0
            PowerSystemUnspecified = 0,

            /// PowerSystemWorking -> 1
            PowerSystemWorking = 1,

            /// PowerSystemSleeping1 -> 2
            PowerSystemSleeping1 = 2,

            /// PowerSystemSleeping2 -> 3
            PowerSystemSleeping2 = 3,

            /// PowerSystemSleeping3 -> 4
            PowerSystemSleeping3 = 4,

            /// PowerSystemHibernate -> 5
            PowerSystemHibernate = 5,

            /// PowerSystemShutdown -> 6
            PowerSystemShutdown = 6,

            /// PowerSystemMaximum -> 7
            PowerSystemMaximum = 7,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct BATTERY_REPORTING_SCALE
        {

            /// DWORD->unsigned int
            public uint Granularity;

            /// DWORD->unsigned int
            public uint Capacity;
        }


        [DllImport("powrprof.dll")]
        private static extern UInt32 CallNtPowerInformation(
             Int32 InformationLevel,
             IntPtr lpInputBuffer,
             UInt32 nInputBufferSize,
             ref SYSTEM_POWER_CAPABILITIES lpOutputBuffer,
             UInt32 nOutputBufferSize
             );

        [DllImport("PowrProf.dll", CharSet = CharSet.Auto)]
        private static extern POWER_PLATFORM_ROLE PowerDeterminePlatformRole();

        /// <summary>
        /// Full call to method PowerSettingAccessCheck().
        /// </summary>
        /// <param name="AccessFlags">One or more check specifier flags</param>
        /// <param name="PowerGuid">The relevant Power Policy GUID</param>
        /// <returns></returns>
        [DllImport("PowrProf.dll")]
        [return: MarshalAs(UnmanagedType.U4)]
        private static extern UInt32 PowerSettingAccessCheck(
                                POWER_DATA_ACCESSOR AccessFlags,
                                [MarshalAs(UnmanagedType.LPStruct)] Guid PowerGuid
                                );

        private PowerConfig() { }
        [DllImport("PowrProf.dll")]
        private static extern uint PowerReadACValueIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      ref UInt32 Value
                               );

        [DllImport("PowrProf.dll")]
        private static extern uint PowerReadDCValueIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      ref UInt32 Value
                               );

        [DllImport("PowrProf.dll")]
        private static extern uint PowerReadACDefaultIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      ref UInt32 Value
                               );

        [DllImport("PowrProf.dll")]
        private static extern uint PowerReadDCDefaultIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      ref UInt32 Value
                               );

        [DllImport("PowrProf.dll")]
        private static extern uint PowerWriteACValueIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      uint AcValueIndex
                               );

        [DllImport("PowrProf.dll")]
        private static extern uint PowerWriteDCValueIndex(
                                      uint RootPowerKey,
                                      ref Guid SchemeGuid,
                                      ref Guid SubGroupOfPowerSettingsGuid,
                                      ref Guid PowerSettingGuid,
                                      uint AcValueIndex
                               );


        [DllImport("PowrProf.dll")]
        private static extern uint PowerGetActiveScheme(
                                      uint UserRootPowerKey,
                                      ref IntPtr ActivePolicyGuid
                                    );
        [DllImport("PowrProf.dll")]
        private static extern uint PowerSetActiveScheme(
                                      uint UserRootPowerKey,
                                      ref Guid SchemeGuid
                                    );

        [DllImport("powrprof.dll")]
        public static extern UInt32 PowerEnumerate(
                    uint RootPowerKey,
                    IntPtr SchemeGuid,
                    IntPtr SubGroupOfPowerSettingGuid,
                    UInt32 AcessFlags,
                    UInt32 Index,
                    ref Guid Buffer,
                    ref UInt32 BufferSize);

        [DllImport("powrprof.dll")]
        public static extern UInt32 PowerReadFriendlyName(
                    IntPtr RootPowerKey,
                    ref Guid SchemeGuid,
                    IntPtr SubGroupOfPowerSettingGuid,
                    IntPtr PowerSettingGuid,
                    IntPtr Buffer,
                    ref UInt32 BufferSize);

        public static Guid ActiveSchemeGuid()
        {
            IntPtr guidPtr = new IntPtr();
            uint res = PowerConfig.PowerGetActiveScheme(0, ref guidPtr);
	    if (res != 0)
            {
                throw new Win32Exception((Int32)res);
            }

            Guid ret = (Guid)Marshal.PtrToStructure(guidPtr, typeof(Guid));
            Marshal.FreeHGlobal(guidPtr);

            return ret;
        }

        public static uint SetPowerActiveSchemeGuid(ref Guid activeSchemeGuid)
        {
            uint res = 0;
            res = PowerConfig.PowerSetActiveScheme(0, ref activeSchemeGuid);
            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }
            return res;
        }

        public static uint ReadPowerSetting(bool ac,
                                ref Guid activeSchemeGuid,
                                ref Guid subGroupGuid,
                                ref Guid settingGuid,
                                ref UInt32 value)
        {
            uint res = 0;

            if (ac)
            {
                res = PowerConfig.PowerReadACValueIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                                      ref settingGuid,
                                      ref value);
            }
            else
            {
                res = PowerConfig.PowerReadDCValueIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                      ref settingGuid,
                      ref value);
            }

            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }

            return res;
        }

        public static uint ReadDefaultSetting(bool ac,
                                ref Guid activeSchemeGuid,
                                ref Guid subGroupGuid,
                                ref Guid settingGuid,
                                ref UInt32 value)
        {
            uint res = 0;

            if (ac)
            {
                res = PowerConfig.PowerReadACDefaultIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                                      ref settingGuid,
                                      ref value);
            }
            else
            {
                res = PowerConfig.PowerReadDCDefaultIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                      ref settingGuid,
                      ref value);
            }

            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }
            return res;
        }

        public static uint WritePowerSetting(bool ac,
                                     ref Guid activeSchemeGuid,
                                     ref Guid subGroupGuid,
                                     ref Guid settingGuid,
                                     UInt32 newValue)
        {
            uint res = 0;
            if (ac)
            {
                res = PowerConfig.PowerWriteACValueIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                                     ref settingGuid,
                                     newValue);
            }
            else
            {
                res = PowerConfig.PowerWriteDCValueIndex(0, ref activeSchemeGuid, ref subGroupGuid,
                                     ref settingGuid,
                                     newValue);
            }

            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }

            res = PowerConfig.PowerSetActiveScheme(0,
                                       ref activeSchemeGuid);
            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }

            return res;
        }

        public static Guid BalancedPowerPlan()
        {
            Guid subgroup = new Guid("fea3413e-7e05-4911-9a71-700331f1c294");
            Guid setting = new Guid("245d8541-3943-4422-b025-13a784f679b7");

            Guid Buffer = new Guid();
            Guid BalancedGuid = new Guid();
            UInt32 SchemeIndex = 0;
            UInt32 BufferSize = (UInt32)Marshal.SizeOf(typeof(Guid));

            while (0 == PowerConfig.PowerEnumerate(0, IntPtr.Zero, IntPtr.Zero, 16, SchemeIndex, ref Buffer, ref BufferSize))
            {
                uint ACvalue = 0;
                uint DCvalue = 0;

                PowerConfig.ReadPowerSetting(true, ref Buffer, ref subgroup, ref setting, ref ACvalue);
                PowerConfig.ReadPowerSetting(false, ref Buffer, ref subgroup, ref setting, ref DCvalue);

                if ((2 == ACvalue) && (2 == DCvalue))
                {
                    BalancedGuid = Buffer;
                }
                SchemeIndex++;
            }
            return BalancedGuid;
        }

        public static UInt32 CheckPowerSetting(bool ac,Guid guid)
        {
            UInt32 res;
            if (ac)
            {
                res = PowerConfig.PowerSettingAccessCheck(POWER_DATA_ACCESSOR.ACCESS_AC_POWER_SETTING_INDEX, guid);
            }
            else
            {
                res = PowerConfig.PowerSettingAccessCheck(POWER_DATA_ACCESSOR.ACCESS_DC_POWER_SETTING_INDEX, guid);
            }

            return res;
        }

        public static UInt32 CheckActiveSchemeAccess()
        {
            UInt32 res;
            res = PowerConfig.PowerSettingAccessCheck(POWER_DATA_ACCESSOR.ACCESS_ACTIVE_SCHEME, new Guid());
            if (res !=0)
            {
                throw new Win32Exception((Int32)res);
            }
            return res;
        }

        public static bool IsLaptop()
        {
            bool result = false;
            POWER_PLATFORM_ROLE platform_role = PowerDeterminePlatformRole();
            if (platform_role == POWER_PLATFORM_ROLE.PlatformRoleMobile)
            {
                result = true;
            }

            return result;
        }


        public static bool IsVideoDim()
        {
            SYSTEM_POWER_CAPABILITIES powercapabilityes = new SYSTEM_POWER_CAPABILITIES();
            uint result = CallNtPowerInformation(
                               4, //SystemPowerCapabilities
                               (IntPtr)null,
                               0,
                               ref powercapabilityes,
                               (UInt32)Marshal.SizeOf(new SYSTEM_POWER_CAPABILITIES()));
            if (result != 0)
            {
                return false;
            }

            if (powercapabilityes.VideoDimPresent == 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static string ReadActiveSchemeFriendlyName()
        {
            Guid ptrActiveGuid = ActiveSchemeGuid();

            uint buffSize = 0;
            uint res = PowerReadFriendlyName(IntPtr.Zero, ref ptrActiveGuid, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, ref buffSize);
            if (res == 0)
            {
                IntPtr ptrName = Marshal.AllocHGlobal((int)buffSize);
                res = PowerReadFriendlyName(IntPtr.Zero,ref ptrActiveGuid, IntPtr.Zero, IntPtr.Zero, ptrName, ref buffSize);
                if (res == 0)
                {
                    string ret = Marshal.PtrToStringUni(ptrName);
                    Marshal.FreeHGlobal(ptrName);
                    return ret;
                }
                Marshal.FreeHGlobal(ptrName);
            }

            throw new Win32Exception((Int32)res);
        }

    }
    public class ScreenSaver
    {
        // Signatures for unmanaged calls
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError=true)]
        private static extern bool SystemParametersInfo(
           int uAction, int uParam, ref int lpvParam,
           int flags);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool SystemParametersInfo(
           int uAction, int uParam, ref bool lpvParam,
           int flags);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int PostMessage(IntPtr hWnd,
           int wMsg, int wParam, int lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr OpenDesktop(
           string hDesktop, int Flags, bool Inherit,
           uint DesiredAccess);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool CloseDesktop(
           IntPtr hDesktop);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool EnumDesktopWindows(
           IntPtr hDesktop, EnumDesktopWindowsProc callback,
           IntPtr lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool IsWindowVisible(
           IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr GetForegroundWindow();


        // Callbacks
        private delegate bool EnumDesktopWindowsProc(
           IntPtr hDesktop, IntPtr lParam);

        // Constants
        private const int SPI_GETSCREENSAVERACTIVE = 16;
        private const int SPI_SETSCREENSAVERACTIVE = 17;
        private const int SPI_GETSCREENSAVERTIMEOUT = 14;
        private const int SPI_SETSCREENSAVERTIMEOUT = 15;
        private const int SPI_GETSCREENSAVERRUNNING = 114;
        private const int SPIF_SENDWININICHANGE = 2;

        private const uint DESKTOP_WRITEOBJECTS = 0x0080;
        private const uint DESKTOP_READOBJECTS = 0x0001;
        private const int WM_CLOSE = 16;

        // Returns TRUE if the screen saver is active
        // (enabled, but not necessarily running).
        public static bool GetScreenSaverActive()
        {
            bool isActive = false;

            SystemParametersInfo(SPI_GETSCREENSAVERACTIVE, 0,
               ref isActive, 0);

            return isActive;
        }

        // Pass in TRUE(1) to activate or FALSE(0) to deactivate
        // the screen saver.
        public static void SetScreenSaverActive(int Active)
        {
            int nullVar = 0;

            bool res = SystemParametersInfo(SPI_SETSCREENSAVERACTIVE,
               Active, ref nullVar, SPIF_SENDWININICHANGE);

            if (!res)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }

        }

        // Returns the screen saver timeout setting, in seconds
        public static Int32 GetScreenSaverTimeout()
        {
            Int32 value = 0;

            bool res = SystemParametersInfo(SPI_GETSCREENSAVERTIMEOUT, 0,
               ref value, 0);
            if (!res)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }
            return value;
        }

        // Pass in the number of seconds to set the screen saver
        // timeout value.
        public static void SetScreenSaverTimeout(Int32 Value)
        {
            int nullVar = 0;

            bool res = SystemParametersInfo(SPI_SETSCREENSAVERTIMEOUT,
               Value, ref nullVar, SPIF_SENDWININICHANGE);
            if (!res)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }

        }

        // Returns TRUE if the screen saver is actually running
        public static bool GetScreenSaverRunning()
        {
            bool isRunning = false;

            bool res = SystemParametersInfo(SPI_GETSCREENSAVERRUNNING, 0,
               ref isRunning, 0);
            if (!res)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }
            return isRunning;
        }

    }
"@

Add-Type -TypeDefinition $methodDefinition
$powerconfig = [PowerConfig]

$ScreenSaver = [ScreenSaver]

function GetActiveSchemeFriendlyName()
{
    return $powerconfig::ReadActiveSchemeFriendlyName()
}

function IsLaptop()
{
    return $powerconfig::IsLaptop()
}

function IsVideoDim()
{
    return $powerconfig::IsVideoDim()
}

function CheckPPMCapability {
    [bool]$result = $false
    try {
        $locator = New-Object -ComObject "WbemScripting.SWbemLocator"
        $server = $locator.connectServer(".", "root\wmi")
    	$class = $server.Get("KernelPerfStates")
        $object = $class.Instances_()
        $result = (0 -lt ($object | Measure-Object).Count)
    } catch {
        $result = $false
    }

    return $result
}

function IsActiveScreenSaver()
{
    $result = $false
    $regpath = "registry::HKEY_CURRENT_USER\Control Panel\Desktop"
    if(test-path $regpath)
    {
        $Executable = Get-ItemProperty $regpath SCRNSAVE.EXE -ErrorAction silentlycontinue
        if($Executable.'SCRNSAVE.EXE') 
        {
            $result = $true
        }
    }

    return $result
}

function DisableScreensaver()
{
    $ScreenSaver::SetScreenSaverActive(0)
    $regpath = "registry::HKEY_CURRENT_USER\Control Panel\Desktop"
    if(test-path $regpath)
    {
        Set-ItemProperty $regpath SCRNSAVE.EXE ""
    }
}

function GetActiveSchemeGuid()
{
    $activeSchemeGuid = $powerconfig::ActiveSchemeGuid()
    return $activeSchemeGuid
}

function SetActiveSchemeGuid([string]$ActiveSchemeGuid = $(throw "No Active Scheme Guid is specified"))
{
    $ActiveSchemeGuid = new-object system.Guid($ActiveSchemeGuid)
    $res = $powerconfig::SetPowerActiveSchemeGuid([ref]$ActiveSchemeGuid)
    return $res
}

function Getpowersetting([bool]$isAC,[string]$subGroupGuid = $(throw "No subGroup Guid is specified"),[string]$settingGuid = $(throw "No setting Guid is specified"))
{
    $activeSchemeGuid = $powerconfig::ActiveSchemeGuid()
    $subGroupGuid = new-object system.Guid($subGroupGuid)
    $settingGuid = new-object system.Guid($settingGuid)
    $settingvalue = 0
    $res = $powerconfig::ReadPowerSetting($isAC,[ref]$activeSchemeGuid,[ref]$subGroupGuid,[ref]$settingGuid,[ref]$settingvalue)
    if($res -eq 0)
    {
        return $settingvalue
    }
}

function GetDefaultpowersetting([bool]$isAC,[string]$subGroupGuid = $(throw "No subGroup Guid is specified"),[string]$settingGuid = $(throw "No setting Guid is specified"))
{
    $BalancedPowerPlan = $powerconfig::BalancedPowerPlan()
    $subGroupGuid = new-object system.Guid($subGroupGuid)
    $settingGuid = new-object system.Guid($settingGuid)
    $settingvalue = 0
    $res = $powerconfig::ReadDefaultSetting($isAC,[ref]$BalancedPowerPlan,[ref]$subGroupGuid,[ref]$settingGuid,[ref]$settingvalue)
    if($res -eq 0)
    {
        return $settingvalue
    }
}

function Setpowersetting([bool]$isAC,[string]$subGroupGuid = $(throw "No subGroup Guid is specified"),[string]$settingGuid = $(throw "No setting Guid is specified"),[int]$settingvalue = $(throw "No setting value is specified"))
{
    $activeSchemeGuid = $powerconfig::ActiveSchemeGuid()
    $subGroupGuid = new-object system.Guid($subGroupGuid)
    $settingGuid = new-object system.Guid($settingGuid)
    $res = $powerconfig::WritePowerSetting($isAC,[ref]$activeSchemeGuid,[ref]$subGroupGuid,[ref]$settingGuid,$settingvalue)
    return $res
}

function GetBalancedPowerPlan()
{
    $BalancedPowerPlan = $powerconfig::BalancedPowerPlan()
    return $BalancedPowerPlan
}

function CheckPowerSettingAccess([bool]$isAC,[string]$settingGuid = $(throw "No setting Guid is specified"))
{
    $settingGuid = new-object system.Guid($settingGuid)
    $result = $powerconfig::CheckPowerSetting($isAC,$settingGuid)
    if($result -eq 0)
    {
        return $true
    }
    else
    {
        return $false
    }
}

function CheckActiveSchemeAccess()
{
    $result = $powerconfig::CheckActiveSchemeAccess()
    if($result -eq 0)
    {
        return $true
    }
    else
    {
        return $false
    }
}