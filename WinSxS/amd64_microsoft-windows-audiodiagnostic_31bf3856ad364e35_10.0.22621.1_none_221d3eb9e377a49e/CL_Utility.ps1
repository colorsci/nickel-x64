# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  CL_Utility is common library for audio troubleshooter.

	ARGUMENTS:
	  None

	RETURNS:
	  None

	FUNCTIONS:
	  Write-ExceptionTelemetry
	  GetAdapterName
	  GetAbsolutionPath
	  Get-AudioDeviceCount
	  Get-DeviceId
	  Get-DeviceName
	  Get-DeviceStateName
	  Get-DeviceTypeName
	  GetId
	  GetRuntimePath
	  GetSystemPath
	  Parse-List
	  RemoveDevice
	  RescanAllDevices
	  Set-DefaultEndpoint
	  Get-AudioSamplingRate
	  Start-AudioService
      Stop-AudioService
	  Get-AudioDriverSource32
	  Get-AudioDriverSource
	  PlaySound
	  Get-HDAudioID
	  Set-AudioEndpointProperty
#>

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_AudioDiagnosticSnapIn.ps1

#====================================================================================
# Main
#====================================================================================
function Pop-Msg {
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

function StartProcess([string]$deviceId)
{
	$ExePath = [System.Environment]::SystemDirectory +"\" + "control.exe"
	Start-Process -FilePath $ExePath -ArgumentList "mmsys.cpl,,$deviceId,sysfx"

}


function GetAdapterName($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object AdapterName).AdapterName
}

function GetAbsolutionPath([string]$fileName = $(throw "No file name is specified"))
{
	if([string]::IsNullorEmpty($fileName))
	{
		throw "Invalid file name"
	}

	return Join-Path (Get-Location).Path $fileName
}

function Get-AudioDeviceCount()
{
	$audioDevices = Get-WmiObject Win32_SoundDevice
	[int]$deviceCount = ($audioDevices.Name).Count
	return $deviceCount
}

function Get-DeviceId([string]$deviceName, [string]$deviceTypes)
{
	[string]$deviceID = [String]::Empty
	try 
	{
		$devices = @()
		$EndPointListID = @()
		$AudioMethods = Get-AudioEndpoints
		$EndPointListID = $AudioMethods::GetAudioEndPointsbyType($deviceTypes)
		$devices += $EndPointListID.ForEach({[PSCustomObject]$_})
		
		foreach($devs in $devices)
		{
			$devId = GetId $devs
			$devName = GetAdapterName $devs

			if($deviceName -contains $devName)
			{
				$deviceID = [string]$devId
				break
			}
		}
	} 
	Catch [System.Exception]
	{
		Write-ExceptionTelemetry "GetDeviceId" $_
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "CL_Utility" -Name "CL_Utility" -Verbosity Debug
	}
	return $deviceID
}

# Function to get the localized device name
function Get-DeviceName([string]$deviceType=$(throw "No device type is specified")) {
	[string]$deviceName = $localizationString.unknownAudioDevice

	if("Render" -eq $deviceType) {
		$deviceName = $localizationString.audioPlayback
	}

	if("Capture" -eq $deviceType) {
		$deviceName = $localizationString.audioRecording
	}

	return $deviceName
}

# Function to get the audio endpoint state name
function Get-DeviceStateName([int]$stateCode=$(throw "No state code is specified")) {
	[string]$stateName = ""
	if(1 -eq $stateCode) {
		$stateName = $localizationString.stateEnabled
	} elseif (2 -eq $stateCode) {
		$stateName = $localizationString.stateDisabled
	} elseif (4 -eq $stateCode) {
		$stateName = $localizationString.stateNotPresent
	} elseif (8 -eq $stateCode) {
		$stateName = $localizationString.stateUnplugged
	} else {
		$stateName = $localizationString.stateUnknown
	}

	return $stateName
}

# Function to get the audio device type name
function Get-DeviceTypeName([string]$deviceType = $(throw "No device type name is specified"))
{
	[string]$deviceTypeName = ""
	if([String]::IsNullOrEmpty($deviceType))
	{
		return $deviceTypeName
	}

	if($deviceType -eq "Render")
	{
		$deviceTypeName = $localizationString.speaker + ", " + $localizationString.headset  + " " + $localizationString.or + " " + $localizationString.headphone
	}
	elseif ($deviceType -eq "Capture")
	{
		$deviceTypeName = $localizationString.microphone  + " " + $localizationString.or + " " + $localizationString.headset
	}

	return $deviceTypeName
}


function GetId($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object DeviceId).DeviceId
}

