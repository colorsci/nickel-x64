# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

$HDaudio = $true
$flagDefault = $true
$flagLowVolume  = $true
$flagMute = $true
$flagSamplingRate = $true
$flagAPOLoadFailure = $true
$flagServiceResponse = $true
$IsRenderFlow = $false
$postBackPath = $null
$endPointtype = "Capture"

$devices = @()
$EndPointList = @()

# Set env path to fetch the AudioDiagnosticUtil.DLL
$env:Path = $env:Path + ";$env:windir\diagnostics\system\Audio\"
#====================================================================================
# Load Common Library
#====================================================================================
. .\CL_RunDiagnosticScript.ps1
. .\CL_Utility.ps1

#====================================================================================
# Functions
#====================================================================================
if(Test-PostBack -CurrentScriptName 'Diag_Audio')
{
   $postBackFlag =  $true
}

function GetId($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object DeviceId).DeviceId
}

function GetAdapterName($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object AdapterName).AdapterName
}

function Get-DeviceName([string]$deviceID = $(throw "No device ID is specified"), [string]$deviceType = $(throw "No device type is specified") )
{
	[String]$deviceName = [String]::Empty
	try 
	{
		$devices = @()
		$AudioMethods = Get-AudioEndpoints
        $EndPointList = @()
        $EndPointList = $AudioMethods::GetAudioEndPointsbyType($deviceType)
        $devices += $EndPointList.ForEach({[PSCustomObject]$_})
		
		foreach($dev in $devices)
		{
			$id = GetId $dev
			$name = GetAdapterName $dev

			if([String]$id -eq $deviceID)
			{
				$deviceName = $name
				break
			}
		}

	} 
	Catch [System.Exception]
	{
		Write-ExceptionTelemetry "Get-DeviceName" $_
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "MF_AudioDiagnostic" -Name "MF_AudioDiagnostic" -Verbosity Debug
	}
	return $deviceName
}

function GetDes($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object DeviceDes).DeviceDes
}

function GetJackInfo($deviceInfo=$("No device info is specified"))
{
	return ($deviceInfo | Select-Object JackInfo).JackInfo
}

function GetDeviceType()
{
	[string]$type = Get-DiagInput -id "IT_GetDeviceType"

	$type | Select-Object @{Name=$localizationString.deviceType;Expression={$_}} | ConvertTo-Xml | Update-DiagReport -id AudioDevice -name $localizationString.AudioDevice_name -description $localizationString.AudioDevice_Description -Verbosity Informational
	return $type
}

function ConvertTo-JackLoc([int]$index = $(throw "No index is specified"))
{
	$result = $localizationString.jackLocInfo  + " "
	switch ($index) {
		1 {$result += $localizationString.rear; break}
		2 {$result += $localizationString.front; break}
		3 {$result += $localizationString.left; break}
		4 {$result += $localizationString.right; break}
		5 {$result += $localizationString.top; break}
		6 {$result += $localizationString.bottom; break}
		7 {$result += $localizationString.rearslide; break}
		8 {$result += $localizationString.risercard; break}
		9 {$result += $localizationString.insidelid; break}
		10 {$result += $localizationString.drivebay; break}
		11 {$result += $localizationString.HDMIconnector; break}
		12 {$result += $localizationString.Outsidelid; break}
		13 {$result += $localizationString.ATAPIconnector; break}
		default {$result = $localizationString.noJackInfoAvailable; break}
	}

	return $result
}

