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

Write-DiagProgress -Activity $Strings_Main.ID_Check_MSVideo_Driver

$drivers = gwmi win32_VideoController |select DeviceID,Name,DriverVersion
$isRootCauseDetected = $false
foreach($driver in $drivers)
{
	if((($driver.Name) -ilike "*Microsoft Basic Display*"))
	{
		$isRootCauseDetected = $true
		break
	}
}
if($isRootCauseDetected -eq $false)
{
	update-diagrootcause -id "RC_MSFTBasicVideoDriver" -detected $false
}
else
{
	update-diagrootcause -id "RC_MSFTBasicVideoDriver" -detected $true -Parameter @{"DName"= $driver.Name; "DVersion"=$driver.DriverVersion}
}



