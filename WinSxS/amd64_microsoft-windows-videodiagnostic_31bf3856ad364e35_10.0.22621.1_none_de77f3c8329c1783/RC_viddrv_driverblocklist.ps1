# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
# Parameters
#*=================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
# Run detection logic
#*=================================================================================

Write-DiagProgress -Activity $Strings_Main.ID_Check_Driver_Blocklist

$drivers = gwmi win32_VideoController |select DeviceID,Name,DriverVersion
$isRootCauseDetected = $false

$ToMatch = @( '22.20.16.4811', '22.20.16.4815', '22.20.16.4836' )

foreach($driver in $drivers)
{
	if((($driver.Name) -ilike "*Intel*") -and ( $ToMatch.Contains($drivers.DriverVersion)))
	{
		$isRootCauseDetected = $true
		break
	}
}

if($isRootCauseDetected -eq $false)
{
	update-diagrootcause -id "RC_DriverBlocklist" -detected $false
}
else
{
	update-diagrootcause -id "RC_DriverBlocklist" -detected $true -Parameter @{"DName"= $driver.Name; "DVersion"=$driver.DriverVersion}
}



