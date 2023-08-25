# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:
	  RS_AudioService resolves the problem related the audio services, Set the sevices to automatic and start services.

	ARGUMENTS:
	  None

	RETURNS:
	  None
#>

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $localizationString.audioServiceStart_progress

function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"), [ServiceProcess.ServiceControllerStatus]$serviceStatus=$(throw "No service status is specified")) 
{
<#
	DESCRIPTION:
	  Initialize the ServiceController for the audio services and wait for Time span of 5 minutes and get status of the service.

	ARGUMENTS:
	  serviceName: String contains service name.
	  serviceStatus: ServiceControllerStatus datatype contains error message "No service status is specified"

	RETURNS:
	  None
#>

	[ServiceProcess.ServiceController]$sc = New-Object "ServiceProcess.ServiceController" $serviceName
	[TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,5,0)
	$sc.WaitForStatus($serviceStatus, $timeOut)
}

# Check the audio service startup type
$audioEndpointServicestartupType = (Get-WmiObject -query "select * from win32_baseService where Name='AudioEndpointBuilder'").StartMode
$audioSrvstartupType = (Get-WmiObject -query "select * from win32_baseService where Name='Audiosrv'").StartMode

# Change the audio service startup type to automatic
if($audioEndpointServicestartupType -ne "auto")
{
	(Get-WmiObject -query "select * from win32_baseService where Name='AudioEndpointBuilder'").changeStartMode("automatic") > $null
}

if($audioSrvstartupType -ne "auto")
{
	(Get-WmiObject -query "select * from win32_baseService where Name='Audiosrv'").changeStartMode("automatic") > $null
}

Restart-Service AudioEndpointBuilder -Force
WaitFor-ServiceStatus "AudioEndpointBuilder" ([ServiceProcess.ServiceControllerStatus]::Running)

Restart-Service Audiosrv
WaitFor-ServiceStatus "Audiosrv" ([ServiceProcess.ServiceControllerStatus]::Running)