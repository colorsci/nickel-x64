# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  RC_CheckDriversOnInstall checks for a registry key and if it is not present then the root cause will be detected

	ARGUMENTS:
	  

	RETURNS:
	  Updates the Diag report 
#>
#==================================================================================
# Loading Utilities
#==================================================================================
. .\CL_Utility.ps1
#==================================================================================
# Initialize
#==================================================================================
$wuBlocked = $false

#*=================================================================================
# Main
#*=================================================================================
try
{
	$gpSetting = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -ErrorAction SilentlyContinue
	if(($gpSetting -eq $null) -or ($gpSetting.DriverUpdateWizardWUSearchEnabled -eq 0)) 
	{
		$wuBlocked = $true
	}
	$setting = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -ErrorAction SilentlyContinue
	if(($setting -eq $null) -or ($setting.SearchOrderConfig -eq 0)) 
	{
		$wuBlocked = $true
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RC_CheckDriversOnInstall" $null $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RC_CheckDriversOnInstall" -Name "RC_CheckDriversOnInstall" -Verbosity Debug
}

Update-DiagRootCause -ID RC_CheckDriversOnInstall -Detected $wuBlocked

return $wuBlocked

