# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Common utility functions
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Function to get user troubleshooting history
function Get-UserTSHistoryPath {
    return "${env:localappdata}\diagnostics"
}

# Function to get admin troubleshooting history
function Get-AdminTSHistoryPath {
    return "${env:localappdata}\elevateddiagnostics"
}

# Function to get user report folder path
function Get-UserReportPath {
    return "${env:localappdata}\Microsoft\Windows\WER\ReportQueue"
}

# Function to get system report folder path
function Get-MachineReportPath {
    return "${env:AllUsersProfile}\Microsoft\Windows\WER\ReportQueue"
}

# Function to get threshold to check whether a folder is old
function Get-ThresholdForCheckOlderFile {
    [int]$threshold = -1
    return $threshold
}

# Function to get threshold for deleting WER folder
function Get-ThresholdForFileDeleting() {
    [string]$registryEntryPath = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
    [string]$registryEntryName = "PurgeThreshholdValueInKB"
    [double]$defaultValue = 10.0

    return Get-RegistryValue $registryEntryPath $registryEntryName $defaultValue
}

# Function to get the size of a directory in kb
function Get-FolderSize([string]$folder = $(throw "No folder is specified")) {
    if([String]::IsNullOrEmpty($folder) -or (-not(Test-Path $folder))) {
        return 0
    }

    if(-not $Global:DirectoryObject) {
        $Global:DirectoryObject = New-Object -comobject "Scripting.FileSystemObject"
    }

    return ($Global:DirectoryObject.GetFolder($folder).Size) / 1kb
}

# Function to delete a folder
function Delete-Folder([string]$folder = $(throw "No folder is specified")) {
    if([String]::IsNullOrEmpty($folder) -or (-not(Test-Path $folder))) {
        return
    }

    Remove-Item -literalPath $folder -Recurse -Force
}

# Function to delete old folders
function Delete-OldFolders($folder=$(throw "No folder is specified")) {
    if(($folder -eq $null) -or (-not(Test-Path $folder))) {
        return
    }

    [int]$threshold = Get-ThresholdForCheckOlderFile
    $folders = Get-ChildItem -LiteralPath ($folder.FullName) -Force | Where-Object {$_.PSIsContainer}
    if($folders -ne $null) {
        foreach($folder in $folders) {
            if((($folder.CreationTime).CompareTo((Get-Date).AddMonths($threshold))) -lt 0) {
                Delete-Folder ($folder.FullName)
            } else {
                Delete-OldFolders (Get-Item ($folder.FullName))
            }
        }
    }
}

# Function to get registry value
function Get-RegistryValue([string]$registryEntryPath = $(throw "No registry entry path is specified"), [string]$registryEntryName = $(throw "No registry entry name is specified"), [double]$defaultValue = 0.0) {
    [double]$registryEntryValue = $defaultValue

    $registryEntry = Get-ItemProperty -Path $registryEntryPath -Name $registryEntryName
    if($registryEntry -ne $null) {
        $registryEntryValue = $registryEntry.$registryEntryName
    }

	return $registryEntryValue
}

# Function to get the percentage that WER queue can take up
function Get-Percentage() {
    [string]$registryEntryPath = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
    [string]$registryEntryName = "MaxQueueSizePercentage"
    [double]$defaultValue = 100.0

    return Get-RegistryValue $registryEntryPath $registryEntryName $defaultValue
}

# Function to get free disk space on machine
function Get-FreeSpace {
    [double]$freeSpace = 0.0
    [string]$wql = "SELECT * FROM Win32_LogicalDisk WHERE MediaType=12"
    $drives = Get-WmiObject -query $wql
    if($null -ne $drives) {
        foreach($drive in $drives) {
            $freeSpace += ($drive.freeSpace)
        }
    }

    return ($freeSpace / 1KB)
}

# Function to get all unnecessary files
function Get-UnnecessaryFiles([string]$folder = $(throw "No folder is specified")) {
    if([String]::IsNullOrEmpty($folder) -or (-not(Test-Path $folder))) {
        return $null
    }

    [int]$threshold = Get-ThresholdForCheckOlderFile

    return (Get-ChildItem -literalPath $folder -Recurse -Force | Where-Object {($_.PSIsContainer) -and ((($_.CreationTime).CompareTo((Get-Date).AddMonths($threshold))) -lt 0)})
}

# Function to format disk space (KB -> MB)
function Format-DiskSpaceMB([double]$space = $(throw "No space is specified")) {
    return [string]([Math]::Round(($space / 1KB), 3))
}

