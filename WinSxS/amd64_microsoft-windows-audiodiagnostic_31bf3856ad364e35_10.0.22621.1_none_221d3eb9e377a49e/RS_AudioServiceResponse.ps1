# Copyright © 2015, Microsoft Corporation. All rights reserved.
#*=================================================================================
<#
RS_AudioServiceResponse resolves the problem related the audio services, Set the sevices to automatic and start services.

Arguments:
	None

Return values:
	None	
#>
#*=================================================================================
#Initialize
#*=================================================================================

function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"), [ServiceProcess.ServiceControllerStatus]$serviceStatus=$(throw "No service status is specified")) {
<#
	Function description:
		Initailize the ServiceController for the audio services and wait for Time span of 5 minutes and get status of the service.

	Arguments:

	serviceName: String contains service name.
	serviceStatus: ServiceControllerStatus datatype contains error message "No service status is specified"

	Return values:
		None
#>
    [ServiceProcess.ServiceController]$sc = New-Object "ServiceProcess.ServiceController" $serviceName
    [TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,5,0)
    $sc.WaitForStatus($serviceStatus, $timeOut)
}

# Killing the host process for Audiosrv

$ProcessId = Get-WmiObject -Class Win32_Service | where {$_.Name -EQ "Audiosrv"} | Select-Object -ExpandProperty ProcessId
$process = Get-Process -Id $ProcessId
$process.Kill()
Start-Sleep -Seconds 20

Stop-Service AudioEndpointBuilder -Force -ErrorAction SilentlyContinue
WaitFor-ServiceStatus "AudioEndpointBuilder" ([ServiceProcess.ServiceControllerStatus]::Stopped)


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

Restart-Service AudioEndpointBuilder -Force -ErrorAction SilentlyContinue
WaitFor-ServiceStatus "AudioEndpointBuilder" ([ServiceProcess.ServiceControllerStatus]::Running)

Restart-Service Audiosrv -ErrorAction SilentlyContinue
WaitFor-ServiceStatus "Audiosrv" ([ServiceProcess.ServiceControllerStatus]::Running)