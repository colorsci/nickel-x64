# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
#=================================================================================
. .\CL_Utility.ps1
. .\CL_SetupEnv.ps1
. .\CL_Service.ps1	

#=================================================================================
# Get-DateLastWeek
# Function gets the last week starting from midnight
#=================================================================================
function Get-DateLastWeek()
{
	$lastweek = (Get-Date) - (New-Timespan -day 8)
	$lastweek = $lastweek.addminutes(-($lastweek.minute))
	$lastweek = $lastweek.addhours(-($lastweek.hour))
	$lastweek = $lastweek.addseconds(-($lastweek.second))
	return $lastweek
}

#=================================================================================
# Get-ComponentAndErrorCode
#=================================================================================
function Get-ComponentAndErrorCode([string]$msg)
{	
	$codes=[regex]::matches($msg, "0x[a-f0-9a-f0-9A-F0-9A-F0-9]{6,8}")
	if($codes.count -gt 1)
	{
		$codeList = ""
		# there can be more than one error code can be returned for the same component at once
		foreach($code in $codes)
		{
			$codeList += "_" + $code
		}
		return $codeList
	}
	else
	{
		return $codes[0].Value
	}
}

#=================================================================================
# Get-DatedEvents
# Gets the dated events from given date to present date
#=================================================================================
function Get-DatedEvents($eventlog)
{
    $datedEvents = @()
	if($eventlog -eq $null) 
	{ 
		return $null 
	}
	foreach($event in $eventlog)
	{
        #$eventMsg = $event.Message
        $datedEvents += $event.Message
	}   
	return $datedEvents	
}

#=================================================================================
# Get-SystemEvents
# Function to get the Windows Event logs
#=================================================================================
function Get-SystemEvents($eventSrc,$time)
{
    $events = Get-WinEvent -ProviderName $eventsSrc -ErrorAction 0 | ?{($_.LevelDisplayName -ne "Information") -and (($_.Id -eq 20) -or ($_.Id -eq 25)) -and ($_.TimeCreated -gt $time)}
    return $events	
}

#=================================================================================
# HasWinUpdateErrorInLastWeek
#=================================================================================
function HasWinUpdateErrorInLastWeek([switch]$allLastWeekError)
{
	$events = @()
	$eventsSrc = "Microsoft-Windows-WindowsUpdateClient"
	$startTime = (Get-Date) - (New-TimeSpan -Day 8)
	$wuEvents = Get-SystemEvents $eventsSrc $startTime
	if($wuEvents -eq $null) 
	{ 
		return $null 
	}
	$events += Get-DatedEvents $wuEvents
    $latestError =  Get-ComponentAndErrorCode $events[0]
	$errorList = @{}
	$errorList.add("latest",$latestError)
	if($allLastWeekError)
	{
		foreach($str in $events)
		{
		    $ecode = Get-ComponentAndErrorCode $str	
			if($ecode -ne $null -and !$errorList.ContainsValue($ecode))
			{
				$errorList.add($ecode,$ecode)
			}
		}
	}
	return $errorList
}

#*=================================================================================
# Get-AllErrorCodes
#*=================================================================================
function Get-AllErrorCodes()
{
	return (HasWinUpdateErrorInLastWeek -AllLastWeekError)
}

function Test-ServiceStarted($serviceName)
{
	<#
	.DESCRIPTION:
	Function that checks whether a service is started or not

	.ARGUMENT:
	ServiceName - Name of the service

	.RETURNS:
	<True> if service started otherwise <false>
	#>

	if($serviceName -eq $null)
	{ 
		return $false 
	}

	$service=get-service $serviceName
	if($service.status -ieq "running")
	{
		return $true
	}

	return $false
}

function Test-PostBack
{
    [CmdletBinding()]
    PARAM
    (
        [Alias('S')]
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $CurrentScriptName
    )
    PROCESS 
    {
        # Writing the trace to current directory
        $CurrentScriptName = ("{0}.temp" -f [System.IO.Path]::GetFileNameWithoutExtension($CurrentScriptName))

        if(Test-Path($CurrentScriptName))
        {
            return $true
        }

        'Executed' >> $CurrentScriptName
        return $false
    }
}