# Function to format disk space (B -> GB)
Function Format-DiskSpaceGB([double]$space = $(throw "No space is specified")) {
    return [string]([Math]::Round(($space / 1GB), 3))
}

# Function to attach item to the list with delimiter "/"
function AttachTo-List([string]$list = $(throw "No list is specified"), [string]$item = $(throw "No item is specified"))
{
    if([String]::IsNullOrEmpty($list))
    {
        return $item
    }

    if([String]::IsNullOrEmpty($item))
    {
        return $list
    }

    return $list + "/" + $item
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

# Function to get list length
function Get-ListLength([string]$list = $(throw "No list is specified"))
{
    if($list -eq $null)
    {
        return 0
    }

    $result = Parse-List $list

    if($result -is [string])
    {
        return 1
    }
    elseif($result -is [object[]])
    {
        return $result.count
    }
    else
    {
        return 0
    }
}

# Function to convert to WQL path
function ConvertTo-WQLPath([string]$wqlPath = $(throw "No WQL path is specified"))
{
    if($wqlPath -eq $null)
    {
        return ""
    }

    return $wqlPath.Replace("\", "\\")
}

# Function to check whether the shortcut is valid
function Test-ValidLink([Wmi]$wmiLinkFile = $(throw "No WMI link file is specified"))
{
    if(($wmiLinkFile -eq $null) -or ([String]::IsNullOrEmpty($wmiLinkFile.Target)))
    {
        return $false
    }

    return Test-Path $wmiLinkFile.Target
}

# Function to chech whether have permission to delete the shortcut file
function Test-Delete([Wmi]$wmiLinkFile = $(throw "No WMI link file is specified"))
{
    if($wmiLinkFile -eq $null)
    {
        return $false
    }

    return ($wmiLinkFile.AccessMask -band 0x10000) -eq 0x10000
}

# Function to get desktop path
function Get-DesktopPath()
{
$methodDefinition = @"
    public static string GetDesktopPath
    {
        get
        {
            return Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
        }
    }
"@

    $type = Add-Type -MemberDefinition $methodDefinition -Name "DesktopPath" -PassThru

    return $type::GetDesktopPath
}

# Function to get startup path
function Get-StartupPath()
{
$methodDefinition = @"
    public static string GetStartupPath
    {
        get
        {
            return Environment.GetFolderPath(Environment.SpecialFolder.Startup);
        }
    }
"@

    $type = Add-Type -MemberDefinition $methodDefinition -Name "StartupPath" -PassThru

    return $type::GetStartupPath
}

# Function to remove all files in the list
function Remove-FileList([string]$list = $(throw "No list is specified"))
{
    if([String]::IsNullOrEmpty($list))
    {
        return
    }

    try
    {
        Parse-List $list | Foreach-Object {
            if(-not([String]::IsNullOrEmpty($_)))
            {
                Remove-Item $_ -Force
            }
        }
    }
    catch
    {
        $_ | ConvertTo-Xml | Update-DiagReport -id DeleteFileExceptions -Name $localizationString.filesFailToRemove_name -Description $localizationString.filesFailToRemove_description -Verbosity Warning
    }
}

# Function to get the last access time of an Icon
function Get-LastAccessTime([string]$filePath = $(throw "No file path is specified"))
{
    if([String]::IsNullOrEmpty($filePath) -or -not(Test-Path $filePath))
    {
        throw "No file path found"
    }

$typeDefinition = @"

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using ComType = System.Runtime.InteropServices.ComTypes;

public sealed class FileInfo
{
    private FileInfo()
    {
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct UAINFO
    {
        internal int cbSize;
        internal int dwMask;
        internal float R;
        internal uint cLaunches;
        internal uint cSwitches;
        internal int dwTime;
        internal ComType.FILETIME ftExecute;
        [MarshalAs(UnmanagedType.Bool)] internal bool fExcludeFromMFU;

        internal UAINFO(int dwMask)
        {
            this.cbSize = Marshal.SizeOf(typeof(UAINFO));
            this.dwMask = dwMask;
            this.R = 0;
            this.cLaunches = 0;
            this.cSwitches = 0;
            this.dwTime = 0;
            this.ftExecute = new ComType.FILETIME();
            this.fExcludeFromMFU = false;
        }
    }

    internal const int UAIM_FILETIME = 1;
    internal static Guid UAIID_SHORTCUTS = new Guid("F4E57C4B-2036-45F0-A9AB-443BCFE33D9F");

    [ComImport, Guid("90D75131-43A6-4664-9AF8-DCCEB85A7462"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IShellUserAssist
    {
        int FireEvent(ref Guid pguidGrp, int eCmd, string pszPath, int dwTimeElapsed);
        int QueryEntry(ref Guid pguidGrp, string pszPath, ref UAINFO pui);
        int SetEntry(ref Guid pguidGrp, string pszPath, ref UAINFO pui);
        int RenameEntry(ref Guid pguidGrp, string pszFrom, string pszTo);
        int DeleteEntry(ref Guid pguidGrp, string pszPath);
        int Enable(bool fEnable);
    }

    [ComImport, Guid("DD313E04-FEFF-11d1-8ECD-0000F87A470C")]
    internal class UserAssist { }

    public static DateTime GetLastAccessTime(string filePath)
    {
        if(String.IsNullOrEmpty(filePath))
        {
            throw new ArgumentException("The file path is null or empty");
        }

        UAINFO uaInfo = new UAINFO(UAIM_FILETIME);
        IShellUserAssist iShellUserAssist = new UserAssist() as IShellUserAssist;
        if (iShellUserAssist == null)
        {
            throw new InvalidOperationException("Can't get iShellUserAssist interface");
        }

        try
        {
            Marshal.ThrowExceptionForHR(iShellUserAssist.QueryEntry(ref UAIID_SHORTCUTS, filePath, ref uaInfo));
        }
        catch
        {
            throw new InvalidOperationException("Can't query info about" + filePath);
        }

        long fileTime = (((long)uaInfo.ftExecute.dwHighDateTime) << 32) + uaInfo.ftExecute.dwLowDateTime;

        return DateTime.FromFileTime(fileTime);
    }
}
"@

    $type = Add-Type -TypeDefinition $typeDefinition -PassThru

    return $type[0]::GetLastAccessTime($filePath)
}

# Function to check whether the icon is pointing to a file
function Test-FileShortcut([Wmi]$wmiLinkFile = $(throw "No wmi link file is specified"))
{
    if($wmiLinkFile -eq $null)
    {
        return $false
    }

    [string]$target = $wmiLinkFile.Target
    if([String]::IsNullOrEmpty($target) -or -not(Test-Path $target))
    {
        return $false
    }

    return -not((Get-Item $target).PSIsContainer)
}

# Function to create a choice in interaction page
function Get-Choice([string]$name = $(throw "No choice name is specified"), [string]$description = $(throw "No choice description is specified"),
                   [string]$value = $(throw "No choice value is specified"), [xml]$extension)
{
    return @{"Name"=$name;"Description"=$description;"Value"=$value;"ExtensionPoint"=$extension.InnerXml}
}

# Function to check whether the current machine is domain joined
Function Test-DomainJoined()
{
    return (Get-WmiObject -query "select * from win32_ntdomain where Status ='OK'") -ne $null
}

# Function to update time source
Function Update-TimeSource([string]$timeSource = $(throw "No time source is specified"))
{
    w32tm.exe /config /update /manualpeerlist:"$timeSource"
}

# Function to get system drive info
function Get-SystemDriveInfo() {
    [string]$wql = "SELECT * FROM Win32_LogicalDisk WHERE MediaType=12 AND Name = '" + ${env:systemdrive} + "'"
    return Get-WmiObject -query $wql
}

# Function to get time service status
function Get-ServiceStatus([string]$serviceName=$(throw "No service name is specified")) {
   [bool]$startService = $true

   [WMI]$timeService = @(Get-WmiObject -Query "Select * From Win32_Service Where Name = `"$serviceName`"")[0]
   if($null -ne $timeService) {
      [ServiceProcess.ServiceControllerStatus]$timeServicesStatus = (Get-Service $serviceName).Status
      if(([ServiceProcess.ServiceControllerStatus]::Stopped -eq $timeServicesStatus) -or ([ServiceProcess.ServiceControllerStatus]::StopPending -eq $timeServicesStatus)) {
         $startService = $false
      }
   }

   return $startService
}

# Function to wait for expected service status
function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"), [ServiceProcess.ServiceControllerStatus]$serviceStatus=$(throw "No service status is specified")) {
    [ServiceProcess.ServiceController]$sc = New-Object "ServiceProcess.ServiceController" $serviceName
    [TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,5,0)
    $sc.WaitForStatus($serviceStatus, $timeOut)
}