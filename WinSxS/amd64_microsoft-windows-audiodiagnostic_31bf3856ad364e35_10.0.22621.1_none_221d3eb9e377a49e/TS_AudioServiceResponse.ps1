# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	 TS_AudioServiceResponse checks for audio service resposive or not.

	ARGUMENTS:
	 NA

	RETURNS:
	  <&true> if root cause detected otherwise <$false>
#>

#====================================================================================
# Initialize
#====================================================================================
$detected = $false
[int]$rcDetected = 0
#====================================================================================
function Verify-AudioServiceResponse([string]$action)
{
	<#
	FUNCTION DESCRIPTION:
		Initailize the IAudioClient interface for the audio devices 

	ARGUMENTS:
		None

	RETURNS:
		<&true> if IAudioClient intialization successfull otherwise <$false>    
#>
	
    $audioServiceTestSource = @"
	using System;
	using System.Collections.Generic;
	using System.Linq;
	using System.Text;
	using System.Threading.Tasks;
	using System.Runtime.InteropServices;

	namespace Microsoft.Windows.Diagnosis
	{
		public static class AudioServiceResponsive
		{
			const string IID_IAudioClientString = "1CB9AD4C-DBFA-4c32-B178-C2F568A703B2";
			const string IID_IMMDeviceString = "D666063F-1587-4E43-81F1-B948E807363F";
			const string IID_IMMDeviceCollectionString = "0BD7A1BE-7A1A-44DB-8397-CC5392387B5E";
			const string IID_IMMDeviceEnumeratorString = "A95664D2-9614-4F35-A746-DE8DB63617E6";
			static Guid CLSID_MMDeviceEnumerator = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E");
			static Guid IID_IAudioClient = new Guid(IID_IAudioClientString);
            static Guid IID_IUnknown = new Guid("00000000-0000-0000-C000-000000000046");
		    static object oEnumerator;
            static IMMDeviceEnumerator iDeviceEnumerator;

			[Flags]
			public enum CLSCTX : uint
			{
				CLSCTX_INPROC_SERVER = 0x1,
				CLSCTX_INPROC_HANDLER = 0x2,
				CLSCTX_LOCAL_SERVER = 0x4,
				CLSCTX_INPROC_SERVER16 = 0x8,
				CLSCTX_REMOTE_SERVER = 0x10,
				CLSCTX_INPROC_HANDLER16 = 0x20,
				CLSCTX_RESERVED1 = 0x40,
				CLSCTX_RESERVED2 = 0x80,
				CLSCTX_RESERVED3 = 0x100,
				CLSCTX_RESERVED4 = 0x200,
				CLSCTX_NO_CODE_DOWNLOAD = 0x400,
				CLSCTX_RESERVED5 = 0x800,
				CLSCTX_NO_CUSTOM_MARSHAL = 0x1000,
				CLSCTX_ENABLE_CODE_DOWNLOAD = 0x2000,
				CLSCTX_NO_FAILURE_LOG = 0x4000,
				CLSCTX_DISABLE_AAA = 0x8000,
				CLSCTX_ENABLE_AAA = 0x10000,
				CLSCTX_FROM_DEFAULT_CONTEXT = 0x20000,
				CLSCTX_ACTIVATE_32_BIT_SERVER = 0x40000,
				CLSCTX_ACTIVATE_64_BIT_SERVER = 0x80000,
				CLSCTX_INPROC = CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER,
				CLSCTX_SERVER = CLSCTX_INPROC_SERVER | CLSCTX_LOCAL_SERVER | CLSCTX_REMOTE_SERVER,
				CLSCTX_ALL = CLSCTX_SERVER | CLSCTX_INPROC_HANDLER
			}

			enum EDataFlow
			{
				eRender,
				eCapture,
				eAll,
				EDataFlow_enum_count
			}

			enum ERole
			{
				eConsole,
				eMultimedia,
				eCommunications,
				ERole_enum_count
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

			enum AUDCLNT_SHAREMODE
			{
				AUDCLNT_SHAREMODE_SHARED,
				AUDCLNT_SHAREMODE_EXCLUSIVE
			}

			//WAVEFORMATEX;
			[StructLayout(LayoutKind.Sequential)]
			class WAVEFORMATEX
			{
				public ushort wFormatTag;
				public ushort nChannels;
				public uint nSamplesPerSec;
				public uint nAvgBytesPerSec;
				public ushort nBlockAlign;
				public ushort wBitsPerSample;
				public ushort cbSize; // if this is non-zero, something more is needed

				public WAVEFORMATEX()
				{
				}
                
			}

			[Guid(IID_IAudioClientString),
				InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
				]
			interface IAudioClient
			{
				//HRESULT Initialize(
				//  [in]       AUDCLNT_SHAREMODE ShareMode,
				//  [in]       DWORD StreamFlags,
				//  [in]       REFERENCE_TIME hnsBufferDuration,
				//  [in]       REFERENCE_TIME hnsPeriodicity,
				//  [in] const WAVEFORMATEX* pFormat,           // Using IntPtr for this instead of WAVEFORMATEX because otherwise the extra bytes are lost
				//  [in]       LPCGUID AudioSessionGuid
				//);
				[PreserveSig] int Initialize(AUDCLNT_SHAREMODE ShareMode, uint StreamFlags, long hnsBufferDuration, long hnsPeriodicity, IntPtr pFormat, ref Guid AudioSessionGuid);

				//HRESULT GetBufferSize(
				//  [out] UINT32* pNumBufferFrames
				//);
				int GetBufferSize(out uint pNumBufferFrames);

				//HRESULT GetStreamLatency(
				//  [out] REFERENCE_TIME* phnsLatency
				//);
				int GetStreamLatency(out long phnsLatency);

				//HRESULT GetCurrentPadding(
				//    [out] UINT32* pNumPaddingFrames
				//);
				int GetCurrentPadding(out uint pNumPaddingFrames);

				//HRESULT IsFormatSupported(
				//  [in]        AUDCLNT_SHAREMODE ShareMode,
				//  [in]  const WAVEFORMATEX* pFormat,
				//  [out]       WAVEFORMATEX** ppClosestMatch
				//);
				int IsFormatSupported(AUDCLNT_SHAREMODE ShareMode, WAVEFORMATEX pFormat, ref WAVEFORMATEX ppClosestMatch);

				//HRESULT GetMixFormat(
				//  [out] WAVEFORMATEX** ppDeviceFormat         // Using IntPtr for this instead of WAVEFORMATEX because otherwise the extra bytes are lost
				//);
				int GetMixFormat(ref IntPtr ppDeviceFormat);

				//HRESULT GetDevicePeriod(
				//    [out] REFERENCE_TIME* phnsDefaultDevicePeriod,
				//    [out] REFERENCE_TIME* phnsMinimumDevicePeriod
				//);
				int GetDevicePeriod(out long phnsDefaultDevicePeriod, out long phnsMinimumDevicePeriod);

				//HRESULT Start();
				int Start();

				//HRESULT Stop();
				int Stop();

				//HRESULT Reset();
				int Reset();

				//HRESULT SetEventHandle(
				//    [in] HANDLE eventHandle
				//);
				int SetEventHandle(ref IntPtr eventHandle);

				//HRESULT GetService(
				//    [in]  REFIID riid,
				//    [out] void** ppv
				//);
				int GetService(ref Guid riid, ref IntPtr ppv);
			}

			[Guid(IID_IMMDeviceString),
				InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
			interface IMMDevice
			{
				//HRESULT Activate(
				//  [in]  REFIID iid,
				//  [in]  DWORD dwClsCtx,
				//  [in]  PROPVARIANT* pActivationParams,
				//  [out] void** ppInterface
				//);
				int Activate(ref Guid iid, uint dwClsCtx, IntPtr pActivationParams, ref IntPtr ppInterface);

				//HRESULT OpenPropertyStore(
				//  [in]  DWORD stgmAccess,
				//  [out] IPropertyStore** ppProperties
				//);
				int OpenPropertyStore(uint stgmAccess, ref IntPtr ppProperties);

				//HRESULT GetId(
				//  [out] LPWSTR* ppstrId
				//);
				int GetId([MarshalAs(UnmanagedType.LPWStr)] out string ppstrId);

				//HRESULT GetState(
				//  [out] DWORD* pdwState
				//);
				int GetState(out uint pdwState);
			}

			[Guid(IID_IMMDeviceCollectionString),
				InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
			interface IMMDeviceCollection
			{
				//HRESULT GetCount(
				//  [out] UINT* pcDevices
				//);
				int GetCount(out uint pcDevices);

				//HRESULT Item(
				//  [in]  UINT nDevice,
				//  [out] IMMDevice** ppDevice
				//);
				int Item(uint nDevice, ref IntPtr ppDevice);
			}

			[Guid(IID_IMMDeviceEnumeratorString),
				InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
			interface IMMDeviceEnumerator
			{
				//HRESULT EnumAudioEndpoints(
				//  [in]  EDataFlow           dataFlow,
				//  [in]  DWORD               dwStateMask,
				//  [out] IMMDeviceCollection **ppDevices
				//);
				int EnumAudioEndpoints(EDataFlow dataFlow, uint dwStateMask, ref IntPtr ppDevices);

				//HRESULT GetDefaultAudioEndpoint(
				//  [in]  EDataFlow dataFlow,
				//  [in]  ERole role,
				//  [out] IMMDevice** ppDevice
				//);
				int GetDefaultAudioEndpoint(EDataFlow dataFlow, ERole role, ref IntPtr ppDevice);

				//HRESULT GetDevice(
				//  [in]  LPCWSTR pwstrId,
				//  [out] IMMDevice** ppDevice
				//);
				int GetDevice(string pwstrId, ref IntPtr ppDevice);

				//HRESULT RegisterEndpointNotificationCallback(
				//  [in] IMMNotificationClient* pNotify
				//);
				int RegisterEndpointNotificationCallback(IntPtr pNotify);

				//HRESULT UnregisterEndpointNotificationCallback(
				//  [in] IMMNotificationClient* pNotify
				//);
				int UnregisterEndpointNotificationCallback(IntPtr pNotify);
			}

			public static class NativeMethods
           	{
		                [DllImport("ole32.Dll")]
                		internal static extern int CoCreateInstance(ref Guid guid, [MarshalAs(UnmanagedType.IUnknown)] object inner, uint context, ref Guid id, [MarshalAs(UnmanagedType.IUnknown)] out object pointer);
           	}		

           public static uint audioClientCount()
            {
                uint count = 0;
                try
                {
                    IntPtr ppDevices = IntPtr.Zero;
					object oDevices = null;
					IMMDeviceCollection endpointCollection = null;
                    const uint CLSCTX_INPROC_SERVER = 1;
										
					//1.to obtain IMMDeviceEnumerator
                    int result1 = NativeMethods.CoCreateInstance(ref CLSID_MMDeviceEnumerator, null, CLSCTX_INPROC_SERVER, ref IID_IUnknown, out oEnumerator);

                    iDeviceEnumerator = oEnumerator as IMMDeviceEnumerator;
                    int hr = iDeviceEnumerator.EnumAudioEndpoints(EDataFlow.eAll, (uint)DEVICE_STATE.DEVICE_STATE_ACTIVE, ref ppDevices);

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

					uint deviceCount;
					hr = endpointCollection.GetCount(out deviceCount);
					if (hr != 0)
					{
						throw new Exception("HResult from IMMDeviceCollection.GetCount = " + hr);
					}
                    count = deviceCount;
                }
                catch
                {
                   
                }
                return count;
            }

			
			public static bool intiateAudioClient()
			{
				bool result = false;
				try
				{
					IntPtr ppDevices = IntPtr.Zero;
					object oDevices = null;
					IMMDeviceCollection endpointCollection = null;
                    const uint CLSCTX_INPROC_SERVER = 1;
										
					//1.to obtain IMMDeviceEnumerator
                    int result1 = NativeMethods.CoCreateInstance(ref CLSID_MMDeviceEnumerator, null, CLSCTX_INPROC_SERVER, ref IID_IUnknown, out oEnumerator);

                    iDeviceEnumerator = oEnumerator as IMMDeviceEnumerator;
                    int hr = iDeviceEnumerator.EnumAudioEndpoints(EDataFlow.eAll, (uint)DEVICE_STATE.DEVICE_STATE_ACTIVE, ref ppDevices);

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

					uint deviceCount;
					hr = endpointCollection.GetCount(out deviceCount);
					if (hr != 0)
					{
						throw new Exception("HResult from IMMDeviceCollection.GetCount = " + hr);
					}

					for (uint i = 0; i < deviceCount; ++i)
					{
						// Get the IMMDevice endpoint
						IntPtr ppDevice = IntPtr.Zero;
						object oDevice = null;
						IMMDevice endpoint = null;
						hr = endpointCollection.Item(i, ref ppDevice);
						if (hr != 0)
						{
							throw new Exception("HResult from IMMDeviceCollection.Item = " + hr);
						}
						oDevice = Marshal.GetObjectForIUnknown(ppDevice);
						endpoint = oDevice as IMMDevice;
						if (endpoint == null)
						{
							throw new Exception("Could not cast to IMMDevice");
						}

						// Get the IMMDevice endpoint id
						string endpointId;
						hr = endpoint.GetId(out endpointId);
						if (hr != 0)
						{
							throw new Exception("HResult from IMMDevice.GetId = " + hr);
						}
						
						// Activate the IMMDevice endpoint
						IntPtr pActivationParams = IntPtr.Zero;
						IntPtr ppClient = IntPtr.Zero;
						object oClient = null;
						IAudioClient client = null;
						hr = endpoint.Activate(ref IID_IAudioClient, (uint)CLSCTX.CLSCTX_ALL, pActivationParams, ref ppClient);
						if (hr != 0)
						{
							throw new Exception("HResult from IMMDevice.Activate = " + hr);
						}
						else if (ppClient == IntPtr.Zero)
						{
							throw new Exception("IMMDevice.Activate returned pointer was zero.");
						}
						oClient = Marshal.GetObjectForIUnknown(ppClient);
						client = oClient as IAudioClient;
						if (client == null)
						{
							throw new Exception("Could not cast to IAudioClient");
						}
                    
						// Get device mix format
						IntPtr deviceFormat = IntPtr.Zero;
						hr = client.GetMixFormat(ref deviceFormat);
						if (deviceFormat == null)
						{
							throw new Exception("IAudioClient.GetMixFormat returned null value.");
						}

						// Initialize stream
						Guid sessionGuid = Guid.Empty;
						hr = client.Initialize(AUDCLNT_SHAREMODE.AUDCLNT_SHAREMODE_SHARED, 0, 0, 0, deviceFormat, ref sessionGuid);
						
						result = true;
					}
				}
				catch(InvalidCastException icex)
				{
					Console.WriteLine("Unexpected COM exception: " + icex.Message);
					 result = false;
				}
				catch(Exception ex)
				{
					Console.WriteLine(ex.Message);
					result = false;
				}
				return result;
			}
		}
	}
"@
	Add-Type -TypeDefinition $audioServiceTestSource
	$audioServiceResponsive = [Microsoft.Windows.Diagnosis.AudioServiceResponsive]
    if($action.Contains("audioClientResponse"))
    {
        # Call IAudioClient::Initialize on all the Active endpoints
	    $result = $audioServiceResponsive::intiateAudioClient()
    }
    elseif($action.Contains("audioClientCount"))
    {
	    # Call IAudioClient to return the count of audio client
	    $result = $audioServiceResponsive::audioClientCount()
    }
	return $result

}


#====================================================================================
# Main
#====================================================================================

$audioClientCount = Verify-AudioServiceResponse("audioClientCount")
if($audioClientCount -gt 0)
{
	$serviceResponse = Verify-AudioServiceResponse("audioClientResponse")
	if(!($serviceResponse))
	{
		$detected = $true
		$rcDetected = 1
	}
	Update-DiagRootCause -id "RC_AudioServiceResponse" -Detected $detected
}
else
{
	$rcDetected = 2
	Update-DiagRootCause -ID 'RC_AudioDevice' -Detected $true -Parameter @{'DEVICEID' = 'ScanOnly'}
}

return $rcDetected