function GetRuntimePath([string]$fileName = $(throw "No file name is specified"))
{
	if([string]::IsNullorEmpty($fileName))
	{
		throw "Invalid file name"
	}

	 [string]$runtimePath =  [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
	 return Join-Path $runtimePath $fileName
}

function GetSystemPath([string]$fileName = $(throw "No file name is specified"))
{
	if([string]::IsNullorEmpty($fileName))
	{
		throw "Invalid file name"
	}

	 [string]$systemPath = [System.Environment]::SystemDirectory
	 return Join-Path $systemPath $fileName
}

# Function to import audio management types
function Get-AudioManager
{
[string]$code = @'
using System;
using System.Runtime.InteropServices;

namespace Microsoft.Windows.Diagnosis
{

	public static class AudioConfigManager
	{
		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int AudioSetEndPointVisibility(string pszDeviceName, bool Status);

		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int AudioSetDefaultdevice(string pszDeviceName);

		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int SetAudioEndpointProperty(string pszDeviceName);

		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern int IsEndpointDefault(string pszDeviceName, string pDataFlow, ref IntPtr IsDefault);

		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern int GetDefaultEndpointID(string pDataFlow, ref IntPtr pDefaultId);
		
        [DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern float GetMasterVolumeLevel(string dataflow, out float pLevel);

        [DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern bool GetMute(string dataflow, ref bool pMute);

        [DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern void SetMute(string dataflow, bool pMute);
		
		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern void SetDeviceMute(string deviceId, bool pMute);
		
		[DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern float GetDeviceMasterVolumeLevel(string deviceId, out float pLevel);

        [DllImport("AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
        private static extern bool GetDeviceMute(string deviceId, ref bool pMute);

		public static string GetDefaultID(string dataFlow)
		{
			IntPtr pId = IntPtr.Zero;
			GetDefaultEndpointID(dataFlow, ref pId);
			
			string id = Marshal.PtrToStringAuto(pId);
			return id;
		}
		
		public static bool IsEndPointDefault(string deviceID, string dataFlow)
        {
                bool retBool = true;
                IntPtr pBool = IntPtr.Zero;
                IsEndpointDefault(deviceID, dataFlow, ref pBool);

                if (pBool.ToInt32() == 0)
                {
                    retBool = false;
                }
                return retBool;

        }

		public static int SetAudioProperty(string pszDeviceName)
        {
            return AudioConfigManager.SetAudioEndpointProperty(pszDeviceName);
        }

		public static int EnableDevice(string pszDeviceName, bool Status)
		{
			return AudioConfigManager.AudioSetEndPointVisibility(pszDeviceName, Status);
		}

		public static int SetDefault(string pszDeviceName)
		{
			return AudioConfigManager.AudioSetDefaultdevice(pszDeviceName);
		}

        public static bool GetMuteStatus(string deviceId)
        {
            bool mute = false;

            AudioConfigManager.GetMute(deviceId,ref mute);
            return mute;
        }
		
		public static bool GetDeviceMuteStatus(string deviceId)
        {
            bool mute = false;

            AudioConfigManager.GetDeviceMute(deviceId,ref mute);
            return mute;
        }

        public static void SetMuteStatus(string deviceId, bool muteStatus)
        {
            AudioConfigManager.SetMute(deviceId, muteStatus);
        }
		
		public static void SetDeviceMuteStatus(string deviceID, bool muteStatus)
        {
            AudioConfigManager.SetDeviceMute(deviceID, muteStatus);
        }		

        public static int GetVolume(string deviceId)
        {
            float retVal = 0.0f;

			AudioConfigManager.GetMasterVolumeLevel(deviceId, out retVal);
            return Convert.ToInt32(retVal * 100);
        }
		
        public static int GetDeviceVolume(string deviceId)
        {
            float retVal = 0.0f;

			AudioConfigManager.GetDeviceMasterVolumeLevel(deviceId, out retVal);
            return Convert.ToInt32(retVal * 100);
        }
		
	}
}

'@

Add-Type -TypeDefinition $code 

}


# Function to parse the the list with delimiter "/"
function Parse-List([string]$list = $(throw "No list is specified"))
{
	if($list -eq $null)
	{
		return $null
	}

	return $list.Split("/", [StringSplitOptions]::RemoveEmptyEntries)
}

# Function to Reinstall any devices.
function ReinstallDevice([string]$deviceID)
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
	$ErrorCode = $DeviceManager::ReinstallDevice($deviceID)
	return $ErrorCode
}

# Function to Remove any devices.
function RemoveDevice([string]$deviceID)
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
	$ErrorCode = $DeviceManager::RemoveDevice($deviceID)
	return $ErrorCode
}

# Rescans the device changes
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

function Set-DefaultEndpoint([string]$id = $(throw "No id is specified"))
{
	if(!([String]::IsNullOrEmpty($id)))
	{
		try
		{
				Get-AudioManager
				[Microsoft.Windows.Diagnosis.AudioConfigManager]::SetDefault($id)
		}
		catch [System.Exception]
		{
			Write-ExceptionTelemetry "Set-DefaultEndpoint" $_
		}
	}
}

#Function Get-AudioSamplingRate()
#{
#<#
#	DESCRIPTION:
#	  Load the module related to Audio EndPointCtrl and get and set the default sampling rate of specific the audio device .

#	ARGUMENTS:
#	  None

#	RETURNS:
#	  AudioResetDeviceFormats Type 
##>
#    $audioSampleFormatSource = @"
#using System;
#using System.Collections.Generic;
#using System.Text;
#using System.Runtime.InteropServices;
#using System.ComponentModel;
#using System.Security.Permissions;
#using System.Globalization;

#namespace Microsoft.Windows.Diagnosis
#{
#    public static class AudioResetDeviceFormats
#    {
#        public enum EDataFlow
#        {
#            ERender,
#            ECapture,
#            EAll,
#            EDataFlowEnumCount
#        }

#        /// <summary>
#        /// Used by IMMDeviceEnumerator
#        /// </summary>
#        public enum ERole
#        {
#            EConsole,
#            EMultimedia,
#            ECommunications,
#            ERoleEnumCount
#        }

#        internal static class NativeMethods
#        {
#            [DllImport("ole32.Dll")]
#            internal static extern int CoCreateInstance(ref Guid guid, [MarshalAs(UnmanagedType.IUnknown)] object inner, uint context, ref Guid id, [MarshalAs(UnmanagedType.IUnknown)] out object pointer);
#        }

#        public class EndpointCtrl
#        {
#            #region Private internal vars

#            static object oEnumerator;
#            static IMMDeviceEnumerator iDeviceEnumerator;
#            static object oDevice;
#            static IMMDevice iDevice;

#            #endregion

#            #region Interface to COM objects

#            const int E_FAIL = 0x00000001;

#            static Guid CLSID_MMDeviceEnumerator = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E");
#            static Guid IID_IUnknown = new Guid("00000000-0000-0000-C000-000000000046");

#            /// <summary>
#            /// interface IMMDevice
#            /// </summary>
#            [Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
#            private interface IMMDevice
#            {
#                int Activate(ref Guid guid, uint context, IntPtr parameters, ref IntPtr pointer);
#                int OpenPropertyStore(uint access, ref IntPtr properties);
#                int GetId(ref IntPtr id);
#                int GetState(ref int state);
#            }

#            /// <summary>
#            /// interface IMMDeviceEnumerator
#            /// </summary>
#            [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
#            interface IMMDeviceEnumerator
#            {
#                int EnumAudioEndpoints(EDataFlow dataflow, int mask, ref IntPtr devices);
#                int GetDefaultAudioEndpoint(EDataFlow dataflow, ERole role, ref IntPtr endpoint);
#                int GetDevice(string id, ref IntPtr device);
#                int RegisterEndpointNotificationCallback(IntPtr client);
#                int UnregisterEndpointNotificationCallback(IntPtr client);
#            }

#            private static bool comInitialized;
#            #endregion

#            /// <summary>
#            /// Constructor, initialize com interfaces
#            /// </summary>
#            internal EndpointCtrl()
#            {
#                int result = 0;
#                //1.to obtain IMMDeviceEnumerator
#                result = InitializedInstance();
#                if (result != 0)
#                {
#                    throw new Win32Exception("Can't obtain IMMDeviceEnumerator: " + result);
#                }

#                //2.to obtain IMMDevice by IMMDeviceEnumerator
#                //result = GetAudioDevice(deviceId);
#                if (result != 0)
#                {
#                    throw new Win32Exception("Can't obtain IMMDevice: " + result);
#                }
#            }

#            /// <summary>
#            /// initialize com interfaces and get IMMDeviceEnumerator
#            /// </summary>
#            /// <returns></returns>
#            private static int InitializedInstance()
#            {
#                if (comInitialized == true)
#                {
#                    return 0;
#                }

#                const uint CLSCTX_INPROC_SERVER = 1;

#                //1.to obtain IMMDeviceEnumerator
#                int result = NativeMethods.CoCreateInstance(ref CLSID_MMDeviceEnumerator, null, CLSCTX_INPROC_SERVER, ref IID_IUnknown, out oEnumerator);
#                if (result != 0)
#                {
#                    return result;
#                }

#                comInitialized = true;

#                if (oEnumerator == null)
#                {
#                    return E_FAIL;
#                }

#                iDeviceEnumerator = oEnumerator as IMMDeviceEnumerator;

#                if (iDeviceEnumerator == null)
#                {
#                    return E_FAIL;
#                }

#                return result;
#            }

#            /// <summary>
#            /// Get expected Audio Device
#            /// </summary>
#            /// <returns></returns>
#            int GetAudioDevice(string deviceId)
#            {
#                IntPtr pDevice = IntPtr.Zero;
#                int result = 0;

#                if (iDeviceEnumerator == null)
#                    return E_FAIL;

#                result = iDeviceEnumerator.GetDevice(deviceId, ref pDevice);
#                if (result != 0)
#                {
#                    throw new Win32Exception("Can't obtain IMMDevice: " + result);
#                }

#                oDevice = Marshal.GetObjectForIUnknown(pDevice);
#                iDevice = oDevice as IMMDevice;

#                iDevice.GetState(ref state);

#                return result;
#            }

#            /// <summary>
#            /// Get default Audio Device
#            /// </summary>
#            /// <returns></returns>
#            [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
#            static string GetDefaultAudioDeviceId(string type, ERole role)
#            {
#                IntPtr pDefaultDevice = IntPtr.Zero;
#                IntPtr pID = IntPtr.Zero;
#                string id = "";
#                int result = 0;
#                object oDefaultDevice;
#                IMMDevice iDefaultDevice;

#                if (iDeviceEnumerator == null)
#                    return "";

#                result = iDeviceEnumerator.GetDefaultAudioEndpoint(EDataFlow.ERender, role, ref pDefaultDevice);
#                if (result != 0)
#                {
#                    throw new Win32Exception("Can't obtain IMMDevice: " + result);
#                }

#                oDefaultDevice = Marshal.GetObjectForIUnknown(pDefaultDevice);
#                iDefaultDevice = oDefaultDevice as IMMDevice;

#                if (iDefaultDevice != null)
#                {
#                    iDefaultDevice.GetId(ref pID);
#                }

#                id = Marshal.PtrToStringAuto(pID);

#                return id;
#            }


#            /// <summary>
#            /// Call this method to release all com objetcs
#            /// </summary>
#            [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
#            public virtual void Dispose()
#            {
#                if (iDevice != null)
#                {
#                    Marshal.ReleaseComObject(iDevice);
#                    iDevice = null;
#                }
#                if (oDevice != null)
#                {
#                    Marshal.ReleaseComObject(oDevice);
#                    oDevice = null;
#                }
#                if (iDeviceEnumerator != null)
#                {
#                    Marshal.ReleaseComObject(iDeviceEnumerator);
#                    iDeviceEnumerator = null;
#                }
#                if (oEnumerator != null)
#                {
#                    Marshal.ReleaseComObject(oEnumerator);
#                    oEnumerator = null;
#                }
#            }

#            #region Public properties


#            /// <summary>
#            /// Get the default device state.
#            /// </summary>
#            int state;
#            public int State
#            {
#                get
#                {
#                    return state;
#                }
#            }

#            [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2122:DoNotIndirectlyExposeMethodsWithLinkDemands")]
#            public string EndpointId
#            {
#                get
#                {
#                    IntPtr id = IntPtr.Zero;
#                    if (iDevice != null)
#                    {
#                        iDevice.GetId(ref id);
#                    }

#                    return Marshal.PtrToStringAuto(id);
#                }
#            }
#            #endregion

#            #region Public Method

#            public string GetDefaultSpeakerEndpoint()
#            {
#                return GetDefaultAudioDeviceId("speakers", ERole.EConsole);
#            }
#            #endregion
#        }

#        [StructLayout(LayoutKind.Sequential)]
#        public class WAVEFORMATEX
#        {
#            public UInt16 wFormatTag;
#            public UInt16 nChannels;
#            public UInt32 nSamplesPerSec;
#            public UInt32 nAvgBytesPerSec;
#            public UInt16 nBlockAlign;
#            public UInt16 wBitsPerSample;
#            public UInt16 cbSize;
#        }

#        [ComImport, Guid("870AF99C-171D-4f9e-AF0D-E63DF40C2BC9")]
#        public class IPolicyConfigClass { }

#		public static class LoadDLL
#        {

#            [DllImport("AudioDiagnosticUtil.dll", EntryPoint = "AudioGetDeviceFormat", CharSet = CharSet.Auto)]
#            public static extern int AudioGetDeviceFormat(string pszDeviceName, bool bDefault, ref IntPtr ppFormat);

#            [DllImport("AudioDiagnosticUtil.dll", EntryPoint = "AudioSetDeviceFormat", CharSet = CharSet.Auto)]
#            public static extern int AudioSetDeviceFormat(string pszDeviceName, IntPtr pEndpointFormat, IntPtr MixFormat);
#        }

#        public class IPolicyConfigHelper
#        {
            
#            public Byte[] GetDeviceFormat(string pszDeviceName, bool bDefault, out WAVEFORMATEX retFormat)
#            {
#                IntPtr ptrToWaveFormat = new IntPtr();

#                LoadDLL.AudioGetDeviceFormat(pszDeviceName, bDefault, ref ptrToWaveFormat);
#                WAVEFORMATEX format = (WAVEFORMATEX)Marshal.PtrToStructure(ptrToWaveFormat, typeof(WAVEFORMATEX));
#                int formatSize = format.cbSize + Marshal.SizeOf(typeof(WAVEFORMATEX));
#                Byte[] formatExtData = new Byte[format.cbSize + Marshal.SizeOf(typeof(WAVEFORMATEX))];
#                Marshal.Copy(ptrToWaveFormat, formatExtData, 0, formatSize);
#                retFormat = format;
#                return formatExtData;
#            }
#            public int SetDeviceFormat(string pszDeviceName, Byte[] formatExtData, int formatSize)
#            {
#                IntPtr ptrToFormat = Marshal.AllocHGlobal(formatSize);
#                Marshal.Copy(formatExtData, 0, ptrToFormat, formatSize);

#				int rval = LoadDLL.AudioSetDeviceFormat(pszDeviceName, ptrToFormat, IntPtr.Zero);
#                Marshal.FreeHGlobal(ptrToFormat);
#                return rval;
#            }


#        }
    
#        public static bool verifySamplingRate(string deviceID)
#        {
#            EndpointCtrl control = new EndpointCtrl();
#            bool result = false;
#            string defSpeakerEndpoint = deviceID;
#            IPolicyConfigHelper policyHelper = new IPolicyConfigHelper();
#            WAVEFORMATEX defaultFormatEx = new WAVEFORMATEX();
#            WAVEFORMATEX currentFormatEx = new WAVEFORMATEX();
#            Byte[] defaultFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, true, out defaultFormatEx);
#            Byte[] currentFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx);
#            if (defaultFormatEx.nAvgBytesPerSec != currentFormatEx.nAvgBytesPerSec)
#            {
#                result = true;
#            }
#            return result;
#        }
#        public static bool resetSamplingRate(string deviceID)
#        {
#            EndpointCtrl control = new EndpointCtrl();
#            string defSpeakerEndpoint = deviceID;
#            IPolicyConfigHelper policyHelper = new IPolicyConfigHelper();
#            WAVEFORMATEX defaultFormatEx = new WAVEFORMATEX();
#            WAVEFORMATEX currentFormatEx = new WAVEFORMATEX();
#            Byte[] defaultFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, true, out defaultFormatEx);
#            Byte[] currentFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx);

#            policyHelper.SetDeviceFormat(defSpeakerEndpoint, defaultFormat, defaultFormat.Length);
#            WAVEFORMATEX currentFormatEx2 = new WAVEFORMATEX();
#            Byte[] currentFormat2 = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx2);
#            control.Dispose();
#            return true;
#        }
#    }
#}
	
#"@
#    Add-Type -TypeDefinition $audioSampleFormatSource
#    $audioSampleFormat = [Microsoft.Windows.Diagnosis.AudioResetDeviceFormats]

#    return $audioSampleFormat
#}

Function Start-AudioService()
{
	<#
        .DESCRIPTION
           Function to start Audio service forcefully 
        .PARAMETER 
			None
        .OUTPUTS
            None
    #>
	$audioService = (Get-WmiObject -query "select * from win32_baseService where Name='Audiosrv'")
	if($audioService.State -ne "Running")
	{
		Set-Service Audiosrv -StartupType Automatic
		Start-Service Audiosrv -PassThru -ErrorAction SilentlyContinue
	}
}

Function Stop-AudioService()
{
	<#
        .DESCRIPTION
           Function to stop Audio service forcefully 
        .PARAMETER 
			None
        .OUTPUTS
            None
    #>
	$audioService = (Get-WmiObject -query "select * from win32_baseService where Name='Audiosrv'")
	if($audioService.State -eq "Running")
	{
		Stop-Service Audiosrv -PassThru -ErrorAction SilentlyContinue
	}
}

function Get-AudioEndPointsCount
{
	<#
	FUNCTION DESCRIPTION:
		Enum audio active endpoints 

	ARGUMENTS:
		None

	RETURNS:
		Total number of audio endpoints   
#>
	$audioEnumSource = @"
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Runtime.InteropServices;
    using System.ComponentModel;
    using System.Security.Permissions;
    using System.Globalization;

    namespace Microsoft.Windows.Diagnosis
	{
		public static class AudioEnumEndPoints
		{
            public enum EDataFlow
        {
            ERender,
            ECapture,
            EAll,
            EDataFlowEnumCount
        }

            /// <summary>
            /// Used by IMMDeviceEnumerator
            /// </summary>
            public enum ERole
            {
                EConsole,
                EMultimedia,
                ECommunications,
                ERoleEnumCount
            }
            [Flags]
		    enum DEVICE_STATE : uint
		    {
			    DEVICE_STATE_ACTIVE = 0x00000001,
			    DEVICE_STATE_DISABLED = 0x00000002,
			    DEVICE_STATE_NOTPRESENT = 0x00000004,
			    DEVICE_STATE_UNPLUGGED = 0x00000008,
			    DEVICE_STATEMASK_ALL = 0x0000000F
		    }
            internal static class NativeMethods
            {
                [DllImport("ole32.Dll")]
                internal static extern int CoCreateInstance(ref Guid guid, [MarshalAs(UnmanagedType.IUnknown)] object inner, uint context, ref Guid id, [MarshalAs(UnmanagedType.IUnknown)] out object pointer);
            }

        
            #region Private internal vars

            static object oEnumerator;
            static IMMDeviceEnumerator iDeviceEnumerator;
          
         

            #endregion

            #region Interface to COM objects

            const int E_FAIL = 0x00000001;

            static Guid CLSID_MMDeviceEnumerator = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E");
            static Guid IID_IUnknown = new Guid("00000000-0000-0000-C000-000000000046");

            /// <summary>
            /// interface IMMDeviceEnumerator
            /// </summary>
            [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
            interface IMMDeviceEnumerator
            {
                int EnumAudioEndpoints(EDataFlow dataflow, uint mask, ref IntPtr devices);
                int GetDefaultAudioEndpoint(EDataFlow dataflow, ERole role, ref IntPtr endpoint);
                int GetDevice(string id, ref IntPtr device);
                int RegisterEndpointNotificationCallback(IntPtr client);
                int UnregisterEndpointNotificationCallback(IntPtr client);
            }

           
            #endregion
            [Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
            interface IMMDeviceCollection
            {
                //HRESULT GetCount(
                //  [out] UINT* pcDevices
                //);
                int GetCount(out int pcDevices);

                //HRESULT Item(
                //  [in]  UINT nDevice,
                //  [out] IMMDevice** ppDevice
                //);
                int Item(uint nDevice, ref IntPtr ppDevice);
            }
            
            /// <summary>
            /// Get expected Audio Device
            /// </summary>
            /// <returns></returns>
            public static int GetAudioEndPointsCount()
            {
                int result = 0;
                try
                {
                    IntPtr ppDevices = IntPtr.Zero;
                    object oDevices = null;
                    IMMDeviceCollection endpointCollection = null;
                    const uint CLSCTX_INPROC_SERVER = 1;
                    //1.to obtain IMMDeviceEnumerator
                    int result1 = NativeMethods.CoCreateInstance(ref CLSID_MMDeviceEnumerator, null, CLSCTX_INPROC_SERVER, ref IID_IUnknown, out oEnumerator);

                    iDeviceEnumerator = oEnumerator as IMMDeviceEnumerator;
                    int hr = iDeviceEnumerator.EnumAudioEndpoints(EDataFlow.EAll, (uint)DEVICE_STATE.DEVICE_STATE_ACTIVE, ref ppDevices);
                    if (hr != 0)
                    {
                        throw new Exception("HResult from IMMDeviceEnumerator.EnumAudioEndpoints = " + hr);
                    }
                    else if (ppDevices == IntPtr.Zero)
                    {
                        throw new Exception("IMMDeviceEnumerator.EnumAudioEndpoints returned pointer was zero.");
                    }
                    oDevices = Marshal.GetObjectForIUnknown(ppDevices);
                    endpointCollection = oDevices as IMMDeviceCollection;
                    if (endpointCollection == null)
                    {
                        throw new Exception("Could not cast to IMMDeviceCollection");
                    }

                    int deviceCount;
                    hr = endpointCollection.GetCount(out deviceCount);
                    if (hr != 0)
                    {
                        throw new Exception("HResult from IMMDeviceCollection.GetCount = " + hr);
                    }
                    Console.WriteLine(deviceCount.ToString());
                    result = deviceCount;

                }
                catch (InvalidCastException icex)
                {
                    Console.WriteLine("Unexpected COM exception: " + icex.Message);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
                return result;
            
            }
        }
    }

"@

    Add-Type -TypeDefinition $audioEnumSource
	$audioEndpoints = [Microsoft.Windows.Diagnosis.AudioEnumEndPoints]

	# Call IAudioClient::Initialize on all the Active endpoints
	$result = $audioEndpoints::GetAudioEndPointsCount()
	return $result
}

Function Get-AudioDriverSource32
{
    <#
        .DESCRIPTION
           Function get driver resources of the specific audio device on 32 bit OS
        .PARAMETER 
			None
        .OUTPUTS
            Returns data type of get driver resources
    #>
    $ChangeAudioDriverSource32 = @"
using System;
using System.Runtime.InteropServices;
namespace Microsoft.Windows.Diagnosis
{
	public static class ChangeAudioDriver32
    {
        public enum DIOD
        {
            None = (0),
            CANCEL_REMOVE = (0x00000004),
            // If this flag is specified and the device had been marked for pending removal, the OS cancels the pending removal. 
            INHERIT_CLASSDRVS = (0x00000002)
            //the resulting device information element inherits the class driver list, if any
        }

        public enum DICD
        {
            None = (0),
            GENERATE_ID = (0x00000001), // create unique device instance key
            INHERIT_CLASSDRVS = (0x00000002)  // inherit class driver list
        }

        public enum SPDIT
        {
            None = (0),
            SPDIT_COMPATDRIVER = (0x00000002), // Build a list of compatible drivers
            SPDIT_CLASSDRIVER = (0x00000001)  // Build a list of class drivers
        }

        public enum DI_FLAGS
        {
             DI_FLAGSEX_INSTALLEDDRIVER = (0x04000000),
             DI_FLAGSEX_ALLOWEXCLUDEDDRVS = (0x00000800)
        }

        [StructLayout(LayoutKind.Sequential)]
        public class SP_DEVINFO_DATA
        {
            /// <summary>
            /// Size of the structure, in bytes. 
            /// </summary>
            public Int32 cbSize = Marshal.SizeOf(typeof(SP_DEVINFO_DATA));

            /// <summary>
            /// GUID of the device interface class. 
            /// </summary>
            public Guid ClassGuid;

            /// <summary>
            /// Handle to this device instance. 
            /// </summary>
            public Int32 DevInst;

            /// <summary>
            /// Reserved; do not use. 
            /// </summary>
            public IntPtr Reserved;
        }
        // 64 bit: Pack=4
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack=1)]
        public class SP_DRVINFO_DATA
        {
            public Int32 cbSize;
            public Int32 DriverType;
            public IntPtr Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String Description;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String MfgName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String ProviderName;
            public System.Runtime.InteropServices.ComTypes.FILETIME DriverDate;
            public Int64 DriverVersion;
        }
        // 64 bit: Pack=8
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 1)]
        public class SP_DRVINFO_DETAIL_DATA
        {
            public Int32 cbSize;
            public System.Runtime.InteropServices.ComTypes.FILETIME InfDate;
            public Int32 CompatIDsOffset;
            public Int32 CompatIDsLength;
            public IntPtr Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string SectionName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string InfFileName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string DrvDescription;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 1)]
            public string HardwareID;
        }
        // 64 bit: Pack=8
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 4)]
        public class SP_DEVINSTALL_PARAMS
        {
            public Int32 cbSize;
            public Int32 Flags;
            public DI_FLAGS FlagsEx;
            public IntPtr hwndParent;
            public IntPtr InstallMsgHandler;
            public IntPtr InstallMsgHandlerContext;
            public IntPtr FileQueue;
            public UIntPtr ClassInstallReserved;
            public Int32 Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string DriverPath;
        }

        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiOpenDeviceInfo(
            IntPtr DeviceInfoSet,
            string device,
            IntPtr handleToWindow,
            DIOD flag,
            SP_DEVINFO_DATA deviceInfoData
            );
        [DllImport("Setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public extern static IntPtr SetupDiCreateDeviceInfoList
            (
            IntPtr ClassGuid,
            IntPtr hwndParent
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiBuildDriverInfoList(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SPDIT DriverType
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiEnumDriverInfo(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SPDIT DriverType,
            int MemberIndex,
            [In, Out] SP_DRVINFO_DATA DriverInfoData
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiGetDriverInfoDetail(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DRVINFO_DATA DriverInfoData,
            [In, Out] SP_DRVINFO_DETAIL_DATA DriverInfoDetailData,
            int DriverInfoDetailDataSize,
            out int RequiredSize
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiSetDeviceInstallParams(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DEVINSTALL_PARAMS DeviceInstallParams
            );
        [DllImport("Newdev.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool DiInstallDevice(
            IntPtr hwndParent,
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DRVINFO_DATA DriverInfoData,
            int Flags,
            out bool rebootRequired            
            );

		[DllImport("Newdev.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool DiInstallDriver
        (
            [In] IntPtr hwndParent,
            [In] string FullInfPath,
            [In] uint Flags,
            [Out] bool NeedReboot
        );

        public static int ForceInstallDriver(string deviceId, string infPath)
        {
            int error = 0;
            IntPtr hDevSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            SP_DEVINFO_DATA deviceInfoData = new SP_DEVINFO_DATA();
            bool bRet = SetupDiOpenDeviceInfo(hDevSet, deviceId, IntPtr.Zero, 0, deviceInfoData);
            if (bRet == false)
            {
                return Marshal.GetLastWin32Error();
            }

            bRet = SetupDiBuildDriverInfoList(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER);
            if (bRet == false)
            {
                return Marshal.GetLastWin32Error();
            }
            int driverItr = 0;
            bool bResult = true;
            while (bResult)
            {
                SP_DRVINFO_DATA driverInfoData = new SP_DRVINFO_DATA();
                driverInfoData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DATA));
                bRet = SetupDiEnumDriverInfo(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER, driverItr, driverInfoData);
                if (bRet == false)
                {
                    return Marshal.GetLastWin32Error();
                }

                int requiredSize = 0;
                SP_DRVINFO_DETAIL_DATA driverInfoDetailData = new SP_DRVINFO_DETAIL_DATA();
                driverInfoDetailData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DETAIL_DATA));
                int dataSize = Marshal.SizeOf(driverInfoDetailData);

                bRet = SetupDiGetDriverInfoDetail(hDevSet, deviceInfoData, driverInfoData, driverInfoDetailData, dataSize, out requiredSize);
                if (bRet == false)
                {
                    error = Marshal.GetLastWin32Error();
                    //122 - ERROR_INSUFFICIENT_BUFFER, expected error
                    if (error != 122)
                    {
                        Marshal.GetLastWin32Error();
                    }
                }

                if (driverInfoDetailData.InfFileName != null && driverInfoDetailData.InfFileName.Contains(infPath))
                {
                    bool bReboot = false;
                    //bRet = DiInstallDevice(IntPtr.Zero, hDevSet, deviceInfoData, driverInfoData, 0, out bReboot);
					//DIIRFLAG_FORCE_INF = 0x00000002 to force windows to honor the driver installation
					bRet = DiInstallDriver(IntPtr.Zero, driverInfoDetailData.InfFileName, 2, bReboot);
                    if (bRet == false)
                    {
                        error = Marshal.GetLastWin32Error();
                        driverItr++;
                        continue;
                    }
                    else
                    {
                        return 0;
                    }
                }
                driverItr++;
            }
            return -1;
        }
        public static int ForceInstallHDAudio(string deviceId)
        {
            return ForceInstallDriver(deviceId, "hdaudio.inf");
        }

        public static string GetCurrentDriverINF(string deviceId)
        {
            string infPath = "ErrorFindingINF";
            int error = 0;
            IntPtr hDevSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            SP_DEVINFO_DATA deviceInfoData = new SP_DEVINFO_DATA();

            bool bRet = SetupDiOpenDeviceInfo(hDevSet, deviceId, IntPtr.Zero, 0, deviceInfoData);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }

            // Get Currently Installed Driver
            SP_DEVINSTALL_PARAMS deviceInstallParams = new SP_DEVINSTALL_PARAMS();
            deviceInstallParams.cbSize = Marshal.SizeOf(typeof(SP_DEVINSTALL_PARAMS));
            deviceInstallParams.FlagsEx = DI_FLAGS.DI_FLAGSEX_ALLOWEXCLUDEDDRVS | DI_FLAGS.DI_FLAGSEX_INSTALLEDDRIVER;
            bRet = SetupDiSetDeviceInstallParams(hDevSet, deviceInfoData, deviceInstallParams);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }

            bRet = SetupDiBuildDriverInfoList(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }
            int driverItr = 0;
           
            SP_DRVINFO_DATA driverInfoData = new SP_DRVINFO_DATA();
            driverInfoData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DATA));
            bRet = SetupDiEnumDriverInfo(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER, driverItr, driverInfoData);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }
            int requiredSize = 0;
            SP_DRVINFO_DETAIL_DATA driverInfoDetailData = new SP_DRVINFO_DETAIL_DATA();
            driverInfoDetailData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DETAIL_DATA));
            int dataSize = Marshal.SizeOf(driverInfoDetailData);
            // First get the required size
            bRet = SetupDiGetDriverInfoDetail(hDevSet, deviceInfoData, driverInfoData, driverInfoDetailData, dataSize, out requiredSize);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                //122 - ERROR_INSUFFICIENT_BUFFER, expected error
                if (error != 122)
                {
                    return infPath;
                }
            }

            if (driverInfoDetailData.InfFileName != null)
            {
                infPath = driverInfoDetailData.InfFileName;
            }
            return infPath;
        }
    }
}
"@
    Add-Type -TypeDefinition $ChangeAudioDriverSource32
    $driverSource = [Microsoft.Windows.Diagnosis.ChangeAudioDriver32]
    return $driverSource
}

