# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#

	DESCRIPTION
	CL_Utilities.ps1 is common library for Speech troubleshooter.

	ARGUMENTS:
	None

	RETURNS:
	None

	FUNCTIONS:
	Diagnose-AudioDevice 
	Get-AudioCapturingDevices
	Get-LocalizedJackInfo
	Get-OSVersion
	Get-StringResource
	Set-DefaultEndpoint
	Test-DefaultMicrophone
	Test-PostBack
	Test-RemoteSession
	Write-ExceptionTelemetry
#>

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizedStrings -FileName CL_LocalizationData

# Initializing DEVICE_STATE Enumeration
# https://msdn.microsoft.com/en-us/library/windows/desktop/dd370823%28v=vs.85%29.aspx
Add-Type -TypeDefinition @"
	[System.Flags]
	public enum DeviceState
	{
		/// <summary>
		/// The audio endpoint device is active. That is, the audio adapter that connects to the endpoint device is present and enabled. In addition, if the endpoint device plugs into a jack on the adapter, then the endpoint device is plugged in.
		/// </summary>
		Active = 0x00000001,

		/// <summary>
		/// The audio endpoint device is disabled. The user has disabled the device in the Windows multimedia control panel, Mmsys.cpl. 
		/// </summary>
		Disabled = 0x00000002,

		/// <summary>
		/// The audio endpoint device is not present because the audio adapter that connects to the endpoint device has been removed from the system, or the user has disabled the adapter device in Device Manager.
		/// </summary>
		NotPresent = 0x00000004,
	  
		/// <summary>
		/// The audio endpoint device is unplugged. The audio adapter that contains the jack for the endpoint device is present and enabled, but the endpoint device is not plugged into the jack. Only a device with jack-presence detection can be in this state. 
		/// </summary>
		Unplugged = 0x00000008,

		/// <summary>
		/// Includes audio endpoint devices in all states—active, disabled, not present, and unplugged.
		/// </summary>
		All = 0x0000000F
	}
"@

# Initializing SpeechDiagnosticUtil.dll and respective PInvokes
Add-Type -TypeDefinition @"
namespace SpeechDiagnostic
{
	using System;
	using System.Runtime.InteropServices;

	public static class SpeechConfigManager
	{
		/// <summary>
		/// All methods will only run on 64bit machine and only under Admin privileges  
		/// </summary>

		private enum MicDiagnosticResult
		{
			MicDiagnosticPass,
			MicDiagnosticFail,
			MicDiagnosticSilence,
			MicDiagnosticCancelled
		}

		private enum TroublePageShowStatus
		{
			TroublePageShowNone = 0,
			TroublePageShowModern = 1,
			TroublePageShowLegacy = 2
		}

