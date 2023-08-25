# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#==================================================================================
# Initialize
#==================================================================================
PARAM($userSID, $localProfilePath)

Import-LocalizedData -BindingVariable RS_TempInetLocalizedString -FileName CL_LocalizationData

#==================================================================================
# Main
#==================================================================================

Write-DiagProgress -Activity $RS_TempInetLocalizedString.ID_NAME_RS_TempInetFolder

$choice = Get-DiagInput -Id "INT_MOVETIF"
if($choice -eq 'Y')
{
	$true > $ENV:TEMP\TEMP.log

	$regPath1 = "registry::HKU\$userSID\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
	$regPath2 = "registry::HKU\$userSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
	$regPath3 = 'registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
	
	if (Test-Path $regPath1)
	{
		$currentTIF = (Get-ItemProperty $regPath1 -Name Cache).Cache
	}
	elseif(Test-Path $regPath3)
	{
		$currentTIF = (Get-ItemProperty $regPath3 -Name Cache).Cache
	}

	# Temporary Internet Cache location: "%LocalAppData%\Microsoft\Windows\INetCache"
	$defaultINetCacheLocation = "$localProfilePath\AppData\Local\Microsoft\Windows\INetCache"

	if(!($currentTIF.Contains('Temporary Internet Files')))
	{
		$currentTIF = "$currentTIF\Temporary Internet Files"
	}

	if(Test-Path $regPath1)
	{
		Set-ItemProperty -Path $regPath1 -Name Cache -Value $defaultINetCacheLocation
	}
	
	if(Test-Path $regPath2)
	{
		Set-ItemProperty -Path $regPath2 -Name Cache -Value $defaultINetCacheLocation
	}
	
	if(Test-Path $regPath3)
	{
		Set-ItemProperty -Path $regPath3 -Name Cache -Value $defaultINetCacheLocation
	}
	
	if(!(Test-Path $defaultINetCacheLocation))
	{
		$temp = mkdir $defaultINetCacheLocation | out-null
	}

	# Move Files from current Temporary internet files to Default
	if ((Test-Path $currentTIF) -and (Test-Path $defaultINetCacheLocation))
	{
		Copy-Item $currentTIF -Destination $defaultINetCacheLocation -Recurse -Force -EA 0 
	}
}
else
{
	$false > $ENV:TEMP\TEMP.log
}