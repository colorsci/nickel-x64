# Copyright � 2008, Microsoft Corporation. All rights reserved.


#TS_ProgramCompatibilityWizard
#rparsons - 05 May 2008

$ShortcutListing = New-Object System.Collections.Hashtable
$ExeListing = New-Object System.Collections.ArrayList
$CombinedListing = New-Object System.Collections.ArrayList

Import-LocalizedData -BindingVariable CompatibilityStrings -FileName CL_LocalizationData

# Block PCW on unsupported SKUs
$BlockedSKUs = @(178)
[Int32]$OSSKU = (Get-WmiObject -Class "Win32_OperatingSystem").OperatingSystemSKU
if ($BlockedSKUs.Contains($OSSKU))
{
    return
}

$typeDefinition = @"

using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections;

public class Utility
{
    public static string GetStartMenuPath()
    {
        return Environment.GetFolderPath(Environment.SpecialFolder.StartMenu);
    }

    public static string GetAllUsersStartMenuPath()
    {
        return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "Microsoft\\Windows\\Start Menu");
    }

    public static string GetDesktopPath()
    {
        return Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
    }

    [DllImport("sfc.dll", SetLastError=true, EntryPoint="SfcIsFileProtected", CharSet=CharSet.Unicode)]
    [return : MarshalAs(UnmanagedType.Bool)]
    public static extern bool SfcIsFileProtected(IntPtr RpcHandle, String ProtFileName);

    public static bool IsFileProtected(String FileName)
    {
        return SfcIsFileProtected(IntPtr.Zero, FileName);
    }

    [DllImport("pcwutl.dll", EntryPoint = "GetAppInformationFromCloud", CharSet = CharSet.Unicode)]
    [return: MarshalAs(UnmanagedType.U4)]
    public static extern uint GetAppInformationFromCloud(String PathToFile, StringBuilder URL, out uint CompatStatus, StringBuilder RecommendedLayer, out bool Apphelp);

    public static ArrayList GetAppInfoFromCOS(String PathToFile)
    {
        const int MAX_PATH = 260;
        const int MAX_URL = 2048;
        const String KnownVersions = "WIN8RTM WIN7RTM VISTASP2 WINXPSP3";
        const String KnownLayers = "256COLOR 16BITCOLOR 640X480 HIGHDPIAWARE MSIAUTO RUNASADMIN";

        StringBuilder URL = new StringBuilder(MAX_URL);
        StringBuilder RecommendedLayer = new StringBuilder(MAX_PATH);
        uint CompatStatus = 0;
        uint ConvertedCompatStatus = 0;
        uint ReturnValue = 0;
        bool Apphelp = false;
        String FilteredLayers = "";

        ReturnValue = GetAppInformationFromCloud(PathToFile, URL, out CompatStatus, RecommendedLayer, out Apphelp);

        ArrayList AppInfo = new ArrayList();

        //
        // There is a difference between the return value and what we want to use internally
        // Semantic Meaning                                   | COS Response   | Used Value
        // ---------------------------------------------------------------------------------
        // Failed to get file info (Program ID, File ID, etc) | N/A            | 1
        // Failed when calling COS                            | N/A            | 2
        // Free Update                                        | 30             | 3
        // Paid Update (apphelp)                              | 40 and Apphelp | 4
        // Paid Update (no apphelp)                           | 40 no Apphelp  | 5
        // Unknown solution                                   | 50             | 6
        // Compatible                                         | 10             | 7
        // KB Article available                               | 15             | 8
        // No info available from COS                         | 0              | 9
        //

        switch (CompatStatus)
        {

            case 0:

                if (ReturnValue == 58)
                {

                    //
                    // ERROR_BAD_NET_RESP
                    //

                    ConvertedCompatStatus = 2;
                }
                else if (ReturnValue == 13)
                {

                    //
                    // ERROR_INVALID_DATA
                    //

                    ConvertedCompatStatus = 1;
                }
                else
                {

                    ConvertedCompatStatus = 9;
                }
                break;

            case 10:
                ConvertedCompatStatus = 7;
                break;

            case 15:
                ConvertedCompatStatus = 8;
                break;

            case 30:
                ConvertedCompatStatus = 3;
                break;

            case 40:
                if (Apphelp == true)
                {
                    ConvertedCompatStatus = 4;
                }
                else
                {
                    ConvertedCompatStatus = 5;
                }
                break;

            case 50:
            default:
                ConvertedCompatStatus = 6;
                break;
        }

        //
        // Filter out all but the oldest version layer
        // Filter out anything not in either list
        //

        int VersionIndex = -1;
        String VersionLayer = "";
        foreach (String s in (RecommendedLayer.ToString()).Split(' '))
        {
            if (KnownVersions.IndexOf(s) > VersionIndex)
            {
                VersionIndex = KnownVersions.IndexOf(s);
                VersionLayer = s;
            }
            else
            {
                if (KnownLayers.IndexOf(s) != -1)
                {
                    FilteredLayers += s;
                    FilteredLayers += " ";
                }
            }
        }

        if (VersionIndex != -1)
        {
            FilteredLayers += VersionLayer;
        }

        FilteredLayers = FilteredLayers.TrimEnd(null);

        if (FilteredLayers.Length == 0)
        {
            FilteredLayers = "NONE";
        }

        AppInfo.Add(ConvertedCompatStatus);
        AppInfo.Add(URL.ToString());
        AppInfo.Add(FilteredLayers);

        return AppInfo;
    }

    [DllImport("pcwutl.dll", EntryPoint = "LogPCWDebugEvent", CharSet = CharSet.Unicode)]
    public static extern void LogPCWDebugEvent(string DebugString, Int64 qwDebugValue);


    public static void LogDebugEvent(String Message, Int64 DebugValue)
    {
        LogPCWDebugEvent(Message, DebugValue);
    }
}
"@

