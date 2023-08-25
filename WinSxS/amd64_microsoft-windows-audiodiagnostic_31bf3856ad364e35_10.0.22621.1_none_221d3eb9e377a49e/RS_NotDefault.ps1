# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  RS_NotDefault sets the given audio device to default.

	ARGUMENTS:
	  $deviceID: ID of the audio device which needs to be set default.

	RETURNS:
	  None
	
	FUNCTIONS:
	  Get-DefaultEndpoint
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceID)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1
#==================================================================================
# Functions
#==================================================================================
Function Get-DefaultEndpoints()
{
	<#
        .DESCRIPTION
           Function to get path of default Audio endpoints 
        .PARAMETER 
			None
        .OUTPUTS
            Array of registry path of audio endpoints
    #>
    $endpointKeys = @()

    # Checking the registry paths for Audio Render and Capture...
    $registryPathRender = "HKLM:\Software\Microsoft\Windows\Currentversion\MMDevices\Audio\Render\" 
    $registryPathCapture = "HKLM:\Software\Microsoft\Windows\Currentversion\MMDevices\Audio\Capture\" 

    $registryPaths = @($registryPathRender,$registryPathCapture)
    $regRoleKeys = @("Role:0","Role:1","Role:2","Level:0","Level:1","Level:2")

    foreach($regPath in $registryPaths)
    {
        $allSubKeys = Get-ChildItem $regPath
        foreach($subkey in $allSubKeys)
        {
            $keyName = $subkey.name
            $keyName =  "Registry::$keyName"
            foreach($roleKey in $regRoleKeys)
            {
                $resultKey = Get-ItemProperty -Path $keyName -Name $roleKey -ErrorAction SilentlyContinue
                if($resultKey)
                {
                    if(!($endpointKeys -Contains $keyName))
                    {
                        $endpointKeys += $keyName
                    }               
                }
            }
        }
    }
    return $endpointKeys
}

Function Set-RegPermisssion([string]$regPath)
{
	<#
        .DESCRIPTION
           Function to set audio endpoint path registry permission to change 
        .PARAMETER 
			String containing registry path of audio endpoint
        .OUTPUTS
            None
    #>
    $definition = @"
    using System;
    using System.Runtime.InteropServices;
    public class AdjPriv
    {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
        [DllImport("advapi32.dll", SetLastError = true)]
        internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct TokPriv1Luid
        {
            public int Count;
            public long Luid;
            public int Attr;
        }
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

        public static bool EnablePrivilege(long processHandle, string privilege)
        {
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            if (!OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok))
            {
                return false;
            }
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            if (!LookupPrivilegeValue(null, privilege, ref tp.Luid))
            {
                return false;
            }
            if (!AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero))
            {
                return false;
            }
            return true;
        }
    }
"@ 

    $ProcessHandle = (Get-Process -id $pid).Handle
	$type = Add-Type $definition -PassThru
	try
	{
		# Enable SeTakeOwnershipPrivilege
		$type[0]::EnablePrivilege($processHandle, 'SeTakeOwnershipPrivilege')

		$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($regPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
		$acl = $key.GetAccessControl()
		$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")

		$key.SetAccessControl($acl)

		$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($regPath,[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)

    
		$acl = $key.GetAccessControl()
		$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("BUILTIN\Administrators","FullControl","Allow")
		$acl.SetAccessRule($rule)
		$key.SetAccessControl($acl)
	}
	catch [System.Exception]
	{
	    Write-ExceptionTelemetry "Set-RegPermission" $_
	}

}
 
Function Remove-RegKey([string]$path)
{
	<#
        .DESCRIPTION
           Function to remove role key of default Audio endpoints 
        .PARAMETER 
			String containing registry path of Audio endpoints
        .OUTPUTS
            None
    #>
    $regRoleKeys = @("Role:0","Role:1","Role:2","Level:0","Level:1","Level:2")
    foreach($roleKey in $regRoleKeys)
    {
        Remove-ItemProperty -Path $path -Name $roleKey -ErrorAction SilentlyContinue
    }
    
}

#====================================================================================
# Main
#====================================================================================

Write-DiagProgress -activity $localizationString.setAsDefault_progress

$endpointPaths = @()
$endpointPaths = Get-DefaultEndpoints 
if($endpointPaths)
{
	foreach($path in $endpointPaths)
	{
		[int]$intTemp1 = $path.length - 29
		$regPath = $path.Substring(29,$intTemp1)
		Set-RegPermisssion($regPath)
		Remove-RegKey($path)
	}
}
 
Set-DefaultEndpoint $deviceID
Write-DiagProgress -activity " "