Function Get-AudioDriverSource
{
    <#
        .DESCRIPTION
           Function get driver resources of the specific audio device on 64 bit OS
        .PARAMETER 
			None
        .OUTPUTS
            Returns data type of get driver resources
    #>
     $ChangeAudioDriverSource = @"
using System;
using System.Runtime.InteropServices;
namespace Microsoft.Windows.Diagnosis
{
    public static class ChangeAudioDriver
    {
        public enum DIOD
        {
            None = (0),
            CANCEL_REMOVE = (0x00000004),
            // If this flag is specified and the device had been marked for pending removal, the OS cancels the pending removal. 
            INHERIT_CLASSDRVS = (0x00000002)
            //the resulting device information element inherits the class driver list, if any
        }

        public enum DICD
        {
            None = (0),
            GENERATE_ID = (0x00000001), // create unique device instance key
            INHERIT_CLASSDRVS = (0x00000002)  // inherit class driver list
        }

        public enum SPDIT
        {
            None = (0),
            SPDIT_COMPATDRIVER = (0x00000002), // Build a list of compatible drivers
            SPDIT_CLASSDRIVER = (0x00000001)  // Build a list of class drivers
        }

        public enum DI_FLAGS
        {
             DI_FLAGSEX_INSTALLEDDRIVER = (0x04000000),
             DI_FLAGSEX_ALLOWEXCLUDEDDRVS = (0x00000800)
        }

        [StructLayout(LayoutKind.Sequential)]
        public class SP_DEVINFO_DATA
        {
            /// <summary>
            /// Size of the structure, in bytes. 
            /// </summary>
            public Int32 cbSize = Marshal.SizeOf(typeof(SP_DEVINFO_DATA));

            /// <summary>
            /// GUID of the device interface class. 
            /// </summary>
            public Guid ClassGuid;

            /// <summary>
            /// Handle to this device instance. 
            /// </summary>
            public Int32 DevInst;

            /// <summary>
            /// Reserved; do not use. 
            /// </summary>
            public IntPtr Reserved;
        }
        // 64 bit: Pack=4
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack=4)]
        public class SP_DRVINFO_DATA
        {
            public Int32 cbSize;
            public Int32 DriverType;
            public IntPtr Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String Description;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String MfgName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public String ProviderName;
            public System.Runtime.InteropServices.ComTypes.FILETIME DriverDate;
            public Int64 DriverVersion;
        }
        // 64 bit: Pack=8
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 8)]
        public class SP_DRVINFO_DETAIL_DATA
        {
            public Int32 cbSize;
            public System.Runtime.InteropServices.ComTypes.FILETIME InfDate;
            public Int32 CompatIDsOffset;
            public Int32 CompatIDsLength;
            public IntPtr Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string SectionName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string InfFileName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string DrvDescription;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 1)]
            public string HardwareID;
        }
        // 64 bit: Pack=8
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 8)]
        public class SP_DEVINSTALL_PARAMS
        {
            public Int32 cbSize;
            public Int32 Flags;
            public DI_FLAGS FlagsEx;
            public IntPtr hwndParent;
            public IntPtr InstallMsgHandler;
            public IntPtr InstallMsgHandlerContext;
            public IntPtr FileQueue;
            public UIntPtr ClassInstallReserved;
            public Int32 Reserved;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string DriverPath;
        }

        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiOpenDeviceInfo(
            IntPtr DeviceInfoSet,
            string device,
            IntPtr handleToWindow,
            DIOD flag,
            SP_DEVINFO_DATA deviceInfoData
            );
        [DllImport("Setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public extern static IntPtr SetupDiCreateDeviceInfoList
            (
            IntPtr ClassGuid,
            IntPtr hwndParent
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiBuildDriverInfoList(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SPDIT DriverType
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiEnumDriverInfo(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SPDIT DriverType,
            int MemberIndex,
            [In, Out] SP_DRVINFO_DATA DriverInfoData
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiGetDriverInfoDetail(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DRVINFO_DATA DriverInfoData,
            [In, Out] SP_DRVINFO_DETAIL_DATA DriverInfoDetailData,
            int DriverInfoDetailDataSize,
            out int RequiredSize
            );
        [DllImport("Setupapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetupDiSetDeviceInstallParams(
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DEVINSTALL_PARAMS DeviceInstallParams
            );
        [DllImport("Newdev.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool DiInstallDevice(
            IntPtr hwndParent,
            IntPtr DeviceInfoSet,
            SP_DEVINFO_DATA DeviceInfoData,
            SP_DRVINFO_DATA DriverInfoData,
            int Flags,
            out bool rebootRequired            
            );

		[DllImport("Newdev.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool DiInstallDriver
        (
            [In] IntPtr hwndParent,
            [In] string FullInfPath,
            [In] uint Flags,
            [Out] bool NeedReboot
        );

        public static int ForceInstallDriver(string deviceId, string infPath)
        {
            int error = 0;
            IntPtr hDevSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            SP_DEVINFO_DATA deviceInfoData = new SP_DEVINFO_DATA();
            bool bRet = SetupDiOpenDeviceInfo(hDevSet, deviceId, IntPtr.Zero, 0, deviceInfoData);
            if (bRet == false)
            {
                return Marshal.GetLastWin32Error();
            }

            bRet = SetupDiBuildDriverInfoList(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER);
            if (bRet == false)
            {
                return Marshal.GetLastWin32Error();
            }
            int driverItr = 0;
            bool bResult = true;
            while (bResult)
            {
                SP_DRVINFO_DATA driverInfoData = new SP_DRVINFO_DATA();
                driverInfoData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DATA));
                bRet = SetupDiEnumDriverInfo(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER, driverItr, driverInfoData);
                if (bRet == false)
                {
                    return Marshal.GetLastWin32Error();
                }

                int requiredSize = 0;
                SP_DRVINFO_DETAIL_DATA driverInfoDetailData = new SP_DRVINFO_DETAIL_DATA();
                driverInfoDetailData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DETAIL_DATA));
                int dataSize = Marshal.SizeOf(driverInfoDetailData);

                bRet = SetupDiGetDriverInfoDetail(hDevSet, deviceInfoData, driverInfoData, driverInfoDetailData, dataSize, out requiredSize);
                if (bRet == false)
                {
                    error = Marshal.GetLastWin32Error();
                    //122 - ERROR_INSUFFICIENT_BUFFER, expected error
                    if (error != 122)
                    {
                        Marshal.GetLastWin32Error();
                    }
                }

                if (driverInfoDetailData.InfFileName != null && driverInfoDetailData.InfFileName.Contains(infPath))
                {
                    bool bReboot = false;
                    //bRet = DiInstallDevice(IntPtr.Zero, hDevSet, deviceInfoData, driverInfoData, 0, out bReboot);
					//DIIRFLAG_FORCE_INF = 0x00000002 to force windows to honor the driver installation
					bRet = DiInstallDriver(IntPtr.Zero, driverInfoDetailData.InfFileName, 2, bReboot);
                    if (bRet == false)
                    {
                        error = Marshal.GetLastWin32Error();
                        driverItr++;
                        continue;
                    }
                    else
                    {
                        return 0;
                    }
                }
                driverItr++;
            }
            return -1;
        }
        public static int ForceInstallHDAudio(string deviceId)
        {
            return ForceInstallDriver(deviceId, "hdaudio.inf");
        }

        public static string GetCurrentDriverINF(string deviceId)
        {
            string infPath = "ErrorFindingINF";
            int error = 0;
            IntPtr hDevSet = SetupDiCreateDeviceInfoList(IntPtr.Zero, IntPtr.Zero);
            SP_DEVINFO_DATA deviceInfoData = new SP_DEVINFO_DATA();

            bool bRet = SetupDiOpenDeviceInfo(hDevSet, deviceId, IntPtr.Zero, 0, deviceInfoData);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }

            // Get Currently Installed Driver
            SP_DEVINSTALL_PARAMS deviceInstallParams = new SP_DEVINSTALL_PARAMS();
            deviceInstallParams.cbSize = Marshal.SizeOf(typeof(SP_DEVINSTALL_PARAMS));
            deviceInstallParams.FlagsEx = DI_FLAGS.DI_FLAGSEX_ALLOWEXCLUDEDDRVS | DI_FLAGS.DI_FLAGSEX_INSTALLEDDRIVER;
            bRet = SetupDiSetDeviceInstallParams(hDevSet, deviceInfoData, deviceInstallParams);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }

            bRet = SetupDiBuildDriverInfoList(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }
            int driverItr = 0;
           
            SP_DRVINFO_DATA driverInfoData = new SP_DRVINFO_DATA();
            driverInfoData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DATA));
            bRet = SetupDiEnumDriverInfo(hDevSet, deviceInfoData, SPDIT.SPDIT_COMPATDRIVER, driverItr, driverInfoData);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                return infPath;
            }
            int requiredSize = 0;
            SP_DRVINFO_DETAIL_DATA driverInfoDetailData = new SP_DRVINFO_DETAIL_DATA();
            driverInfoDetailData.cbSize = Marshal.SizeOf(typeof(SP_DRVINFO_DETAIL_DATA));
            int dataSize = Marshal.SizeOf(driverInfoDetailData);
            // First get the required size
            bRet = SetupDiGetDriverInfoDetail(hDevSet, deviceInfoData, driverInfoData, driverInfoDetailData, dataSize, out requiredSize);
            if (bRet == false)
            {
                error = Marshal.GetLastWin32Error();
                //122 - ERROR_INSUFFICIENT_BUFFER, expected error
                if (error != 122)
                {
                    return infPath;
                }
            }

            if (driverInfoDetailData.InfFileName != null)
            {
                infPath = driverInfoDetailData.InfFileName;
            }
            return infPath;
        }
    }
}
"@
    Add-Type -TypeDefinition $ChangeAudioDriverSource
    $driverSource = [Microsoft.Windows.Diagnosis.ChangeAudioDriver]
    return $driverSource
}