function Test-ConnectedToInternet
{
	$NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
	$INetworkListManager = [Activator]::CreateInstance($NLMType)  
	return ($INetworkListManager.IsConnectedToInternet -eq $true)
}

function Test-UpdateAvailable
{
    # Default value to return in case we fail to search for updates
    $results = $false
	
    try
    {
        $PowerShell = [PowerShell]::Create()

        [void]$PowerShell.AddScript({
			$updateSession = New-Object -ComObject Microsoft.Update.Session
			$updateSearcher = $updateSession.CreateUpdateSearcher()
			$searchResult = $updateSearcher.Search("IsInstalled = 0")
     		return ($searchResult.Updates.Count -gt 0)
        })

        # Start executing the script block asynchronously in a separate thread in the current runspace
        $AsyncTask = $PowerShell.BeginInvoke()

        # Wait till IsCompleted is signalled or timeout expires
        $AsyncTask.AsyncWaitHandle.WaitOne(60000) | Out-Null

        if ($AsyncTask.IsCompleted -eq $false)
        {
            # If the async activity was not complete then terminate it. You will not have access to the results of the asynchronous invoke.
            $PowerShell.Stop() | Out-Null
        } 
        else
        {
            #Async activity completed before timeout. Retrieve the results.
            $AsyncResultCollection = $PowerShell.EndInvoke($AsyncTask)

            if (($AsyncResultCollection.Count -eq 1) -and ($AsyncResultCollection[0] -is [System.Boolean]))
            {
                $results = $AsyncResultCollection[0]
            }
        }

        $PowerShell.Dispose() | Out-Null	
    }
    catch 
    {}

    return $results
}

