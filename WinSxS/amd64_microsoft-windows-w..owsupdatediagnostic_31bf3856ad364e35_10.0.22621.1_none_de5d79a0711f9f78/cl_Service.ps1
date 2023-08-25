# Copyright © 2017, Microsoft Corporation. All rights reserved.
# ===============================================================================
# Load Utilities
# ==============================================================================
. .\CL_Utility.ps1
#*================================================================================
# Functions
#	Test-ServiceState
#	Test-ServiceStateChange 
#   WaitFor-ServiceStatus
#   Set-ServiceRunning
#	Fix-ServiceWithDebugFile
#   SideBySide
#*================================================================================
#Test-ServiceState
#*================================================================================
function Test-ServiceState
{
	param($srvcName = $(throw "need name of service"), $state = $("Need state Running or Stopped"))
	$svc = Get-Service $srvcName
	if($svc.status -eq $state) 
	{
		Write-Debug "no change needed"
	}
	if($svc.status -ne $state)
	{
		switch($state)
		{
			"Running" {Start-Service $srvcName;
				if((Test-ServiceStateChange -test $svc -goal 'Running' -til 9))
				{ 
					return $true}
				}
			"Stopped"  {Stop-Service -Force $srvcName -ErrorAction SilentlyContinue;
				if((Test-ServiceStateChange -test $svc -goal 'Stopped' -til 9))
				{ 
					return $true}
				}
			default {Get-Service $srvcName;
					 return $false
					 }
		}
	}
}

#*================================================================================
#SvcStateChange
#*================================================================================
Function Test-ServiceStateChange 
{
	param($test, $goal, $til)
	$atEnd = $false
	$range = 1..$til
	while(-not ($test.status -eq $goal) -and (-not $atEnd))
	{
		$range | foreach-object { 
		sleep ($_ * 1.1); 
		$test.refresh()
		if($test.status -eq $goal)
		{continue}
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

#*================================================================================
#WaitFor-ServiceStatus
#*================================================================================
function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"),$serviceStatus=$(throw "No service status is specified"))
{
    $Service = Get-Service | Where-Object {$_.Name -eq $ServiceName}
    if($Service -ne $null)
    {
		[TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,10,0)
		$Service.WaitForStatus($serviceStatus, $timeOut)
    }
}

#*================================================================================
#Set-ServiceRunning
#*================================================================================
function Set-ServiceRunning()
{
    Param($svc,[switch]$nostop,$scriptname)
	sc.exe sdset $svc "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
	sc.exe config $svc start= auto
	
	if(!$nostop)
	{
		&{
			Test-ServiceState $svc "Stopped"
		 } trap [Exception]{
			[string]$str = ($RS_DataSore_LocalizedStrings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%",$svc)
			$str | ConvertTo-Xml | Update-Diagreport -Id $scriptname -Name "$str" -Verbosity informational
		}
	}
	&{
		Fix-Service $svc
	 } trap [Exception]{
		[string]$str = ($RS_DataSore_LocalizedStrings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%",$svc)
		$str | ConvertTo-Xml | Update-Diagreport -Id $scriptname -Name "$str" -Verbosity informational
	}
}

#*================================================================================
#Fix-ServiceWithDebugFile
#*================================================================================
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
		Set-Service -Name $ServiceName -StartupType Automatic 
		Start-Service $ServiceName 
		WaitFor-ServiceStatus $ServiceName 'Running'
		("$message : $ServiceName "+( (get-service $servicename).status ) ) >> $debugFile 
	}
	else
	{
		[string]$DebugString = 'Fix-Service Warning: Service ' + $ServiceName + ' not found.'
		 $DebugString  >> $debugFile 
	}

}