$typeDefinition2 = @"

using System;
using System.Collections;
using System.Diagnostics;
using System.IO;

public class ProgramSorter : IComparer
{
    int IComparer.Compare(Object x, Object y)
    {
        string friendlyNameX = GetFriendlyName(x.ToString());
        string friendlyNameY = GetFriendlyName(y.ToString());

        return friendlyNameX.CompareTo(friendlyNameY);
    }

    public string GetFriendlyName(string path)
    {
        if (path.EndsWith(".lnk"))
        {
            return Path.GetFileNameWithoutExtension(path);
        }

        FileVersionInfo versionInfo = FileVersionInfo.GetVersionInfo(path);
        string friendlyName = null;

        if(versionInfo != null)
        {
            if(versionInfo.FileDescription != null)
            {
                friendlyName = versionInfo.FileDescription.Trim();
            }
        }

        if((friendlyName == null) || (friendlyName == String.Empty))
        {
            friendlyName = Path.GetFileNameWithoutExtension(path);
        }

        return friendlyName;
    }
}
"@

$typeDefinition3 = @"

using System;
using System.Runtime.InteropServices;
using System.Text;

public class ExeFromLnk
{
    const int MAX_PATH = 260;

    [DllImport("acppage.dll", EntryPoint="GetExeFromLnk", CharSet=CharSet.Unicode)]
    [return : MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetExeFromLnk(String pszLnk, StringBuilder pszExe, int cchSize);

    public static String GetTargetExePath(String LinkPath)
    {
        StringBuilder exePath = new StringBuilder(MAX_PATH);
        if (GetExeFromLnk(LinkPath, exePath, exePath.Capacity))
        {
            return exePath.ToString().Replace("$", "`$");
        }

        return String.Empty;
    }

    public static String EscapePath(String Path)
    {
        return Path.Replace("$", "`$");
    }
}
"@

$type = Add-Type -TypeDefinition $typeDefinition -PassThru -IgnoreWarnings
$type3 = Add-Type -TypeDefinition $typeDefinition3 -PassThru  -IgnoreWarnings

# Function to convert to WQL path
function ConvertTo-WQLPath([string]$wqlPath = $(throw "No path is specified"))
{
    if($wqlPath -eq $null)
    {
        return $false
    }

    return $wqlPath.Replace("\", "\\")
}

# Function to retrieve all of the shortcuts from the provided directory
function Get-ShortcutList([string]$path = $(throw $CompatibilityStrings.Throw_NO_PATH))
{
    Get-ChildItem -Path $path -recurse -filter *.lnk | Foreach-Object {
        $fullPath = ConvertTo-WQLPath($_.FullName)

        $exePath = $type3::GetTargetExePath($fullPath)

        if(($exePath -ne $null) -and -not([String]::IsNullOrEmpty($exePath)) -and ([System.IO.Path]::GetExtension($exePath) -eq ".exe"))
        {
            if(Test-Path -literalpath $exePath)
            {
                if(-not($type::IsFileProtected($exePath)))
                {
                    if(-not($ShortcutListing.ContainsKey($fullPath)) -and -not($ShortcutListing.ContainsValue($exePath)))
                    {
                        [System.Collections.Hashtable]$ShortcutListing.Add($fullPath, $exePath)
                    }
                }
            }
        }
    }
}

# Function to retrieve all the executables from the provided directory
function Get-ExeList([string]$path = $(throw $CompatibilityStrings.Throw_NO_PATH))
{
    Get-ChildItem -Path $path -recurse -filter *.exe | Foreach-Object {
        $exePath = $_.FullName.Replace("$", "`$")

        if(Test-Path -literalpath $exePath)
        {
            if(-not($type::IsFileProtected($exePath)))
            {
                if(-not($ExeListing.Contains($exePath)) -and -not($ShortcutListing.ContainsValue($exePath)))
                {
                    $ExeListing.Add($exePath)
                }
            }
        }
    }
}

# Function to determine whether the selected program is valid
function Test-Selection([string]$appPath)
{
    $testresult = $false

    if(($appPath -ne $null) -and -not([String]::IsNullOrEmpty($appPath)))
    {
        $testresult = test-path -literalpath $appPath

        if($testresult)
        {
            if(-not($type::IsFileProtected($appPath)))
            {
                $extension = [System.IO.Path]::GetExtension($appPath)
                $testresult = ($extension -eq ".exe") -or ($extension -eq ".msi")
            }
            else
            {
                $testresult = $false
                Set-Variable -name rebrowseText -value $CompatibilityStrings.Text_FILE_PROTECTED -scope global
            }
        }
    }

    Set-Variable -name appValid -value $testResult -scope global
}

function WriteTrace([string]$text)
{   
    $now = Get-Date
    $type::LogDebugEvent($text, $now.Second)
}

# This block of code determines how the troubleshooter was invoked.  If it was invoked
# through the control panel, we have to get an exe name to work with.  If context menu
# we already have it.

$LaunchMethod = "ControlPanel"

try {
    $LaunchMethod = Get-DiagInput -id IT_LaunchMethod -errorAction silentlyContinue
}
# MSDT_E_NO_ANSWER_NOUI
catch {
    $LaunchMethod = "ControlPanel"
}

# This block of code will build the list of applications that are in the start menu,
# public start menu, and the desktop.  It is looking for only shortcuts, actual binaries
# in these locations will not be examined.

[string]$startMenuPath = $type::GetStartMenuPath()
[string]$allUsersStartMenuPath = $type::GetAllUsersStartMenuPath()
[string]$desktopPath = $type::GetDesktopPath()

$choices = New-Object System.Collections.ArrayList
set-variable ChoicesAvailable $false -scope global

#Add a 'Not Listed' entry
$notListedChoice = @{}
$notListedChoice.Add("Name", $CompatibilityStrings.Program_Choice_NOTLISTED)
$notListedChoice.Add("Description", $CompatibilityStrings.Program_Choice_NOTLISTED)
$notListedChoice.Add("Value", "NotListed")

$choices += $notListedChoice

if($LaunchMethod -eq "ControlPanel")
{ 
    Write-DiagProgress -activity $CompatibilityStrings.Text_Status_SEARCHING -status " "

    Get-ShortcutList($startMenuPath)
    Get-ShortcutList($allUsersStartMenuPath)
    Get-ShortcutList($desktopPath)
    Get-ExeList($desktopPath)

    #Combine the entries into one list for sorting
    foreach($pathKey in $ShortcutListing.keys)
    {
        $CombinedListing.Add($pathKey)
    }

    foreach($exePath in $ExeListing)
    {
        $CombinedListing.Add($exePath)
    }

    #Sort the combined list
    Add-Type -TypeDefinition $typeDefinition2 -IgnoreWarnings
    $programSorter = New-Object ProgramSorter
    $CombinedListing.Sort($programSorter)

    #Add choices for each entry in the combined list
    foreach($path in $CombinedListing)
    {
        Set-Variable -name ChoicesAvailable -value $true -scope global
        $friendlyName = $programSorter.GetFriendlyName($path)
        $fullPathToTarget = $path

        if ($path.EndsWith(".lnk"))
        {
            $fullPathToTarget = $ShortcutListing[$path]
        }

        $choice = @{}
        $choice.Add("Name", $friendlyName)
        $choice.Add("Description", $fullPathToTarget)
        $choice.Add("Value", $fullPathToTarget)

        $choices += $choice
    }
}

# If no shortcuts were found in these locations, we will go to the browse for file screen.
if(-not($ChoicesAvailable))
{
    $selectedProgram = Get-DiagInput -id IT_BrowseForFile
}
else
{
    $selectedProgram = Get-DiagInput -id IT_SelectProgram -choice $choices

	# If the user chose the option "Not listed" we will ask them to browse for a file
    if($selectedProgram -eq "NotListed")
    {
        $selectedProgram = Get-DiagInput -id IT_BrowseForFile
    }

}

# This block tests the validity of the path provided (either through selection or browsing to a file
# Test-Selection manipulates the global variables rebrowseText (a reason you have to choose a file)
# and appValid (the file is an exe that is valid to troubleshoot)
Set-Variable -name rebrowseText -value $CompatibilityStrings.Text_FILE_INVALID -scope global
Set-Variable -name appValid -value $false -scope global
Test-Selection($selectedProgram)

$InstanceId = 0

while(-not($appValid))
{
    $InstanceId++
    $selection = $selectedProgram
    $selectedProgram = Get-DiagInput -id IT_RebrowseForFile -parameter @{ "SelectedProgram" = $selection; "RebrowseText" = $rebrowseText; "Instance" = $InstanceId }
    Set-Variable -name rebrowseText -value $CompatibilityStrings.Text_FILE_INVALID -scope global
    Test-Selection($selectedProgram)
}

$appName = [System.IO.Path]::GetFileNameWithoutExtension($selectedProgram).Replace("$", "`$")

#Go back through the choices to find the display name for the selected application.
foreach ($choice in $choices)
{
    if($choice["Value"] -eq $selectedProgram)
    {
        $appName = $choice["Name"].Replace("$", "`$")
        break
    }
}

#Find out what information COS has about the application, and display an early out if 
#COS has update information about the application

#Info comes back as an ArrayList object, with three things in it:
#  1. number representing what we recommend to be done
#  2. string that is a URL if there is a URL associated with the solution.
#  3. string that is the recommended layer to apply (if one exists).

$AppInfo = $type::GetAppInfoFromCOS($selectedProgram)
$COSInfoPage = ""
switch($AppInfo[0])
{
    3 { $COSInfoPage = "IT_Free_Update" }
    4 { $COSInfoPage = "IT_Paid_Update_SB" }
    5 { $COSInfoPage = "IT_Paid_Update_SB" }
    8 { $COSInfoPage = "IT_KB_Available" }
}

$Env:COSURL = $AppInfo[1]

if ($COSInfoPage -ne "" )
{
    $UpdateChoice = Get-DiagInput -id $COSInfoPage    
}
else
{
    $UpdateChoice = "ts_Manual"
}

#This last call will invoke the RS_ script, see the other file. It does the manual troubleshooting portion of the app.
if ($UpdateChoice -eq "ts_Manual")
{
    $Env:RecommendedLayer = $AppInfo[2]
    Update-DiagRootCause -id "RC_IncompatibleApplication" -iid $appName -Detected $true -parameter @{ "TARGETPATH" = $selectedProgram; "APPNAME" = $appName}
}
else
{
    Start-Process -FilePath $AppInfo[1]
}


