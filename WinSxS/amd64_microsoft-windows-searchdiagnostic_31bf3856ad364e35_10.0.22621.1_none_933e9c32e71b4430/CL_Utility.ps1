# Copyright © 2008, Microsoft Corporation. All rights reserved.

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Returns absolute path of given filename relative to current directory
function GetAbsolutePath([string]$fileName)
{
    if([string]::IsNullorEmpty($fileName))
    {
        WriteFunctionExceptionReport "GetAbsolutePath" $localizationString.throw_invalidFileName
        return
    }

    return Join-Path (Get-Location).Path $fileName
}

# Get system path of a file by adding the system path of current directory in the head of the specified file
function GetSystemPath([string]$fileName)
{
    if([string]::IsNullorEmpty($fileName))
    {
        WriteFunctionExceptionReport "GetSystemPath" $localizationString.throw_invalidFileName
        return
    }

    [string]$systemPath = [System.Environment]::SystemDirectory
    return Join-Path $systemPath $fileName
}

# Synchronize with the invoked process. Main process will wait for the child process to end.
function SyncInvoke([string]$executableCommand, [string]$arguments, [string]$windowName, [string]$className)
{
    if([string]::IsNullorEmpty($executableCommand))
    {
        WriteFunctionExceptionReport "SyncInvoke" $localizationString.throw_noExecutableCommandSpecified
        return
    }

    [System.Diagnostics.ProcessStartInfo]$startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $executableCommand
    $startInfo.Arguments = $arguments
    $startInfo.UseShellExecute = $true

    $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal

    [System.Diagnostics.Process]$process = $null
    try
    {
        $process = [System.Diagnostics.Process]::Start($startInfo)
        SetTopWindow $windowName $className $false
        $process.waitforexit()
    }
    finally
    {
        if(-not $process.HasExited)
        {
            $process.kill()
        }
    }
}

# Run PowerShell script and return boolean value
function RunDiagnosticScript([string]$scriptPath)
{
    if([string]::IsNullorEmpty($scriptPath) -or -not (Test-Path $scriptPath))
    {
        WriteFunctionExceptionReport "RunDiagnosticScript" $localizationString.throw_invalidFileName
        return
    }
    $result = &($scriptPath)
    if($result -is [bool])
    {
        return [bool]$result
    }
    else
    {
        return $false
    }
}

# Convert string to the PSObject and set the string as property value to specified property name
function ConvertStringToPSObject([string]$propertyName, [string]$propertyValue)
{
    $obj = New-Object -TypeName System.Management.Automation.PSObject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name $propertyName -Value $propertyValue
    return $obj
}

# Convert string array to the PSObject array and set the string value as property value to specified property name
function ConvertStringArrayToPSObjectArray($stringArray, [string]$propertyName)
{
    if($stringArray -eq $null)
    {
        return $null
    }
    $objArray = New-Object System.Collections.ArrayList
    foreach( $str in $stringArray)
    {
        $objArray += ConvertStringToPSObject $propertyName $str
    }
    return $objArray
}

# Write function exception to debug report
function WriteFunctionExceptionReport([string]$functionName, [string]$exceptionInfo)
{
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    $obj = ConvertStringToPSObject "exceptionInformation" $exceptionInfo
    $obj | select-object -Property @{Name=$localizationString.error_information; Expression={$_.exceptionInformation}} | convertto-xml | Update-DiagReport -id $functionName -name $errorFunctionName -description $errorFunctionDescription -verbosity Debug
}

# Write API exception in function to debug report
function WriteFunctionAPIExceptionReport([string]$functionName, [string]$APIName, [int]$errorCode)
{
    [string]$exceptionInfo = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, $APIName, $errorCode)
    WriteFunctionExceptionReport $functionName $exceptionInfo
}

# Write function exception to debug report
function WriteFileExceptionReport([string]$fileName, [string]$exceptionInfo)
{
    [string]$errorFileName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_file_name, $fileName)
    [string]$errorFileDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_file_description, $fileName)
    $obj = ConvertStringToPSObject "exceptionInformation" $exceptionInfo
    $obj | select-object -Property @{Name=$localizationString.error_information; Expression={$_.exceptionInformation}} | convertto-xml | Update-DiagReport -id $fileName -name $errorFileName -description $errorFileDescription -verbosity Debug
}

# Write API exception in file to debug report
function WriteFileAPIExceptionReport([string]$fileName, [string]$APIName, [int]$errorCode)
{
    [string]$exceptionInfo = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, $APIName, $errorCode)
    WriteFileExceptionReport $fileName $exceptionInfo
}

