# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:
	  CL_Service.ps1 is common library for BITS troubleshooter which contains function related to Windows Services.

	ARGUMENTS:
	  None

	RETURNS:
	  None

	FUNCTIONS:
	  Servicer
	  SvcStateChange
	  Get-ServiceStart
	  WaitFor-ServiceStatus
	  Check-ServiceRunning
	  Fix-Service
#>

# ================================================================================
# IsServiceInstalled Determine whether a service is found on the local machine
# ================================================================================
Function IsServiceInstalled($serviceName)
{
	# get list of Windows services
	$services= Get-Service

	# Determine whether the service is found on the local machine
	foreach ($service in $services)
	{
		if ([System.String]::Equals($service.ServiceName, $serviceName,  [System.StringComparison]::OrdinalIgnoreCase)) 
		{                   
			return $true;
		}
	}
	return $false;
}

# ================================================================================
# Servicer
# ================================================================================
function Servicer {
	param($SrvcName = $(throw "need name of service"), $state = $("Need state Running or Stopped"))
	$z = get-service #initialize
	$Svc = Get-Service $SrvcName
	if($Svc.status -eq $state) 
	{write-debug "no change needed"}
	if($Svc.status -ne $state)
	{
		switch($state)
		{
			"Running" {Start-Service $SrvcName;
				if((SvcStateChange -test $Svc -goal 'Running' -til 9))
				{ #Write-Debug "Service $SrvcName did start"
					return $true}
				}
			"Stopped"  {Stop-Service -Force $SrvcName;
				if((SvcStateChange -test $Svc -goal 'Stopped' -til 9))
				{ #Write-Debug "Service $SrvcName did stop"
					return $true}
				}
			default {Get-Service $SrvcName;
					 return $false
					 }
		}
	}
}
# ================================================================================
# Silent Servicer
# ================================================================================
function SServicer {
	param($SrvcName = $(throw "need name of service"), $state = $("Need state Running or Stopped"))
	$z = get-service #initialize
	if ((IsServiceInstalled $SrvcName) -eq $false)
	{
	 write-debug "No Service found with this name"
	 return $false
	}
	$Svc = Get-Service $SrvcName -ErrorAction SilentlyContinue
	if ([string]::IsNullOrEmpty($Svc)){	  
	  return $false
	}
	if($Svc.status -eq $state) 
	{write-debug "no change needed"}
	if($Svc.status -ne $state)
	{
		switch($state)
		{
			"Running" {Start-Service $SrvcName 2>$null;
				if((SvcStateChange -test $Svc -goal 'Running' -til 9))
				{ #Write-Debug "Service $SrvcName did start"
					return $true}
				}
			"Stopped"  {Stop-Service -Force $SrvcName 2>$null;
				if((SvcStateChange -test $Svc -goal 'Stopped' -til 9))
				{ #Write-Debug "Service $SrvcName did stop"
					return $true}
				}
			default {Get-Service $SrvcName;
					 return $false
					 }
		}
	}
}

# ================================================================================
# SvcStateChange
# ================================================================================
Function SvcStateChange {
	param($test, $goal, $til)
	$atEnd = $false
	$range = 1..$til
	while(-not ($test.status -eq $goal) -and (-not $atEnd))
	{
		$range | foreach-object {
			sleep ($_ * 1.1); 
			$test.refresh()
			if($test.status -eq $goal)
			{
				continue
			}
		} 
		$atEnd = $true
	}
	
	if($test.status -eq $goal)
	{	
		return $true
	}
	else
	{	
		return $false
	}
}

# ================================================================================
# Get-ServiceStartup
# ================================================================================
function Get-ServiceStartup([Object]$objService)
{
	$path = "HKLM:\SYSTEM\CurrentControlSet\Services\" + $objService.Name
	if(Test-path $path)
	{
		$StartupType = (Get-ItemProperty -Path $path -ea silentlycontinue).start
	}
	Switch($StartupType)
	{
			  0 { $TypeName = "Boot" 		}
			  1 { $TypeName = "System" 		}
			  2 { $TypeName = "Automatic"	}
			  3 { $TypeName = "Manual" 		}
			  4 { $TypeName = "Disabled" 	}
		default { $TypeName = "Error" 		}
	}

	Switch($StartupType)
	{
			  0 { $TypeDescription = "Loaded by kernel loader. Components of the driver stack for the boot (startup) volume must be loaded by the kernel loader." }
			  1 { $TypeDescription = "Loaded by I/O subsystem. Specifies that the driver is loaded at kernel initialization." }
			  2 { $TypeDescription = "Loaded by Service Control Manager. Specifies that the service is loaded or started automatically." }
			  3 { $TypeDescription = "The service does not start until the user starts it manually, such as by using Services or Devices in Control Panel. " }
			  4 { $TypeDescription = "Specifies that the service should not be started." }
		default { $TypeDescription = "There was an error retrieving information about this service." }
	}

	return $TypeName
}
# ================================================================================
# WaitFor-ServiceStatus
# ================================================================================
function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"),$serviceStatus=$(throw "No service status is specified"))
{
	$Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}
	if($Service -ne $null)
	{
		[TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,5,0)
		$Service.WaitForStatus($serviceStatus, $timeOut)
	}
}