Function PlaySound()
{
	<#
        .DESCRIPTION
           Function Play windows default sound file thrice
        .PARAMETER 
			None
        .OUTPUTS
            None
    #>
	$count = 1
	while($count -le 3)
	{
		$count++
		$playSound = (new-object Media.SoundPlayer  "$env:SystemDrive\Windows\Media\notify.wav").play()
		Start-Sleep 1
	}
}

Function Get-HDAudioID($deviceTypes)
{
	<#
        .DESCRIPTION
           Function to get the device ID of HD audio driver
        .PARAMETER 
			None
        .OUTPUTS
            Array of device ID
    #>
    try 
    {
        $devices = @()
        $devIds = @()
	    [string]$deviceFlow = $endPointtype
        $audioDevices = Get-WmiObject Win32_SoundDevice
        foreach ($device in $audioDevices)
        {

	        $pnpdevid = $device.PNPDeviceID

            $pnpSignedDriver = Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object -FilterScript {$_.DeviceID -eq $pnpdevid}
            $infname = $pnpSignedDriver.InfName
	        $infname = $infname.ToLower()
	        if($infname.Contains("hdaudio"))
	        {
                $devName = $pnpSignedDriver.DeviceName
                break
            }
        }    
		
		$EndPointListID_HDAudioID = @()
		$AudioMethods_HDAudioID = Get-AudioEndpoints
		$EndPointListID_HDAudioID = $AudioMethods_HDAudioID::GetAudioEndPointsbyType($deviceTypes)
		$devices += $EndPointListID_HDAudioID.ForEach({[PSCustomObject]$_})

        foreach($devs in $devices)
		{
			$devId = GetId $devs
            $deviceName = GetAdapterName $devs
            if($deviceName.Contains($devName))
            {
                $devIds += $devId
            }
        }
    }
	catch
	{
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "CL_Utility" -Name "CL_Utility" -Verbosity Debug
	}
    
	return $devIds
}