# Function to create a choice in interaction page
function Get-Choice([string]$name = $(throw "No choice name is specified"), [string]$description = $(throw "No choice description is specified"),
                   [string]$value = $(throw "No choice value is specified"), [xml]$extension)
{
    return @{"Name"=$name;"Description"=$description;"Value"=$value;"ExtensionPoint"=$extension.InnerXml}
}

# Function to grant the current process the right to assign ownership of security descriptors
function Set-RestorePrivilege()
{
    $typeDefinition = @"

    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    public static class SetPrivilegeMethods
    {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
            [In] ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool OpenProcessToken(IntPtr h, int acc, out IntPtr phtok);

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct LUID
        {
            public uint LowPart;
            public int  HighPart;
        }

        [DllImport("advapi32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool LookupPrivilegeValue(string host, string name, out LUID pluid);

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool LookupPrivilegeName(string lpSystemName, [In] ref LUID lpLuid,
            System.Text.StringBuilder lpName, [In, Out] ref int cchName );

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct TokPriv1Luid
        {
            public uint Count;
            public LUID Luid;
            public uint Attr;
        }

        internal const int ERROR_SUCCESS = 0;
        internal const int ERROR_NOT_ALL_ASSIGNED = 1300;
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int SE_PRIVILEGE_REMOVED = 0x00000004;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
        internal const string SE_RESTORE_NAME = "SeRestorePrivilege";

        public static void SetRestorePrivilege()
        {
            TokPriv1Luid tp;
            IntPtr hproc = Process.GetCurrentProcess().Handle;
            IntPtr htok = IntPtr.Zero;
            if (!OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, out htok))
            {
                int error = Marshal.GetLastWin32Error();
                throw new System.ComponentModel.Win32Exception(error);
            }
            tp.Count = 1;
            tp.Luid.LowPart = 0;
            tp.Luid.HighPart = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            if (!LookupPrivilegeValue(null, SE_RESTORE_NAME, out tp.Luid))
            {
                int error = Marshal.GetLastWin32Error();
                throw new System.ComponentModel.Win32Exception(error);
            }

            if (!AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero))
            {
                int error = Marshal.GetLastWin32Error();
                throw new System.ComponentModel.Win32Exception(error);
            }
            else
            {
                int error = Marshal.GetLastWin32Error();
                if (ERROR_NOT_ALL_ASSIGNED == error)
                {
                    throw new System.ComponentModel.Win32Exception(error);
                }
            }
        }
    }
"@

    (Add-Type -TypeDefinition $typeDefinition -PassThru)[0]::SetRestorePrivilege()
}

[uint32]$GENERIC_ALL = 0x10000000L
[uint32]$GENERIC_READ = 0x80000000L
[uint32]$GENERIC_WRITE = 0x40000000L
[uint32]$GENERIC_EXECUTE = 0x20000000L

