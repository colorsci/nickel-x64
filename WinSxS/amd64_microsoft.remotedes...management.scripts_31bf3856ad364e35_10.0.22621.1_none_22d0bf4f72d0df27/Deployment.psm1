
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\CustomRdpProperty.psm1
Import-Module $PSScriptRoot\VirtualDesktopCollection.psm1
Import-Module $PSScriptRoot\VirtualDesktopCollectionProperties.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-VirtualDesktopDeployment {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254049")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String[]]
    $VirtualizationHost,
    
    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $WebAccessServer,
    
    [Parameter(Mandatory=$false, Position=3)]
    [Switch]
    $CreateVirtualSwitch
  
)
    
    $error = $null
    $VDIError = $null
    $ValidRDVHServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDVHServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDVHFailures = New-Object 'System.Collections.Generic.List[Microsoft.RemoteDesktopServices.Common.DeploymentValidations]'
    $WarningRDVHServers = New-Object 'System.Collections.Generic.List[String]'
    $ValidNetworkAdapters = New-Object 'System.Collections.Generic.List[String]'
    $ServerResult =  New-Object 'System.Collections.Generic.List[System.Collections.Generic.KeyValuePair[String, Microsoft.RemoteDesktopServices.Common.DeploymentValidations]]'
    
    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    $activity = Get-ResourceString ValidationInprogress
    Write-Progress -Activity $activity -PercentComplete 0
    
    # VDI Deployment validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::VDIDeployment, 
                            $VirtualizationHost, 
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId, 
                            $ConnectionBroker,
                            [ref]$FailedServers)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentErrorMessage(
                                [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::VDIDeployment,
                                $result,
                                $FailedServers,
                                [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)
        Write-Error $error

        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::VDIDeployment,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)
        Write-Verbose $criteria         
                
        return
    }

    # RDMS Server validations
    
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForVDI, 
                    $ConnectionBroker, 
                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId, 
                    $ConnectionBroker)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServerErrorMessage(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForVDI,
                        $result,
                        $ConnectionBroker,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForVDI,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Verbose $criteria         
                
        return
    }
    
    # RDWA Server validations 
    
    if(-not [string]::IsNullOrEmpty($WebAccessServer))
    {
        $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                      [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                        $WebAccessServer, 
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId, 
                        $ConnectionBroker)
                            
        if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServerErrorMessage(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                            $result,
                            $WebAccessServer,
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId)
            Write-Error $error
            
            $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId)
            Write-Verbose $criteria         
                
            return
        }
    }
    
    # RDVH validations

    $ServerResult = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServersParallel(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDVHServer, 
                        $VirtualizationHost, 
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId, 
                        $ConnectionBroker)
               
    foreach ($ResultItem in $ServerResult)
    {
        if($ResultItem.Value -eq [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $ValidRDVHServers.Add($ResultItem.Key)
        }
        else
        {
            $InvalidRDVHServers.Add($ResultItem.Key)
            $InvalidRDVHFailures.Add($ResultItem.Value)
        }
    }
             
    if($InvalidRDVHServers.Count -gt 0)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServersErrorMessage(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDVHServer,
                        $InvalidRDVHFailures,
                        $InvalidRDVHServers,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)

        if( $ValidRDVHServers.Count -eq 0 )
        {
            Write-Error $error
        }
        else
        {
            Write-Warning $error
        }
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDVHServer,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)
        Write-Verbose $criteria         

        if( $ValidRDVHServers.Count -eq 0 )
        {
            return
        }
        # Continue deployment for valid servers
    }

    # Select Network Adapters for each valid RDVH servers

    foreach ($RDVirtualizationHostServer in $ValidRDVHServers)
    {
        $BestNetworkAdapter = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::GetBestNetworkCard($RDVirtualizationHostServer)

        $SelectedNetworkAdapter = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::SelectNetworkAdapterName($BestNetworkAdapter, $CreateVirtualSwitch)
        
        $ValidNetworkAdapters.Add($SelectedNetworkAdapter)
    }
    

    $activity = Get-ResourceString DeploymentInprogress
    Write-Progress -Activity $activity -PercentComplete 15       
    
    # If at lease one RDVH server is valid then call VDI deployment.
            
    if($ValidRDVHServers.Count -gt 0)
    {
        $VirtualNetworkName = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::SelectVirtualNetworkName($ConnectionBroker, $CreateVirtualSwitch)

        $temp = $ProgressPreference
        $ProgressPreference  = "SilentlyContinue"
        $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        if([string]::IsNullOrEmpty($WebAccessServer))
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDVHServers, $ValidNetworkAdapters, $VirtualNetworkName)`
            {     
                param($ConnectionBroker, $ValidRDVHServers, $ValidNetworkAdapters, $VirtualNetworkName)
                RDManagement\Set-VDIDeployment -RDMSServer $ConnectionBroker -RDVHServers $ValidRDVHServers -NetworkAdapterName $ValidNetworkAdapters -VirtualNetworkName $VirtualNetworkName -WarningAction SilentlyContinue
            } -ErrorVariable VDIError  | Out-Null
        }
        else
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $WebAccessServer, $ValidRDVHServers, $ValidNetworkAdapters, $VirtualNetworkName)`
            {     
                param($ConnectionBroker, $WebAccessServer, $ValidRDVHServers, $ValidNetworkAdapters, $VirtualNetworkName)
                RDManagement\Set-VDIDeployment -RDMSServer $ConnectionBroker -RDWebAccessServers $WebAccessServer -RDVHServers $ValidRDVHServers -NetworkAdapterName $ValidNetworkAdapters -VirtualNetworkName $VirtualNetworkName -WarningAction SilentlyContinue
            } -ErrorVariable VDIError  | Out-Null
        }
        
        if($null -ne $M3PSession)
        {
            Remove-PSSession -Session $M3PSession
        }
        
        $ProgressPreference  = $temp
        
        $activity = Get-ResourceString DeploymentInprogress
        Write-Progress -Activity $activity -PercentComplete 95
        
        $UnJoinedServers = $null;
        $IsJoined = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::RdmsJoinStatus($true, 
                                                                                                                    $ConnectionBroker, 
                                                                                                                    $ValidRDVHServers,  
                                                                                                                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId, 
                                                                                                                    [ref] $UnJoinedServers)
        Write-Progress -Activity " " -PercentComplete 100
        
        if ((!$VDIError) -And ($IsJoined -eq $true))
        {
            Write-Verbose (Get-ResourceString Succeeded)
            return
        }
        else
        {
            if(($IsJoined -eq $true) -Or (($UnJoinedServers -ne $null) -And ($ValidRDVHServers.Count > $UnJoinedServers.Count)))
            {
                Write-Verbose (Get-ResourceString SucceededWithErrors)
                return
            }
            else
            {
                Write-Verbose (Get-ResourceString Failed)
                return
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-SessionDeployment {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254050")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String[]]
    $SessionHost,

    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $WebAccessServer
    )
    
    $error = $null
    $RDSHError = $null
    $ValidRDSHServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDSHServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDSHFailures = New-Object 'System.Collections.Generic.List[Microsoft.RemoteDesktopServices.Common.DeploymentValidations]'
    $ServerResult =  New-Object 'System.Collections.Generic.List[System.Collections.Generic.KeyValuePair[String, Microsoft.RemoteDesktopServices.Common.DeploymentValidations]]'

    
    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    $activity = Get-ResourceString ValidationInprogress
    Write-Progress -Activity $activity -PercentComplete 0    
    
    # RDSH Deployment validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::RDSHDeployment, 
                    $SessionHost, 
                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId, 
                    $ConnectionBroker,
                    [ref] $FailedServers)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentErrorMessage(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::RDSHDeployment,
                        $result,
                        $FailedServers,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::RDSHDeployment,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)
        Write-Verbose $criteria          
        
        #
        # RDSHDeployment check for IsInHAAndActiveManagementServer and IsRdshDeploymentNotExists, 
        # neither set any $FailedServer and so return immediately if validation failed
        # 

        return
    }

    # RDMS Server validations
    
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForRDSH, 
                            $ConnectionBroker, 
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId, 
                            $ConnectionBroker)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServerErrorMessage(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForRDSH,
                            $result,
                            $ConnectionBroker,
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDMSForRDSH,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Verbose $criteria        
        
        #
        # Need a valid ConnectionBroker for deployment so return immediately if validation failed
        #
        return
    }
    
    # RDWA Server validations 
    
    if(-not [string]::IsNullOrEmpty($WebAccessServer))
    {
        $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                            $WebAccessServer, 
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId, 
                            $ConnectionBroker)
                            
        if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServerErrorMessage(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                            $result,
                            $WebAccessServer,
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId)
            Write-Error $error
            
            $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDWAServer,
                            [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId)
            Write-Verbose $criteria
            
            #
            # Fail call if WebAccessServer is invalid, caller can always re-run with NULL/Empty RDWeb
            return
        }
    }
    
    # RDSH validations

    $ServerResult = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServersParallel(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDSHServer, 
                        $SessionHost, 
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId, 
                        $ConnectionBroker)
               
    foreach ($ResultItem in $ServerResult)
    {
        if($ResultItem.Value -eq [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $ValidRDSHServers.Add($ResultItem.Key)
        }
        else
        {
            $InvalidRDSHServers.Add($ResultItem.Key)
            $InvalidRDSHFailures.Add($ResultItem.Value)
        }
    }
    
    if($InvalidRDSHServers.Count -gt 0)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServersErrorMessage(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDSHServer,
                        $InvalidRDSHFailures,
                        $InvalidRDSHServers,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)

        if( $ValidRDSHServers.Count -eq 0 )
        {
            Write-Error $error
        }
        else
        {
            Write-Warning $error
        }
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::DeployRDSHServer,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)
        Write-Verbose $criteria

        if( $ValidRDSHServers.Count -eq 0 )
        {
            return;
        }

        # Continue deployment for valid servers
    }
    
    $activity = Get-ResourceString DeploymentInprogress
    Write-Progress -Activity $activity -PercentComplete 15   
    
    # If at lease one RDSH server is valid then call RDSH deployment.
            
    if($ValidRDSHServers.Count -gt 0)
    {
        $temp = $ProgressPreference
        $ProgressPreference  = "SilentlyContinue"
        
        $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
        if([string]::IsNullOrEmpty($WebAccessServer))
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDSHServers)`
            {        
                param($ConnectionBroker, $ValidRDSHServers)
                RDManagement\Set-RDSHDeployment -RDMSServer $ConnectionBroker -RDSHServers $ValidRDSHServers -WarningAction SilentlyContinue 
            } -ErrorVariable RDSHError | Out-Null
        }
        else
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $WebAccessServer, $ValidRDSHServers)`
            {        
                param($ConnectionBroker, $WebAccessServer, $ValidRDSHServers)
                RDManagement\Set-RDSHDeployment -RDMSServer $ConnectionBroker -RDWebAccessServers $WebAccessServer -RDSHServers $ValidRDSHServers -WarningAction SilentlyContinue 
            } -ErrorVariable RDSHError | Out-Null
        }
        
        if($null -ne $M3PSession)
        {
            Remove-PSSession -Session $M3PSession
        }
        
        $ProgressPreference  = $temp
        
        $activity = Get-ResourceString VerificationInprogress
        Write-Progress -Activity $activity -PercentComplete 95
        
        $UnJoinedServers = $null;
        $IsJoined = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::RdmsJoinStatus($true, 
                                                                                                                    $ConnectionBroker, 
                                                                                                                    $ValidRDSHServers,  
                                                                                                                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId, 
                                                                                                                    [ref] $UnJoinedServers)

        Write-Progress -Activity " " -PercentComplete 100

        if ((!$RDSHError) -And ($IsJoined -eq $true))
        {
            Write-Verbose (Get-ResourceString Succeeded)
            return
        }
        else
        {
            if(($IsJoined -eq $true) -Or (($UnJoinedServers -ne $null) -And ($ValidRDVHServers.Count > $UnJoinedServers.Count)))
            {
                Write-Verbose (Get-ResourceString SucceededWithErrors)
                return
            }
            else
            {
                Write-Verbose (Get-ResourceString Failed)
                return
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Add-Server {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254051")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDDeploymentServer[]")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $Server,

    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet(
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopConnectionBroker,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopVirtualizationHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopSessionHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopWebAccess,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopGateway,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopLicensing 
     )]
    [String]
    $Role,
        
    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$false, Position=3)]
    [String]
    $GatewayExternalFqdn,
    
    [Parameter(Mandatory=$false, Position=4)]
    [Switch]
    $CreateVirtualSwitch      
)

    #$RoleServiceName = (@{"Gateway" = "RDS-Gateway"; "WebAccess" = "RDS-Web-Access";})[$RoleServiceName]
    
 
    if (($Role -ne "RDS-Gateway" ) -And ($GatewayExternalFqdn))
    { 
        $error = Get-ResourceString ValidOnlyForGateway
        Write-Host $error
    }
  
    if (($Role -eq "RDS-Gateway" ) -And (-Not $GatewayExternalFqdn))
    { 
        $error = Get-ResourceString ValidExternalGatewayName
        Write-Error $error
        return
    }
    
    if (($Role -ne "RDS-Virtualization" ) -And ($CreateVirtualSwitch))
    { 
        $error = Get-ResourceString ValidOnlyForVirtualizationHost
        Write-Host $error
    }
              
    $error = $null
    $InstallError = $null
    $ConfigError = $null
    $ValidRDServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDFailures = New-Object 'System.Collections.Generic.List[Microsoft.RemoteDesktopServices.Common.DeploymentValidations]'
    $WarningRDServers = New-Object 'System.Collections.Generic.List[String]'
    $ValidNetworkAdapters = New-Object 'System.Collections.Generic.List[String]'
    $Servers = New-Object 'System.Collections.Generic.List[String]'
    
    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    $activity = Get-ResourceString ValidationInprogress
    Write-Progress -Activity $activity -PercentComplete 0
    
    # Validate Role Service Name

    $RoleId = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetRoleId($Role)
    if($RoleId -eq 0)
    {
        $error = Get-ResourceString ValidRoleServiceName
        Write-Error $error
        return
    }
    
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    #verify that the server to be added as broker has same OS version as the active broker in the deployment
    #we do not support mixed OS versions of brokers in HA configuration
    if($Role -eq "RDS-Connection-Broker")
    {
        $serversMatchOsVersion = Test-BrokerServersMatchOSVersion $ConnectionBroker $Server
        if(!$serversMatchOsVersion)
        {
            $obj = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue
            $error = (Get-ResourceString BrokerNotMatchingOSVersionErr ($Server, $ConnectionBroker, $obj.Caption))
            Write-Error $error
            return
        }
    }

    $Servers.Add($Server)
    
    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction] $Action = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentAction(
                                                                                                $RoleId,
                                                                                                [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentActionType]::Add)

    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction] $RunOnceAction = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentRunOnceAction(
                                                                                                    $RoleId,
                                                                                                    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentActionType]::Add)

    # Add RD Servers to Deployment validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                    $RunOnceAction,
                    $Servers,
                    $RoleId, 
                    $ConnectionBroker,
                    [ref]$FailedServers)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentErrorMessage(
                        $RunOnceAction,
                        $result,
                        $FailedServers,
                        $RoleId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        $RunOnceAction,
                        $RoleId)
        Write-Verbose $criteria           
        
        return
    }

    # Verify feature is available on target
    foreach ($RDDeploymentServer in $Servers)
    {
        #
        # Make sure target server can support Role
        $FeatureAvailable = Get-WindowsFeature -ComputerName $RDDeploymentServer -Name $Role

        if( !$FeatureAvailable )
        {
            $InstallError = Get-ResourceString FailedToInstallRoleServicesOnServer $RDDeploymentServer
            Write-Error $InstallError
            return
        }
    }

    # RD server validations

    Write-Verbose "Validating RD Deployment Server '$Servers'"
    
    foreach ($RDDeploymentServer in $Servers)
    {        
        $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                            $Action, 
                            $RDDeploymentServer, 
                            $RoleId, 
                            $ConnectionBroker)
        if($result -eq [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $ValidRDServers.Add($RDDeploymentServer)
        }
        else
        {
            $InvalidRDServers.Add($RDDeploymentServer)
            $InvalidRDFailures.Add($result)
        }                
    }

    if($InvalidRDServers.Count -gt 0)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServersErrorMessage(
                        $Action,
                        $InvalidRDFailures,
                        $InvalidRDServers,
                        $RoleId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        $Action,
                        $RoleId)
        Write-Verbose $criteria         
        
        return
    }

    # If at lease one RD server is valid then we proceed to Add servers to deployment.
            
    if($ValidRDServers.Count -gt 0)
    {

        #Network Adapter selection is specific to Add RDVH Servers

        if($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)
        {
            # Select Network Adapters for each valid RDVH servers

            foreach ($RDDeploymentServer in $ValidRDServers)
            {
                $BestNetworkAdapter = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::GetBestNetworkCard($RDDeploymentServer)
                
                $SelectedNetworkAdapter = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::SelectNetworkAdapterName($BestNetworkAdapter, $CreateVirtualSwitch)
                
                $ValidNetworkAdapters.Add($SelectedNetworkAdapter)

                Write-Verbose "Network adapter chosen for '$RDDeploymentServer' is '$BestNetworkAdapter'"

            }
    
            $VirtualNetworkName = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::SelectVirtualNetworkName($ConnectionBroker, $CreateVirtualSwitch)
        }

        if($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopGatewayId)
        {
            $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::Validate(
                            [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::IsFullyQualifiedDomainName,
                            $GatewayExternalFqdn,
                            $RoleId,
                            $ConnectionBroker)
            if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
            {
                $error = Get-ResourceString ValidExternalGatewayName
                Write-Error $error
                return
            }
        }
        
        $activity = Get-ResourceString InstallationInprogress
        Write-Progress -Activity $activity -PercentComplete 20
        
        $temp = $ProgressPreference
        $ProgressPreference  = "SilentlyContinue"           
        $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
        Invoke-Command -Session $M3PSession -ArgumentList @($Role, $ValidRDServers)`
        {
             param($Role, $ValidRDServers)
             RDManagement\Install-RoleService -RoleFeatureName $Role -RestartIfNeeded $true -PSComputerName $ValidRDServers -WarningAction SilentlyContinue 
        } -ErrorVariable InstallError | Out-Null 
        
        $ProgressPreference = $temp
        
        $activity = Get-ResourceString ConfigurationInprogress
        Write-Progress -Activity $activity -PercentComplete 60
        
        $ProgressPreference  = "SilentlyContinue" 
        if(!$InstallError)
        {
            if([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId -eq $RoleId)
            {
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $ValidNetworkAdapters, $VirtualNetworkName)`
                {
                    param($ConnectionBroker, $ValidRDServers, $ValidNetworkAdapters, $VirtualNetworkName)
                    RDManagement\Add-RDVirtualizationHostServer -RDMSServer $ConnectionBroker -RDVHServers $ValidRDServers -NetworkAdapterName $ValidNetworkAdapters -VirtualNetworkName $VirtualNetworkName 
                } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null 
            }
            elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId -eq $RoleId)
            {
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers)`
                {   
                    param($ConnectionBroker, $ValidRDServers)    
                    RDManagement\Add-RDSessionHostServer -RDMSServer $ConnectionBroker -RDSHServers $ValidRDServers      
                } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null   
            }
            elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId -eq $RoleId)
            {
                # Assuming that $ValidRDServers contain one and only one server
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers)`
                {                   
                    param($ConnectionBroker, $ValidRDServers)                
                    RDManagement\Add-RDManagementServer -RDMSServer $ValidRDServers -PrimaryManagementServer $ConnectionBroker -DeploymentType 2 
                } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null
            }
            elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId -eq $RoleId) 
            {
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers)`
                {
                    param($ConnectionBroker, $ValidRDServers)              
                    RDManagement\Add-RDWebAccessServer -RDMSServer $ConnectionBroker -RDWebAccessServers $ValidRDServers
                }  -ErrorVariable ConfigError -WarningAction SilentlyContinue| Out-Null 

                # Update workspace name on the WA server from CB
                $WorkspaceDetails = Get-RDWorkspace -ConnectionBroker $ConnectionBroker
                if($WorkspaceDetails -ne $null)
                {
                    foreach ($RDWAServer in $ValidRDServers)
                    {
                        $ret = Set-RemoteWebConfig -RemoteServer $RDWAServer -workspaceName $WorkspaceDetails.WorkspaceName
                    }
                }
            }
            elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopLicensingId -eq $RoleId) 
            {
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers)`
                {
                    param($ConnectionBroker, $ValidRDServers)             
                    RDManagement\Add-RDLicenseServer -RDMSServer $ConnectionBroker -LicenseServers $ValidRDServers
                }  -ErrorVariable ConfigError -WarningAction SilentlyContinue| Out-Null 
                                
                if (!$ConfigError)
                {
                    $CurrLicenseSettings = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker
                    $FinalLicenseServers = $CurrLicenseSettings.LicenseServer + $ValidRDServers | Get-Unique
                    
                    #remove any entry came because of case difference
                    $FinalLicenseServers = $FinalLicenseServers | %{$_.ToUpper()} | Get-Unique
                     
                    $CurrentLicenseMode = $CurrLicenseSettings.Mode

                    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                    $LicenseSettings = Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $FinalLicenseServers, $CurrentLicenseMode)`
                    {     
                        param($ConnectionBroker, $FinalLicenseServers, $CurrentLicenseMode)
                        RDManagement\Set-LicenseSettings -ManagementServer $ConnectionBroker -LicenseServers $FinalLicenseServers -LicenseMode $CurrentLicenseMode
                    } -ErrorVariable SetRDLicensingErrors -WarningAction SilentlyContinue 

                    if($null -ne $M3PSession)
                    {
                        Remove-PSSession -Session $M3PSession
                    }                  
                }
            }
            elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopGatewayId -eq $RoleId) 
            {
                Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $GatewayExternalFqdn)`
                {
                    param($ConnectionBroker, $ValidRDServers, $GatewayExternalFqdn)               
                    RDManagement\Add-RDGatewayServer -RDMSServer $ConnectionBroker -GatewayServers $ValidRDServers -ExternalGatewayName $GatewayExternalFqdn 
                } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null 

                if (!$ConfigError)
                {                
                    $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
                    $wmic.SetStringProperty('DeploymentExternalGatewayName',$GatewayExternalFqdn) | Out-Null 

                    # Only update with eFQDN as the gateway name when there is no gateway already specified
                    $rdgatewaySetting =  Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker

                    if( -Not (($rdgatewaySetting.GatewayMode -eq ([Microsoft.RemoteDesktopServices.Common.GatewayUsage]::UseSpecifiedBypassLocal)).value__ `
                            -Or ($rdgatewaySetting.GatewayMode -eq ([Microsoft.RemoteDesktopServices.Common.GatewayUsage]::UseSpecifiedGateway).value__)))
                    {
                        Set-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -GatewayMode ([Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom).value__`
                                -GatewayExternalFqdn $GatewayExternalFqdn -LogonMethod ([Microsoft.RemoteDesktopServices.Common.GatewayAuthMode]::Password).value__ `
                                -UseCachedCredentials $true -BypassLocal $true -Force
                    }
                }
            }
            else 
            {
                if($null -ne $M3PSession)
                {
                    Remove-PSSession -Session $M3PSession
                }            
                $ProgressPreference  = $temp
                Write-Verbose (Get-ResourceString Failed)
                return
            }
        }
        else
        {
            if($null -ne $M3PSession)
            {
                Remove-PSSession -Session $M3PSession
            }        
            $ProgressPreference  = $temp
            Write-Verbose (Get-ResourceString Failed)
            return
        }
        
        if($null -ne $M3PSession)
        {
            Remove-PSSession -Session $M3PSession
        }        
        
        $ProgressPreference  = $temp
        
        $activity = Get-ResourceString VerificationInprogress
        Write-Progress -Activity $activity -PercentComplete 95
        
        $UnJoinedServers = $null;
        $IsJoined = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::RdmsJoinStatus($true, 
                                                                                                                    $ConnectionBroker, 
                                                                                                                    $ValidRDServers,  
                                                                                                                    $RoleId, 
                                                                                                                    [ref] $UnJoinedServers)

        # Do this after the Join has been validated, so that the error message from this failing does not confuse users if other validations failing are the real cause of failing the install
        if(([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId -eq $RoleId) -and !$ConfigError -and ($IsJoined -eq $true))
        {
            Write-Verbose "Updating the Custom RDP Properties on the new Connection Broker(s)"
            foreach ($newBroker in $ValidRDServers)
            {
                try
                {
                    Update-AllCollectionsCustomRdpPropertiesOnBroker -NewConnectionBroker $newBroker -ExistingConnectionBroker $ConnectionBroker
                }
                catch
                {
                    Write-Error $_
                    # Treat this as best-effort, the same way setting the CustomRdpProperties after the fact. So don't fail the Add-RDServer call because of this.
                }
            }
        }
        #add all RDVHs to the existing SMB shares for all existing collections
        if(([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId -eq $RoleId) -and !$ConfigError -and ($IsJoined -eq $true))
        {
            try
            {
                #get all VDI collections in the deployment
                $vdiCollections = Get-RDVirtualDesktopCollection -ConnectionBroker $ConnectionBroker
                foreach($coll in $vdiCollections)
                {
                    #get all properties for each collection
                    Write-Verbose ("Collection Name:  '$coll.CollectionName'")
                    $collProps = Get-RDVirtualDesktopCollectionConfiguration -CollectionName $coll.CollectionName -VirtualDesktopConfiguration -ConnectionBroker $ConnectionBroker
                    #give host permissions to SMBShare 
                    if(-not (Set-StoragePermissions  -StorageType $collProps.StorageType -CentralStoragePath $collProps.CentralStoragePath  `
                            -LocalStoragePath $collProps.LocalVmLocation -VmTemplateStoragePath $collProps.LocalGoldVmLocation `
                            -HostList $Server ))               
                    {
                        Write-Verbose ("Set-StoragePermissions failed for collection: '$coll.CollectionName'")
                    }
                }
            }
            catch
            {
                Write-Error $_
                # Treat this as best-effort. So don't fail the Add-RDServer call because of this.
            }
        }
        Write-Progress -Activity " " -PercentComplete 100
        
        if ((!$ConfigError) -And ($IsJoined -eq $true))
        {
            Write-Verbose (Get-ResourceString Succeeded)
            New-Object Microsoft.RemoteDesktopServices.Management.RDDeploymentServer $Server, $Role
            return
        }
        else
        {
            if(($IsJoined -eq $true) -Or (($UnJoinedServers -ne $null) -And ($ValidRDServers.Count > $UnJoinedServers.Count)))
            {
                Write-Verbose (Get-ResourceString SucceededWithErrors)
                return
            }
            else
            {
                Write-Verbose (Get-ResourceString Failed)
                return
            }
        }

    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-Server {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254052")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $Server,
    
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet(
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopConnectionBroker,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopVirtualizationHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopSessionHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopWebAccess,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopGateway,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopLicensing 
     )]
    [String]
    $Role,
        
    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $ConnectionBroker,
    
    [Switch]
    $Force  
)
    
    $error = $null
    $ConfigError = $null
    $ValidRDServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDServers = New-Object 'System.Collections.Generic.List[String]'
    $InvalidRDFailures = New-Object 'System.Collections.Generic.List[Microsoft.RemoteDesktopServices.Common.DeploymentValidations]'
    $WarningRDServers = New-Object 'System.Collections.Generic.List[String]'
    $ValidNetworkAdapters = New-Object 'System.Collections.Generic.List[String]'
    $Servers = New-Object 'System.Collections.Generic.List[String]'
    
    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    $message = Get-ResourceString WarnRemoveServerMessage

    if((-not $Force) -and !$PSCmdlet.ShouldContinue($message,""))
    {
        return
    }

    $activity = Get-ResourceString ValidationInprogress
    Write-Progress -Activity $activity -PercentComplete 0
        
    # Validate Role Service Name

    $RoleId = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetRoleId($Role)

    if($RoleId -eq 0)
    {
        $error = Get-ResourceString ValidRoleServiceName
        Write-Error $error
        return 
    }
   
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    $Servers.Add($Server)
    
    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction] $Action = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentAction(
                                                                                                $RoleId,
                                                                                                [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentActionType]::Remove)


    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction] $RunOnceAction = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentRunOnceAction(
                                                                                                    $RoleId,
                                                                                                    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentActionType]::Remove)

    # Remove RD Servers to Deployment validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                    $RunOnceAction,
                    $Servers,
                    $RoleId, 
                    $ConnectionBroker,
                    [ref]$FailedServers)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentErrorMessage(
                        $RunOnceAction,
                        $result,
                        $FailedServers,
                        $RoleId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        $RunOnceAction,
                        $RoleId)
        Write-Verbose $criteria        
        
        return
    }

    # RD server validations

    foreach ($RDDeploymentServer in $Servers)
    {
        $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeploymentServer(
                        $Action, 
                        $RDDeploymentServer, 
                        $RoleId, 
                        $ConnectionBroker)
        if($result -eq [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
        {
            $ValidRDServers.Add($RDDeploymentServer)

        }
        else
        {
            $InvalidRDServers.Add($RDDeploymentServer)
            $InvalidRDFailures.Add($result)
        }                
    }

    if($InvalidRDServers.Count -gt 0)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentServersErrorMessage(
                        $Action,
                        $InvalidRDFailures,
                        $InvalidRDServers,
                        $RoleId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        $Action,
                        $RoleId)
        Write-Verbose $criteria        
        
        return
    }

    # If at lease one RD server is valid then we proceed to Remove servers to deployment.
            
    if($ValidRDServers.Count -gt 0)
    {

        # Check if all the RDVH/RDSH server are being removed from deployment

        if(($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId) -Or 
           (($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)))
        {

            $Validation = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::IsAllDeploymentServers
            $IsAllServers = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::IsAllDeploymentServers(
                                    $ConnectionBroker,
                                    $Servers,
                                    $RoleId)
    
            if($IsAllServers -eq $true)
            {
                $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetWarningMessage(
                                [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::IsAllDeploymentServers,
                                $Servers,
                                $RoleId)
                Write-Verbose $error
                $RoleString = ""
                if($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId)
                {    
                    $RoleString = Get-ResourceString VDIDeploymentTypeNameString
                }
                elseif($RoleId -eq [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId)
                {    
                    $RoleString = Get-ResourceString SessionDeploymentTypeNameString
                }

                if((-not $Force) -and !$pscmdlet.ShouldContinue((Get-ResourceString RemoveAndProceed $RoleString),""))
                {
                    return;
                }
            }
        }
        
        $activity = Get-ResourceString RemovalInprogress
        Write-Progress -Activity $activity -PercentComplete 40
        
        $temp = $ProgressPreference
        $ProgressPreference  = "SilentlyContinue"
        
        $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        if(([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopVirtualizationId -eq $RoleId) -Or
            ([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopSessionHostId -eq $RoleId))
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $Role)`
            {
                param($ConnectionBroker, $ValidRDServers, $Role)
                RDManagement\Remove-HostServers -RDMSServer $ConnectionBroker -RDHostServers $ValidRDServers -RoleFeatureName $Role  
            } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null 
        }
        elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId -eq $RoleId)
        {
            # Assuming that $ValidRDServers contain one and only one server
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers)`
            {            
                param($ConnectionBroker, $ValidRDServers)
                RDManagement\Remove-RDManagementServer -RDMSServer $ValidRDServers -PrimaryManagementServer $ConnectionBroker 
            } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null
        }
        elseif(([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopLicensingId -eq $RoleId))
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $Role)`
            { 
                param($ConnectionBroker, $ValidRDServers, $Role)
                RDManagement\Remove-RDRoleDeployment -RDMSServer $ConnectionBroker -RDServers $ValidRDServers -RoleFeatureName $Role 
            } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null 
            
            if (!$ConfigError)
            {
                $CurrLicenseSettings = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker
                $FinalLicenseServers = $CurrLicenseSettings.LicenseServer | ?{ $_ -notin $ValidRDServers}
                if($FinalLicenseServers -eq $null)
                {
                    $FinalLicenseServers = @()
                }
                else
                {
                    #remove any entry came because of case difference
                    $FinalLicenseServers = $FinalLicenseServers | %{$_.ToUpper()} | Get-Unique
                }
                
                $CurrentLicenseMode = $CurrLicenseSettings.Mode

                $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                $LicenseSettings = Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $FinalLicenseServers, $CurrentLicenseMode)`
                {     
                    param($ConnectionBroker, $FinalLicenseServers, $CurrentLicenseMode)
                    RDManagement\Set-LicenseSettings -ManagementServer $ConnectionBroker -LicenseServers $FinalLicenseServers -LicenseMode $CurrentLicenseMode
                } -ErrorVariable SetRDLicensingErrors -WarningAction SilentlyContinue 

                if($null -ne $M3PSession)
                {
                    Remove-PSSession -Session $M3PSession
                }  
            }
        }
        elseif(([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopGatewayId -eq $RoleId) )
        {
            $rdGatewayServers = Get-RDServer -ConnectionBroker $ConnectionBroker -Role $Role 
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $Role)`
            { 
                param($ConnectionBroker, $ValidRDServers, $Role)
                RDManagement\Remove-RDRoleDeployment -RDMSServer $ConnectionBroker -RDServers $ValidRDServers -RoleFeatureName $Role 
            } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null 
            
            # If all the gateway servers are removed update deployment gateway settings to "not to use gateway"
            
            if((!$ConfigError) -And ($rdGatewayServers.Count -eq $ValidRDServers.Count ))
            {
                $rdgatewaySetting = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker

                if( (($rdgatewaySetting.GatewayMode).value__ -eq ([Microsoft.RemoteDesktopServices.Common.GatewayUsage]::UseSpecifiedBypassLocal).value__) `
                        -Or ($rdgatewaySetting.GatewayMode -eq ([Microsoft.RemoteDesktopServices.Common.GatewayUsage]::UseSpecifiedGateway).value__))
                {
                    # if the current eFQDN is being used as the gateway then set it to not use gateway
                    Set-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -GatewayMode ([Microsoft.RemoteDesktopServices.Management.GatewayUsage]::DoNotUse).value__ -Force
                }
                
                $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
                $wmic.RemoveDeploymentSetting('DeploymentExternalGatewayName') | Out-Null 
            }
        }
        elseif([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopWebAccessId -eq $RoleId)
        {
            Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ValidRDServers, $Role)`
            {         
                param($ConnectionBroker, $ValidRDServers, $Role)
                RDManagement\Remove-RDRoleDeployment -RDMSServer $ConnectionBroker -RDServers $ValidRDServers -RoleFeatureName $Role  
            } -ErrorVariable ConfigError -WarningAction SilentlyContinue | Out-Null
        }
        else 
        {

            if($null -ne $M3PSession)
            {
                Remove-PSSession -Session $M3PSession
            }        
            $ProgressPreference  = $temp
            Write-Verbose (Get-ResourceString Failed)
            return
        }
        
        if($null -ne $M3PSession)
        {
            Remove-PSSession -Session $M3PSession
        }        
        
        $ProgressPreference  = $temp
        
        $activity = Get-ResourceString VerificationInprogress
        Write-Progress -Activity $activity -PercentComplete 95
        
        $JoinedServers = $null;
        $IsUnJoined = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::RdmsJoinStatus($false, 
                                                                                                                    $ConnectionBroker, 
                                                                                                                    $ValidRDServers,  
                                                                                                                    $RoleId, 
                                                                                                                    [ref] $JoinedServers)
        Write-Progress -Activity " " -PercentComplete 100

        if ((!$ConfigError) -And ($IsUnJoined -eq $true))
        {
            Write-Verbose (Get-ResourceString Succeeded)
            return
        }
        else
        {
            if(($IsUnJoined -eq $true) -Or (($JoinedServers -ne $null) -And ($ValidRDServers.Count > $JoinedServers.Count)))
            {
                Write-Verbose (Get-ResourceString SucceededWithErrors)
                return
            }
            else
            {
                Write-Verbose (Get-ResourceString Failed)
                return
            }
        }
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-Server {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254053")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDDeploymentServer[]")]
param (

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,
    [Parameter(Mandatory=$false)]
    [ValidateSet(
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopVirtualizationHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopSessionHost,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopConnectionBroker,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopWebAccess,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopGateway,
     [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopLicensing 
     )]
    [String[]]
    $Role

)

    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }
    

    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction] $RunOnceAction = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentRunOnceAction(
                                                                                                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId, 
                                                                                                    [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentActionType]::Get)

    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                    $RunOnceAction,
                    $Null,
                    [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId, 
                    $ConnectionBroker,
                    [ref]$FailedServers)
    
    if($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentErrorMessage(
                        $RunOnceAction,
                        $result,
                        $FailedServers,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Error $error
        
        $criteria = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetDeploymentValidationCriteria(
                        $RunOnceAction,
                        [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::RemoteDesktopConnectionBrokerId)
        Write-Verbose $criteria
        return
    }



    $optionalParams = Get-BoundParameter $PSBoundParameters "Role"

    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

    $servers = Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker,$optionalParams)`
    {     
        param($ConnectionBroker,$optionalParams)
        RDManagement\Get-RDMSJoinedNode -ManagementServer $ConnectionBroker @optionalParams
    } -ErrorVariable GetRDServerErrors -WarningAction SilentlyContinue 

   
    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }  

     $servers | 
    % {
        $installedRoles = @();

        if($_.IsVirtualizationHost -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopVirtualizationHost;
        }
        
        if($_.IsSessionHost -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopSessionHost;
        }
        

        if($_.IsConnectionBroker -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopConnectionBroker;
        }
        
        if($_.IsWebAccess -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopWebAccess;
        }
        
        if($_.IsGateway -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopGateway;
        }
        
        if($_.IsLicenseServer -eq $true)
        {
            $installedRoles += [Microsoft.RemoteDesktopServices.Common.RDMSConstants]::RoleServiceRemoteDesktopLicensing;
        }

        New-Object Microsoft.RemoteDesktopServices.Management.RDDeploymentServer $_.FullyQualifiedDomainName, $installedRoles 
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-ConnectionBrokerHighAvailability {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254054")]
param (

    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $DatabaseConnectionString,

    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $DatabaseSecondaryConnectionString,
    
    [Parameter(Mandatory=$false, Position=3)]
    [String]
    $DatabaseFilePath,
    
    [Parameter(Mandatory=$true, Position=4)]
    [String]
    $ClientAccessName
)

    $error = $null

    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'
    $otherParams.Add("DatabaseConnectionString", $DatabaseConnectionString);
    $otherParams.Add("ClientAccessName", $ClientAccessName);

    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }    

    $isWin10OrLater = Test-IsWindows10OrLater($ConnectionBroker)
    $isDedicatedHAConfig = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker, $DatabaseConnectionString)

    #check we were not given the shared database connection string for legacy deployments
    if(!$isWin10OrLater)
    {
        if(!$isDedicatedHAConfig)
        {
            #we do not support shared databse on legacy deployments
            $error = (Get-ResourceString SharedDatabaseServerOnLegacyOSNotSupported $ConnectionBroker)
            Write-Error $error
            return
        }

        # -DatabaseFilePath is mandatory for legacy Windows OS (Windows 2012 R2 or Windows 2012)  
        if([string]::IsNullOrEmpty($DatabaseFilePath))
        {
            $error = Get-ResourceString DatabaseFilePathMandotoryForLegacyOSBrokers $ConnectionBroker
            Write-Error $error
            return
        }  

        if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
        {
            $error = (Get-ResourceString SecondaryDBConnStringLegacyOSNotSupported $ConnectionBroker)
            Write-Error $error
            return $false
        }
    }
    else
    {
        if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
        {
            #if is dedicated database server DatabaseSecondaryConnectionString is not supported
            if($isDedicatedHAConfig)
            {
                $error = Get-ResourceString DedicatedServerHAConfigDoNotSetSecConnStr
                Write-Error $error
                return
            }
            else
            {
                #check both primary and secondary connection strings are pointing to same database
                if(![Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDatabaseNameMatching($DatabaseConnectionString, $DatabaseSecondaryConnectionString))
                {          
                    $error = Get-ResourceString NotMatchingDatabaseNameErr
                    Write-Error $error
                    return
                }
                $otherParams.Add("DatabaseSecondaryConnectionString", $DatabaseSecondaryConnectionString)
            }        
        }        
    }

    if(![string]::IsNullOrEmpty($DatabaseFilePath))
    {
        #if this is a shared database server configuration - then DatabaseFilePath parameter is not supported
        if( !$isDedicatedHAConfig)
        {
            $error = Get-ResourceString SharedServerConnStringDoNotSetDbFilePath
            Write-Error $error
            return
        }
        else
        {
            if($isWin10OrLater)
            {
                #for Windows 2016 and later deployments, we do not requore the admin to specify the .mdf file
                if(![System.IO.Path]::HasExtension($DatabaseFilePath))
                {
                    $otherParams.Add("DatabaseFilePath", $DatabaseFilePath)
                } 
                else
                {
                    Write-Error (Get-ResourceString InvalidSqlFilePath $DatabaseFilePath)
                    return
                }
            }
            else
            {
                #for legacy OS deployments, we require the admin to provide the .mdf file
                if([System.IO.Path]::HasExtension($DatabaseFilePath))
                {
                    $otherParams.Add("DatabaseFilePath", $DatabaseFilePath)
                } 
                else
                {
                    Write-Error (Get-ResourceString InvalidSqlFilePath $DatabaseFilePath)
                    return
                }
            }
         }  
    }
    
    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None  
    
    # Parameter validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::ConfigureHighAvailability, 
                            $null,
                            0, 
                            $ConnectionBroker,
                            [ref]$FailedServers,
                            $otherParams)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
        Write-Error $error
        return
    }
    
    # Resolve ClientAcessName and ask user consent if not valid DNS
    
    # Call workflow

    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

    Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $DatabaseConnectionString, $DatabaseSecondaryConnectionString, $DatabaseFilePath, $ClientAccessName)`
    {         
        param($ConnectionBroker, $DatabaseConnectionString, $DatabaseSecondaryConnectionString, $DatabaseFilePath, $ClientAccessName)
        RDManagement\Set-RDMSHighAvailability -RDMSServer $ConnectionBroker -ConnectionString $DatabaseConnectionString -SecondaryConnectionString $DatabaseSecondaryConnectionString -DatabaseFilePath $DatabaseFilePath -DnsRRName $ClientAccessName
    } -ErrorVariable HAError -WarningAction SilentlyContinue | Out-Null

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    } 
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-ActiveManagementServer {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254055")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $ManagementServer
)

    $error = $null

    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    # Parameter validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::SetActiveManagementServer, 
                            $null,
                            0, 
                            $ManagementServer,
                            [ref]$FailedServers)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
        Write-Error $error
        return
    }
    
    Invoke-Command -ComputerName $ManagementServer {Invoke-WmiMethod -Path ROOT\cimv2\rdms:Win32_RDMSEnvironment -Name SetActiveServer} | Out-Null
    
    $newActiveManagementServer = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::GetActiveManagementServer($ManagementServer)

    if ([System.String]::Equals($ManagementServer, $newActiveManagementServer, [System.StringComparison]"InvariantCultureIgnoreCase"))
    {
        return
    }
    else
    {
        return
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-ClientAccessName {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254056")]
param (

    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $ConnectionBroker,

    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $ClientAccessName
)

    $error = $null

    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'
    $otherParams.Add("ClientAccessName", $ClientAccessName);

    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }    

    # Parameter validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::SetClientAccessName, 
                            $null,
                            0, 
                            $ConnectionBroker,
                            [ref]$FailedServers,
                            $otherParams)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
        Write-Error $error
        return
    }

    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
    Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $ClientAccessName)`
    {     
        param($ConnectionBroker, $ClientAccessName)
        RDManagement\Set-DNSRR -ManagementServer $ConnectionBroker -DnsRRName $ClientAccessName -WarningAction SilentlyContinue
    } | Out-Null

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }
        
    return    
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-DatabaseConnectionString {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254057")]
param (

    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $DatabaseConnectionString,

    [Parameter(Mandatory=$false, Position=1)]
    [String]
    $DatabaseSecondaryConnectionString,

    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $ConnectionBroker,

    [Parameter(Mandatory=$false, Position=3)]
    [switch]
    $RestoreDatabaseConnection,
    
    [Parameter(Mandatory=$false, Position=4)]
    [switch]
    $RestoreDBConnectionOnAllBrokers

)

    $error = $null
    #indicates weather we update on the specified broker only, or we run the cmdlet to update ConnStrings on all.

    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }    

    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'

    $isWin10OrLater = Test-IsWindows10OrLater($ConnectionBroker)
    #check if the brtoker is HA configure, then see what type: shared or dedicated
    if([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsHighAvailabilityConfigured($ConnectionBroker))
    {
        $isDedicatedHAConfig = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker)
    }
    else
    {
        $error = (Get-ResourceString BrokerIsNotHAConfigured $ConnectionBroker)
        Write-Error $error
        return  
    }    

    #if is dedicated database server (windows authentication) configuration DatabaseConnectionString cannot be null or empty 
    if($isDedicatedHAConfig -and ([string]::IsNullOrEmpty($DatabaseConnectionString)))
    {
        $error = Get-ResourceString InvalidDatabaseConnStr
        Write-Error $error
        return
    } 

    if(!([string]::IsNullOrEmpty($DatabaseConnectionString)))
    {
        # connection string should be in the correct format, with Windows Authentication or SQL authentication specified
        $isConnStringWinAuth = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker, $DatabaseConnectionString)
    }

    #if it is dedicated database server configuration - then the connection string should be in teh correct format, with Windows Authentication specified
    if($isDedicatedHAConfig -and !$isConnStringWinAuth)
    {
        $error = Get-ResourceString DedicatedDatabaseConnStrFormatError
        Write-Error $error
        return
    }

    if(!$isDedicatedHAConfig -and $isConnStringWinAuth)
    {
        $error = Get-ResourceString SharedDatabaseConnStrFormatError
        Write-Error $error
        return
    }

    if(!$isWin10OrLater )
    {
        #for legacy OS version (Windows 2012 R2 and Windows 2012) $DatabaseConnectionString should be given
        if([string]::IsNullOrEmpty($DatabaseConnectionString))
        {
            $error = Get-ResourceString InvalidDatabaseConnStr
            Write-Error $error
            return
        }
        #if the connection broker is legacy (Windows 2012 R2 or Windows 2012) - this parameter is not supported.  
        if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
        {
           $error = (Get-ResourceString SecondaryDBConnStringLegacyOSNotSupported $ConnectionBroker)
           Write-Error $error
           return
        } 
        
        if($RestoreDatabaseConnection)
        {
            #if the connection broker is legacy (Windows 2012 R2 or Windows 2012) - this parameter is not supported.        
            $error =(Get-ResourceString RestoreDatabaseConnectionLegacyOSNotSupported $ConnectionBroker)       
            Write-Error $error
            return
        }    

        if($RestoreDBConnectionOnAllBrokers)
        {
            #if the connection broker is legacy (Windows 2012 R2 or Windows 2012) - this parameter is not supported.        
            $error =(Get-ResourceString RestoreDatabaseConnectionOnAllBrokersNotSupported $ConnectionBroker)       
            Write-Error $error
            return            
        }
        
        #check if the -DatabaseConnectionString parameter is for shared database server and legacy OS      
        if( !$isDedicatedHAConfig)
        {
            $error = (Get-ResourceString SharedDatabaseServerOnLegacyOSNotSupported $ConnectionBroker)
            Write-Error $error
            return
        }   
    }  
    else
    {
        #check if -RestoreDatabaseConnection parameter was given with -RestoreDBConnectionOnAllBrokers - for Windows 2016 and later OS versions
        if($RestoreDBConnectionOnAllBrokers)
        {
            if($RestoreDatabaseConnection)
            {
                $onSpecifiedBrokerOnly = $false
            }
            else
            {
                $error = Get-ResourceString RestoreOnAllBrokersWithoutRestoreDBConnString
                Write-Error $error
                return
            }        
        }
        else
        {
            $onSpecifiedBrokerOnly = $true
        }    

        #if it is not shared database(SQL/database authentication) configuration DatabaseSecondaryConnectionString is not supported
        if($isDedicatedHAConfig)
        {
             if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
             {            
                $error = Get-ResourceString DoNotSetSecondaryDatabaseConnStr
                Write-Error $error
                return
             }
        }
        else
        {
             if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
             {            
                # connection string should be in the correct format, with SQL authentication specified, as it is supported only on shared database configuration
                $isSecondaryConnStringWinAuth = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker, $DatabaseSecondaryConnectionString)

                if($isSecondaryConnStringWinAuth)
                {
                    $error = Get-ResourceString SharedDatabaseConnStrFormatError
                    Write-Error $error
                    return
                }
             }            
        }

        # at least one connection string should be provided
        if(([string]::IsNullOrEmpty($DatabaseConnectionString)) -and ([string]::IsNullOrEmpty($DatabaseSecondaryConnectionString)))
        {
            $error = Get-ResourceString BothConnStringNullErr
            Write-Error $error
            return
        }  

        #check that the database name matches
        $matchDB = Test-DatabaseNameMatch -ConnectionBroker $ConnectionBroker -DatabaseConnectionString $DatabaseConnectionString -DatabaseSecondaryConnectionString $DatabaseSecondaryConnectionString
        if(!$matchDB)
        {
            $error = Get-ResourceString NotMatchingDatabaseNameErr
            Write-Error $error
            return
        }
    }
    

    if($RestoreDatabaseConnection)
    {        
        if($onSpecifiedBrokerOnly)
        {
            $result = Update-DBConnStringNoDatabaseAccess -ConnectionBroker $ConnectionBroker -DatabaseConnectionString $DatabaseConnectionString -DatabaseSecondaryConnectionString $DatabaseSecondaryConnectionString -OnSpecifiedBrokerOnly
        }
        else
        {
            $result = Update-DBConnStringNoDatabaseAccess -ConnectionBroker $ConnectionBroker -DatabaseConnectionString $DatabaseConnectionString -DatabaseSecondaryConnectionString $DatabaseSecondaryConnectionString
        }     
    }
    else
    {
        $result = Update-DBConnStringWithDatabaseAccess -ConnectionBroker $ConnectionBroker -DatabaseConnectionString $DatabaseConnectionString -DatabaseSecondaryConnectionString $DatabaseSecondaryConnectionString
    }

    if(!$result)
    {
        $error = Get-ResourceString ConnStringResetFailed
        Write-Error $error
        return
    }

    return
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
#need to update the help link ID (254057) once we update the help doc
function Remove-DatabaseConnectionString {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254057")]
param (

    [Parameter(ParameterSetName="DatabaseConnectionString", Mandatory=$true)]
    [switch]
    $DatabaseConnectionString,

    [Parameter(ParameterSetName="DatabaseSecondaryConnectionString", Mandatory=$true)]
    [switch]
    $DatabaseSecondaryConnectionString,

    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force

)

    $error = $null

    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'

      
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }   
    
    #check if the connection broker is legacy (Windows 2012 R2 or Windows 2012) - this cmdlet is not supported on legacy Windows OS.
    $isWin10OrLater = Test-IsWindows10OrLater($ConnectionBroker)
    if(!$isWin10OrLater)
    {
         $error =(Get-ResourceString LegacyOSNotSupported $ConnectionBroker)
         Write-Error $error
         return
    }

    #if it is not shared database(SQL/database authentication) configuration deleting DatabaseSecondaryConnectionString is not supported
    if([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker))
    {           
            $error = Get-ResourceString RemoveConnStringOnDedicatedDBServer
            Write-Error $error
            return
    }

    #get the secondary database connection string that we will remove from all brokers in the deployment
    $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    #check if it is NULL or empty ans show a message
    if([string]::IsNullOrEmpty($SbServiceProp.SBDbSecondaryConnectionString))
    {
        $error = Get-ResourceString SecondaryConnectionStringNotSet
        Write-Debug $error
        return
    }
  
    try
    {
        # check the db connection string to be removed
        switch ($PsCmdlet.ParameterSetName)
        {
            "DatabaseConnectionString"
            {
                $error = Get-ResourceString RemovePrimaryConnStringNotSupported
                Write-Error $error
                return
            }

            "DatabaseSecondaryConnectionString"
            {

             $RemoveRDSecondaryDBConnectionStringMessageWhatif = (Get-ResourceString RemoveRDSessionCollectionServerMessageWhatif $SbServiceProp.SBDbSecondaryConnectionString)
             $RemoveRDSecondaryDBConnectionStringCaption = (Get-ResourceString RemoveRDSecondaryDBConnectionStringCaption)
             $RemoveRDSecondaryDBConnectionStringMessage = (Get-ResourceString RemoveRDSecondaryDBConnectionStringMessage $SbServiceProp.SBDbSecondaryConnectionString)
             if( -not ($PSCmdlet.ShouldProcess($RemoveRDSecondaryDBConnectionStringMessageWhatif, $RemoveRDSecondaryDBConnectionStringMessage, $RemoveRDSecondaryDBConnectionStringCaption)) )
             {
                return
             }

             if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue( $RemoveRDSecondaryDBConnectionStringMessage, $RemoveRDSecondaryDBConnectionStringCaption)) )
             {
                return
             }
               
                $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER
                $oldDbSecondaryConnStringList = New-Object 'System.Collections.Generic.Dictionary[String,Object]'
                foreach ($broker in $brokerList) 
                {
                    Write-Debug ("Broker = " + $broker.Server)

                    $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker.Server -Authentication PacketPrivacy -ErrorAction Stop

                    if($SbServiceProp.SBDbSecondaryConnectionString)
                    {               
                        $oldDbSecondaryConnString = $SbServiceProp.SBDbSecondaryConnectionString
                        $SbServiceProp.DeleteSBDbConnectionString($true) | Out-Null
                        $oldDbSecondaryConnStringList.Add($broker.Server, $oldDbSecondaryConnString)
                    } 
                }     
            }
        }
        #update connections strings in RDMS database (only on the active broker)
        $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
        $OldRdmsSecondaryConnStr = $wmic.GetSecondaryConnectionString().SecondaryConnectionString

        $wmic.RemoveDeploymentSetting('DatabaseSecondaryConnectionString') | Out-Null
    }
    catch
    {
        Write-Error $_.Exception.Message        

        # Reset values in case of failure
        foreach ($broker in $oldDbSecondaryConnStringList.Keys) 
        {
            Write-Debug ("Resetting Broker = " + $broker)

            $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker -Authentication PacketPrivacy -ErrorAction SilentlyContinue
            if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
            {
               $SbServiceProp.SBDbSecondaryConnectionString = $oldDbSecondaryConnStringList[$broker]               
               $SbServiceProp.Put() | Out-Null
            }
        }
        #reset values for RDMS as well (on active broker only)
        $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
        if(![string]::IsNullOrEmpty($OldRdmsSecondaryConnStr))
        {        
            $wmic.SetSecondaryConnectionString($OldRdmsSecondaryConnStr) | Out-Null
        }
    }
    finally
    {
    }

    return
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-ConnectionBrokerHighAvailability {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254058")]
[OutputType("Microsoft.RemoteDesktopServices.Common.RDCBHADetails")]
param (

    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $ConnectionBroker)
    
    $error = $null

    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None
    
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }    
    
    # Parameter validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::GetHighAvailabilityDetails, 
                            $null,
                            0, 
                            $ConnectionBroker,
                            [ref]$FailedServers)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
       $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
       Write-Error $error
       return
    }

    $haConfigInfo = [Microsoft.RemoteDesktopServices.Common.DeploymentModel]::GetDeploymentHighAvailabilityProperties($ConnectionBroker)

    $isWin10OrLater = Test-IsWindows10OrLater($ConnectionBroker)
    $haConfigData = $null

    if($haConfigInfo -ne $null)
    {
         #format the data for display
        $haConfigData = new-object psobject

        Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name ConnectionBroker -Value $haConfigInfo.ConnectionBroker
        Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name ActiveManagementServer -Value $haConfigInfo.ActiveManagementServer
        Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name ClientAccessName -Value $haConfigInfo.ClientAccessName
        Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name DatabaseConnectionString -Value $haConfigInfo.DatabaseConnectionString

        #check the HA configuration: dedicated or shared database server
        if([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker))
        {       
           Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name DatabaseFilePath -Value $haConfigInfo.DatabaseFilePath
           if($isWin10OrLater)
           {
             Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name DatabaseSecondaryConnectionString -Value $null
           }          
        }
        else
        {
            #SecondaryConnectionString is supported only on Windows 2016 and later deployments
            if($isWin10OrLater)
            {
                Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name DatabaseSecondaryConnectionString -Value $haConfigInfo.DatabaseSecondaryConnectionString
                Add-Member -InputObject $haConfigData -MemberType NoteProperty -Name DatabaseFilePath -Value $null
            }           
        }   
    }     

   $haConfigData
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktopTemplateExportPath {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254059")]
[OutputType([String])]
param(
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    $out = Invoke-WmiMethod -Class Win32_RDMSDeploymentSettings -Name GetExportPath `
                -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Namespace "root\cimv2\rdms"

    if ($out.ReturnValue -eq 0)
    {
        Write-Debug "Win32_RDMSDeploymentSettings::Get-DeploymentExportLocation method executed successfully."
        return $out.DirectoryPath
    }
    else
    {
        Write-Error (Get-ResourceString DeploymentExportLocationQueryFailed $out.ReturnValue)
        return $null
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-VirtualDesktopTemplateExportPath {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254060")]
param(
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$true)]
    [string]
    $Path
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    $found = test-path $Path

    if ($found -eq $true)
    {
        $out = Invoke-WmiMethod -Class Win32_RDMSDeploymentSettings -Name SetExportPath  -ArgumentList ($Path) `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Namespace "root\cimv2\rdms"

        if($out.ReturnValue -eq 0)
        {
            Write-Verbose (Get-ResourceString SetDeploymentExportLocationSuccess $Path)
        }
        else
        {
            Write-Error (Get-ResourceString SetDeploymentExportLocationFailed $out.ReturnValue)
        }
    }
    else
    {
        Write-Error (Get-ResourceString InvalidPath $Path)
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Test-OUAccess {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254061")]
param(

    [Parameter(Mandatory=$false)]
    [string]
    $Domain,

    [Parameter(Mandatory=$true)]
    [string]
    $OU,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if (Test-LocalUser)
    {
        Write-Error(Get-ResourceString InvalidLocalUser)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    if(-not $Domain)
    {
        $Domain = Get-RDManagementServerDomain($ConnectionBroker)
        if(-not $Domain)
        {
            Write-Error (Get-ResourceString FailedToGetComputerObject $ConnectionBroker)
            return
        }
    }

    # Validate OU

    $distinguishedName = Get-DistinguishedName $Domain $OU

    if ($distinguishedName -eq $null)
    {
        Write-Error (Get-ResourceString InvalidDomainOrOU ($Domain, $OU))
        return
    }

    Write-Debug ("OU Validated. DistinguishedName = " + $distinguishedName)

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    $returnValue=$true
    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        foreach ($broker in $brokerList) {

            Write-Debug ("Broker = " + $broker.Server)
            $netbiosName = ""
            $domainName = ""
            [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetNetbiosAndDomainFromJoinedNode($ConnectionBroker, $broker.Server, [ref]$netbiosName, [ref]$domainName)
            $adObjectName = $domainName + "\" + $netbiosName

            $out = Invoke-Command -Session $workflowSession -ArgumentList @($distinguishedName, $adObjectName) `
            {
                param($dn, $adObjectName)
                RDManagement\Test-OUAccess -ContainerName $dn -ComputerName $adObjectName
            }

            if (($out) -and ($out[0] -eq 0) -and ($out[1]))
            {
                Write-Verbose (Get-ResourceString TestOUAccessSuccess ($distinguishedName, $broker.Server))
                $returnValue = ($returnValue -and $true)
            }
            else
            {
                if(($out) -and (0 -ne $out[0]))
                {
                    Write-Verbose ("Error: "+$out[0])
                }
            
                Write-Verbose (Get-ResourceString FailedToTestOUAccess ($distinguishedName, $broker.Server))
                $returnValue=$false
            }
        }
    }
    catch
    {
        Write-Error $_.Exception.Message        
    }
    finally
    {
        if($workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
    return $returnValue
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Grant-OUAccess {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254062")]
param(

    [Parameter(Mandatory=$false)]
    [string]
    $Domain,

    [Parameter(Mandatory=$true)]
    [string]
    $OU,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if (Test-LocalUser)
    {
        Write-Error(Get-ResourceString InvalidLocalUser)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    if(-not $Domain)
    {
        $Domain = Get-RDManagementServerDomain($ConnectionBroker)
        if(-not $Domain)
        {
            Write-Error (Get-ResourceString FailedToGetComputerObject $ConnectionBroker)
            return
        }
    }

    # Validate OU
    $distinguishedName = Get-DistinguishedName $Domain $OU

    if ($distinguishedName -eq $null)
    {
        Write-Error (Get-ResourceString InvalidDomainOrOU ($Domain, $OU))
        return
    }

    Write-Debug ("OU Validated. DistinguishedName = " + $distinguishedName)

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        foreach ($broker in $brokerList) {

            Write-Debug ("Broker = " + $broker.Server)
            $netbiosName = ""
            $domainName = ""
            [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetNetbiosAndDomainFromJoinedNode($ConnectionBroker, $broker.Server, [ref]$netbiosName, [ref]$domainName)
            $adObjectName = $domainName + "\" + $netbiosName

            $out = Invoke-Command -Session $workflowSession -ArgumentList @($distinguishedName, $adObjectName) `
            {
                param($dn, $adObjectName)
                RDManagement\Grant-OUAccess -ContainerName $dn -ComputerName $adObjectName
            }

            if ($out -eq 0)
            {
                Write-Debug "Grant-OUAccess workflow executed successfully."

                Write-Verbose (Get-ResourceString GrantOUAccessSuccess ($distinguishedName, $broker.Server))
            }
            else
            {
                Write-Error (Get-ResourceString FailedToGrantOUAccess ($distinguishedName, $broker.Server, $out))
            }
        }
    }
    catch
    {
        Write-Error $_.Exception.Message        
    }
    finally
    {
        if($workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
}
