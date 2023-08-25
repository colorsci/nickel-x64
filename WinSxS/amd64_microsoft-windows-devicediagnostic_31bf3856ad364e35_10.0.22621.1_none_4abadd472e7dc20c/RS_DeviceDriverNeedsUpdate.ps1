# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_InstallDrivers resolves the problem related to drivers
	ARGUMENTS:
	  
	RETURNS:
#>
#================================================================================
PARAM($DeviceName, $DeviceID)
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.Resolution_UpdateDriver
try
{
	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}
	if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
	{
		[string]$DeviceName = $ProblemDevice.Name
		[string]$ErrorCode = $ProblemDevice.ConfigManagerErrorCode
		[string]$ClassGuid = $ProblemDevice.ClassGuid
		if(($ErrorCode -eq "19") -or ($ErrorCode -eq "31") -or ($ErrorCode -eq "10"))
		{
		  # Check if UpperFilter or LowerFilter present for the error codes.
		  # Corrupt UpperFilter or LowerFilter could be a possible reason for the error codes.
		  $RegPath = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\'
		  $FullPath = $RegPath + $ClassGuid
		  $checkregPath = Get-ItemProperty -Path $FullPath
		  if(($checkregPath.UpperFilters) -or ($checkregPath.LowerFilters))
		  {
			Remove-ItemProperty -Path $FullPath -Name "UpperFilters" -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $FullPath -Name "LowerFilters" -ErrorAction SilentlyContinue
			RemoveDevice $DeviceID
			ReinstallDevice $DeviceID
			RescanAllDevices
		  }
		  else
		  {
			# UpperFilter or LowerFilter not present. Just remove,re-install and scan.
			RemoveDevice $DeviceID
			ReinstallDevice $DeviceID
			RescanAllDevices
		  }
		}
		elseif($ErrorCode -eq "39")
		  {
			RemoveDevice $DeviceID
			ReinstallDevice $DeviceID
			RescanAllDevices
		  }
		else
		{
		  ReinstallDevice $DeviceID
		}
		
		if($ProblemDevice.Manufacture -eq $null)
		{
			$OEM = $localizationString.OEM
		} else {$OEM = $ProblemDevice.Manufacture }

		Get-DiagInput -ID INT_OpenWUUpdate -Parameter @{'OEM'=$OEM}	
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_DeviceDriverNeedUpdated" $ErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_DeviceDriverNeedUpdated" -Name "RS_DeviceDriverNeedUpdated" -Verbosity Debug
}
