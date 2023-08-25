# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RC_DeviceDisabled checks device is in disabled state

	ARGUMENTS:
	  $DeviceID : String containing device pnp id
	  $Action : String containing whether script run in verification flow

	RETURNS:
	  Bool value True if device is disabled else False 
#>
PARAM($DeviceID, $Action)
#==================================================================================
# Loading Utilities
#================================================================================
. .\DB_DeviceErrorLibrary.ps1
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
$RootCauseAdded = $false

#*=================================================================================
# Main
#*=================================================================================
Write-DiagProgress -activity $localizationString.Troubleshoot_DeviceDisabled
try
{
	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}

	if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
	{
		[string]$DeviceName = $ProblemDevice.Name
		[string]$ErrorCode = $ProblemDevice.ConfigManagerErrorCode

		if ([String]::IsNullOrEmpty($DeviceName))
		{
			$DeviceName = $localizationString.UnknownDevice
		}

		if($HashDisabled.Contains($ErrorCode) -eq $True)
		{
			$RootCauseAdded = $true
		}
	}

	 Update-DiagRootCause -id RC_DeviceDisabled -iid $DeviceID -Detected $RootCauseAdded -p @{'DeviceName'= $DeviceName; 'DeviceID'= $DeviceID; 'ErrorCode'= $ErrorCode}
	if ($RootCauseAdded)
	{
		 Write-DiagTelemetry -Property "RC_DeviceDisabled" -Value $ErrorCode
		 $ProblemDevice | Select-Object -Property @{Name=$localizationString.DeviceName; Expression={$_.Name}}, @{Name=$localizationString.PnPDeviceID; Expression={$_.PNPDeviceID}}, @{Name=$localizationString.ConfigManagerErrorCode; Expression={$_.ConfigManagerErrorCode}} | ConvertTo-XML | Update-DiagReport -ID DeviceDisabled -Name $localizationString.Report_Name_ProblemDevice -Verbosity Informational -rid RC_DeviceDisabled -riid $DeviceID
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_DeviceDisabled" $ErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_DeviceDisabled" -Name "RC_DeviceDisabled" -Verbosity Debug
}


return $RootCauseAdded

