# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION
	  TS_AudioService verifies the services related to audio device is running or not.

	ARGUMENTS:
	  None 

	RETURNS:
	  $result : Boolean value $true if audio device is disabled or $false 
#>

#=====================================================================================
# Initialize
#=====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#=====================================================================================
# Main
#=====================================================================================
Write-DiagProgress -activity $localizationString.audioService_progress

# Check Whether the service of audio service is existent
$audioService = (Get-WmiObject -Query "select * from win32_baseService where Name='Audiosrv'")
$audioEndpointBuilderService = (Get-WmiObject -Query "select * from win32_baseService where Name='AudioEndpointBuilder'")

if(($audioService -eq $NULL) -or ($audioEndpointBuilderService -eq $null))
{
	return $false
}

# Check the audio service status 
[bool]$result = ($audioService.State -eq 'Running') -and ($audioEndpointBuilderService.State -eq 'Running')

if(-not($result))
{
	Update-DiagRootCause -ID 'RC_AudioService' -Detected $true
}
else 
{
	Update-DiagRootCause -ID 'RC_AudioService' -Detected $false
}
Write-DiagProgress -activity " "
return $result