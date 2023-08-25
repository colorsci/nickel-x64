# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. .\CL_Utility.ps1

#==============================================================
# Main
#==============================================================

$detected = $false
$expectedString = Get-AppDataExpectedString
$res =  (Get-ItemProperty 'Registry::HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').AppData 
if (($expectedString.Replace('%USERPROFILE%',$env:userprofile)) -ne $res)
{
	$detected = $true
}

Update-Diagrootcause -Id RC_APPDATA -Detected $detected

