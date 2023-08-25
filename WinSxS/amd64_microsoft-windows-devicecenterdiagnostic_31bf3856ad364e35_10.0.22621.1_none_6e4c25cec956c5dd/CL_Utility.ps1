# Copyright © 2008, Microsoft Corporation. All rights reserved.


#CL_Utility

function GetProblematicFunctionForObject([string]$DDOContainerID)
{
$GetProblematicFunctionSource = @"
using System;
using System.Text;
using System.Collections;
using System.Runtime.InteropServices;
namespace Microsoft.Windows.Diagnosis
{
    [StructLayout(LayoutKind.Sequential)]
    public struct PropVariant
    {
        #region struct fields

        // The layout of these elements needs to be maintained.
        //
        // NOTE: We could use LayoutKind.Explicit, but we want
        //       to maintain that the IntPtr may be 8 bytes on
        //       64-bit architectures, so we'll let the CLR keep
        //       us aligned.
        //
        // NOTE: In order to allow x64 compat, we need to allow for
        //       expansion of the IntPtr. However, the BLOB struct
        //       uses a 4-byte int, followed by an IntPtr, so
        //       although the p field catches most pointer values,
        //       we need an additional 4-bytes to get the BLOB
        //       pointer. The p2 field provides this, as well as
        //       the last 4-bytes of an 8-byte value on 32-bit
        //       architectures.

        // This is actually a VarEnum value, but the VarEnum type
        // shifts the layout of the struct by 4 bytes instead of the
        // expected 2.
        ushort vt;
        ushort wReserved1;
        ushort wReserved2;
        ushort wReserved3;
        IntPtr p;
        int p2;

        #endregion // struct fields

        #region union members

        sbyte cVal // CHAR cVal;
        {
            get { return (sbyte)GetDataBytes()[0]; }
        }

        byte bVal // UCHAR bVal;
        {
            get { return GetDataBytes()[0]; }
        }

        short iVal // SHORT iVal;
        {
            get { return BitConverter.ToInt16(GetDataBytes(), 0); }
        }

        ushort uiVal // USHORT uiVal;
        {
            get { return BitConverter.ToUInt16(GetDataBytes(), 0); }
        }

        int lVal // LONG lVal;
        {
            get { return BitConverter.ToInt32(GetDataBytes(), 0); }
        }

        uint ulVal // ULONG ulVal;
        {
            get { return BitConverter.ToUInt32(GetDataBytes(), 0); }
        }

        long hVal // LARGE_INTEGER hVal;
        {
            get { return BitConverter.ToInt64(GetDataBytes(), 0); }
        }

        ulong uhVal // ULARGE_INTEGER uhVal;
        {
            get { return BitConverter.ToUInt64(GetDataBytes(), 0); }
        }

        float fltVal // FLOAT fltVal;
        {
            get { return BitConverter.ToSingle(GetDataBytes(), 0); }
        }

        double dblVal // DOUBLE dblVal;
        {
            get { return BitConverter.ToDouble(GetDataBytes(), 0); }
        }

        bool boolVal // VARIANT_BOOL boolVal;
        {
            get { return (iVal == 0 ? false : true); }
        }

        int scode // SCODE scode;
        {
            get { return lVal; }
        }

        decimal cyVal // CY cyVal;
        {
            get { return decimal.FromOACurrency(hVal); }
        }

        DateTime date // DATE date;
        {
            get { return DateTime.FromOADate(dblVal); }
        }

        #endregion // union members

        /// <summary>
        /// Gets a byte array containing the data bits of the struct.
        /// </summary>
        /// <returns>A byte array that is the combined size of the data bits.</returns>
        private byte[] GetDataBytes()
        {
            byte[] ret = new byte[IntPtr.Size + sizeof(int)];
            if (IntPtr.Size == 4)
                BitConverter.GetBytes(p.ToInt32()).CopyTo(ret, 0);
            else if (IntPtr.Size == 8)
                BitConverter.GetBytes(p.ToInt64()).CopyTo(ret, 0);
            BitConverter.GetBytes(p2).CopyTo(ret, IntPtr.Size);
            return ret;
        }

        /// <summary>
        /// Called to properly clean up the memory referenced by a PropVariant instance.
        /// </summary>
        [DllImport("ole32.dll")]
        private extern static int PropVariantClear(ref PropVariant pvar);

        /// <summary>
        /// Called to clear the PropVariant's referenced and local memory.
        /// </summary>
        /// <remarks>
        /// You must call Clear to avoid memory leaks.
        /// </remarks>
        public void Clear()
        {
            // Can't pass "this" by ref, so make a copy to call PropVariantClear with
            PropVariant var = this;
            PropVariantClear(ref var);

            // Since we couldn't pass "this" by ref, we need to clear the member fields manually
            // NOTE: PropVariantClear already freed heap data for us, so we are just setting
            //       our references to null.
            vt = (ushort)VarEnum.VT_EMPTY;
            wReserved1 = wReserved2 = wReserved3 = 0;
            p = IntPtr.Zero;
            p2 = 0;
        }

        /// <summary>
        /// Gets the variant type.
        /// </summary>
        public VarEnum Type
        {
            get { return (VarEnum)vt; }
        }

        /// <summary>
        /// Gets the variant value.
        /// </summary>
        public object Value
        {
            get
            {
                // TODO: Add support for reference types (ie. VT_REF | VT_I1)
                // TODO: Add support for safe arrays

                switch ((VarEnum)vt)
                {
                    case VarEnum.VT_I1:
                        return cVal;
                    case VarEnum.VT_UI1:
                        return bVal;
                    case VarEnum.VT_I2:
                        return iVal;
                    case VarEnum.VT_UI2:
                        return uiVal;
                    case VarEnum.VT_I4:
                    case VarEnum.VT_INT:
                        return lVal;
                    case VarEnum.VT_UI4:
                    case VarEnum.VT_UINT:
                        return ulVal;
                    case VarEnum.VT_I8:
                        return hVal;
                    case VarEnum.VT_UI8:
                        return uhVal;
                    case VarEnum.VT_R4:
                        return fltVal;
                    case VarEnum.VT_R8:
                        return dblVal;
                    case VarEnum.VT_BOOL:
                        return boolVal;
                    case VarEnum.VT_ERROR:
                        return scode;
                    case VarEnum.VT_CY:
                        return cyVal;
                    case VarEnum.VT_DATE:
                        return date;
                    case VarEnum.VT_FILETIME:
                        return DateTime.FromFileTime(hVal);
                    case VarEnum.VT_BSTR:
                        return Marshal.PtrToStringBSTR(p);
                    case VarEnum.VT_BLOB:
                        byte[] blobData = new byte[lVal];
                        IntPtr pBlobData;
                        if (IntPtr.Size == 4)
                        {
                            pBlobData = new IntPtr(p2);
                        }
                        else if (IntPtr.Size == 8)
                        {
                            // In this case, we need to derive a pointer at offset 12,
                            // because the size of the blob is represented as a 4-byte int
                            // but the pointer is immediately after that.
                            pBlobData = new IntPtr(BitConverter.ToInt64(GetDataBytes(), sizeof(int)));
                        }
                        else
                            throw new NotSupportedException();
                        Marshal.Copy(pBlobData, blobData, 0, lVal);
                        return blobData;
                    case VarEnum.VT_LPSTR:
                        return Marshal.PtrToStringAnsi(p);
                    case VarEnum.VT_LPWSTR:
                        return Marshal.PtrToStringUni(p);
                    case VarEnum.VT_UNKNOWN:
                        return Marshal.GetObjectForIUnknown(p);
                    case VarEnum.VT_DISPATCH:
                        return p;
                    case VarEnum.VT_CLSID:
                        return Marshal.PtrToStructure(p, typeof(Guid));
                    case VarEnum.VT_EMPTY:
                        return null;
                    default:
                        throw new NotSupportedException("The type of this variable is not support ('" + vt.ToString() + "')");
                }
            }
        }
    }

    public class DDOManager
    {
        //
        //Define const and static varialbe
        //
        #region

        public const UInt32 S_OK = 0;
        public const UInt32 CLSCTX_ALL = 23;
        public const UInt32 STGM_READ = 0;

        public static Guid CLSID_FunctionDiscovery = new Guid("C72BE2EC-8E90-452c-B29A-AB8FF1C071FC");
        public static Guid IID_IFunctionDiscovery = new Guid("4DF99B70-E148-4432-B004-4C9EEB535A5E");
        public static Guid IID_IFunctionInstanceCollection = new Guid("F0A3D895-855C-42A2-948D-2F97D450ECB1");
        public static Guid SID_EnumDeviceFunction = new Guid("13E0E9E2-C3FA-4E3C-906E-64502FA4DC95");
        public static Guid SID_EnumInterface = new Guid("40eab0b9-4d7f-4b53-a334-1581dd9041f4");

        public static PROPERTYKEY PKEY_NAME = new PROPERTYKEY(new Guid("B725F130-47EF-101A-A5F1-02608C9EEBAC"), 10);
        public static PROPERTYKEY PKEY_DeviceInterface_PrinterName = new PROPERTYKEY(new Guid("0A7B84EF-0C27-463F-84EF-06C5070001BE"), 10);
        public static PROPERTYKEY PKEY_DeviceInterface_ClassGuid = new PROPERTYKEY(new Guid("026E516E-B814-414B-83CD-856D6FEF4822"), 4);
        public static PROPERTYKEY PKEY_DeviceInterface_DevicePath = new PROPERTYKEY(new Guid("53808008-07BB-4661-BC3C-B5953E708560"), 1);
        public static PROPERTYKEY PKEY_Device_InstanceId = new PROPERTYKEY(new Guid("78C34FC8-104A-4ACA-9EA4-524D52996E57"), 256);
        public static PROPERTYKEY PKEY_Device_ConfigFlags = new PROPERTYKEY(new Guid("A45C254E-DF1C-4EFD-8020-67D146A850E0"), 12);
        public static PROPERTYKEY PKEY_Device_ProblemCode = new PROPERTYKEY(new Guid("4340A6C5-93FA-4706-972C-7B648008A5A7"), 3);
        public static PROPERTYKEY PKEY_Device_ContainerId = new PROPERTYKEY(new Guid("8c7ed206-3f8a-4827-b3ab-ae9e1faefc6c"), 2);
        public static PROPERTYKEY PKEY_Device_DriverInfPath = new PROPERTYKEY(new Guid("a8b865dd-2e3d-4094-ad97-e593a70c75d6"), 5);
        public static PROPERTYKEY PKEY_Device_Capabilities = new PROPERTYKEY(new Guid("A45C254E-DF1C-4EFD-8020-67D146A850E0"), 17);

        public static readonly Guid Guid_DeviceType_Printer = new Guid("0ECEF634-6EF0-472A-8085-5AD023ECBCCD");
        public static readonly Guid ContainerId_Computer = new Guid("{00000000-0000-0000-ffff-ffffffffffff}");

        public const string FCTN_CATEGORY_DEVQUERYOBJECTS = "Provider\\Microsoft.Base.DevQueryObjects";

        public const UInt32 RAW_DEVICE_OK_FLAG = 0x40;

        #endregion

        //
        //Define useful enum and struct
        //
        #region

        public enum HardDeviceType
        {
            PNPDevice = 0,
            Printer,
            USB
        };

        public enum SystemVisibilityFlags
        {
            SVF_SYSTEM = 0,
            SVF_USER
        };

        public struct DeviceInfo
        {
            private string deviceName;
            private HardDeviceType type;
            private string deviceID;

            public string DeviceName
            {
                get
                {
                    return deviceName;
                }
                set
                {
                    deviceName = value;
                }
            }

            public HardDeviceType Type
            {
                get
                {
                    return type;
                }
                set
                {
                    type = value;
                }
            }
            public string DeviceID
            {
                get
                {
                    return deviceID;
                }
                set
                {
                    deviceID = value;
                }
            }
        };

        public struct PROPERTYKEY
        {
            public PROPERTYKEY(Guid InputId, UInt32 InputPid)
            {
                fmtid = InputId;
                pid = InputPid;
            }
            Guid fmtid;
            UInt32 pid;
        };

        #endregion

        //
        //P/Invoke Win32 APIs
        //
        #region

        [DllImport("ole32.dll", EntryPoint = "CoCreateInstance", SetLastError = true)]
        public static extern UInt32 CoCreateInstance(ref Guid guid, [MarshalAs(UnmanagedType.IUnknown)] object inner, uint context, ref Guid id, ref IntPtr pointer);

        #endregion

        //
        //P/Invoke COM Interfaces
        //
        #region

        [Guid("4DF99B70-E148-4432-B004-4C9EEB535A5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        public interface IFunctionDiscovery
        {
            UInt32 GetInstanceCollection([MarshalAs(UnmanagedType.LPWStr)] string pszCategory,
                IntPtr pszSubCategory,
                [MarshalAs(UnmanagedType.Bool)]bool fIncludeAllSubCategories,
                ref IntPtr ppIFunctionInstanceCollection);

            UInt32 GetInstance([MarshalAs(UnmanagedType.LPWStr)] ref string pszFunctionInstanceIdentity,
                ref IntPtr ppIFunctionInstance);

            UInt32 CreateInstanceCollectionQuery([MarshalAs(UnmanagedType.LPWStr)] string pszCategory,
                [MarshalAs(UnmanagedType.LPWStr)] string pszSubCategory,
                [MarshalAs(UnmanagedType.Bool)] bool fIncludeAllSubCategories,
                IntPtr pIFunctionDiscoveryNotification,
                IntPtr pfdqcQueryContext,
                ref IntPtr ppIFunctionInstanceCollectionQuery);

            UInt32 CreateInstanceQuery([MarshalAs(UnmanagedType.LPWStr)] string pszFunctionInstanceIdentity,
                IntPtr pIFunctionDiscoveryNotification,
                IntPtr pfdqcQueryContext,
                ref IntPtr ppIFunctionInstanceQuery);

            UInt32 AddInstance(SystemVisibilityFlags enumSystemVisibility,
                [MarshalAs(UnmanagedType.LPWStr)] string pszCategory,
                [MarshalAs(UnmanagedType.LPWStr)] string pszSubCategory,
                [MarshalAs(UnmanagedType.LPWStr)] string pszCategoryIdentity,
                ref IntPtr ppIFunctionInstance);

            UInt32 RemoveInstance(SystemVisibilityFlags enumSystemVisibility,
                [MarshalAs(UnmanagedType.LPWStr)] string pszCategory,
                [MarshalAs(UnmanagedType.LPWStr)] string pszSubCategory,
                [MarshalAs(UnmanagedType.LPWStr)] string pszCategoryIdentity);
        }

        [Guid("F0A3D895-855C-42A2-948D-2F97D450ECB1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        public interface IFunctionInstanceCollection
        {
            UInt32 GetCount(ref UInt32 pdwCount);

            UInt32 Get([MarshalAs(UnmanagedType.LPWStr)] string pszInstanceIdentity,
                ref UInt32 pdwIndex,
                ref IntPtr ppIFunctionInstance);

            UInt32 Item(UInt32 dwIndex, ref IntPtr ppIFunctionInstance);

            UInt32 Add(IntPtr pIFunctionInstance);

            UInt32 Remove(UInt32 dwIndex, ref IntPtr ppIFunctionInstance);

            UInt32 Delete(UInt32 dwIndex);

            UInt32 DeleteAll();
        }

        [Guid("6D5140C1-7436-11CE-8034-00AA006009FA"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        public interface IServiceProvider
        {
            UInt32 QueryService(ref Guid guidService, ref Guid riid, ref IntPtr ppvObject);
            UInt32 QueryService(ref Guid guidService, ref IntPtr pp);
        }

        [Guid("33591C10-0BED-4F02-B0AB-1530D5533EE9"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        public interface IFunctionInstance
        {
            UInt32 QueryService(ref Guid guidService, ref Guid riid, ref IntPtr ppvObject);

            UInt32 GetID([MarshalAs(UnmanagedType.LPWStr)] ref string ppszCoMemIdentity);

            UInt32 GetProviderInstanceID([MarshalAs(UnmanagedType.LPWStr)] ref string ppszCoMemProviderInstanceIdentity);

            UInt32 OpenPropertyStore(UInt32 dwStgAccess, ref IntPtr ppIPropertyStore);

            UInt32 GetCategory([MarshalAs(UnmanagedType.LPWStr)] ref string ppszCoMemCategory, [MarshalAs(UnmanagedType.LPWStr)] ref string ppszCoMemSubCategory);
        }

        [Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        public interface IPropertyStore
        {
            UInt32 GetCount(ref UInt32 cProps);

            UInt32 GetAt(UInt32 iProp, ref PROPERTYKEY pkey);

            UInt32 GetValue(ref PROPERTYKEY key, ref PropVariant pv);

            UInt32 SetValue(ref PROPERTYKEY key, ref PropVariant propvar);

            UInt32 Commit();
        };

        #endregion

        public static bool IsPrinterDevice(IFunctionInstance DeviceDisplayObject, ref DeviceInfo printerInfo)
        {
            bool isPrinter = false;
            Guid devicTypeID = Guid.Empty;
            UInt32 serviceCount = 0;
            UInt32 deviceFunctionCount = 0;

            IntPtr deviceFICollectionPtr = IntPtr.Zero;
            IntPtr serviceFICollectionPtr = IntPtr.Zero;
            IntPtr deviceFunctionInstancePtr = IntPtr.Zero;
            IntPtr serviceFunctionInstancePtr = IntPtr.Zero;
            IntPtr propertyStorePtr = IntPtr.Zero;

            IFunctionInstanceCollection deviceFICollection = null;
            IFunctionInstanceCollection serviceFICollection = null;
            IFunctionInstance deviceFunctionInstance = null;
            IFunctionInstance serviceFunctionInstance = null;
            IPropertyStore propertyStore = null;

            PropVariant variantData = new PropVariant();

            //
            //Enumerate device function instances
            //
            DeviceDisplayObject.QueryService(ref SID_EnumDeviceFunction, ref IID_IFunctionInstanceCollection, ref deviceFICollectionPtr);
            deviceFICollection = (IFunctionInstanceCollection)Marshal.GetObjectForIUnknown(deviceFICollectionPtr);
            deviceFICollection.GetCount(ref deviceFunctionCount);
            for (UInt32 i = 0; i < deviceFunctionCount; i++)
            {
                deviceFICollection.Item(i, ref deviceFunctionInstancePtr);
                if (IntPtr.Zero != deviceFunctionInstancePtr)
                {
                    deviceFunctionInstance = (IFunctionInstance)Marshal.GetObjectForIUnknown(deviceFunctionInstancePtr);

                    //
                    //Enumerate service for a device function instance
                    //
                    deviceFunctionInstance.QueryService(ref SID_EnumInterface, ref IID_IFunctionInstanceCollection, ref serviceFICollectionPtr);
                    if (IntPtr.Zero != serviceFICollectionPtr)
                    {
                        serviceFICollection = (IFunctionInstanceCollection)Marshal.GetObjectForIUnknown(serviceFICollectionPtr);
                        serviceFICollection.GetCount(ref serviceCount);

                        for (UInt32 j = 0; j < serviceCount; j++)
                        {
                            serviceFICollection.Item(j, ref serviceFunctionInstancePtr);
                            if (IntPtr.Zero != serviceFunctionInstancePtr)
                            {
                                serviceFunctionInstance = (IFunctionInstance)Marshal.GetObjectForIUnknown(serviceFunctionInstancePtr);
                                serviceFunctionInstance.OpenPropertyStore(STGM_READ, ref propertyStorePtr);
                                if (IntPtr.Zero != propertyStorePtr)
                                {
                                    propertyStore = (IPropertyStore)Marshal.GetObjectForIUnknown(propertyStorePtr);
                                    propertyStore.GetValue(ref PKEY_DeviceInterface_ClassGuid, ref variantData);

                                    if (VarEnum.VT_CLSID != variantData.Type)
                                    {
                                        variantData.Clear();
                                        Marshal.Release(propertyStorePtr);
                                        continue;
                                    }

                                    devicTypeID = (Guid)variantData.Value;
                                    variantData.Clear();
                                    if (devicTypeID.Equals(Guid_DeviceType_Printer))
                                    {
                                        isPrinter = true;
                                        propertyStore.GetValue(ref PKEY_DeviceInterface_PrinterName, ref variantData);
                                        printerInfo.DeviceName = variantData.Value.ToString();
                                        printerInfo.Type = HardDeviceType.Printer;

                                        variantData.Clear();
                                        Marshal.Release(propertyStorePtr);
                                        break;
                                    }
                                    Marshal.Release(propertyStorePtr);
                                }
                                Marshal.Release(serviceFunctionInstancePtr);
                            }
                        }
                        Marshal.Release(serviceFICollectionPtr);
                    }
                    Marshal.Release(deviceFunctionInstancePtr);
                }
            }

            if (IntPtr.Zero != deviceFICollectionPtr)
            {
                Marshal.Release(deviceFICollectionPtr);
            }
            return isPrinter;
        }

        public static ArrayList GetDeviceInfo(IFunctionInstance deviceDisplayObject)
        {
            // Generate a list of DeviceInfo structs where each element is targeted
            // for one of: Printer TS(max 1 element), PnP TS, or USB TS.
            ArrayList deviceInfoAry = new ArrayList();
            DeviceInfo deviceDataInfo = new DeviceInfo();

            if (IsPrinterDevice(deviceDisplayObject, ref deviceDataInfo))
            {
                deviceInfoAry.Add(deviceDataInfo);
            }

            GetPnpAndUsbDeviceInfo(deviceDisplayObject, deviceInfoAry);

            return deviceInfoAry;
        }

        public static void GetPnpAndUsbDeviceInfo(IFunctionInstance DeviceDisplayObject, ArrayList DeviceInfoArray)
        {
            UInt32 ResultCode = 0;
            UInt32 FunctionCount = 0;

            // ResultDeviceInfo will store data about a devnode (different devnodes at different times).
            // When a devnode should be troubleshooted, we'll call DeviceInfoArray.Add(ResultDeviceInfo).
            // This saves off the current value of ResultDeviceInfo.  (Note the object's value is saved off
            // instead of the object itself being referenced, since the object is a DeviceInfo, a value type.)
            DeviceInfo ResultDeviceInfo = new DeviceInfo();

            IntPtr FICollectionPtr = IntPtr.Zero;
            IntPtr FunctionInstancePtr = IntPtr.Zero;
            IntPtr PropertyStorePtr = IntPtr.Zero;

            IFunctionInstanceCollection FICollection = null;
            IFunctionInstance FunctionInstance = null;
            IPropertyStore PropertyStore = null;

            PropVariant VariantData = new PropVariant();
            bool NoDriver = false;
            bool RawCapable = false;

            string Category = null;
            string SubCategory = null;

            //
            //Enumerate device function instance for DDO
            //
            DeviceDisplayObject.QueryService(ref SID_EnumDeviceFunction, ref IID_IFunctionInstanceCollection, ref FICollectionPtr);
            if (IntPtr.Zero != FICollectionPtr)
            {
                FICollection = (IFunctionInstanceCollection)Marshal.GetObjectForIUnknown(FICollectionPtr);
                ResultCode = FICollection.GetCount(ref FunctionCount);

                for (UInt32 i = 0; i < FunctionCount; i++)
                {
                    ResultCode = FICollection.Item(i, ref FunctionInstancePtr);
                    if (IntPtr.Zero != FunctionInstancePtr)
                    {
                        FunctionInstance = (IFunctionInstance)Marshal.GetObjectForIUnknown(FunctionInstancePtr);

                        ResultCode = FunctionInstance.GetCategory(ref Category, ref SubCategory);
                        if (Category != null)
                        {
                            ResultCode = FunctionInstance.OpenPropertyStore(STGM_READ, ref PropertyStorePtr);
                            if (IntPtr.Zero != PropertyStorePtr)
                            {
                                PropertyStore = (IPropertyStore)Marshal.GetObjectForIUnknown(PropertyStorePtr);

                                ResultCode = PropertyStore.GetValue(ref PKEY_NAME, ref VariantData);
                                if (VarEnum.VT_EMPTY != VariantData.Type)
                                {
                                    ResultDeviceInfo.DeviceName = VariantData.Value.ToString();
                                    VariantData.Clear();
                                }
                                else
                                {
                                    ResultDeviceInfo.DeviceName = string.Empty;
                                }

                                ResultCode = PropertyStore.GetValue(ref PKEY_Device_InstanceId, ref VariantData);
                                ResultDeviceInfo.DeviceID = VariantData.Value.ToString();
                                VariantData.Clear();

                                // Check if this is a USB devnode relevant to USB troubleshooter.
                                // Include any device whose enumerator is "USB".  This includes:
                                // 1. USB root hubs; 2. USB hubs; 3. USB peripheral devices; 4. USB composite device interfaces
                                if (ResultDeviceInfo.DeviceID.StartsWith("USB", StringComparison.InvariantCultureIgnoreCase))
                                {

                                    // Get container ID.
                                    ResultCode = PropertyStore.GetValue(ref PKEY_Device_ContainerId, ref VariantData);
                                    Guid DeviceContainerId = (Guid)VariantData.Value;
                                    VariantData.Clear();

                                    // If it's an internal (computer container) USB device,
                                    //   don't include it for the USB troubleshooter.
                                    if (!DeviceContainerId.Equals(ContainerId_Computer))
                                    {
                                        ResultDeviceInfo.Type = HardDeviceType.USB; // which troubleshooter
                                        DeviceInfoArray.Add(ResultDeviceInfo); // copies current value into new array element
                                    }

                                }

                                ResultCode = PropertyStore.GetValue(ref PKEY_Device_ProblemCode, ref VariantData);
                                if (VariantData.Type == VarEnum.VT_UI4)
                                {
                                    int ConfigManagerErrorCode = Convert.ToInt32(VariantData.Value);
                                    VariantData.Clear();

                                    ResultCode = PropertyStore.GetValue(ref PKEY_Device_DriverInfPath, ref VariantData);
                                    NoDriver = (VariantData.Type == VarEnum.VT_EMPTY);
                                    VariantData.Clear();

                                    // Check to see if the device is RAW capable by selecting the Device Capabilities
                                    // flag from the Property Store and examining the proper bit in the bitfield.
                                    ResultCode = PropertyStore.GetValue(ref PKEY_Device_Capabilities, ref VariantData);
                                    RawCapable = (RAW_DEVICE_OK_FLAG == (Convert.ToUInt32(VariantData.Value) & RAW_DEVICE_OK_FLAG));
                                    VariantData.Clear();

                                    // If a device is RAW capable and has no driver then it should be excluded from
                                    // the device info array.
                                    if (0 != ConfigManagerErrorCode || (NoDriver && !RawCapable))
                                    {
                                        ResultDeviceInfo.Type = HardDeviceType.PNPDevice;
                                        DeviceInfoArray.Add(ResultDeviceInfo); // copies current value into new array element
                                    }
                                }
                                Marshal.Release(PropertyStorePtr);
                            }
                        }
                        Marshal.Release(FunctionInstancePtr);
                    }
                }
                Marshal.Release(FICollectionPtr);
            }
        }

        public static ArrayList DiagnosticDeviceDisplayObject(Guid TargetContainerID)
        {
            ArrayList ProblemDeviceInfo = null;
            UInt32 ResultCode = 0;
            UInt32 InstanceCount = 0;

            IntPtr FunctionDiscoveryPtr = IntPtr.Zero;
            IntPtr FICollectionPtr = IntPtr.Zero;
            IntPtr FunctionInstancePtr = IntPtr.Zero;
            IntPtr PropertyStorePtr = IntPtr.Zero;

            IFunctionDiscovery FunctionDiscovery = null;
            IFunctionInstanceCollection FICollection = null;
            IFunctionInstance FunctionInstance = null;
            IPropertyStore PropertyStore = null;

            PropVariant VariantData = new PropVariant();

            ResultCode = CoCreateInstance(ref CLSID_FunctionDiscovery, null, CLSCTX_ALL, ref IID_IFunctionDiscovery, ref FunctionDiscoveryPtr);
            if (IntPtr.Zero != FunctionDiscoveryPtr)
            {
                FunctionDiscovery = (IFunctionDiscovery)Marshal.GetObjectForIUnknown(FunctionDiscoveryPtr);
                ResultCode = FunctionDiscovery.GetInstanceCollection(FCTN_CATEGORY_DEVQUERYOBJECTS, IntPtr.Zero, false, ref FICollectionPtr);

                if (IntPtr.Zero != FICollectionPtr)
                {
                    FICollection = (IFunctionInstanceCollection)Marshal.GetObjectForIUnknown(FICollectionPtr);
                    ResultCode = FICollection.GetCount(ref InstanceCount);
                    for (UInt32 i = 0; i < InstanceCount; i++)
                    {
                        ResultCode = FICollection.Item(i, ref FunctionInstancePtr);
                        if (IntPtr.Zero != FunctionInstancePtr)
                        {
                            FunctionInstance = (IFunctionInstance)Marshal.GetObjectForIUnknown(FunctionInstancePtr);
                            ResultCode = FunctionInstance.OpenPropertyStore(STGM_READ, ref PropertyStorePtr);
                            if (IntPtr.Zero != PropertyStorePtr)
                            {
                                PropertyStore = (IPropertyStore)Marshal.GetObjectForIUnknown(PropertyStorePtr);

                                ResultCode = PropertyStore.GetValue(ref PKEY_NAME, ref VariantData);
                                if (VariantData.Value == null)
                                {
                                    continue;
                                }

                                string DeviceObjectName = VariantData.Value.ToString();
                                VariantData.Clear();

                                ResultCode = PropertyStore.GetValue(ref PKEY_Device_ContainerId, ref VariantData);
                                Guid ContainerID = (Guid)VariantData.Value;
                                VariantData.Clear();
                                if (TargetContainerID.Equals(ContainerID))
                                {
                                    ProblemDeviceInfo = GetDeviceInfo(FunctionInstance);
                                    Marshal.Release(FunctionInstancePtr);
                                    Marshal.Release(PropertyStorePtr);

                                    break;
                                }
                                Marshal.Release(PropertyStorePtr);
                            }

                            Marshal.Release(FunctionInstancePtr);
                        }
                    }

                    Marshal.Release(FICollectionPtr);
                }

                Marshal.Release(FunctionDiscoveryPtr);
            }
            return ProblemDeviceInfo;
        }
    }
}
"@
    Add-Type -TypeDefinition $GetProblematicFunctionSource

    $DDOManagerObject = [Microsoft.Windows.Diagnosis.DDOManager]

    [Guid]$guidContainer = new-object -TypeName System.Guid($DDOContainerID)

    $DeviceIDArray = $DDOManagerObject::DiagnosticDeviceDisplayObject($guidContainer)

    return $DeviceIDArray
}
 