		/// <summary>
		/// Returns the default Audio ID
		/// </summary>
		/// <param name="ppStrDeviceId"></param>
		/// <returns>Audio Device ID i.e. Guid</returns>
		[DllImport("SpeechDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int GetPrefMicDeviceId(ref IntPtr ppStrDeviceId);

		/// <summary>
		/// Returns the result of the Mic Diagnostic
		/// </summary>
		/// <param name="pResult"></param>
		/// <returns>Returns a enum of MicDiagnosticResult</returns>
		[DllImport("SpeechDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int GetMicDiagnosticResult(ref MicDiagnosticResult pResult);

		/// <summary>
		/// Query if we need to display a trouble page
		/// </summary>
		/// <param name="pState"></param>
		/// <returns>Returns a enum of TroublePageShowStatus</returns>
		[DllImport("SpeechDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern void GetTroublePageShowStatus(ref TroublePageShowStatus status);

		/// <summary>
		/// This marks the trouble page as shown to the user, so it won't be shown again
		/// </summary>
		/// <param name="pState"></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern void MarkTroublePageDisplayed();

		/// <summary>
		/// Starts microphone calibration
		/// </summary>
		/// <param></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", PreserveSig = false, CallingConvention = CallingConvention.StdCall)]
		private static extern void StartMicDiagnostic();

		/// <summary>
		/// Stops microphone calibration and cleans up memory
		/// </summary>
		/// <param></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", PreserveSig = false, CallingConvention = CallingConvention.StdCall)]
		private static extern void StopMicDiagnostic();

		/// <summary>
		/// Test if calibration is complete
		/// </summary>
		/// <param name="pState"></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", PreserveSig = false, CallingConvention = CallingConvention.StdCall)]
		private static extern void IsCalibrationDone(out Boolean done);

		/// <summary>
		/// Retrieves current peak level
		/// </summary>
		/// <param name="level"></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", PreserveSig = false, CallingConvention = CallingConvention.StdCall)]
		private static extern void GetMicrophoneLevel(out float level);

		/// <summary>
		/// Writes new calibration information to registry
		/// </summary>
		/// <param name="useDefaults"></param>
		/// <returns></returns>
		[DllImport("SpeechDiagnosticUtil.dll", PreserveSig = false, CallingConvention = CallingConvention.StdCall)]
		private static extern void UpdateRegistryValues(bool useDefaults);

		public static void StartDiagnostic()
		{
			StartMicDiagnostic();
		}

		public static void StopDiagnostic()
		{
			StopMicDiagnostic();
		}

		public static bool IsDiagnosticDone()
		{
			bool done;
			IsCalibrationDone(out done);
			return done;
		}

		public static int GetLevel()
		{
			float level;
			GetMicrophoneLevel(out level);
			return Convert.ToInt32(level * 100);
		}

		public static void UpdateRegistry(bool useDefaults)
		{
			UpdateRegistryValues(useDefaults);
		}

		/// <summary>
		/// Public methods to P/Invoke APIs
		/// </summary>
		/// <returns></returns>
		public static string GetResult()
		{
			MicDiagnosticResult MicResult = new MicDiagnosticResult();
			int val = GetMicDiagnosticResult(ref MicResult);

			return MicResult.ToString();
		}

		public static string GetDeviceId()
		{
			IntPtr dId = IntPtr.Zero;
			GetPrefMicDeviceId(ref dId);

			string id = Marshal.PtrToStringAuto(dId);
			return id;

		}

		public static string GetTroublePageDisplayStatus()
		{
			TroublePageShowStatus showStatus = new TroublePageShowStatus();
			GetTroublePageShowStatus(ref showStatus);
			return showStatus.ToString();
		}

		/// Sets the trouble page status to displayed
		public static void SetTroublePageDisplayStatus()
		{
			MarkTroublePageDisplayed();
		}
	}
}

"@

# Initializing AudioDiagnosticUtil.dll and respective PInvokes for AudioConfigManager
Add-Type -TypeDefinition @"
namespace Microsoft.Windows.Diagnosis
{
	using System;
	using System.Runtime.InteropServices;

	public static class AudioConfigManager
	{
		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int AudioSetEndPointVisibility(string pszDeviceName, bool Status);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int AudioSetDefaultdevice(string pszDeviceName);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int SetAudioEndpointProperty(string pszDeviceName);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int IsEndpointDefault(string pszDeviceName, string pDataFlow, ref IntPtr IsDefault);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern int GetDefaultEndpointID(string pDataFlow, ref IntPtr pDefaultId);
		
		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern float GetMasterVolumeLevel(string Datatype, out float pLevel);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern bool GetMute(string Datatype, ref bool pMute);

		[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", CharSet = CharSet.Auto)]
		private static extern void SetMute(string Datatype, bool pMute);

		
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

		public static void SetMuteStatus(string dataType, bool muteStatus)
		{
			AudioConfigManager.SetMute(dataType, muteStatus);
		}

		public static int GetVolume(string deviceId)
		{
			float retVal = 0.0f;

			AudioConfigManager.GetMasterVolumeLevel(deviceId, out retVal);
			return Convert.ToInt32(retVal * 100);
		}
		
	}
}

"@

# Load the module related to Audio EndPointCtrl and get and set the default sampling rate of specific the audio device.
Add-Type -TypeDefinition @"
namespace Microsoft.Windows.Diagnosis
{
	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.Runtime.InteropServices;
	using System.ComponentModel;
	using System.Security.Permissions;
	using System.Globalization;

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

				[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", EntryPoint = "AudioGetDeviceFormat", CharSet = CharSet.Auto)]
				public static extern int AudioGetDeviceFormat(string pszDeviceName, bool bDefault, ref IntPtr ppFormat);

				[DllImport(@"$env:windir\diagnostics\system\Audio\AudioDiagnosticUtil.dll", EntryPoint = "AudioSetDeviceFormat", CharSet = CharSet.Auto)]
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

# Initializing LoadLibrary, LoadStringW, and FreeLibrary helper functions
Add-Type -TypeDefinition @"
namespace Microsoft.Windows.Diagnosis.Strings
{
	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.Runtime.InteropServices;

	internal class NativeMethods
	{
		[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern int LoadStringW(IntPtr hInst, int id, StringBuilder buf, int buflen);
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern IntPtr LoadLibrary(string path);
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern bool FreeLibrary(IntPtr hInst);
	}

	public class PublicMethods
	{
		public static string GetString(string FileName, int ResourceId)
		{
			string path = FileName;
			string value = "";

			IntPtr hInst = NativeMethods.LoadLibrary(@path);
			StringBuilder sb = new StringBuilder(2034);
			int len = NativeMethods.LoadStringW(hInst, ResourceId, sb, sb.Capacity);
			if (len > 0)
			{
				value = sb.ToString();
			}

			NativeMethods.FreeLibrary(hInst);

			return value;
		}
	}
}
"@

#====================================================================================
# Functions
#====================================================================================

function Get-StringResource([string]$inputstring)
{
	<#
		DESCRIPTION:
		Wraps LoadStringW for use in PowerShell to load localized string resource from the provided assembly

		ARGUMENTS:
		InputString - full path to resource (example: "@$env:windir\diagnostics\system\AERO\DiagPackage.dll,-1"

		RETURNS:
		String resource from provided assembly if successful, empty string if not successful
	#>

	# Get the numeric ID of the string (ex: 100)
	$resourceID = $inputstring.substring($inputstring.lastindexof('-')+1)

	# Assembly path
	$AssemblyPath = $inputstring.remove(0,1)
	$AssemblyPath = $AssemblyPath.Remove($AssemblyPath.LastIndexOf(','))
	
	# Return the value from the stringtable in the .dll
	return [Microsoft.Windows.Diagnosis.Strings.PublicMethods]::GetString($AssemblyPath, $resourceID)
}

function Write-ExceptionTelemetry($FunctionName, [System.Management.Automation.ErrorRecord] $ex)
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
	
	Write-DiagTelemetry 'ScriptError' "$ExceptionScript\$FunctionName\$ExceptionScriptLine\$ExceptionScriptColumn\$ExceptionMessage"
}

function Test-RemoteSession
{
	<#
		DESCRIPTION:
		Checks whether the current package is running on remote session.

		ARGUMENTS:
		None

		RETURNS:
		TRUE if the current package is running on remote session otherwise FALSE
	#>

	[string]$sourceCode = @"
	using System;
	using System.Runtime.InteropServices;

	namespace Microsoft.Windows.Diagnosis {
		public static class RemoteManager {
			private const int SM_REMOTESESSION = 0x1000;

			[DllImport("User32.dll", CharSet = CharSet.Unicode)]
			private static extern int GetSystemMetrics(int Index);

			public static bool IsRemote() {
				return (0 != GetSystemMetrics(SM_REMOTESESSION));
			}
		}
	}
"@
	$type = Add-Type -TypeDefinition $sourceCode -PassThru

	return $type::IsRemote()
}

function Get-AudioCapturingDevices
{
	<#
		DESCRIPTION:
		Lists all the recording devices available on the localhost with their details.

		ARGUMENTS:
		None

		RETURNS:
		Returns all the audio recording devices available on the localhost with following details.

		AdapterName     : Microsoft LifeChat LX-6000
		Description     : Headset Microphone
		DeviceId        : {0.0.1.00000000}.{d63bbf97-3308-439c-ad4a-aaca7438fed4}
		JackInfo        : 2
		JackDescription : The connector for this device is located on the front of the computer
		State           : Active
		IsDefault       : True
		IsMuted         : False
		Level           : 70
	#>

	$audioDevices = @()

	try
	{
		$dataFlowType = 'Capture'
		
		# Getting all audio capturing devices
		$devices = [System.Array]([Microsoft.Windows.Diagnosis.AudioResetDeviceFormats]::GetAudioEndPointsbyType($dataFlowType))

		# Getting the device details
		foreach ($device in $devices)
		{
			$audioDevice = '' | Select AdapterName, Description, DeviceId, JackInfo, JackDescription, State, IsDefault, IsMuted, Level
			$audioDevice.AdapterName = $device.AdapterName
			$audioDevice.Description = $device.DeviceDes
			$audioDevice.DeviceId = $device.DeviceId
			$audioDevice.JackInfo = $device.JackInfo
			$audioDevice.JackDescription = (Get-LocalizedJackInfo($device.JackInfo))
			$audioDevice.State = [Enum]::Parse(([Type][DeviceState]), ($device.State))
			$audioDevice.IsDefault = $device.IsDefault

 			if($audioDevice.State -eq "Active") 
			{
				$audioDevice.IsMuted = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetMuteStatus($device.DeviceId)
				$audioDevice.Level = [Microsoft.Windows.Diagnosis.AudioConfigManager]::GetVolume($device.DeviceId)
			}
			else
			{
				$audioDevice.IsMuted = $false
				$audioDevice.Level = 0
			}

			$audioDevices += $audioDevice;
		}
	}
	catch
	{
		Write-ExceptionTelemetry 'Get-AudioCapturingDevices' $_
	}

	return $audioDevices
}

function Set-DefaultEndpoint
{
	[CmdletBinding()]
	PARAM
	(
		[Alias('ID')]
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({-not([string]::IsNullOrWhiteSpace($_))})]
		$DeviceID
	)
	PROCESS 
	{
		try
		{
			[Microsoft.Windows.Diagnosis.AudioConfigManager]::SetDefault($DeviceID)
		}
		catch [System.Exception]
		{
			Write-ExceptionTelemetry 'Set-DefaultEndpoint' $_
		}
	}
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

function Get-OSVersion
{
	$osVersion = [System.Environment]::OSVersion.Version;
	return [float]("{0}.{1}" -f $osVersion.Major, $osVersion.Minor)
}

function Get-LocalizedJackInfo
{
	[CmdletBinding()]
	PARAM
	(
		[Alias('I')]
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[int]$Index
	)
	PROCESS 
	{
		$result = "$($localizedStrings.JackLocInfo) "
		switch ($Index)
		{
			1 {$result += $localizedStrings.Rear; break}
			2 {$result += $localizedStrings.Front; break}
			3 {$result += $localizedStrings.Left; break}
			4 {$result += $localizedStrings.Right; break}
			5 {$result += $localizedStrings.Top; break}
			6 {$result += $localizedStrings.Bottom; break}
			7 {$result += $localizedStrings.RearSlide; break}
			8 {$result += $localizedStrings.RiserCard; break}
			9 {$result += $localizedStrings.InsideLid; break}
			10 {$result += $localizedStrings.DriveBay; break}
			11 {$result += $localizedStrings.HDMIconnector; break}
			12 {$result += $localizedStrings.OutsideLid; break}
			13 {$result += $localizedStrings.ATAPIConnector; break}
			default {$result = $localizedStrings.NoJackInfoAvailable; break}
		}

		return $result
	}
}

function Diagnose-AudioSpeech
{
	[CmdletBinding()]
	PARAM
	(
		[Alias('ID')]
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string] $DeviceID
	)
	PROCESS 
	{
		$audioDevice = Get-AudioCapturingDevices | ?{ $_.DeviceId -ieq $DeviceID }
		if($audioDevice)
		{
                # If the device is not Active OR Not default OR Is muted. 
                if (($audioDevice.State -ne [DeviceState]::Active) -or ($audioDevice.IsDefault -eq $false) -or ($audioDevice.IsMuted))
                {
                	# Let audio troubleshooter try to fix it.
					Update-DiagRootCause -ID RC_MicProblem -InstanceId ($audioDevice.AdapterName) -Detected $true -Parameter @{'SkipAudioRecordingDiagnostic' = $false; 'SelectedDevice' = $DeviceID}

					# Calibrate only when the device is not unplugged.
                    if ($audioDevice.State -ne [DeviceState]::Unplugged)
                    {
                        Diagnose-SpeechCalibration -DeviceID $audioDevice.DeviceID 
                    }

                }else
                    {
					   Diagnose-SpeechCalibration -DeviceID $audioDevice.DeviceID 
				    }
        }
    }
}
        
        

		
    
    
	

function Diagnose-SpeechCalibration
{
	[CmdletBinding()]
	PARAM
	(
		[Alias('ID')]
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string] $DeviceID
	)
	PROCESS
	{
                $entryPoint = 'Undefined'
                $audioDevice = Get-AudioCapturingDevices | ?{ $_.DeviceId -ieq $DeviceID }
				$troublePageShow = [SpeechDiagnostic.SpeechConfigManager]::GetTroublePageDisplayStatus()
				if(-not ($troublePageShow -eq 'TroublePageShowNone'))
				{
					[string]$description = $localizedStrings.TroublePage_DefaultDescription

					if($troublePageShow -eq 'TroublePageShowModern')
					{
						$description = ($localizedStrings.TroublePage_NotLegacyDevice_Description)
					}
					else
					{
						$description = ($localizedStrings.TroublePage_LegacyDevice_Description)
					}

					$consent = Get-DiagInput -ID IT_TroublePage -Parameter @{'Description' = $description}
					$canCalibrate = ($consent[0] -eq 'calibrate')
					
					Update-DiagRootCause -ID RC_CalibrationRequired -InstanceId ($audioDevice.AdapterName) -Detected $canCalibrate -Parameter @{'CalibrationReason' = $entryPoint; 'CalibrationConsent' = $canCalibrate; 'MicLevel' = ($audioDevice.Level); 'AdapterName' = ($audioDevice.AdapterName); 'Description' = ($audioDevice.Description); 'DeviceId' = ($audioDevice.DeviceId); 'JackInfo' = ($audioDevice.JackInfo); 'State' = ($audioDevice.State); 'IsDefault' = ($audioDevice.IsDefault -eq $true)}

					# Set trouble page displayed
					[SpeechDiagnostic.SpeechConfigManager]::SetTroublePageDisplayStatus();
				}
				else
				{
					$response = Get-DiagInput -id IT_MicSetup
					$canCalibrate = ($response[0] -eq 'calibrate')
                    Update-DiagRootCause -ID RC_CalibrationRequired -InstanceId ($audioDevice.AdapterName) -Detected $canCalibrate -Parameter @{'CalibrationReason' = $entryPoint; 'CalibrationConsent' = $canCalibrate; 'MicLevel' = ($audioDevice.Level); 'AdapterName' = ($audioDevice.AdapterName); 'Description' = ($audioDevice.Description); 'DeviceId' = ($audioDevice.DeviceId); 'JackInfo' = ($audioDevice.JackInfo); 'State' = ($audioDevice.State); 'IsDefault' = ($audioDevice.IsDefault -eq $true)}
				}
    }
}

