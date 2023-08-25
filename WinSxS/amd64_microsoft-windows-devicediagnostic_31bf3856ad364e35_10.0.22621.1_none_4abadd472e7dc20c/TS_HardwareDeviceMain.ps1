# Copyright © 2017, Microsoft Corporation. All rights reserved.
#====================================================================================
# Loading Utilities
#================================================================================
. .\CL_DetectingDevice.ps1
. .\CL_Utility.ps1
#================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
$DriverProblem = $false
$PNPDeviceArray = $Null
$HashProblemDeviceTable = $Null
$allDeviceList = @()
$deviceList = @()


if(Test-PostBack -CurrentScriptName 'Diag_Devices')
{
   $postBackFlag =  $true
}
# Checking for Pending System Reboot. 
#================================================================================
$IsRebootneeded = .\TS_PendingRestart.ps1 

# Collecting Device IDs passed by Audio Troubleshooter
[String]$SelectResult = "None"

try
{
    $SelectResult = Get-DiagInput -id "IT_SelectDevice" -ErrorAction SilentlyContinue
}
catch
{
    $SelectResult = "None"
}

if ($SelectResult -eq "ScanOnly") {
    .\TS_RescanAllDevices.ps1
    return
}

if($SelectResult -ne "None")
{
    $PNPDeviceArray = $SelectResult.Split("#")
    $HashProblemDeviceTable = New-Object System.Collections.HashTable

    foreach ($DeviceID in $PNPDeviceArray)
    {
        if (-not [String]::IsNullOrEmpty($DeviceID)) {
            $HashProblemDeviceTable.Add($DeviceID, $DeviceID)
        }
    }
}
else
{
    $HashProblemDeviceTable = DetectingDeviceFromPnPEntity
}

try
{
	# Get user selected device.
	if($HashProblemDeviceTable.Count -ge 1)
	{
		foreach($deviceIDs in $HashProblemDeviceTable.Values)
		{
			if(Check-UnknownDevice $deviceIDs)
			{
				$unKnownDevices += $deviceIDs
				if ($HashProblemDeviceTable.Count -ne 1){ Continue }
			}
		
			$deviceList = Get-ErrorCodeStringMapping $deviceIDs
			if($deviceList.Count -ge 1)
			{
				$allDeviceList += @{"Name" = $deviceList.Name; "Value" = $deviceList.Value; "Description" = ""; "ExtensionPoint" = ""}
			}
			if($unKnownDevices.Count -ge 1)
			{
				foreach($dev in $unKnownDevices)
				{
					$devIDUnknown = $localizationString.UnknownDevice + "#" + $dev
				}
				$deviceName = $localizationString.UnknownDevice
				$devDescription = $localizationString.UnknownDevice
				$devDescription = $devDescription -replace ("%DEVICENAME%",$deviceName)
				$allDeviceList += @{"Name" = $devDescription; "Value" = $devIDUnknown; "Description" = ""; "ExtensionPoint" = ""}
			}
		}
		if($deviceList.Count -ge 1)
		{
			# Add default if device doesn't get listed
			$allDeviceList += @{"Name" = $localizationString.DeviceNotListed; "Value" = $localizationString.DeviceNotListedValue; "Description" = ""; "ExtensionPoint" = ""}
		}
		if(!$postBackFlag)
		{
			$selectedDeviceID = Get-DiagInput -Id "INT_SelectDevices" -Choice $allDeviceList
			$selectedDeviceID = [string]$selectedDeviceID
			$deviceStr = $selectedDeviceID.Split('#')
			$DeviceID = $deviceStr[1]
			if(!($DeviceID -eq $localizationString.DeviceNotListedValue))
			{
			   $IsDisabled = .\TS_DeviceDisabled.ps1 $DeviceID
				if(!$IsDisabled)
				{
				   $IsDriverNotFound = .\TS_DriverNotFound.ps1 $DeviceID
					if(!$IsDriverNotFound)
					 {
						$IsDriverNeedUpdated = .\TS_DeviceDriverNeedsUpdate.ps1 $DeviceID
						 if(!$IsDriverNeedUpdated)
						 {
							$IsNotWorkProperly = .\TS_NotWorkingProperly.ps1 $DeviceID
						 }
						  if(!$IsNotWorkProperly)
						  {
							   $informCX = .\TS_InformCustomer.ps1 $DeviceID
						  }
					 }
				}
			}
			else
			{  
				Get-DiagInput -Id INT_ProblemWithDifferentDevice
			}
		      
		}
		# Capture Errorcode via telemetry 
		$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}

		if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
		{
			Write-DiagTelemetry -Property "DeviceErrorCode" -Value $ProblemDevice.ConfigManagerErrorCode
		}
	}
}
Catch [System.Exception]
	{
		Write-ExceptionTelemetry "TS_Main" $Null $_
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "TS_Main" -Name "TS_Main" -Verbosity Debug
	} 


if (($SelectResult -eq "None") -or ($IsDriverNotFound -eq $true) -or ($IsDriverNeedUpdated -eq $true))
{
    .\TS_CheckDriversOnInstall.ps1
}

if($SelectResult -eq "None")
{
     .\TS_RescanAllDevices.ps1
}
