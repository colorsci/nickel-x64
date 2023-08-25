# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RC_DriverNotFound checks whether driver is found or not

	ARGUMENTS:
	  $DeviceID : String containing device pnp id
	  $Action : String containing whether script run in verification flow

	RETURNS:
	  Bool value True if driver is not found else False 
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

Write-DiagProgress -activity $localizationString.Troubleshoot_DriverNotFound
try
{

	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}

	if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
	{
		[string]$DeviceName = $ProblemDevice.Name
		[string]$ErrorCode = $ProblemDevice.ConfigManagerErrorCode
		[bool]$NoDriver = $False

		if ([String]::IsNullOrEmpty($DeviceName))
		{
			$DeviceName = $localizationString.UnknownDevice
		}

		if($HashDriverNotFound.Contains($ErrorCode) -eq $True)
		{
			$NoDriver = $True
		}
		elseif ($ErrorCode -eq "0")
		{
			$NoDriver = DriverNotFound $DeviceID
		}

		$DeviceDetails = Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}
		[string]$DriverInfName = $DeviceDetails.InfName
		[string]$DriverDate = $DeviceDetails.DriverDate
		[string]$DriverVersion = $DeviceDetails.DriverVersion

		if([String]::IsNullOrEmpty($DriverInfName))
		{
		   $DriverInfName = $localizationString.UnknownDevice
		}
		if([String]::IsNullOrEmpty($DriverDate))
		{
		   $DriverDate = $localizationString.UnknownDevice
		}
    
		if([String]::IsNullOrEmpty($DriverVersion))
		{
		   $DriverVersion = $localizationString.UnknownDevice
		}

		[string]$DeviceIDInstance = $DeviceID + "/" + $DriverInfName + "/" + $DriverVersion + "/" + $DriverDate
		if ($NoDriver -eq $True)
		{
			$RootCauseAdded = $True
		}
	}

	Update-DiagRootCause -id RC_DriverNotFound -iid $DeviceIDInstance -Detected $RootCauseAdded -p @{'DeviceName'= $DeviceName; 'DeviceID'= $DeviceID; 'ErrorCode'= $ErrorCode}

	if($RootCauseAdded)
	{
		 $ProblemDevice | Select-Object -Property @{Name=$localizationString.DeviceName; Expression={$_.Name}}, @{Name=$localizationString.PnPDeviceID; Expression={$_.PNPDeviceID}}, @{Name=$localizationString.ConfigManagerErrorCode; Expression={$_.ConfigManagerErrorCode}} | ConvertTo-XML | Update-DiagReport -ID DriverProblem -Name $localizationString.Report_Name_ProblemDevice -Verbosity Informational -rid RC_DriverNotFound -riid $DeviceIDInstance
	}

}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_DriverNotFound" $ErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_DriverNotFound" -Name "RC_DriverNotFound" -Verbosity Debug
}

return $RootCauseAdded