function Get-PendingReboot
{
    <#
    SYNOPSIS:
        Gets the pending reboot status on a local computer.

    DESCRIPTION:
        This function will query the registry on a local or remote computer and determine if the
        system is pending a reboot, from Microsoft updates, Configuration Manager Client SDK, Pending Computer 
        Rename, Domain Join or Pending File Rename Operations. For Windows 2008+ the function will query the 
        CBS registry key as another factor in determining pending reboot state.  "PendingFileRenameOperations" 
        and "Auto Update\RebootRequired" are observed as being consistent across Windows Server 2003 & 2008.
	
        CBServicing			   : Component Based Servicing (Windows 2008+)
        WindowsUpdate		   : Windows Update / Auto Update (Windows 2003+)
        CCMClientSDK		   : SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
        PendingComputerRename  : Detects either a computer rename or domain join operation (Windows 2003+)
		PendingFileRename	   : PendingFileRenameOperations (Windows 2003+)
		PendingFileRenameValue : PendingFileRenameOperations registry value; used to filter if needed, some Anti-Virus 
							    leverage this key for def/dat removal, giving a false positive PendingReboot

    EXAMPLE:
        PS C:\> Get-PendingReboot
	
        CBServicing            : False
        WindowsUpdate          : True
        CCMClient              : False
        PendingComputerRename  : False
        PendingFileRename      : False
        PendingFileRenameValue : {\??\C:\Users\Administrator\AppData\Local\Temp\nsz994B.tmp\p\syschk.dll, , \??\C:\Users\Administrator\AppData\Local\Temp\nsz994B.tmp\p\, ...}
        RebootPending          : True
	
        This example will query the local machine for pending reboot information.
	
    LINK:
        Component-Based Servicing:
        http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx
	
        PendingFileRename/Auto Update:
        http://support.microsoft.com/kb/2723674
        http://technet.microsoft.com/en-us/library/cc960241.aspx
        http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

        SCCM 2012/CCM_ClientSDK:
        http://msdn.microsoft.com/en-us/library/jj902723.aspx
    #>

    try
    {
        $Computer = $env:COMPUTERNAME

        # Setting pending values to false
	    $CBSRebootPending = $PendingComputerRename = $PendingFileRename = $SCCM = $Pending = $false
    						
	    # Making registry connection to the computer
	    $HKLM = [UInt32] "0x80000002"
	    $WmiRegistryConnection = [WMIClass] "\\$Computer\root\default:StdRegProv"
						
	    # Querying the CBS Registry Key
	    $RegSubKeysCBS = $WmiRegistryConnection.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
	    $CBSRebootPending = $RegSubKeysCBS.sNames -contains "RebootPending"		
					
	    # Query WUAU from the registry
	    $RegWUAURebootRequired = $WmiRegistryConnection.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
	    $WUAURebootRequired = $RegWUAURebootRequired.sNames -contains "RebootRequired"
						
	    # Query PendingFileRenameOperations from the registry
	    $RegSubKeySM = $WmiRegistryConnection.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations")
	    $RegValuePFRO = $RegSubKeySM.sValue

	    # Query JoinDomain key from the registry - These keys are present if pending a reboot from a domain join operation
	    $Netlogon = $WmiRegistryConnection.EnumKey($HKLM,"SYSTEM\CurrentControlSet\Services\Netlogon").sNames
	    $PendingDomainJoin = ($Netlogon -contains 'JoinDomain') -or ($Netlogon -contains 'AvoidSpnSet')

	    # Query ComputerName and ActiveComputerName from the registry
	    $ActiveComputerName = $WmiRegistryConnection.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")            
	    $ComputerName = $WmiRegistryConnection.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")

	    if (($ActiveComputerName -ne $ComputerName) -or $PendingDomainJoin) 
        { 
            $PendingComputerRename = $true 
        }
						
	    # If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
	    if ($RegValuePFRO) 
        { 
            $PendingFileRename = $true 
        }

	    # Determine SCCM 2012 Client Reboot Pending Status
	    # To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
	    $CCMClientSDK = $null
	    $CCMSplat = @{
	        NameSpace = 'ROOT\ccm\ClientSDK'
	        Class = 'CCM_ClientUtilities'
	        Name = 'DetermineIfRebootPending'
	        ComputerName = $Computer
	        ErrorAction = 'Stop'
	    }

	    try 
        {
	        $CCMClientSDK = Invoke-WmiMethod @CCMSplat
	    } 
        catch [System.UnauthorizedAccessException] 
        {
	        $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
	        if ($CcmStatus.Status -ne 'Running') 
            {
	            Write-Warning "$Computer`: Error - CcmExec service is not running."
	            $CCMClientSDK = $null
	        }
	    } 
        catch 
        {
	        $CCMClientSDK = $null
	    }

	    if ($CCMClientSDK) 
        {
	        if ($CCMClientSDK.ReturnValue -ne 0) 
            {
		        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"          
		    }
		
            if ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) 
            {
		        $SCCM = $true
		    }
	    }
	    else 
        {
	        $SCCM = $null
	    }

	    # Creating Custom PSObject and Select-Object Splat
	    $SelectSplat = @{
	        Property = (
	            'CBServicing',
	            'WindowsUpdate',
	            'CCMClientSDK',
	            'PendingComputerRename',
	            'PendingFileRename',
	            'PendingFileRenameValue',
	            'RebootPending'
	        )}
	    New-Object -TypeName PSObject -Property @{
	        CBServicing = $CBSRebootPending
	        WindowsUpdate = $WUAURebootRequired
	        CCMClientSDK = $SCCM
	        PendingComputerRename = $PendingComputerRename
	        PendingFileRename = $PendingFileRename
	        PendingFileRenameValue = $RegValuePFRO
	        RebootPending = ($PendingComputerRename -or $CBSRebootPending -or $WUAURebootRequired -or $SCCM -or $PendingFileRename)
	    } | Select-Object @SelectSplat

    } 
    catch 
    {
	    Write-Warning "$Computer`: $_"
	    # Updating diagnostics report
	    if ($ErrorLog) {
	        Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
	    }				
    }			
}

function Get-PendingRebootOfflineUpdates
{
	$updateSession = New-Object -ComObject "Microsoft.Update.Session"
	$updateSession.ClientApplicationID = "Script to query updates"
	$updateSearcher = $updateSession.CreateUpdateSearcher() 
	$updateSearcher.Online = 0  
	[array]$searchResult = [array]($updateSearcher.Search("IsPresent=1 and RebootRequired=1"))
    [int]$result = ($searchResult.Updates).Count
	if($result -ge 1)
	{
		return $true
	}
	return $false
}