
Import-Module $PSScriptRoot\Utility.psm1


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-Workspace {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254117")]
[OutputType("Microsoft.RemoteDesktopServices.Management.WorkspaceClass[]")]
    param (
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
    )

    #
    # verify deployment
    #
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {       
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    try
    {
        $WkspObjCol = get-wmiobject -ComputerName $ConnectionBroker -namespace "root\cimv2\terminalservices" `
                                    -query "Select * From Win32_Workspace" -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (GetWorkspacesWmiError $ConnectionBroker, $_)
        return
    }

    if ($WkspObjCol -eq $null) {
        Write-Error (Get-ResourceString NoWorkspacesInRDMgmt $ConnectionBroker)
        return
    }

    foreach ($WkspObj in $WkspObjCol) 
    {
        new-object Microsoft.RemoteDesktopServices.Management.WorkspaceClass -ArgumentList $WkspObj.ID, $WkspObj.Name
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-Workspace {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254118")]
    param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $Name,
    
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
    )

    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 0

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    if (-not $brokerList) 
    {
        Write-Error (Get-ResourceString GetListOfConnectionBrokersFailed)
        return
    }
    
    $rdwaCollection = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-WEB-ACCESS

    if (-not $rdwaCollection) 
    {
        Write-Error (Get-ResourceString GetListOfRDWAServersFailed)
        return
    }

    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 5

    try
    {
        Test-CanSetWorkspace -ConnectionBroker $brokerList.Server -WebAccessServer $rdwaCollection.Server
    }
    catch
    {
        Write-Error $_
        return
    }

    #
    # update cpub on connection broker servers
    #
    
    # Make sure it is an array so that we can call .Length
    $brokerList = @($brokerList)

    $percentCompleteAfterUpdatingBrokers = 50
    $percentComplete = 10
    $progressPerBroker = ($percentCompleteAfterUpdatingBrokers - $percentComplete) / $brokerList.Length
    
    $brokerNum = 0
    foreach ($broker in $brokerList) 
    {
        $brokerNum++
    
        $activity = Get-ResourceString UpdateBrokersInProgress $brokerNum, $brokerList.Length
        Write-Progress -Activity $activity -PercentComplete $percentComplete
    
        try
        {
        	$WkspObjCol = get-wmiobject -ComputerName $broker.Server -namespace "root\cimv2\terminalservices" -query "Select * From Win32_Workspace" `
                                        -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            Write-Error (Get-ResourceString GetWorkspacesWmiError $broker.Server, $_)
            return
        }

        if ($WkspObjCol -eq $null) {
            Write-Error (Get-ResourceString NoWorkspacesInRDMgmt $broker.Server)
            return
        }

        foreach ($WkspObj in $WkspObjCol) 
        {
            try
            {
                $WkspObj.Name = $Name
                $out = $WkspObj.Put()
            }
            catch
            {
                Write-Error (Get-ResourceString WriteWorkspaceWmiError $broker.Server, $_)
                return
            }
            
            if (-not $out) {
                Write-Error (Get-ResourceString SetWorkspaceNameFailed)
                return
            }
        }
        
        $percentComplete += $progressPerBroker
    }
    
    #
    # for all rdwa servers in this deployment update their web.config file
    #

    $rdwaCollection = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-WEB-ACCESS

    if (-not $rdwaCollection) 
    {
        Write-Error (Get-ResourceString GetListOfRDWAServersFailed)
        return
    }

    # Make sure it is an array so that we can call .Length
    $rdwaCollection = @($rdwaCollection)

    $percentCompleteAfterUpdatingRDWAs = 95
    $percentComplete = $percentCompleteAfterUpdatingBrokers
    $progressPerRDWA = ($percentCompleteAfterUpdatingRDWAs - $percentComplete) / $rdwaCollection.Length

    $rdwaNum = 0
    foreach ($rdwaServer in $rdwaCollection) 
    {
        $rdwaNum++
    
        $activity = Get-ResourceString UpdateRDWAsInProgres $rdwaNum, $rdwaCollection.Length
        Write-Progress -Activity $activity -PercentComplete $percentComplete
    
        $ret = Set-RemoteWebConfig -RemoteServer $rdwaServer.Server -workspaceName $Name
   
        if (-not $ret)
        {
            Write-Error (Get-ResourceString SetRemoteWebConfigFileFailed $rdwaServer.Server)
        }
        
        $percentComplete += $progressPerRDWA
    }
    
    Write-Progress -Activity " " -PercentComplete 100
}

function Test-CanSetWorkspace {

param (
    [Parameter(Mandatory=$true)]
    [string[]]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$true)]
    [string[]]
    $WebAccessServer
)

    $offlineBrokers = @()
    $misconfiguredBrokers = @()
    
    foreach ($broker in $ConnectionBroker) 
    {
        # Test if the broker WMI is up
        try 
        {
            $wmiObj = Get-WmiObject -Namespace "root\cimv2\TerminalServices" -Class Win32_Workspace `
                                    -ComputerName $broker -Authentication PacketPrivacy -ErrorAction Stop
        } 
        catch 
        { 
            # WMI Error - assume the broker is offline
            Write-Debug (Get-ResourceString GetWorkspacesWmiError $broker, $_)
            $offlineBrokers += $broker
            continue
        }

        if ($wmiObj -eq $null) 
        {
    	    # Missing workspace object - the broker is misconfigured
            Write-Debug (Get-ResourceString NoWorkspacesInRDMgmt $broker)
            $misconfiguredBrokers += $broker
            continue
        } 
    }
    
    $offlineRDWAs = @()
    $misconfiguredRDWAs = @()

    foreach ($rdwa in $WebAccessServer) 
    {
        # Test if the broker WMI is up
        try
        {
            $res = Test-CanSetRemoteWebConfig -RemoteServer $rdwa
        }
        catch
        {
            # We could not contact the server - assume it is offline
            Write-Debug (Get-ResourceString SetWorkspaceOfflineRdwa $rdwa, $_)
            $offlineRDWAs += $rdwa
            continue
        }
        
        if (!$res)
        {
            # Missing the Web.config file - the server is misconfigured
            Write-Debug (Get-ResourceString SetWorkspaceMissingWebConfig $rdwa)
            $misconfiguredRDWAs += $rdwa
            continue
        }
    }
    
    if (($offlineBrokers.Length -gt 0) -or ($misconfiguredBrokers.Length -gt 0) -or ($offlineRDWAs.Length -gt 0) -or ($misconfiguredRDWAs.Length -gt 0))
    {
        throw (Get-ResourceString SetWorkspaceBadServers ([System.String]::Join(", ", $offlineBrokers)), ([System.String]::Join(", ", $misconfiguredBrokers)), ([System.String]::Join(", ", $offlineRDWAs)), ([System.String]::Join(", ", $misconfiguredRDWAs)))
    }
}