function Set-AudioEndpointProperty($deviceType)
{
	<#
        .DESCRIPTION
           Function to set property related to audio MMdevice
        .PARAMETER 
			None
        .OUTPUTS
            Bool value True if property is set else false
    #>
	$flag = $false
	$ids = @()
	$ids = Get-HDAudioID $deviceTypes
	Get-AudioManager
	foreach($id in $ids)
	{
		if(!([String]::IsNullOrEmpty($id)))
		{
			try
			{
					$returnValue = [Microsoft.Windows.Diagnosis.AudioConfigManager]::SetAudioProperty($id)
					if($returnValue -eq "0")
					{
						$flag = $true
					}
			}
			catch [System.Exception]
			{
				Write-ExceptionTelemetry "Set-AudioEndpointProperty" $_

				$errorMsg =  $_.Exception.Message
				$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "CL_Utility" -Name "CL_Utility" -Verbosity Debug
			}
		}
	}
	return $flag
}


Function Get-AudioEndpoints()
{
<#
	DESCRIPTION:
	  Load the module related to Audio EndPointCtrl and get and set the default sampling rate of specific the audio device .

	ARGUMENTS:
	  None

	RETURNS:
	  AudioResetDeviceFormats Type 
#>
$AudioEndpointsSource = @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Security.Permissions;
using System.Globalization;

namespace Microsoft.Windows.Diagnosis
{
     public static class AudioResetDeviceFormats
        {
            /// <summary>
            /// Used by IMMDeviceEnumerator
            /// </summary>
            public enum EDataFlow
            {
                ERender,
                ECapture,
                EAll,
                EDataFlowEnumCount
            }

            public enum DeviceState
            {
                Active = 0x00000001,
                Disabled = 0x00000002,
                NotPresent = 0x00000004,
                Unplugged = 0x00000008,
                All = 0x0000000f
            }

            /// <summary>
            /// Used by IMMDeviceEnumerator
            /// </summary>
            public enum ERole
            {
                EConsole,
                EMultimedia,
                ECommunications,
                ERoleEnumCount
            }

            /// <summary>
            /// PROPVARIANT, Used by IMMDevice::OpenPropertyStore
            /// </summary>
            [StructLayout(LayoutKind.Explicit)]
            private struct UnionMembers
            {
                [FieldOffset(0)]
                public IntPtr deviceName;
                [FieldOffset(0)]
                public uint deviceTypeValue;
            }

            [StructLayout(LayoutKind.Sequential, Size = 32)]
            private struct PROPVARIANT
            {
                private ushort variantType;
                private short reserved1;
                private short reserved2;
                private short reserved3;
                private UnionMembers unionmembers;

                public string DeviceName
                {
                    get
                    {

                        return Marshal.PtrToStringAuto(this.unionmembers.deviceName);
                    }
                }

                public uint DeviceTypeValue
                {
                    get
                    {
                        return this.unionmembers.deviceTypeValue;
                    }
                }
            }
            internal static class NativeMethods
            {
                [DllImport("ole32.Dll")]
                internal static extern int CoCreateInstance(ref Guid guid, [MarshalAs(UnmanagedType.IUnknown)] object inner, uint context, ref Guid id, [MarshalAs(UnmanagedType.IUnknown)] out object pointer);
            }

            public class EndpointList
            {
                public EndpointList(string deviceDes, string deviceId, string adapterName, int jackInfo, bool isDefault,int State)
                {
                    this.deviceDes = deviceDes;
                    this.deviceId = deviceId;
                    this.adapterName = adapterName;
                    this.jackInfo = jackInfo;
                    this.isDefault = isDefault;
                    this.state = State;

                }

                private string adapterName;
                public string AdapterName
                {
                    get
                    {
                        return adapterName;
                    }
                }

                private string deviceDes;
                public string DeviceDes
                {
                    get
                    {
                        return deviceDes;
                    }
                }

                private string deviceId;
                public string DeviceId
                {
                    get
                    {
                        return deviceId;
                    }
                }
                private int jackInfo;
                public int JackInfo
                {
                    get
                    {
                        return jackInfo;
                    }
                }
                private bool isDefault;
                public bool IsDefault
                {
                    get
                    {
                        return isDefault;
                    }
                }

                private int state;
                public int State
                {
                    get
                    {
                        return state;
                    }
                 
                }

            }

            public class EndpointCtrl
            {
                #region Private internal vars

                static object oEnumerator;
                static IMMDeviceEnumerator iDeviceEnumerator;
                static object oDevices;
                static IMMDevices iDeviceCollection;
                static object oDevice;
                static IMMDevice iDevice;

                static object oProperty;
                static IPropertyStore iProperty;

                #endregion

                #region Interface to COM objects

                const int E_FAIL = 0x00000001;
                const int STGM_READ = 0x00000000;
                const int STGM_WRITE = 0x00000001;
                const int STGM_READWRITE = 0x00000002;

                static Guid CLSID_MMDeviceEnumerator = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E");
                static Guid IID_IUnknown = new Guid("00000000-0000-0000-C000-000000000046");
                static Guid IID_IDeviceTopology = new Guid("2A07407E-6497-4A18-9787-32F79BD0D98F");
                static Guid IID_IPart = new Guid("AE2DE0E4-5BCA-4F2D-AA46-5D13F8FDB3A9");
                static Guid IID_IKsJackDescription = new Guid("4509F757-2D46-4637-8E62-CE7DB944F57B");
                static int jackErrorInfo = 0;


                static PropertyKey PKEY_Device_DeviceDesc = new PropertyKey(new Guid("A45C254E-DF1C-4EFD-8020-67D146A850E0"), 2);
                static PropertyKey PKEY_AudioEndpoint_FormFactor = new PropertyKey(new Guid("1DA5D803-D492-4EDD-8C23-E0C0FFEE7F0E"), 0);
                static PropertyKey PKEY_DeviceInterface_FriendlyName = new PropertyKey(new Guid("026e516e-b814-414b-83cd-856d6fef4822"), 2);



                /// <summary>
                /// Interface IPropertyStore
                /// </summary>
                [Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                private interface IPropertyStore
                {

                    //virtual HRESULT STDMETHODCALLTYPE GetCount(/* [out] */ __RPC__out DWORD *cProps) = 0;

                    int GetCount(ref uint props);

                    //virtual HRESULT STDMETHODCALLTYPE GetAt( /* [in] */ DWORD iProp, /* [out] */ __RPC__out PROPERTYKEY *pkey) = 0;

                    int GetAt(uint prop, ref PropertyKey key);

                    //virtual HRESULT STDMETHODCALLTYPE GetValue(/* [in] */ __RPC__in REFPROPERTYKEY key, /* [out] */ __RPC__out PROPVARIANT *pv) = 0;

                    int GetValue(ref PropertyKey key, ref PROPVARIANT variant);
                    //int GetValue([MarshalAs(UnmanagedType.Struct)]ref PropertyKey key, [MarshalAs(UnmanagedType.Struct)]ref PROPVARIANT variant);

                    //virtual HRESULT STDMETHODCALLTYPE SetValue(/* [in] */ __RPC__in REFPROPERTYKEY key, /* [in] */ __RPC__in REFPROPVARIANT propvar) = 0;

                    int SetValue(ref PropertyKey key, ref PROPVARIANT variant);

                    //virtual HRESULT STDMETHODCALLTYPE Commit( void) = 0;

                    int Commit();
                }

                /// <summary>
                /// interface IMMDevice
                /// </summary>
                [Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                private interface IMMDevice
                {
                    int Activate(ref Guid guid, uint context, IntPtr parameters, ref IntPtr pointer);
                    int OpenPropertyStore(uint access, ref IntPtr properties);
                    int GetId(ref IntPtr id);
                    int GetState(ref int state);
                }

                /// <summary>
                /// interface IMMDeviceCollection
                /// </summary>
                [Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                private interface IMMDevices
                {
                    //HRESULT GetCount([out, annotation("__out")] UINT* pcDevices);

                    int GetCount(ref uint pcDevices);

                    //HRESULT Item([in, annotation("__in")]UINT nDevice, [out, annotation("__out")] IMMDevice** ppDevice);

                    int Item(uint deviceId, ref IntPtr ppDevice);
                }

                /// <summary>
                /// interface IMMDeviceEnumerator
                /// </summary>
                [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                interface IMMDeviceEnumerator
                {
                    int EnumAudioEndpoints(EDataFlow dataflow, int mask, ref IntPtr devices);
                    int GetDefaultAudioEndpoint(EDataFlow dataflow, ERole role, ref IntPtr endpoint);
                    int GetDevice(string id, ref IntPtr device);
                    int RegisterEndpointNotificationCallback(IntPtr client);
                    int UnregisterEndpointNotificationCallback(IntPtr client);
                }

                [Guid("2A07407E-6497-4A18-9787-32F79BD0D98F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                internal interface IDeviceTopology
                {
                    int GetConnectorCount(ref uint pConnectorCount);

                    int GetConnector(uint nIndex, ref IntPtr ppConnector);

                    int GetSubunitCount(ref uint pCount);

                    int GetSubunit(uint nIndex, ref IntPtr ppSubunit);

                    int GetPartById(uint nId, ref IntPtr ppPart);

                    int GetDeviceId(ref IntPtr ppwstrDeviceId);

                    int GetSignalPath(IntPtr pIPartFrom, IntPtr pIPartTo, bool bRejectMixedPaths, ref IntPtr ppParts);
                }

                [Guid("9C2C4058-23F5-41DE-877A-DF3AF236A09E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                internal interface IConnector
                {
                    int GetType(ref int pType);
                    int GetDataFlow(ref int pFlow);
                    int ConnectTo(ref IntPtr pConnectTo);
                    int Disconnect();
                    int IsConnected(ref bool pbConnected);
                    int GetConnectedTo(ref IntPtr ppConTo);
                    int GetConnectorIdConnectedTo(ref IntPtr ppwstrConnectorId);
                    int GetDeviceIdConnectedTo(ref IntPtr ppwstrDeviceId);
                }

                [Guid("AE2DE0E4-5BCA-4F2D-AA46-5D13F8FDB3A9"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                internal interface IPart
                {
                    int GetName(ref string ppwstrName);
                    int GetLocalId(ref uint pnId);
                    int GetGlobalId(ref IntPtr ppwstrGlobalId);
                    int GetPartType(IntPtr pPartType);
                    int GetSubType(ref Guid pSubType);
                    int GetControlInterfaceCount(ref uint pCount);
                    int GetControlInterface(uint nIndex, ref IntPtr ppInterfaceDesc);
                    int EnumPartsIncoming(ref IntPtr ppParts);
                    int EnumPartsOutgoing(ref IntPtr ppParts);
                    int GetTopologyObject(ref IntPtr ppTopology);
                    int Activate(int dwClsContext, ref Guid refiid, ref IntPtr ppvObject);
                    int RegisterControlChangeCallback(ref Guid riid, IntPtr pNotify);
                    int UnregisterControlChangeCallback(IntPtr pNotify);
                }

                [Guid("4509F757-2D46-4637-8E62-CE7DB944F57B"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                internal interface IKsJackDescription
                {
                    int GetJackCount(ref uint pcJacks);
                    int GetJackDescription(uint nJack, out KSJACK_DESCRIPTION pDescription);
                }

                [StructLayout(LayoutKind.Sequential)]
                internal struct KSJACK_DESCRIPTION
                {
                    internal int ChannelMapping;
                    internal int Color;
                    internal uint ConnectionType;
                    internal uint GeoLocation;
                    internal uint GenLocation;
                    internal uint PortConnection;
                    internal bool IsConnected;
                }

                private struct PropertyKey
                {
                    public PropertyKey(Guid initId, uint initPid)
                    {
                        id = initId;
                        pid = initPid;
                    }

                    Guid id;
                    uint pid;
                }

                private static bool comInitialized;
                #endregion

                /// <summary>
                /// Constructor, initialize com interfaces
                /// </summary>
                internal EndpointCtrl()
                {
                    int result = 0;
                    //1.to obtain IMMDeviceEnumerator
                    result = InitializedInstance();
                    if (result != 0)
                    {
                        throw new Win32Exception("Can't obtain IMMDeviceEnumerator: " + result);
                    }

                    //2.to obtain IMMDevice by IMMDeviceEnumerator
                    //result = GetAudioDevice(deviceId);
                    if (result != 0)
                    {
                        throw new Win32Exception("Can't obtain IMMDevice: " + result);
                    }
                }

                /// <summary>
                /// initialize com interfaces and get IMMDeviceEnumerator
                /// </summary>
                /// <returns></returns>
                private static int InitializedInstance()
                {
                    if (comInitialized == true)
                    {
                        return 0;
                    }

                    const uint CLSCTX_INPROC_SERVER = 1;

                    //1.to obtain IMMDeviceEnumerator
                    int result = NativeMethods.CoCreateInstance(ref CLSID_MMDeviceEnumerator, null, CLSCTX_INPROC_SERVER, ref IID_IUnknown, out oEnumerator);
                    if (result != 0)
                    {
                        return result;
                    }

                    comInitialized = true;

                    if (oEnumerator == null)
                    {
                        return E_FAIL;
                    }

                    iDeviceEnumerator = oEnumerator as IMMDeviceEnumerator;

                    if (iDeviceEnumerator == null)
                    {
                        return E_FAIL;
                    }

                    return result;
                }

                /// <summary>
                /// Jack Info method
                /// </summary>
                /// <param name="iDevice"></param>
                /// <returns></returns>
                private static int GetJackInfo(IMMDevice iDevice)
                {
                    IDeviceTopology deviceTopology = null;
                    IConnector connFrom = null;
                    IConnector connTo = null;
                    IPart part = null;
                    IKsJackDescription jackDesc = null;
                    IntPtr tempIntPtr = IntPtr.Zero;
                    IntPtr pPart = IntPtr.Zero;
                    object tempObject = null;
                    uint nJacks = 0;
                    const uint CLSCTX_ALL = 23;
                    int result = 0;
                    int jackInfo = -1;

                    if (iDevice == null)
                    {
                        throw new Exception("No device is specified");
                    }

                    result = iDevice.Activate(ref IID_IDeviceTopology, CLSCTX_ALL, IntPtr.Zero, ref tempIntPtr);
                    if (result != 0 || tempIntPtr == IntPtr.Zero)
                    {
                        return jackErrorInfo;
                    }
                    tempObject = Marshal.GetObjectForIUnknown(tempIntPtr);
                    deviceTopology = tempObject as IDeviceTopology;

                    tempIntPtr = IntPtr.Zero;
                    tempObject = null;
                    result = deviceTopology.GetConnector(0, ref tempIntPtr);
                    if (result != 0 || tempIntPtr == IntPtr.Zero)
                    {
                        return jackErrorInfo;
                    }
                    tempObject = Marshal.GetObjectForIUnknown(tempIntPtr);
                    connFrom = tempObject as IConnector;

                    tempIntPtr = IntPtr.Zero;
                    tempObject = null;
                    result = connFrom.GetConnectedTo(ref tempIntPtr);
                    if (result != 0 || tempIntPtr == IntPtr.Zero)
                    {
                        return jackErrorInfo;
                    }
                    tempObject = Marshal.GetObjectForIUnknown(tempIntPtr);
                    connTo = tempObject as IConnector;

                    tempObject = null;
                    result = Marshal.QueryInterface(tempIntPtr, ref IID_IPart, out pPart);
                    if (result != 0 || pPart == IntPtr.Zero)
                    {
                        return jackErrorInfo;
                    }
                    tempObject = Marshal.GetObjectForIUnknown(pPart);
                    part = tempObject as IPart;

                    tempIntPtr = IntPtr.Zero;
                    tempObject = null;
                    try
                    {
                        result = part.Activate(1, ref IID_IKsJackDescription, ref tempIntPtr);
                    }
                    catch
                    {
                        return jackErrorInfo;
                    }
                    if (result != 0 || tempIntPtr == IntPtr.Zero)
                    {
                        return jackErrorInfo;
                    }

                    tempObject = Marshal.GetObjectForIUnknown(tempIntPtr);
                    jackDesc = tempObject as IKsJackDescription;

                    result = jackDesc.GetJackCount(ref nJacks);
                    for (uint iJack = 0; iJack < nJacks; iJack++)
                    {
                        KSJACK_DESCRIPTION JackDescription = new KSJACK_DESCRIPTION();
                        result = jackDesc.GetJackDescription(iJack, out JackDescription);
                        if (result != 0)
                        {
                            return jackErrorInfo;
                        }

                        jackInfo = (int)JackDescription.GeoLocation;
                    }

                    return jackInfo;
                }


                /// <summary>
                /// Get expected Audio Device
                /// </summary>
                /// <returns></returns>
                int GetAudioDevice(string deviceId)
                {
                    IntPtr pDevice = IntPtr.Zero;
                    int result = 0;

                    if (iDeviceEnumerator == null)
                        return E_FAIL;

                    result = iDeviceEnumerator.GetDevice(deviceId, ref pDevice);
                    if (result != 0)
                    {
                        throw new Win32Exception("Can't obtain IMMDevice: " + result);
                    }

                    oDevice = Marshal.GetObjectForIUnknown(pDevice);
                    iDevice = oDevice as IMMDevice;

                    iDevice.GetState(ref state);

                    return result;
                }

                /// <summary>
                /// Get default Audio Device
                /// </summary>
                /// <returns></returns>
                [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
                static string GetDefaultAudioDeviceId(string type, ERole role)
                {
                    IntPtr pDefaultDevice = IntPtr.Zero;
                    IntPtr pID = IntPtr.Zero;
                    string id = "";
                    int result = 0;
                    object oDefaultDevice;
                    IMMDevice iDefaultDevice;
                    EDataFlow enumDataFlow = EDataFlow.ECapture;

                    if (iDeviceEnumerator == null)
                        return "";

                    if (type == "Render")
                    {
                        enumDataFlow = EDataFlow.ERender;
                    }


                    try
                    {
                        result = iDeviceEnumerator.GetDefaultAudioEndpoint(enumDataFlow, role, ref pDefaultDevice);
                        if (result != 0)
                        {
                            throw new Win32Exception("Can't obtain IMMDevice: " + result);
                        }

                        oDefaultDevice = Marshal.GetObjectForIUnknown(pDefaultDevice);
                        iDefaultDevice = oDefaultDevice as IMMDevice;

                        if (iDefaultDevice != null)
                        {
                            iDefaultDevice.GetId(ref pID);
                        }

                        id = Marshal.PtrToStringAuto(pID);
                        //return id;

                    }
                    catch (Exception)
                    {
                        id = "error";
                    }

                   //finally
                   // {
                   //     id = "none";
                   // }
                    
                    return id;
                }

                [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
                internal class MMDeviceEnumerator
                {
                }

                /// <summary>
                /// Call this method to release all com objetcs
                /// </summary>
                [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
                public virtual void Dispose()
                {
                    if (iDevice != null)
                    {
                        Marshal.ReleaseComObject(iDevice);
                        iDevice = null;
                    }
                    if (oDevice != null)
                    {
                        Marshal.ReleaseComObject(oDevice);
                        oDevice = null;
                    }
                    if (iDeviceEnumerator != null)
                    {
                        Marshal.ReleaseComObject(iDeviceEnumerator);
                        iDeviceEnumerator = null;
                    }
                    if (oEnumerator != null)
                    {
                        Marshal.ReleaseComObject(oEnumerator);
                        oEnumerator = null;
                    }
                }

                #region Public properties


                /// <summary>
                /// Get the default device state.
                /// </summary>
                int state;
                public int State
                {
                    get
                    {
                        return state;
                    }
                }

                [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2122:DoNotIndirectlyExposeMethodsWithLinkDemands")]
                public string EndpointId
                {
                    get
                    {
                        IntPtr id = IntPtr.Zero;
                        if (iDevice != null)
                        {
                            iDevice.GetId(ref id);
                        }

                        return Marshal.PtrToStringAuto(id);
                    }
                }
                #endregion

                #region Public Method

                public string GetDefaultSpeakerEndpoint()
                {
                    return GetDefaultAudioDeviceId("speakers", ERole.EConsole);
                }

                public EndpointList[] GetOutputDevicesByType(EDataFlow DataType)
                {
                    List<EndpointList> list = new List<EndpointList>();
                    IntPtr pDevices = IntPtr.Zero;
                    IntPtr pDevice = IntPtr.Zero;
                    IntPtr ID = IntPtr.Zero;

                    string deviceName = "";
                    string adapterName = "";
                    string id = "";
                    int state = 0;
                    int result = 0;
                    bool bIsDefault = false;
                    string DatatypeString = "Render";


                    if (DataType == EDataFlow.ECapture)
                    {
                        DatatypeString = "Capture";
                    }


                    result = InitializedInstance();
                    if (result != 0 || iDeviceEnumerator == null)
                    {
                        throw new Win32Exception("Can't obtain IMMDeviceEnumerator: " + result);
                    }
                    //2. Get audio device with certain type
                    if (iDeviceEnumerator == null)
                        return null;

                    result = iDeviceEnumerator.EnumAudioEndpoints(DataType, (int)DeviceState.All, ref pDevices);

                    if (result != 0)
                    {
                        return null;
                    }
                    if (pDevices == IntPtr.Zero)
                        return null;

                    oDevices = Marshal.GetObjectForIUnknown(pDevices);
                    iDeviceCollection = oDevices as IMMDevices;

                    uint deviceCount = 0;
                    result = iDeviceCollection.GetCount(ref deviceCount);

                    if (result != 0)
                    {
                        return null;
                    }


                    PROPVARIANT deviceProperty = new PROPVARIANT();
                    for (uint i = 0; i < deviceCount; i++)
                    {
                        // reset the isDefault bool value 
                        //bIsDefault = false;

                        result = iDeviceCollection.Item(i, ref pDevice);
                        if (result != 0 || pDevice == null)
                        {
                            return null;
                        }
                        oDevice = Marshal.GetObjectForIUnknown(pDevice);
                        iDevice = oDevice as IMMDevice;

                        result = iDevice.GetState(ref state);

                        if (result != 0)
                        {
                            continue;
                        }

                        if ((state & (int)DeviceState.NotPresent) != 0) { continue; }

                        IntPtr pProperty = IntPtr.Zero;

                        result = iDevice.OpenPropertyStore(STGM_READ, ref pProperty);
                        if (result != 0)
                        {
                            continue;
                        }

                        oProperty = Marshal.GetObjectForIUnknown(pProperty);
                        iProperty = oProperty as IPropertyStore;

                        result = iProperty.GetValue(ref PKEY_AudioEndpoint_FormFactor, ref deviceProperty);
                        if (result != 0)
                        {
                            continue;
                        }

                        result = iProperty.GetValue(ref PKEY_Device_DeviceDesc, ref deviceProperty);
                        if (result != 0)
                        {
                            continue;
                        }

                        deviceName = deviceProperty.DeviceName;

                        result = iProperty.GetValue(ref PKEY_DeviceInterface_FriendlyName, ref deviceProperty);
                        if (result != 0)
                        {
                            continue;
                        }

                        adapterName = deviceProperty.DeviceName;

                        // Get the endpointID
                        iDevice.GetId(ref ID);
                        if (ID == IntPtr.Zero)
                        {
                            continue;
                        }

                        id = Marshal.PtrToStringAuto(ID);

                        // Jack Info
                        int jackInfo = -1;
                        try
                        {
                            jackInfo = GetJackInfo(iDevice);
                        }
                        catch
                        {
                            jackInfo = jackErrorInfo;
                        }

                        // Get default Id
                        string defaultID = GetDefaultAudioDeviceId(DatatypeString, ERole.EConsole);

                        // Match the defaultID with the current ID
                        //if (defaultID != "none")
                        //{
                        //    if (defaultID == id)
                        //    {
                        //        bIsDefault = true;
                        //    }
                        //    else { bIsDefault = false; }
                        //}
                        //else { bIsDefault = false; }

                        if ((defaultID != "error") && (defaultID == id))
                        {
                            bIsDefault = true;
                        }else { bIsDefault = false; }



                        list.Add(new EndpointList(deviceName, id, adapterName, jackInfo, bIsDefault,state));
                    }
                    return list.ToArray();

                }
                #endregion
            }

            [StructLayout(LayoutKind.Sequential)]
            public class WAVEFORMATEX
            {
                public UInt16 wFormatTag;
                public UInt16 nChannels;
                public UInt32 nSamplesPerSec;
                public UInt32 nAvgBytesPerSec;
                public UInt16 nBlockAlign;
                public UInt16 wBitsPerSample;
                public UInt16 cbSize;
            }

            [ComImport, Guid("870AF99C-171D-4f9e-AF0D-E63DF40C2BC9")]
            public class IPolicyConfigClass { }

            public static class LoadDLL
            {

                [DllImport("AudioDiagnosticUtil.dll", EntryPoint = "AudioGetDeviceFormat", CharSet = CharSet.Auto)]
                public static extern int AudioGetDeviceFormat(string pszDeviceName, bool bDefault, ref IntPtr ppFormat);

                [DllImport("AudioDiagnosticUtil.dll", EntryPoint = "AudioSetDeviceFormat", CharSet = CharSet.Auto)]
                public static extern int AudioSetDeviceFormat(string pszDeviceName, IntPtr pEndpointFormat, IntPtr MixFormat);
            }

            [Guid("6be54be8-a068-4875-a49d-0c2966473b11"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
            public interface IPolicyConfig
            {
                int GetMixFormat(string pszDeviceName, ref IntPtr ppFormat);

                int GetDeviceFormat(string pszDeviceName, bool bDefault, ref IntPtr ppFormat);

                int ResetDeviceFormat(string pszDeviceName);

                int SetDeviceFormat(string pszDeviceName, IntPtr pEndpointFormat, IntPtr MixFormat);

                int GetProcessingPeriod(string pszDeviceName, bool bDefault, IntPtr pmftDefaultPeriod, IntPtr pmftMinimumPeriod);

                int SetProcessingPeriod(string pszDeviceName, IntPtr pmftPeriod);

                int GetShareMode(string pszDeviceName, IntPtr pMode);

                int SetShareMode(string pszDeviceName, IntPtr mode);

                int GetPropertyValue(string pszDeviceName, bool bFxStore, IntPtr key, IntPtr pv);

                int SetPropertyValue(string pszDeviceName, bool bFxStore, IntPtr key, IntPtr pv);

                int SetDefaultEndpoint(string pszDeviceName, ERole role);

                int SetEndpointVisibility(string pszDeviceName, bool bVisible);

                int SetScreenReaderState(bool bEnabled);

                int SetEndpointAbilityToBeDefault(string pszDeviceName, bool bEnable);

                int SetApplicationDefaultEndpoint(Int32 processId, ERole role, string pszInterfaceId);

                int ClearApplicationDefaultEndpoint(Int32 processId, ERole role, EDataFlow flow);

                int RegisterProxyAudioProcess();

                int SetDuckingGainForId(string pszStr1, float floatVal);

                int SetLayoutGainForId(Int32 something1, float floatVal);
            }

            public class IPolicyConfigHelper
            {

                public Byte[] GetDeviceFormat(string pszDeviceName, bool bDefault, out WAVEFORMATEX retFormat)
                {
                    IntPtr ptrToWaveFormat = new IntPtr();

                    LoadDLL.AudioGetDeviceFormat(pszDeviceName, bDefault, ref ptrToWaveFormat);
                    WAVEFORMATEX format = (WAVEFORMATEX)Marshal.PtrToStructure(ptrToWaveFormat, typeof(WAVEFORMATEX));
                    int formatSize = format.cbSize + Marshal.SizeOf(typeof(WAVEFORMATEX));
                    Byte[] formatExtData = new Byte[format.cbSize + Marshal.SizeOf(typeof(WAVEFORMATEX))];
                    Marshal.Copy(ptrToWaveFormat, formatExtData, 0, formatSize);
                    retFormat = format;
                    return formatExtData;
                }
                public int SetDeviceFormat(string pszDeviceName, Byte[] formatExtData, int formatSize)
                {
                    IntPtr ptrToFormat = Marshal.AllocHGlobal(formatSize);
                    Marshal.Copy(formatExtData, 0, ptrToFormat, formatSize);

                    int rval = LoadDLL.AudioSetDeviceFormat(pszDeviceName, ptrToFormat, IntPtr.Zero);
                    Marshal.FreeHGlobal(ptrToFormat);
                    return rval;
                }


            }

            public static bool verifySamplingRate(string deviceID)
            {
                EndpointCtrl control = new EndpointCtrl();
                bool result = false;
                string defSpeakerEndpoint = deviceID;
                IPolicyConfigHelper policyHelper = new IPolicyConfigHelper();
                WAVEFORMATEX defaultFormatEx = new WAVEFORMATEX();
                WAVEFORMATEX currentFormatEx = new WAVEFORMATEX();
                Byte[] defaultFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, true, out defaultFormatEx);
                Byte[] currentFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx);
                if (defaultFormatEx.nAvgBytesPerSec != currentFormatEx.nAvgBytesPerSec)
                {
                    result = true;
                }
                return result;
            }
            public static bool resetSamplingRate(string deviceID)
            {
                EndpointCtrl control = new EndpointCtrl();
                string defSpeakerEndpoint = deviceID;
                IPolicyConfigHelper policyHelper = new IPolicyConfigHelper();
                WAVEFORMATEX defaultFormatEx = new WAVEFORMATEX();
                WAVEFORMATEX currentFormatEx = new WAVEFORMATEX();
                Byte[] defaultFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, true, out defaultFormatEx);
                Byte[] currentFormat = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx);

                policyHelper.SetDeviceFormat(defSpeakerEndpoint, defaultFormat, defaultFormat.Length);
                WAVEFORMATEX currentFormatEx2 = new WAVEFORMATEX();
                Byte[] currentFormat2 = policyHelper.GetDeviceFormat(defSpeakerEndpoint, false, out currentFormatEx2);
                control.Dispose();
                return true;
            }

            public static EndpointList[] GetAudioEndPointsbyType(string type)
            {

                EDataFlow dataflowtype = new EDataFlow();

                if (type == "Render")
                {
                    dataflowtype = EDataFlow.ERender;
                }
                else { dataflowtype = EDataFlow.ECapture; }

                EndpointCtrl control = new EndpointCtrl();
                EndpointList[] list = control.GetOutputDevicesByType(dataflowtype);




                return list;

            }
        }
   
}
	
"@
    Add-Type -TypeDefinition $AudioEndpointsSource
    $AudioEndpoints =  [Microsoft.Windows.Diagnosis.AudioResetDeviceFormats]

    return $AudioEndpoints
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