function GetDeviceId([string]$deviceFlow)
{
	[string]$id = $null
	[int]$count = 0
	[string]$defaultFlag = "<Default />"
	$choices = New-Object System.Collections.ArrayList
	try 
	{
		[Array]$device = $null
		$AudioMethods = Get-AudioEndpoints
        $EndPointListID = $AudioMethods::GetAudioEndPointsbyType($deviceFlow)
        $device += $EndPointListID.ForEach({[PSCustomObject]$_})

		$count = $device.Length
		if($count -eq 1)
		{
			$id = GetId $device
		}
		elseif ($count -gt 1)
		{
			foreach($item in $device)
			{
				$deviceDes = GetDes $item
				$deviceId = GetId $item
				$jackInfo = GetJackInfo $item
				$adapterName = GetAdapterName $item
				$jackloc = ConvertTo-JackLoc $jackInfo
				$name = "$deviceDes - $adapterName`r`n`r`n$jackloc.`r`n"
				if($item.IsDefault -eq $true)
				{
					$CurrentDefaultDevice = $localizationString.Current_Default_Device
                    $name = "$deviceDes - $adapterName $CurrentDefaultDevice`r`n`r`n$jackloc.`r`n"
                    [int]$currentIndex = $device.IndexOf($item)
                    $choices += @{"Name"="$name"; "Description"="$name"; "Value"="$deviceId"; "ExtensionPoint"=""}
				}
				else
				{
					$name = "$deviceDes - $adapterName`r`n`r`n$jackloc.`r`n"
				    $choices += @{"Name"="$name"; "Description"="$name"; "Value"="$deviceId"; "ExtensionPoint"=""}
				}
				
			}

			if($currentIndex -eq $null)
			{
				$currentIndex = 0
			}
			($choices[$currentIndex]).ExtensionPoint = $defaultFlag

			$id = Get-DiagInput -id "IT_GetCertainDevice" -Choice $choices
		}
	}
	Catch [System.Exception]
	{
		Write-ExceptionTelemetry "GetDeviceID" $_
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "MF_AudioDiagnostic" -Name "MF_AudioDiagnostic" -Verbosity Debug
	} 
	return $id
}

function CheckRemoteSession {
<#
	DESCRIPTION
	  CheckRemoteSession check whether current package is running on remote session.

	ARGUMENTS:
	  None 

	RETURNS:
	  $result : Boolean value $true if package running on remote session is disabled or $false 
#>
	[string]$sourceCode = @"
using System;
using System.Runtime.InteropServices;

namespace Microsoft.Windows.Diagnosis {
	public static class RemoteManager {
		private const int SM_REMOTESESSION = 0x1000;

		[DllImport("User32.dll", CharSet = CharSet.Unicode)]
		private static extern int GetSystemMetrics(int Index);

		public static bool Remote() {
			return (0 != GetSystemMetrics(SM_REMOTESESSION));
		}
	}
}
"@
	$type = Add-Type -TypeDefinition $sourceCode -PassThru

	return $type::Remote()
}

function ispostbackOnWin($packName)
{
<#
	DESCRIPTION
	  ispostbackOnWin check whether package is postback.

	ARGUMENTS:
	  packName : String value containing ID of pack 

	RETURNS:
	  $result : Boolean value $true if package running in postback or $false 
#>
	[string] $path1 = (Get-Location -PSProvider FileSystem).ProviderPath
	[string] $path1 = join-path  $path1  "\$packName"
	if(test-path $path1){
		return $true
	}
	"once" > $path1 
	return $false
}

function setpostbackOnWin($packName)
{
<#
	DESCRIPTION
	  setpostbackOnWin check whether package is postback.

	ARGUMENTS:
	  packName : String value containing ID of pack 

	RETURNS:
	  $path1 : String containing the path of postback file
#>
	[string] $path1 = (Get-Location -PSProvider FileSystem).ProviderPath
	[string] $path1 = join-path  $path1  "\$packName"
	
	"once" > $path1 
	return $path1
} 
function isLastRCExecuted($rcName)
{
<#
	DESCRIPTION
	  isLastRCExecuted check whether last root cause executed.

	ARGUMENTS:
	  packName : String value containing package name 

	RETURNS:
	  $result : Boolean value $true if root cause executed or $false 
#>
	[string] $path = (Get-Location -PSProvider FileSystem).ProviderPath
	[string] $path = join-path  $path  "\$rcName"
	if(test-path $path){
		return $true
	}
	return $false
}

function setLastRCExecuted($rcName)
{
	<#
	DESCRIPTION
	  setpostbackOnWin set that last root cause executed.

	ARGUMENTS:
	  packName : String value containing ID of pack 

	RETURNS:
	  $path : String containing the path of postback file
	#>
	[string] $path = (Get-Location -PSProvider FileSystem).ProviderPath
	[string] $path = join-path  $path  "\$rcName"
	"once" > $path 
	return $path
}

