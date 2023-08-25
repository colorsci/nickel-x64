# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
Param ($problemDeviceID,$problemDeviceName)
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RS_DriverProblem -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RS_DriverProblem.ID_RS_PROG_DriverProblems

try
{
	Remove-Device($problemDeviceID)
	Reinstall-Device($problemDeviceID)
	Rescan-Devices
	Get-DiagInput -ID 'INT_UpdateDriver' -Parameter @{'ProblemDeviceName'=$problemDeviceName}
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
	$_ | ConvertTo-Xml | Update-DiagReport -ID 'RS_DriverProblem' -Name 'RS_DriverProblem' -Verbosity Debug
}