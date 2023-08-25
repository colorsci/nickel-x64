# Copyright © 2017, Microsoft Corporation. All rights reserved.


#CL_DetectingDevice
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

. .\DB_DeviceErrorLibrary.ps1
. .\CL_Utility.ps1

function DetectingDeviceFromPnPEntity()
{
    $HashProblemDeviceTable = New-Object System.Collections.HashTable
    if($HashProblemDeviceTable -eq $Null)
    {
        return $False
    }

    $PnPObjects = Get-WmiObject -Class Win32_PnPEntity

    foreach($DeviceItem in $PnPObjects)
    {
        [string]$DeviceName = $DeviceItem.Name
        [string]$DeviceID = $DeviceItem.PNPDeviceID
        [string]$DeviceErrorCode = $DeviceItem.ConfigManagerErrorCode

        if(($DeviceName -eq $Null) -or ($DeviceID -eq $Null) -or ($DeviceErrorCode -eq $Null))
        {
            continue
        }

        if($DeviceID -eq "")
        {
            continue
        }
        # Checking Error Code 45 for not connected device for Windows 10
        if(($DeviceErrorCode -ne "0") -and ($DeviceErrorCode -ne "45"))
        {
            if($HashProblemDeviceTable.Contains($DeviceID) -eq $False)
            {
                $HashProblemDeviceTable.Add($DeviceID, $DeviceID)
            }
        }
    }

    return $HashProblemDeviceTable
}

Function Get-ErrorCodeStringMapping($deviceID)
{
	$deviceDetails = @()
	$ProblemDevice = $null
 try
	{
	   $ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $deviceID}
		if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
		{
			[string]$DeviceName = $ProblemDevice.Name
			[string]$ErrorCode = $ProblemDevice.ConfigManagerErrorCode

			# Check Disabled
			if($HashDisabled.Contains($ErrorCode) -eq $True)
			{
				$devDescription = $localizationString.DeviceDisable
				$devDescription = $devDescription -replace ("%DEVICENAME%",$DeviceName)
				$devValue = "$deviceID#$ErrorCode"
				$deviceDetails += @{"Name" = $devDescription; "Value" = $devValue}
			}
			# Check if driver not found
			elseif(($HashDriverNotFound.Contains($ErrorCode) -eq $True) -or ((DriverNotFound $DeviceID) -eq $true)) 
			{
				$devDescription = $localizationString.DriverNotFound
				$devDescription = $devDescription -replace ("%DEVICENAME%",$DeviceName)
				$devValue = "$deviceID#$ErrorCode"
				$deviceDetails += @{"Name" = $devDescription; "Value" = $devValue}
			}
			# Check if driver has problem
			elseif(($HashUpdateDriver.Contains($ErrorCode) -eq $True)) 
			{
				$devDescription = $localizationString.UpdateDriver
				$devDescription = $devDescription -replace ("%DEVICENAME%",$DeviceName)
				$devValue = "$deviceID#$ErrorCode"
				$deviceDetails += @{"Name" = $devDescription; "Value" = $devValue}
			}
			# $HashDeviceErrors is related to RC_NotWorkingproperly.
			elseif(($HashDeviceErrors.Contains($ErrorCode) -eq $True)) 
			{
				$devDescription = $localizationString.DeviceError
				$devDescription = $devDescription -replace ("%DEVICENAME%",$DeviceName)
				$devValue = "$deviceID#$ErrorCode"
				$deviceDetails += @{"Name" = $devDescription; "Value" = $devValue}
			}
			# $HashInformCx is related to RC_InformCX
			elseif(($HashInformCx.Contains($ErrorCode) -eq $True)) 
			{
				$devDescription = $localizationString.DeviceError
				$devDescription = $devDescription -replace ("%DEVICENAME%",$DeviceName)
				$devValue = "$deviceID#$ErrorCode"
				$deviceDetails += @{"Name" = $devDescription; "Value" = $devValue}
			}

		}
		return $deviceDetails
	}
	Catch [System.Exception]
	{
		Write-ExceptionTelemetry "Get-ErrorCodeStringMapping" $ErrorCode $_
		$errorMsg =  $_.Exception.Message
		$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "CL_DetectingDevice" -Name "CL_DetectingDevice" -Verbosity Debug
	} 
	
}

Function Get-HiddenDevices()
{
    <#
    DESCRIPTION:
      List all hidden devices(only for Windows10(build 10586 onwards))
	ARGUMENTS:
	  None
	RETURN:
	  Returns list of hidden devices with friendly names
    #>
	$allHiddenDevice = @()
    $allHiddenDeviceList = @()
    $hiddendeviceChoices = @()
	$hiddenDevList = Get-PnpDevice | Get-PnpDeviceProperty -KeyName 'DEVPKEY_Device_IsPresent' | ?{$_.Data -eq $false}
	if($hiddenDevList.Count -ge 1)
	{
		foreach($hiddenid in $hiddenDevList.InstanceID)
		{
		  $allHiddenDevice += Get-PnpDevice | Where-Object -FilterScript {$_.InstanceId -eq $hiddenid}
		}
		foreach($hiddendev in $allHiddenDevice.InstanceID)
		{
		  $HiddenDevice = Get-PnpDevice | Where-Object -FilterScript {$_.InstanceId -eq $hiddendev}
		  $allHiddenDeviceList += $HiddenDevice.FriendlyName 
		}
		# Remove duplicate hidden devices 
		$allHiddenDeviceList = $allHiddenDeviceList | Select -Unique
		# Creating final list of hidden devices
		foreach($choice in $allHiddenDeviceList)
		{
		  $devDescription = $localizationString.HiddenDevice
		  $devDescription = $devDescription -replace ("%DEVICENAME%",$choice)
		  $hiddendeviceChoices +=  @{"Name" = $devDescription; "Value" = $choice; "Description" = ""; "ExtensionPoint" = ""}
		}
    }
	return $hiddendeviceChoices
}