# Function to determine if given access rights for given SID are allowed or denied
function Get-AccessGranted([string]$file, [string]$sid, [uint32]$accessMask)
{
    $typeDefinition = @"

    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    public static class GetAccessGrantedMethods
    {
        internal const uint ERROR_SUCCESS                       = 0;
        internal const uint ERROR_ACCESS_DENIED                 = 5;
        internal const uint ERROR_INSUFFICIENT_BUFFER           = 122;
        internal const uint ERROR_INVALID_ACL                   = 1336;

        [Flags]
        public enum AccessRights : uint
        {
            FILE_READ_DATA = (0x0001),    // file & pipe
            FILE_LIST_DIRECTORY = (0x0001),    // directory
            FILE_WRITE_DATA = (0x0002),    // file & pipe
            FILE_ADD_FILE = (0x0002),    // directory
            FILE_APPEND_DATA = (0x0004),    // file
            FILE_ADD_SUBDIRECTORY = (0x0004),    // directory
            FILE_CREATE_PIPE_INSTANCE = (0x0004),    // named pipe
            FILE_READ_EA = (0x0008),    // file & directory
            FILE_WRITE_EA = (0x0010),    // file & directory
            FILE_EXECUTE = (0x0020),    // file
            FILE_TRAVERSE = (0x0020),    // directory
            FILE_DELETE_CHILD = (0x0040),    // directory
            FILE_READ_ATTRIBUTES = (0x0080),    // all
            FILE_WRITE_ATTRIBUTES = (0x0100),    // all
            FILE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x1FF),
            FILE_GENERIC_READ = (STANDARD_RIGHTS_READ |
                                               FILE_READ_DATA |
                                               FILE_READ_ATTRIBUTES |
                                               FILE_READ_EA |
                                               SYNCHRONIZE),
            FILE_GENERIC_WRITE = (STANDARD_RIGHTS_WRITE |
                                               FILE_WRITE_DATA |
                                               FILE_WRITE_ATTRIBUTES |
                                               FILE_WRITE_EA |
                                               FILE_APPEND_DATA |
                                               SYNCHRONIZE),
            FILE_GENERIC_EXECUTE = (STANDARD_RIGHTS_EXECUTE |
                                               FILE_READ_ATTRIBUTES |
                                               FILE_EXECUTE |
                                               SYNCHRONIZE),
            DELETE = (0x00010000),
            READ_CONTROL = (0x00020000),
            WRITE_DAC = (0x00040000),
            WRITE_OWNER = (0x00080000),
            SYNCHRONIZE = (0x00100000),
            STANDARD_RIGHTS_REQUIRED = (0x000F0000),
            STANDARD_RIGHTS_READ = (READ_CONTROL),
            STANDARD_RIGHTS_WRITE = (READ_CONTROL),
            STANDARD_RIGHTS_EXECUTE = (READ_CONTROL),
            STANDARD_RIGHTS_ALL = (0x001F0000),
            SPECIFIC_RIGHTS_ALL = (0x0000FFFF),
        }

        [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
        internal static extern void MapGenericMask([In, Out] ref uint AccessMask, [In] ref GENERIC_MAPPING GenericMapping);

        internal struct GENERIC_MAPPING
        {
            public AccessRights GenericRead;
            public AccessRights GenericWrite;
            public AccessRights GenericExecute;
            public AccessRights GenericAll;
        }

        [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool IsValidSid([MarshalAs(UnmanagedType.LPArray)] byte[] pSid);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
        internal static extern void BuildTrusteeWithSid(out TRUSTEE pTrustee, [MarshalAs(UnmanagedType.LPArray)] byte[] pSid);

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool GetSecurityDescriptorDacl(IntPtr pSecurityDescriptor,
            out bool lpbDaclPresent, out IntPtr pDacl, out bool lpbDaclDefaulted);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
        internal static extern uint GetEffectiveRightsFromAcl(IntPtr pAcl,
            [In] ref TRUSTEE pTrustee, out uint pAccessRights);

        internal enum MULTIPLE_TRUSTEE_OPERATION
        {
            NO_MULTIPLE_TRUSTEE,
            TRUSTEE_IS_IMPERSONATE
        }

        internal enum TRUSTEE_FORM
        {
            TRUSTEE_IS_SID,
            TRUSTEE_IS_NAME,
            TRUSTEE_BAD_FORM,
            TRUSTEE_IS_OBJECTS_AND_SID,
            TRUSTEE_IS_OBJECTS_AND_NAME
        }

        internal enum TRUSTEE_TYPE
        {
            TRUSTEE_IS_UNKNOWN,
            TRUSTEE_IS_USER,
            TRUSTEE_IS_GROUP,
            TRUSTEE_IS_DOMAIN,
            TRUSTEE_IS_ALIAS,
            TRUSTEE_IS_WELL_KNOWN_GROUP,
            TRUSTEE_IS_DELETED,
            TRUSTEE_IS_INVALID,
            TRUSTEE_IS_COMPUTER
        }

        internal struct TRUSTEE
        {
            public IntPtr pMultipleTrustee;
            public MULTIPLE_TRUSTEE_OPERATION MultipleTrusteeOperation;
            public TRUSTEE_FORM TrusteeForm;
            public TRUSTEE_TYPE TrusteeType;
            public IntPtr ptstrName;
        }

        [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
        internal static extern uint GetNamedSecurityInfo(string pObjectName, SE_OBJECT_TYPE ObjectType,
            SECURITY_INFORMATION SecurityInfo, out IntPtr pSidOwner, out IntPtr pSidGroup,
            out IntPtr pDacl, out IntPtr pSacl, out IntPtr pSecurityDescriptor);

        internal enum SE_OBJECT_TYPE
        {
            SE_UNKNOWN_OBJECT_TYPE = 0,
            SE_FILE_OBJECT,
            SE_SERVICE,
            SE_PRINTER,
            SE_REGISTRY_KEY,
            SE_LMSHARE,
            SE_KERNEL_OBJECT,
            SE_WINDOW_OBJECT,
            SE_DS_OBJECT,
            SE_DS_OBJECT_ALL,
            SE_PROVIDER_DEFINED_OBJECT,
            SE_WMIGUID_OBJECT,
            SE_REGISTRY_WOW64_32KEY
        }

        [Flags]
        internal enum SECURITY_INFORMATION : uint
        {
            OWNER_SECURITY_INFORMATION              = 0x00000001,
            GROUP_SECURITY_INFORMATION              = 0x00000002,
            DACL_SECURITY_INFORMATION               = 0x00000004,
            SACL_SECURITY_INFORMATION               = 0x00000008,
            UNPROTECTED_SACL_SECURITY_INFORMATION   = 0x10000000,
            UNPROTECTED_DACL_SECURITY_INFORMATION   = 0x20000000,
            PROTECTED_SACL_SECURITY_INFORMATION     = 0x40000000,
            PROTECTED_DACL_SECURITY_INFORMATION     = 0x80000000
        }

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool GetFileSecurity(string lpFileName, [MarshalAs(UnmanagedType.I4)] SECURITY_INFORMATION RequestedInformation,
            IntPtr pSecurityDescriptor, [MarshalAs(UnmanagedType.I4)] uint nLength, [MarshalAs(UnmanagedType.I4)] out uint lpnLengthNeeded);

        public static bool GetAccessGranted(string fileName, string sidString, uint accessMask)
        {
            // first map generic permissions to object-specific permissions
            GENERIC_MAPPING genericFileMapping = new GENERIC_MAPPING();
            genericFileMapping.GenericRead = AccessRights.FILE_GENERIC_READ;
            genericFileMapping.GenericWrite = AccessRights.FILE_GENERIC_WRITE;
            genericFileMapping.GenericExecute = AccessRights.FILE_GENERIC_EXECUTE;
            genericFileMapping.GenericAll = AccessRights.FILE_ALL_ACCESS;
            MapGenericMask(ref accessMask, ref genericFileMapping);

            // pDacl is a pointer to the DACL inside the SECURITY_DESCRIPTOR referenced by pSD, and hence should not be freed
            IntPtr pSidOwner, pSidGroup, pDacl, pSacl, pSD;
            uint error = GetNamedSecurityInfo(fileName, SE_OBJECT_TYPE.SE_FILE_OBJECT, SECURITY_INFORMATION.DACL_SECURITY_INFORMATION,
                out pSidOwner, out pSidGroup, out pDacl, out pSacl, out pSD);
            if (ERROR_SUCCESS == error)
            {
                try
                {
                    System.Security.Principal.SecurityIdentifier sid = new System.Security.Principal.SecurityIdentifier(sidString);
                    byte[] binarySid = new byte[sid.BinaryLength];
                    sid.GetBinaryForm(binarySid, 0);
                    if (!IsValidSid(binarySid))
                    {
                        return false;
                    }

                    TRUSTEE trustee = new TRUSTEE();
                    BuildTrusteeWithSid(out trustee, binarySid);

                    uint accessRights;
                    error = GetEffectiveRightsFromAcl(pDacl, ref trustee, out accessRights);
                    if (ERROR_SUCCESS == error)
                    {
                        return ((accessMask & accessRights) == accessMask);
                    }
                    // From developerWorks article: "When any local user (i.e. not a domain user) calls GetEffectiveRightsFromAcl()
                    // and passes it the ACL of an unprivileged local user, the file ACLs include those for groups which contain
                    // domain groups, and at a domain level the Network access: Allow anonymous SID/Name translation setting is
                    // disabled (default setting) the function will return ERROR_ACCESS_DENIED."
                    // From MSDN: "The GetEffectiveRightsFromAcl function fails and returns ERROR_INVALID_ACL if the specified ACL
                    // contains an inherited access-denied ACE."
                    else
                    {
                        throw new System.ComponentModel.Win32Exception((int)error);
                    }
                }
                finally
                {
                    // this actually calls LocalFree(), which is the documented way to free the SECURITY_DESCRIPTOR pointer returned
                    // by GetNamedSecurityInfo().
                    Marshal.FreeHGlobal(pSD);
                }
            }
            else
            {
                throw new System.ComponentModel.Win32Exception((int)error);
            }
        }
    }
"@
    return (Add-Type -TypeDefinition $typeDefinition -PassThru)[0]::GetAccessGranted($file, $sid, $accessMask)
}
