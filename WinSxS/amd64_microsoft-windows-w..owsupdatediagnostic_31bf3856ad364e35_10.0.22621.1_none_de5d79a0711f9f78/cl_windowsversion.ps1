# Copyright © 2016, Microsoft Corporation. All rights reserved.
#*================================================================================
# Load Utilities
#*================================================================================
. ./CL_SetupEnv.ps1

#*================================================================================
$registryRW = import-cs `
	-classname Microsoft.Windows.Diagnosis.RegistryReadingAndWriting `
	-sourcefile RegistryReadingAndWriting.cs `
	-sourcetext @"
using System;
using Microsoft.Win32; 

namespace Microsoft.Windows.Diagnosis
{
    public static class RegistryReadingAndWriting
    {

        public static bool setRegistryValue(string hiveKey, string hkPath, string keyName, string value2Set, RegistryValueKind rgValKind)
        {
            if (hiveKey == null) return false;
            if (hiveKey.Length < 3) return false;
            if (hkPath == null) return false;
            if (hkPath.Length < 3) return false;
            RegistryKey parentKey = null;
            if (hiveKey.ToLower() == "hku")
            {
                parentKey = Registry.Users.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hklm")
            {
                parentKey = Registry.LocalMachine.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkcr")
            {
                parentKey = Registry.ClassesRoot.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkcc")
            {
                parentKey = Registry.CurrentConfig.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkpd")
            {
                parentKey = Registry.PerformanceData.OpenSubKey(hkPath, true);
            }
            if (parentKey == null)
            {
                return false;
            }
            try
            {
                parentKey.SetValue(keyName, value2Set, rgValKind);
            }
            catch (Exception e)
            {
                throw e;
            }
            return true;
        }

        public static string getRegistryValue(string hiveKey, string hkPath, string keyName)
        {
            if (hiveKey == null) return ("Hive cannot be null");
            if (hiveKey.Length < 3) return "Hive length cannot be less than 3";
            if (hkPath == null) return ("Path cannot be null");
            if (hkPath.Length < 3) return "Path length cannot be less than 3";
            RegistryKey parentKey = null;
            if (hiveKey.ToLower() == "hku")
            {
                parentKey = Registry.Users.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hklm")
            {
                parentKey = Registry.LocalMachine.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkcr")
            {
                parentKey = Registry.ClassesRoot.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkcc")
            {
                parentKey = Registry.CurrentConfig.OpenSubKey(hkPath, true);
            }
            if (hiveKey.ToLower() == "hkpd")
            {
                parentKey = Registry.PerformanceData.OpenSubKey(hkPath, true);
            }
            if (parentKey == null)
            {
                return (hiveKey + " hive not found");
            }
            try
            {
                string s1 = parentKey.GetValue(keyName).ToString();
                return s1;
            }
            catch (NullReferenceException nullexp)
            {
                return nullexp.Message;
            }
        }
    }
}
"@

#*================================================================================
#Check-WindowsVersion
#*================================================================================	
function Check-WindowsVersion()
{
	# check the Windows version
	
	$OS = Get-WmiObject -Namespace root\CIMV2 -Class Win32_OperatingSystem
	$temp = $OS.Version.Split(".")
    $OSVersion = ($temp[0] + "." + $temp[1])
	if($OS)
	{
		if( ([int]::Parse($OS.version[0]) -eq 6) ){
			return ( [int]::Parse($OS.version[0])*10 + [int]::Parse($OS.version[2])  ) # greater than windows vista
		}elseif(([int]::Parse($OS.version[0]) -eq 6) -and ([int]::Parse($OS.version[2]) -eq 1)){
			return 61 # windows 7
		}elseif(([int]::Parse($OS.version[0]) -eq 6) -and ([int]::Parse($OS.version[2]) -eq 0)){
	
			return 60 # windows vista
		}elseif(([int]::Parse($OS.version[0]) -eq 5) -and ([int]::Parse($OS.version[2]) -eq 1)){
			return 51 # win xp 32 bit
		}elseif(([int]::Parse($OS.version[0]) -eq 5) -and ([int]::Parse($OS.version[2]) -eq 2)){
			return 52 # win xp 64 bit
		}elseif([Float]$OSVersion -gt [Float](6.2)){
			 return 100 # Windows 10
		}
        else{
            return 13 # below win xp
        }
	}
}

#*================================================================================
#Get-AppDataExpectedString
#*================================================================================
function Get-AppDataExpectedString()
{	
	$correctValue = '%USERPROFILE%\AppData\Roaming'
	$currWinVersion = Check-WindowsVersion
	if( ($currwinversion -eq 51) -or ($currwinversion -eq 52) ) # for win xp 32 bit and 64 bit
	{ 
		$correctValue = '%USERPROFILE%\Application Data'
	}
	return $correctValue
}

$expectedString = Get-AppDataExpectedString
$h = ".DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\";
$HKEY_USERS = "hku"
$expRegString = [Microsoft.Win32.RegistryValueKind]::ExpandString

#*================================================================================
#Get-RegistryValue
#*================================================================================
function Get-RegistryValue($hkey,$hpath,$keyName)
{
	return ($registryRW::getRegistryValue($hkey,$hpath,$keyName))
}

#*================================================================================
#Set-RegistryValue
#*================================================================================
function Set-RegistryValue($hkey,$hpath,$keyName,$value2Set,$regStringType)
{
	return ($registryRW::setRegistryValue($hkey,$hpath,$keyName,$value2Set,$regStringType))
}

#*================================================================================
#Get-RegistrySubValues
#*================================================================================
function Get-RegistrySubValues($key,$hpath) 
{   
	 (Get-Item ($key+"\"+$hpath)).GetValueNames()
}

#*================================================================================
#Get-RegistryValues
#*================================================================================
function Get-RegistryValues($key,$hpath)
{    
    $keys = (Get-Item $key).GetValueNames()
    $val=@{}
    foreach($k in $keys)
	{
        $val.add($k, (Get-RegistryValue $key $hpath $k))
    }
    return $val
}