# ================================================================================
# IsServiceAutoandRunning
# ================================================================================
function IsServiceNotAutoandRunning()
{
	param($servicename)
	$objService = Get-Service | Where-Object {$_.Name -eq $servicename}
	if($objService -ne $null)
	{
		$ServiceStatus = $objService.Status
		$StartupType = Get-ServiceStartup $objService
		if($ServiceStatus -ne "Running" -or $StartupType -ne "Automatic") { $svcproblem = $true }
	}
	return $svcproblem
}

# ================================================================================
# Check-ServiceRunning
# ================================================================================
function Check-ServiceRunning($ServiceName)
{
	$RunningStatus = $false
	$Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}

	if( $Service -ne $null)
	{	
		$RunningStatus = ($Service.Status -eq "Running")
	}
	else
	{
		[string]$DebugString = 'Check-ServiceRunning Warning: Service ' + $ServiceName + ' not found.'
		Write-Debug $DebugString
	}

	return $RunningStatus
}

# ================================================================================
# Fix-Service
# ================================================================================
function Fix-Service($ServiceName,[switch]$manual)
{

	$Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}
	if ($Service -ne $null -and !($manual.IsPresent))
	{
		Set-Service -Name $ServiceName -StartupType Automatic -ErrorAction Stop
		Start-Service $ServiceName -ErrorAction Stop
		WaitFor-ServiceStatus $ServiceName 'Running'
	}
	elseif ($Service -ne $null -and ($manual.IsPresent))
	{
		Set-Service -Name $ServiceName -StartupType Manual -ErrorAction Stop
		Start-Service $ServiceName -ErrorAction Stop
		WaitFor-ServiceStatus $ServiceName 'Running'
	}
	else
	{
		[string]$DebugString = 'Fix-Service Warning: Service ' + $ServiceName + ' not found.'
		Write-Debug $DebugString
	}

}

# ================================================================================
# Fix-Service with debug in a file
# ================================================================================
function Fix-ServiceWithDebugFile($ServiceName,$debugFile,$message)
{
	trap [Exception] { 
		[string]$strerror = ("$message"+($_.Exception.Message)) 
		$strerror >> $debugFile 
	  continue; 
   }

	$Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}
	if ($Service -ne $null)
	{
		Set-Service -Name $ServiceName -StartupType Automatic -ErrorAction SilentlyContinue # SilentlyContinue for- service not found
		Start-Service $ServiceName -ErrorAction SilentlyContinue
		WaitFor-ServiceStatus $ServiceName 'Running'
		("$message : $ServiceName "+( (get-service $servicename).status ) ) >> $debugFile 
	}
	else
	{
		[string]$DebugString = 'Fix-Service Warning: Service ' + $ServiceName + ' not found.'
		 $DebugString  >> $debugFile 
	}

}

# ================================================================================
# SetServiceRunning
# ================================================================================
function SetServiceRunning()
{
	Param($svc,[switch]$nostop,$scriptname)
	sc.exe sdset $svc "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
	sc.exe config $svc start= auto
	
	if(!$nostop)
	{
		&{
				Servicer $svc "Stopped"
		} trap [Exception]{
			[string]$str = ($DC_Strings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%",$svc)
			$str | convertto-xml | update-diagreport -id $scriptname -name "$str" -verbosity informational
		}
	}
			&{
		Fix-Service $svc
	} trap [Exception]{
		[string]$str = ($DC_Strings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%",$svc)
		$str | convertto-xml | update-diagreport -id $scriptname -name "$str" -verbosity informational
	}
}

# ================================================================================
# StartMode
# ================================================================================
function Get-ServiceStartMode([string]$serviceName=$(throw "No service name is specified"))
{
	return (get-wmiObject win32_service |?{$_.Name -eq $serviceName}|%{$_.StartMode})
}

# ================================================================================
# Debug Information writing in file
# ================================================================================
function Append-DebugFile($msg1,$file1)
{
	$msg1 >> $file1
}