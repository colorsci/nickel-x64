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

Write-DiagProgress -Activity $Strings_Main.ID_Check_Audio

$registryfound = $false
$path = "registry::HKEY_LOCAL_MACHINE\software\microsoft\windows\currentversion\audio"
if(Test-Path $path)
{
    $v = get-item -Path $path
    foreach($item in $v.GetValueNames())
	{
		if($item.ToLower() -eq "disableprotectedaudiodg")
		{
			update-diagrootcause -id "RC_ProtectedAudioDisabled" -detected $true
			$registryfound = $true
			return
		}
	}
}

update-diagrootcause -id "RC_ProtectedAudioDisabled" -detected $registryfound
