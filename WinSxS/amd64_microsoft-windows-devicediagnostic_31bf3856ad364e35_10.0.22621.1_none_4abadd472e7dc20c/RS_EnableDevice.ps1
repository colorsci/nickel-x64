# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_EnableDevice set the device to enable
	ARGUMENTS:
	  $DeviceName : String contains display name of device
	  $DeviceID	 : String contains device PNP ID
	  $ErrorCode : String containing the error code of device

	RETURNS:
#>
PARAM($DeviceName, $DeviceID, $ErrorCode)
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
Write-DiagProgress -activity $localizationString.Resolution_EnableDevice
try
{
	$IsEnabled = EnableDevice $DeviceID $True $True

	$TargetObject = Get-WmiObject -Class "Win32_PNPEntity" | Where-Object -FilterScript {$_.PNPDeviceID -eq $DeviceID}

	if(($IsEnabled -eq $False) -or (($TargetObject -ne $Null) -and ($TargetObject.ConfigManagerErrorCode -eq $ErrorCode)))
	{
		EnableDevice $DeviceID $True $False
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_EnableDevice" $ErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_EnableDevice" -Name "RS_EnableDevice" -Verbosity Debug
}

