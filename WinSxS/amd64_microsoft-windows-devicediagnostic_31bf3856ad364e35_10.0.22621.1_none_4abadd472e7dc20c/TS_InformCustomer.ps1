# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RC_InformCustomer checks for specific error codes 

	ARGUMENTS:
	  
	RETURNS:
	  Bool value True if specific error codes found else False 
#>
PARAM($DeviceID)
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
#================================================================================
# Checking for various error codes. 
#================================================================================
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

		if($HashInformCx.Contains($ErrorCode) -eq $True)
		{
			$RootCauseAdded = $True
		}
	}

	Update-DiagRootCause -id RC_InformCustomer -iid $DeviceIDInstance -Detected $RootCauseAdded -p @{'DeviceName'= $DeviceName; 'DeviceID'= $DeviceID; 'ErrorCode' = $ErrorCode}

	 if($RootCauseAdded)
	 {
		    Write-DiagTelemetry -Property "RC_InformCustomer" -Value $ErrorCode
			$ProblemDevice | Select-Object -Property @{Name=$localizationString.DeviceName; Expression={$_.Name}}, @{Name=$localizationString.PnPDeviceID; Expression={$_.PNPDeviceID}}, @{Name=$localizationString.ConfigManagerErrorCode; Expression={$_.ConfigManagerErrorCode}} | ConvertTo-XML | Update-DiagReport -ID RC_InformCustomer -Name $localizationString.Report_Name_ProblemDevice -Verbosity Informational -rid RC_InformCustomer -riid $DeviceIDInstance
	 }
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_InformCustomer" $ErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_InformCustomer" -Name "RC_InformCustomer" -Verbosity Debug
}
return $RootCauseAdded

