# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
PARAM($userSID, $localProfilePath)

Import-LocalizedData -BindingVariable RC_TempInetLocalizedString -FileName CL_LocalizationData

$detected = $true 

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $RC_TempInetLocalizedString.ID_NAME_RC_TempInetFolder

# Temporary Internet Cache location: "%LocalAppData%\Microsoft\Windows\INetCache"
$defaultINetCacheLocation = "$localProfilePath\AppData\Local\Microsoft\Windows\INetCache"

# Registry path to get Current value of Internet Cache location
$regPath = "registry::HKU\$userSID\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$regPath2 = 'registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

if(Test-path $regPath)
{
	$tempINetCacheLocation = (Get-ItemProperty $regPath -Name Cache).Cache 
}
elseif(Test-path $regPath2)
{
	$tempINetCacheLocation = (Get-ItemProperty $regPath2 -Name Cache).Cache
}

# Checking whether INetCache exists and points to default location
if((Test-Path $defaultINetCacheLocation) -and ($defaultINetCacheLocation -eq $tempINetCacheLocation))
{
    $detected = $false
}

# Getting consent value whether user choose to change the INetCache location to default.
$tempConsentValue = $true;
if(Test-Path $ENV:TEMP\TEMP.log)
{
	$tempConsentValue = Get-Content -Path $ENV:TEMP\TEMP.log -ErrorAction SilentlyContinue
	Remove-Item $ENV:TEMP\TEMP.log -Recurse -Force -ErrorAction SilentlyContinue
}

# If consent unavailable, skipping the root cause update.
if($tempConsentValue -eq $true)
{
	Update-DiagRootCause -Id 'RC_TempInetFolder' -Detected $detected -Parameter @{'userSID' = $userSID; 'localProfilePath' = $localProfilePath}
}

return $detected