#====================================================================================
# Main
#====================================================================================

if(CheckRemoteSession) {
	Get-DiagInput -ID "IT_RunOnRemoteSession"
	return
}

[string]$regLogName = "Registry log.txt"
(Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices' -Recurse) | Out-File $regLogName
if((Test-Path $regLogName)) {
	Update-DiagReport -file $regLogName -id InstalledAudioDevice -name $localizationString.installedAudioDevice_name -description $localizationString.installedAudioDevice_description -Verbosity Informational
}

if(isLastRCExecuted "HDAudioExecuted")
{
 	return
}


if((RunDiagnosticScript {& .\TS_AudioDeviceDriver.ps1}) -eq $false)
{
	$path = setpostbackOnWin "AudioDiagnostic"
	return
}

if((RunDiagnosticScript {& .\TS_AudioService.ps1}) -eq $false)
{
    $path = setpostbackOnWin "AudioDiagnostic"
    return
}

[int]$rcDetect = . .\TS_AudioServiceResponse.ps1

if($rcDetect -eq 1)
{
	$flagServiceResponse = $false
}


Write-DiagProgress -activity " "
# Get audio device type
[string]$audioDeviceType = GetDeviceType

if ($audioDeviceType -ieq "Render")
{
	$IsRenderFlow = $true
}

if(!$postBackFlag)
{
 # Get audio device ID
 [string]$audioDeviceID = GetDeviceId $audioDeviceType
}

# Get audio device name
[string]$audioDeviceName = Get-DeviceName $audioDeviceID $audioDeviceType


if([String]::IsNullOrEmpty($audioDeviceID))
{
	return
}


RunDiagnosticScript {& .\TS_DisabledInCPL.ps1 $audioDeviceType $audioDeviceID}

if((RunDiagnosticScript {& .\TS_UnpluggedIn.ps1 $audioDeviceType $audioDeviceID}) -eq $false)
{
	$path = setpostbackOnWin "AudioDiagnostic"
    return
}

if((RunDiagnosticScript {& .\TS_Mute.ps1 $audioDeviceType $audioDeviceID}) -eq $true)
{
	 $flagMute = $false
}
if((RunDiagnosticScript {& .\TS_NotDefault.ps1 $audioDeviceType $audioDeviceID}) -eq $true)
{
	$flagDefault = $false
}


if($IsRenderFlow)
{

	if((RunDiagnosticScript {& .\TS_LowVolume.ps1 $audioDeviceType $audioDeviceID}) -eq $true)
	{

		$flagLowVolume = $false
	}
}

if((RunDiagnosticScript {& .\TS_SamplingRate.ps1 $audioDeviceID}) -eq $true)
{
	$flagSamplingRate = $false
}
if((RunDiagnosticScript {& .\TS_APOLoadFailure.ps1 $null $audioDeviceName $audioDeviceType}) -eq $true)
{
	$flagAPOLoadFailure = $false
}

if(ispostbackOnWin "AudioDiagnostic")
{
 	return
}
elseif($IsRenderFlow)
{
	# Record data for Enhancements
	$Response = Get-DiagInput -Id "IT_AudioProperties"
	
	if ($Response -eq "1")
	{
		StartProcess $audioDeviceID
		Write-DiagTelemetry -Property "OpenEnhancements" -Value "Yes"
	}else
		{
		Write-DiagTelemetry -Property "OpenEnhancements" -Value "No"
		}
	if($flagServiceResponse -and $flagMute -and $flagDefault -and $flagLowVolume -and $flagSamplingRate -and $flagAPOLoadFailure)
	{
		if(-not([String]::IsNullOrEmpty($audioDeviceName)))
		{
			RunDiagnosticScript {& .\TS_HDAudioDriver.ps1 $audioDeviceName $audioDeviceID $audioDeviceType}
			$postBackPath = setLastRCExecuted "HDAudioExecuted"
		}
	}
}
