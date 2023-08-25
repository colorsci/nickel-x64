# Copyright © 2018, Microsoft Corporation. All rights reserved.


#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================

#*=================================================================================
#Run verifier logic
#*=================================================================================

$path = "registry::HKEY_LOCAL_MACHINE\software\microsoft\windows\currentversion\audio"
$value = Get-ItemProperty -Path $path -Name DisableprotectedaudioDG -ErrorAction SilentlyContinue
if(($value) -and ((Get-Service "audiosrv" -ErrorAction SilentlyContinue) -ne $null))
{
   	update-diagrootcause -id "RC_ProtectedAudioDisabled" -detected $true
}
else
{
	update-diagrootcause -id "RC_ProtectedAudioDisabled" -detected $false
}
