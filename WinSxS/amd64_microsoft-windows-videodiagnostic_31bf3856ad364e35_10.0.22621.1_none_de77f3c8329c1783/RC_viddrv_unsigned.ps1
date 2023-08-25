# Copyright © 2018, Microsoft Corporation. All rights reserved.
#*=================================================================================
# Parameters
#*=================================================================================
#PARAM ($drivers)

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

Write-DiagProgress -Activity $Strings_Main.ID_Check_Unsigned_Driver

$global:unsignedflag = $false
$iid = "signed"
$debugmode = $false
$drivers = gwmi win32_VideoController |select DeviceID,Name,DriverVersion
foreach($driver in $drivers)
{
	if(($driver.name) -ilike "*Microsoft Basic render*")
	{
		continue
	}
	else
	{
		$out = gwmi Win32_PnPSignedDriver | Where-Object -FilterScript {$_.DeviceName -eq $driver.Name}

		if($out.getType().IsArray)
		{
			$out = $out[0]
		}
		# if driver is unsigned
		if(($out.IsSigned) -eq $false)
		{
			# check for debug mode (intermediate check) before detecting the root cause
			$global:unsignedflag = $true
			$results = bcdedit
			foreach ($result in $results)
			{
				if($result -ilike "*DISABLE_INTEGRITY_CHECKS*")# debug mode check
				{
					$iid = [string]::Format("{0} {1} debug mode unsigned", $driver.Name,$driver.DriverVersion)
					$debugmode = $true
					break
				}	
			}
			if($debugmode -eq $true)
			{
				update-diagrootcause -id "RC_UnsignedVideoDriver" -iid $iid -detected $true -Parameter @{"DName"= $driver.Name; "DVersion"=$driver.DriverVersion}
				break
			}
			else # unsigned but not debug mode --> consider it signed (should not detect the root cause)
			{
				$iid = [string]::Format("{0} {1} normal mode unsigned", $driver.Name,$driver.DriverVersion)
				update-diagrootcause -id "RC_UnsignedVideoDriver" -iid $iid -detected $false -Parameter @{"DName"= $driver.Name; "DVersion"=$driver.DriverVersion}
			}
		}
	}
}
if($global:unsignedflag -eq $false)
{
	update-diagrootcause -id "RC_UnsignedVideoDriver" -iid "signed" -detected $false
}
