# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  TS_APOLoadFailure checks for issues related to audio device caused by 3rd party enhancement issues.

	ARGUMENTS:
	  action: Intended for verification purpose only (verifier will supply "Verify").
	  defaultDevice: Name of default audio device.

	RETURNS:
	  <&true> if root cause detected otherwise <$false>
#>
Param($action, $defaultDeviceName, $defaultDeviceType)
#====================================================================================
# Initialize
#====================================================================================

$isRootCauseDetected = $false
#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_AudioDiagnosticSnapIn.ps1
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================

# Checking the registry paths for Audio Render and Capture...
$registryPathRender = "HKLM:\Software\Microsoft\Windows\Currentversion\MMDevices\Audio\Render\" 
$registryPathCapture = "HKLM:\Software\Microsoft\Windows\Currentversion\MMDevices\Audio\Capture\" 

# Getting the value of 3rd party enhancement from the registry path.
$APO8 = "{b3f8fa53-0004-438e-9003-51a46e139bfc},8"
$APO9 = "{b3f8fa53-0004-438e-9003-51a46e139bfc},9"

# Getting the Value of Registry to get the Audio Name.
$APO6 = "{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
$APO2 = "{b3f8fa53-0004-438e-9003-51a46e139bfc},2"

if($action -eq "Verify")
{
	$deviceID = Get-DeviceId $defaultDeviceName $defaultDeviceType
	if(!([String]::IsNullOrEmpty($deviceID)))
	{
		Set-DefaultEndpoint $deviceID
	}

	(New-Object Media.SoundPlayer "$env:SystemDrive\Windows\Media\notify.wav").Play();
}

# Will hold all devices separated by semicolon(;)
[String]$allDevices = [String]::Empty

# Listing the child item property of the registry paths.
$allRenderKey = Get-ChildItem $registryPathRender
foreach($renderkey in $allRenderKey)
{
	$apoRenderKey = $renderkey.Name 
	$apoRenderKey = "Registry::$apoRenderKey\Properties"
	$resultRenderAPO8 = Get-ItemProperty -Path $apoRenderKey -Name $APO8 -ErrorAction SilentlyContinue 
	$resultRenderAPO9 = Get-ItemProperty -Path $apoRenderKey -Name $APO9 -ErrorAction SilentlyContinue 
	
	if($resultRenderAPO8 -or $resultRenderAPO9)
	{
		$resultRenderAPO6 = Get-ItemProperty -Path $apoRenderKey -Name $APO6
		$deviceName = $resultRenderAPO6.$APO6
		
		$resultRenderAPO2 = Get-ItemProperty -Path $apoRenderKey -Name $APO2
		$regDeviceID = $resultRenderAPO2.$APO2

		$device = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.Name -eq $deviceName}
		$deviceIDs = $device.DeviceID

		if($deviceIDs.Count -ge 1)
		{
			foreach($deviceID in $deviceIDs)
			{
				if($regDeviceID.Contains($deviceID))
				{
					if(($deviceID -ne $null) -and (!($allDevices.Contains($deviceID))))
					{
						$allDevices += "|$deviceID"
						$isRootCauseDetected = $true
					}
				}
			}		
		}
	}
}

$allCaptureKey = Get-ChildItem $registryPathCapture
foreach($capturekey in $allCaptureKey)
{
	$apoCaptureKey = $capturekey.Name 
	$apoCaptureKey = "Registry::$apoCaptureKey\Properties"
	$resultCaptureAPO8 = Get-ItemProperty -Path $apoCaptureKey -Name $APO8 -ErrorAction SilentlyContinue 
	$resultCaptureAPO9 = Get-ItemProperty -Path $apoCaptureKey -Name $APO9 -ErrorAction SilentlyContinue 
	
	if($resultCaptureAPO8 -or $resultCaptureAPO9)
	{
		$resultCaptureAPO6 = Get-ItemProperty -Path $apoCaptureKey -Name $APO6
		$deviceName = $resultCaptureAPO6.$APO6
		$resultCaptureAPO2 = Get-ItemProperty -Path $apoCaptureKey -Name $APO2
		$regDeviceID = $resultCaptureAPO2.$APO2

		$device = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.Name -eq $deviceName}
		$deviceIDs = $device.DeviceID 
		
		if($deviceIDs.Count -ge 1)
		{
			foreach($deviceID in $deviceIDs)
			{
				if($regDeviceID.Contains($deviceID))
				{
					if(($deviceID -ne $null) -and (!($allDevices.Contains($deviceID))))
					{
						$allDevices += "|$deviceID"
						$isRootCauseDetected = $true
					}
				}
			}		
		}
	}
}

if($isRootCauseDetected -and (!([String]::IsNullOrEmpty($allDevices))))
{
	if ($allDevices.StartsWith('|'))
	{
		# Removing Extra Pipe delimiter
		$allDevices = $allDevices.Substring(1)
	}
	$deviceCount = Get-AudioDeviceCount
	Update-DiagRootCause -ID "RC_APOLoadFailure" -Detected $isRootCauseDetected -Parameter @{"deviceIDs" = $allDevices; "deviceCount" = $deviceCount; "defaultDeviceName" = $defaultDeviceName; "defaultDeviceType" = $defaultDeviceType} -ErrorAction SilentlyContinue 
}
else
{
	Update-DiagRootCause -ID "RC_APOLoadFailure" -Detected $isRootCauseDetected
}

return $isRootCauseDetected