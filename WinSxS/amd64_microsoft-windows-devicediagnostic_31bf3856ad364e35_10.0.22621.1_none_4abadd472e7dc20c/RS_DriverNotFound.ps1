# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_DriverNotFound gets driver details and display interaction to download and install
	ARGUMENTS:
	  $DeviceName : String contains display name of device
	  $DeviceID	 : String contains device PNP ID

	RETURNS:
#>
PARAM($DeviceName, $DeviceID)
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.Resolution_DriverNotFound
try
{
	#
	#Get HardwareID for current problematic device
	#
	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}
	if(($ProblemDevice -eq $Null) -or ($ProblemDevice.HardwareID.Count -eq $Null) -or ($ProblemDevice.HardwareID.Count -eq 0))
	{
		return
	}
	$ProblemHardwareID = $ProblemDevice.HardwareID

	$TargetEvent = $Null
	$DriverNotFoundEvents = GetEvent "application" "Windows Error Reporting" 1001
	foreach($Event in $DriverNotFoundEvents)
	{
		[string]$DeviceIDFromEvent = $Event.Properties[6].Value
		if([String]::IsNullOrEmpty($DeviceIDFromEvent) -eq $False)
		{
			foreach($ID in $ProblemHardwareID)
			{
				if([String]::Compare($DeviceIDFromEvent, $ID, $True) -eq 0)
				{
					$TargetEvent = $Event
					break
				}
			}
			if($TargetEvent -ne $Null)
			{
				break
			}
		}
	}

	if($TargetEvent -ne $Null)
	{
		[string]$Platform = $TargetEvent.Properties[5].Value
		[string]$DeviceID = $TargetEvent.Properties[6].Value

		$QueryResult = QueryWERResponse $Platform $DeviceID

		if($QueryResult -ne $NULL)
		{
			if([String]::IsNullOrEmpty($QueryResult.responseUrl) -eq $True)
			{
				return
			}

			if([String]::IsNullOrEmpty($QueryResult.reportStoreLocation) -eq $True)
			{
				return
			}

			if($QueryResult.isResponseApplicable -eq $False)
			{
				return
			}

			Get-DiagInput -id IT_OpenPRSSolution -param @{'DeviceName'=$DeviceName; 'ReportLocation'=$QueryResult.reportStoreLocation; 'ReportType'=$QueryResult.reportStoreType}
		}
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_DriverNotFound" $ProblemDevice.ConfigManagerErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_DriverNotFound" -Name "RS_DriverNotFound" -Verbosity Debug
}