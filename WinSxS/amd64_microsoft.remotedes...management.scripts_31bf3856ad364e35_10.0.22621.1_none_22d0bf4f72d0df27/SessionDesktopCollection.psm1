
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\Common.psm1

function Test-RDSHPersonalCollection{
param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)

    #
    # Caller must verify connection broker

    #
    #verify that collection exists
    try
    {
        $personalColl = Get-WmiObject "Win32_RDSHCollection" -Namespace "root\cimv2\Rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $personalColl)
    {
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return $false
    }

    #
    # verify type of collection is personal
    if( ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_MANUAL_PERSONAL_SESSION.value__ -ne $personalColl.Type) -and 
        ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_AUTO_PERSONAL_SESSION.value__ -ne $personalColl.Type) )
    {
        Write-Error (Get-ResourceString CollectionNotPersonalPool)
        return $false
    }

    return $true
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-SessionHost {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDServer[]")]
param (

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

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

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $rdshCollection = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if ( $rdshCollection -eq $null )
    {
        Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        return
    }

    try
    {
        $wmiNamespace = "root\cimv2\rdms"
        $wmiRDSHServerQuery = "SELECT * FROM Win32_RDSHServer WHERE CollectionAlias='" + $rdshCollection.Alias + "'"
        $rdshServers = Get-WmiObject -Namespace $wmiNamespace -Query $wmiRDSHServerQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
    }

    if ( $rdshServers -eq $null )
    {
        return
    }

    foreach ($rdshServer in $rdshServers)
    {

        try
        {
            $res = $rdshServer.GetInt32Property("DrainMode")
        }
        catch
        {
            Write-Error (Get-ResourceString ErrorWmiDrainModeRDSessionHost $rdshServer.Name, $_.Exception.Message)
            continue
        }

        if ($null -ne $res -and 0 -ne $res.ReturnValue)
        {
            Write-Error (Get-ResourceString ErrorWmiDrainModeRDSessionHost $rdshServer.Name, $res.ReturnValue)
            continue
        }

        if ($null -ne $res -and 0 -eq $res.ReturnValue)
        {
            $NewConnectionAllowed = $res.Value -as [Microsoft.RemoteDesktopServices.Management.RDServerNewConnectionAllowed]
        }

        New-Object Microsoft.RemoteDesktopServices.Management.RDServer `
           -ArgumentList $CollectionName, $rdshServer.Name, $NewConnectionAllowed
    }        
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-SessionHost
{
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [string[]]
    $SessionHost,

    [Parameter(Mandatory=$true, Position=1)]
    [Microsoft.RemoteDesktopServices.Management.RDServerNewConnectionAllowed]
    $NewConnectionAllowed,

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

    foreach ($rdshServerName in $SessionHost)
    {
        if(-not (Test-Fqdn($rdshServerName)))
        {
            Write-Error (Get-ResourceString InvalidFqdn $rdshServerName)
            return
        }
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $ValidSessionHostNames = New-Object System.Collections.Generic.List[string]
    $ValidSessionHost = New-Object System.Collections.Generic.List[System.Management.ManagementObject]
    $wmiNamespace = "root\cimv2\rdms"
    foreach ($rdshServerName in $SessionHost)
    {
        $rdshServer = $null
        try
        {
            $wmiRDSHServerQuery = "SELECT * FROM Win32_RDSHServer WHERE Name='" + $rdshServerName + "'"
            $rdshServer = Get-WmiObject -Namespace $wmiNamespace -Query $wmiRDSHServerQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
        }

        if ( $rdshServer -eq $null )
        {
            Write-Error (Get-ResourceString RDSHNotFound $rdshServerName)
        }
        else
        {
            $ValidSessionHostNames.Add($rdshServerName)
            $ValidSessionHost.Add($rdshServer)
        }
    }

    if ( $ValidSessionHostNames.Count -gt 0 )
    {
        # Make sure we can safely make changes on these servers
        try
        {
            Test-RDSessionHostOnline -SessionHost $ValidSessionHost
        }
        catch
        {
            Write-Error $_
            return
        }

        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $ValidSessionHostNames, $NewConnectionAllowed) `
            {
                param($ConnectionBroker, $SessionHost, $NewConnectionAllowed)
                RDManagement\Set-RDSHServerSetting -RDManagementServer $ConnectionBroker -Name $SessionHost -DrainMode $NewConnectionAllowed
            } | Out-Null
        }
        finally
        {   
            if($null -ne $workflowSession)
            {
                Remove-PSSession -Session $workflowSession
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-SessionHost
{

[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [string[]]
    $SessionHost,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force

)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    foreach ($rdshServerName in $SessionHost)
    {
        if(-not (Test-Fqdn($rdshServerName)))
        {
            Write-Error (Get-ResourceString InvalidFqdn $rdshServerName)
            return
        }
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $RemoveRDSessionCollectionServerCaption       =   (Get-ResourceString RemoveRDSessionCollectionServerCaption)
    $RemoveRDSessionCollectionServerMessage       =   (Get-ResourceString RemoveRDSessionCollectionServerMessage $CollectionName)
    $RemoveRDSessionCollectionServerMessageWhatif =   (Get-ResourceString RemoveRDSessionCollectionServerMessageWhatif $CollectionName)
 
    if( -not ($PSCmdlet.ShouldProcess($RemoveRDSessionCollectionServerMessageWhatif, $RemoveRDSessionCollectionServerMessage, $RemoveRDSessionCollectionServerCaption)) )
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue("", "")) )
    {
        return
    }

    $ValidSessionHost = New-Object System.Collections.Generic.List[string]
    $wmiNamespace = "root\cimv2\rdms"
    foreach ($rdshServerName in $SessionHost)
    {
        $rdshServer = $null
        try
        {
            $wmiRDSHServerQuery = "SELECT * FROM Win32_RDSHServer WHERE Name='" + $rdshServerName + "'"
            $rdshServer = Get-WmiObject -Namespace $wmiNamespace -Query $wmiRDSHServerQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
        }

        if ( $rdshServer -eq $null )
        {
            Write-Error (Get-ResourceString RDSHNotFound $rdshServerName)
        }
        else
        {
            $ValidSessionHost.Add($rdshServerName)
        }
    }

    if ( $ValidSessionHost.Count -gt 0 )
    {
        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $ValidSessionHost) `
            {
                param($ConnectionBroker, $SessionHost)
                RDManagement\Remove-RDSessionHost -RDManagementServer $ConnectionBroker -RDSHServer $SessionHost
            } | Out-Null
        }
        finally
        {   
            if($null -ne $workflowSession)
            {
                Remove-PSSession -Session $workflowSession -Confirm:$false
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Add-SessionHost 
{
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param (

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string[]]
    $SessionHost,

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

    foreach ($rdshServerName in $SessionHost)
    {
        if(-not (Test-Fqdn($rdshServerName)))
        {
            Write-Error (Get-ResourceString InvalidFqdn $rdshServerName)
            return
        }
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }
    
    $rdshCollection = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if ( $rdshCollection -eq $null )
    {
        Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        return
    }


    $IsPersonalCollection = $false
    $IsGrantUserAdmin = $false

    if( ([uint32][Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_MANUAL_PERSONAL_SESSION.value__ -eq $rdshCollection.Type) -or
        ([uint32][Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_AUTO_PERSONAL_SESSION.value__ -eq $rdshCollection.Type) )
    {
        $IsPersonalCollection = $true
        $IsGrantUserAdmin = $rdshCollection.GetInt32Property("IsUserAdmin").Value
    }

    $ValidSessionHost = New-Object System.Collections.Generic.List[string]
    $wmiNamespace = "root\cimv2\rdms"
    foreach ($rdshServerName in $SessionHost)
    {
        $rdshServer = $null
        try
        {
            $wmiRDSHServerQuery = "SELECT * FROM Win32_RDSHServer WHERE Name='" + $rdshServerName + "'"
            $rdshServer = Get-WmiObject -Namespace $wmiNamespace -Query $wmiRDSHServerQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
        }

        if ( $rdshServer -eq $null )
        {
            Write-Error (Get-ResourceString RDSHNotFound $rdshServerName)
        }
        elseif (-not [string]::IsNullOrEmpty($rdshServer.CollectionAlias))
        {
            Write-Error (Get-ResourceString RDSHAlreadyExistInCollection $rdshServerName)
        }
        elseif( ($IsGrantUserAdmin -eq $true) -and ($IsPersonalCollection -eq $true) -and (-not (Test-ServerSupportPersonalDesktopCollection -Server $rdshServerName)))
        {
            # Allow downlevel RDSH to join Personal Session Collection
            Write-Error (Get-ResourceString RDSHServerNotThreshold $rdshServerName )
        }
        else
        {
            $ValidSessionHost.Add($rdshServerName)
        }
    }    

    if ( $ValidSessionHost.Count -gt 0 )
    {
        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $rdshCollection.Alias, $ValidSessionHost, $IsPersonalCollection) `
            {
                param($ConnectionBroker, $CollectionAlias, $SessionHost, $IsPersonalCollection)
                RDManagement\Add-RDSessionHost -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias -RDSHServer $SessionHost -PersonalSessionCollection $IsPersonalCollection
            } | Out-Null
        }
        finally
        {   
            if($null -ne $workflowSession)
            {
                Remove-PSSession -Session $workflowSession -Confirm:$false
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-SessionCollection {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionCollection[]")]
param (

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

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

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    try
    {
        $wmiNamespace = "root\cimv2\rdms"
        
        $cimSessionOption = New-CimSessionOption -PacketPrivacy
        $cimSession = New-CimSession -ComputerName $ConnectionBroker -SessionOption $cimSessionOption
        
        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions
        $options.ShortenLifetimeOfResults = $true

        $wmiClass = "Win32_RDSHCollection"        
        $rdSessionCollections = $cimSession.EnumerateInstances($wmiNamespace, $wmiClass, $options)
    }
    catch
    {
        Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
    }

    if ( $rdSessionCollections -eq $null )
    {
        if ($PSBoundParameters["CollectionName"])
        {
            Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        }
        return
    }

    $ResourceTypeUnknown = (Get-ResourceString ResourceTypeUnknown)
    $ResourceTypeRemoteApp = (Get-ResourceString ResourceTypeRemoteApp)
    $ResourceTypeRemoteDesktop = (Get-ResourceString ResourceTypeRemoteDesktop)

    $enumOptions = New-Object System.Management.EnumerationOptions
    $enumOptions.Rewindable = $false
    $enumOptions.ReturnImmediately = $true

    $connectionOptions = new-object System.Management.ConnectionOptions
    $connectionOptions.Authentication=[System.Management.AuthenticationLevel]::PacketPrivacy
    
    $scope = New-Object System.Management.ManagementScope(("\\" + $ConnectionBroker + "\" + $wmiNamespace), $connectionOptions)

    foreach ($rdSessionCollection in $rdSessionCollections)
    {

        # default or error case value
        $rdSessionServerCount = 0
        $RdSessionResurceType = $ResourceTypeRemoteApp
        try
        {
            $wmiQuery = "SELECT * FROM Win32_RDSHServer WHERE CollectionAlias='" + $rdSessionCollection.Alias + "'"
            
            $query = New-Object System.Management.ObjectQuery $wmiQuery
            $results = New-Object System.Management.ManagementObjectSearcher $scope, $query, $enumOptions
            $items = $results.Get()
            $rdSessionServerCount = $items.Count 
        }
        catch
        {
            Write-Warning (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
        }

        try
        {
            $wmiRemoteAppQuery = "SELECT * FROM Win32_RDMSPublishedApplication WHERE PoolName='" + $rdSessionCollection.Alias + "'"
            
            $query = New-Object System.Management.ObjectQuery $wmiRemoteAppQuery
            $results = New-Object System.Management.ManagementObjectSearcher $scope, $query, $enumOptions
            $items = $results.Get()
            $rdRemoteAppCount = $items.Count 

            if ( $rdRemoteAppCount -eq 0 )
            {
                $RdSessionResurceType = $ResourceTypeRemoteDesktop
            }
        }
        catch
        {
            Write-Warning (Get-ResourceString GetRemoteAppsWmiError $_.Exception.Message)
            $RdSessionResurceType = $ResourceTypeUnknown
        }

        $AutoAssignDesktop = $false
        $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::Unknown
        $GrantAdminPrivilege = $false

        if($rdSessionCollection.Type -eq $null)
        {
            $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PooledUnmanaged
        }
        elseif( [Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_MANUAL_PERSONAL_SESSION.value__ -eq $rdSessionCollection.Type ) 
        {
            $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PersonalUnmanaged
            $GrantAdminPrivilege = $rdSessionCollection.GetInt32Property( "IsUserAdmin" ).Value

        }
        elseif ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_AUTO_PERSONAL_SESSION.value__ -eq $rdSessionCollection.Type )
        {
            $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PersonalUnmanaged
            $AutoAssignDesktop = $true
            $GrantAdminPrivilege = $rdSessionCollection.GetInt32Property( "IsUserAdmin" ).Value

        }
        elseif( [Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_RDSH.value__ -eq $rdSessionCollection.Type )
        {
            $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PooledUnmanaged
        }


        New-Object Microsoft.RemoteDesktopServices.Management.RDSessionCollection `
            -ArgumentList $rdSessionCollection.Name, $rdSessionCollection.Alias, $rdSessionCollection.Description, $rdSessionServerCount, `
                          $RdSessionResurceType, $CollectionType, $AutoAssignDesktop, $GrantAdminPrivilege

    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-SessionCollection 
{

[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param (

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)
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

    $rdSessionCollection = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if ( $rdSessionCollection -eq $null )
    {
        Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        return
    }

    $CollectionAlias = $rdSessionCollection.Alias

    $RemoveRDSessionCollectionCaption       =   (Get-ResourceString RemoveRDSessionCollectionCaption)
    $RemoveRDSessionCollectionMessage       =   (Get-ResourceString RemoveRDSessionCollectionMessage $CollectionName)
    $RemoveRDSessionCollectionMessageWhatif =   (Get-ResourceString RemoveRDSessionCollectionMessageWhatif $CollectionName)

    if( -not ($PSCmdlet.ShouldProcess($RemoveRDSessionCollectionMessageWhatif, $RemoveRDSessionCollectionMessage, $RemoveRDSessionCollectionCaption)) )
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue("", "")) )
    {
        return
    }

    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $CollectionAlias) `
        {
            param($ConnectionBroker, $CollectionAlias)
            RDManagement\Remove-RDSHCollection -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias
        } | Out-Null
    }
    finally
    {   
        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession -Confirm:$false
        }
    }

    $rdSessionCollection = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if ( $rdSessionCollection -ne $null )
    {
        Write-Error (Get-ResourceString ErrorDeletingRDSHCollection $CollectionName)
        return
    }

}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-SessionCollection 
{
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionCollection")]
[CmdletBinding(DefaultParametersetName='PooledSessionCollection')] 
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0, ParameterSetName="PooledSessionCollection")]
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0, ParameterSetName="PersonalSessionCollection")]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$false)]
    [string]
    $CollectionDescription,

    [Parameter(Mandatory=$true)]
    [string[]]
    $SessionHost,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false, ParameterSetName="PooledSessionCollection")]
    [switch]
    $PooledUnmanaged,

    [Parameter(Mandatory=$true, ParameterSetName= "PersonalSessionCollection")]
    [switch]
    $PersonalUnmanaged = $false,

    [Parameter(Mandatory=$false, ParameterSetName= "PersonalSessionCollection")]
    [switch]
    $AutoAssignUser = $false,

    [Parameter(Mandatory=$false, ParameterSetName= "PersonalSessionCollection")]
    [switch]
    $GrantAdministrativePrivilege = $false
)


    $ValidFQDNRDSHServer = New-Object 'System.Collections.Generic.List[String]'
    $ValidRDSHServer = New-Object 'System.Collections.Generic.List[String]'

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    foreach ($rdshServerName in $SessionHost)
    {
        if(-not (Test-Fqdn($rdshServerName)))
        {
            Write-Warning (Get-ResourceString InvalidFqdn $rdshServerName)
        }
        else
        {
            $ValidFQDNRDSHServer.Add($rdshServerName)
        }
    }

    if( $ValidFQDNRDSHServer.Count -eq 0 )
    {
        Write-Error (Get-ResourceString FailedToCreateSessionCollection)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    if(-not (Confirm-CollectionNameDoesNotExist -CollectionName $CollectionName -RDMgmtServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString CannotDetermineCollectionExists)
        return
    }

    # Validate RDSH is not in a collection
    $wmiNamespace = "root\cimv2\rdms"
    foreach ($rdshServerName in $ValidFQDNRDSHServer)
    {
        $rdshServer = $null
        try
        {
            $wmiQuery = "SELECT * FROM Win32_RDSHServer WHERE Name='" + $rdshServerName + "'"; 
            $rdshServer = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            Write-Error (Get-ResourceString ErrorWmiSessionCollectionServer $_.Exception.Message)
        }

        if ( $rdshServer -eq $null )
        {
            Write-Warning (Get-ResourceString RDSHNotFound $rdshServerName)
            continue
        }

        if ( $rdshServer.CollectionAlias -ne $null -and $rdshServer.CollectionAlias -ne "" )
        {
            Write-Warning (Get-ResourceString RDSHAlreadyExistInCollection $rdshServerName)
            continue
        }

        if( ($PersonalSessionCollection -eq $true) -and ($GrantAdministrativePrivilege -eq $true) )
        {
            # Allow downlevel RDSH to join Personal Session Collection
            if( -not (Test-ServerSupportPersonalDesktopCollection -Server $rdshServerName))
            {
                Write-Error( Get-ResourceString RDSHServerNotThreshold $rdshServerName )
                continue
            }
        }

        $ValidRDSHServer.Add( $rdshServerName )
    }

    if( $ValidRDSHServer.Count -eq 0 )
    {
        Write-Error (Get-ResourceString FailedToCreateSessionCollection)
        return
    }

    $params = Get-BoundParameter $PSBoundParameters @{
                        "CollectionName" = "Name"
                        "CollectionDescription" = "Description"
                        "PersonalUnmanaged" = "PersonalSessionCollection"
                        "AutoAssignUser" = "AutoAssignUser"
                        "GrantAdministrativePrivilege" = "GrantAdministrativePrivilege"
                        }

    $params.Add('RDSHServer', $ValidRDSHServer)
   
    $defUserGroup = ConvertTo-NtAccount([microsoft.remotedesktopservices.common.commonutility]::GetCurrentDomainUserSid())
    $params.Add('User',$defUsergroup)


    $CollectionAlias = Get-CollectionAlias -CollectionName $CollectionName -RDManagementServer $ConnectionBroker
    if([string]::IsNullOrEmpty($CollectionAlias))
    {
        Write-Error (Get-ResourceString CannotCreateCollectionAlias)
        return
    }

    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $CollectionAlias, $params) `
        {
            param($ConnectionBroker, $CollectionAlias, $params)
            RDManagement\New-RDSHCollection -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias @params
        } | Out-Null
    }
    finally
    {   
        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }

    $rdSessionCollection = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if ( $rdSessionCollection -eq $null )
    {
        Write-Error (Get-ResourceString ErrorCreatingRDSHCollection)
        return
    }

    $ResourceTypeRemoteDesktop = (Get-ResourceString ResourceTypeRemoteDesktop)
    $GrantAdmin= $False
    $AutoAssignDesktop = $False

    if( ($PersonalUnmanaged -eq $null) -or ($PersonalUnmanaged -eq $false) )
    {
        $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PooledUnmanaged
    }
    else
    {
        $CollectionType = [Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType]::PersonalUnmanaged

        if( ($AutoAssignUser -ne $null) -and ($AutoAssignUser -eq $True) )
        {
            $AutoAssignDesktop = $true
        }

        if( ($GrantAdministrativePrivilege -ne $null) -and ($GrantAdministrativePrivilege -eq $true))
        {
            $GrantAdmin = $true
        }
    }

    New-Object Microsoft.RemoteDesktopServices.Management.RDSessionCollection `
        -ArgumentList $rdSessionCollection.Name, $rdSessionCollection.Alias, $rdSessionCollection.Description, $ValidRDSHServer.Count, $ResourceTypeRemoteDesktop, $CollectionType, $AutoAssignDesktop, $GrantAdmin

}


function Set-PersonalSessionDesktopAssignment{
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $User,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $Name,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return $false
    }

    if ( -not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker) )
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return $false
    }


    #
    #verify user name and get domain and user name
    $sid = ConvertTo-Sid($user)
    if(-not $sid)
    {
        Write-Error (Get-ResourceString InvalidUserName)
        return $false
    }

    $separators=[char[]]('\')
    $userParts = $User.Split($separators)

    if( $userParts.Count -ne 2 )
    {
        #
        # UserName and Domain name is required
        Write-Error (Get-ResourceString InvalidUserName)
        return $false
    }

    $userDomain = $userParts[0]
    $userName = $userParts[1]

    $PDC = Get-RDSHPersonalCollectionFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    if( $PDC -eq $null )
    {
        Write-Error (Get-ResourceString InvalidCollectionOrConnectionBroker $ConnectionBroker, $CollectionName)
        return
    }

    $TargetDesktop = $null

    #
    # Verify target server exists
    try
    {
        $TargetDesktop = Get-WmiObject -Class "Win32_RDSHServer" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                            -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                            -Filter "Name='$Name'"
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    if($null -eq $TargetDesktop)
    {
        Write-Error (Get-ResourceString RDSHNotFound $Name)
        return $false
    }

    #
    # verify server is in right collection
    if([string]::Compare($PDC.Alias, $TargetDesktop.CollectionAlias, $true))
    {
        Write-Error(Get-ResourceString RDSHNotFoundInCollection $Name)
        return $false
    }

    $Alias = $PDC.Alias

    try 
    {
        # Use $Alias instead of PDC.Alias to get right value
        $filterstr = "CollectionAlias='$Alias' AND UserName='$Username' AND UserDomain='$UserDomain'"

        $FoundUser = Get-WmiObject -namespace root\cimv2\rdms  -ComputerName $ConnectionBroker `
                            -class Win32_RDMSDesktopAssignment -Filter $filterstr `
                            -Authentication PacketPrivacy -ErrorAction Stop
        if( $FoundUser -ne $null )
        {
            #
            # user already assign to a desktop, output error even if user alerady assigned to same desktop
            Write-Error(Get-ResourceString UserAlreadyAssignedDesktop $User,$Name)
            return $false
        }
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    try
    {
        $filterstr = "CollectionAlias='$Alias' AND desktopname='$Name'"
        $FoundDesktop = Get-WmiObject -namespace root\cimv2\rdms -ComputerName $ConnectionBroker `
                                    -class Win32_RDMSDesktopAssignment -Filter $filterstr `
                                    -Authentication PacketPrivacy -ErrorAction Stop
        if( $FoundDesktop -ne $null )
        {
            Write-Error(Get-ResourceString DesktopAlreadyAssigned $Name, $FoundDesktop.UserDomain, $FoundDesktop.UserName)
            return $false
        }
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    #
    # Add the assignment
    try
    {
        $AddResult = Invoke-WmiMethod -namespace root\cimv2\rdms -ComputerName $ConnectionBroker `
                                -Class Win32_RDMSDesktopAssignment -Name AddDesktopAssignment -ArgumentList ($PDC.Alias, $Name, $userDomain, $userName) `
                                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop 
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }

    if((-not $AddResult) -or (0 -ne $AddResult.ReturnValue))
    {
        Write-Error (Get-ResourceString FailedToAddDesktopAssignment)
    }
    else
    {
        Write-Verbose (Get-ResourceString SuccessAddDesktopAssignment $User,$Name,$CollectionName )
    }

    return $true
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-PersonalSessionDesktopAssignment{
[CmdletBinding(DefaultParameterSetName="RemoveByUser", SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="RemoveByUser")]
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="RemoveByDesktop")]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true, ParameterSetName="RemoveByUser")]
    [string]
    $User,
    
    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true, ParameterSetName="RemoveByDesktop")]
    [string]
    $Name,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return $false
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return $false
    }

    $userDomain = $null
    $userName = $null

    if( -not [string]::IsNullOrEmpty($User) )
    {
        #
        #verify user name and get domain and user name
        $sid = ConvertTo-Sid($User)
        if(-not $sid)
        {
            Write-Error (Get-ResourceString InvalidUserName)
            return $false
        }

        $separators=[char[]]('\')
        $userParts = $User.Split($separators)

        if( $userParts.Count -ne 2 )
        {
            #
            # UserName and Domain name is required
            Write-Error (Get-ResourceString InvalidUserName)
            return $false
        }

        $userDomain = $userParts[0]
        $userName = $userParts[1]
    }

    $PDC = Get-RDSHPersonalCollectionFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    if( $PDC -eq $null )
    {
        Write-Error (Get-ResourceString InvalidCollectionOrConnectionBroker $ConnectionBroker, $CollectionName)
        return
    }
   

    if( -not [string]::IsNullOrEmpty($Name) )
    {
        #
        # Verify target server exists
        try
        {
            $TargetDesktop = Get-WmiObject -Class "Win32_RDSHServer" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                                -Filter "Name='$Name'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if($null -eq $TargetDesktop)
        {
            Write-Error (Get-ResourceString RDSHNotFound $Name)
            return $false
        }

        #
        # verify server is in right collection
        if([string]::Compare($PDC.Alias, $TargetDesktop.CollectionAlias, $true))
        {
            Write-Error(Get-ResourceString RDSHNotFoundInCollection $Name)
            return $false
        }
    }

    #confirm
    if( (-not [string]::IsNullOrEmpty($User)) -and (-not [string]::IsNullOrEmpty($Name) ) )
    {
        $promptMsg = (Get-ResourceString RemovePersonalDesktopAssignmentMsg1 ($userDomain + '\' + $userName), $Name)
    }
    elseif( (-not [string]::IsNullOrEmpty($User)) )
    {
        $promptMsg = (Get-ResourceString RemovePersonalDesktopAssignmentMsg2 ($userDomain + '\' + $userName))
    }
    else
    {
        $promptMsg = (Get-ResourceString RemovePersonalDesktopAssignmentMsg3 $Name)
    }

    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }
    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    try
    {
        $RemoveResult = Invoke-WmiMethod -namespace root\cimv2\rdms -ComputerName $ConnectionBroker `
                                -Class Win32_RDMSDesktopAssignment -Name RemoveDesktopAssignment -ArgumentList ($PDC.Alias, $Name, $userDomain, $userName) `
                                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop 
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }

    if((-not $RemoveResult) -or (0 -ne $RemoveResult.ReturnValue))
    {
        Write-Error (Get-ResourceString FailedToRemoveDesktopAssignment)
    }
    else
    {
        if( -not [string]::IsNullOrEmpty($User) )
        {
            Write-Verbose (Get-ResourceString SuccessRemoveDesktopAssignment1 $User )
        }
        else
        {
            Write-Verbose (Get-ResourceString SuccessRemoveDesktopAssignment2 $Name )
        }
    }

    return $true
}




function
Get-PersonalSessionDesktopAssignment{
[CmdletBinding(DefaultParameterSetName="GetByCollection",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDPersonalSessionDesktopAssignment[]")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="GetByCollection")]
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="GetByUser")]
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, ParameterSetName="GetByDesktop")]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true, ParameterSetName="GetByUser")]
    [string]
    $User,
    
    [Parameter(Mandatory=$true, ParameterSetName="GetByDesktop")]
    [string]
    $Name,

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

    if ( -not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $userDomain = $null
    $userName = $null

    if( -not [string]::IsNullOrEmpty($User) )
    {
        #
        #verify user name and get domain and user name
        $sid = ConvertTo-Sid($user)
        if(-not $sid)
        {
            Write-Error (Get-ResourceString InvalidUserName)
            return $false
        }

        $separators=[char[]]('\')
        $userParts = $User.Split($separators)

        if( $userParts.Count -ne 2 )
        {
            #
            # UserName and Domain name is required
            Write-Error (Get-ResourceString InvalidUserName)
            return $false
        }

        $userDomain = $userParts[0]
        $userName = $userParts[1]
    }

    $PDC = Get-RDSHPersonalCollectionFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    if( $PDC -eq $null )
    {
        Write-Error (Get-ResourceString InvalidCollectionOrConnectionBroker $ConnectionBroker, $CollectionName)
        return
    }

    if( -not [string]::IsNullOrEmpty($Name) )
    {
        #
        # Verify target server exists
        try
        {
            $TargetDesktop = Get-WmiObject -Class "Win32_RDSHServer" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                                -Filter "Name='$Name'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if($null -eq $TargetDesktop)
        {
            Write-Error (Get-ResourceString RDSHNotFound $Name)
            return $false
        }

        #
        # verify server is in right collection
        if([string]::Compare($PDC.Alias, $TargetDesktop.CollectionAlias, $true))
        {
            Write-Error(Get-ResourceString RDSHNotFoundInCollection $Name)
            return $false
        }
    }

    $filterstr = $null
    $alias = $PDC.Alias

    if( $PSBoundParameters["User"] )
    {
        Write-Verbose ('Getting desktop assignments for user: ' + $User )
        $filterstr = "UserName='$userName' AND UserDomain='$UserDomain'"

    }
    elseif ( $PSBoundParameters["Name"] )
    {
        Write-Verbose ('Getting desktop assignments on the desktop: ' + $Name )
        $filterstr = "DesktopName='$Name'"
    }
    else
    {
        Write-Verbose ('Getting desktop assignments on the collection: ' + $Collection )
        $filterstr = "CollectionAlias='$alias'"
    }

    try
    {
        $DesktopAssignments = Get-WmiObject -namespace root\cimv2\rdms -class Win32_RDMSDesktopAssignment -Filter $filterstr -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

    }
    catch
    {
        Write-Error ($_.Exception)
    }


    if(-not $DesktopAssignments)
    {
        Write-Verbose (Get-ResourceString NoDesktopAssignmentFound)
        return $null
    }

    foreach($assignment in $DesktopAssignments)
    {
        $userAccount= $assignment.UserDomain + '\' + $assignment.UserName
        New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalSessionDesktopAssignment `
                                    -ArgumentList $PDC.Name, $assignment.DesktopName, $userAccount
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Export-PersonalSessionDesktopAssignment {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $path,
    
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

    if( -not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker) )
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    if( -not (Test-RDSHPersonalCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker) )
    {
        Write-Error (Get-ResourceString InvalidCollectionOrConnectionBroker $ConnectionBroker, $CollectionName)
        return
    }

    #make sure file does not exist
    if((Test-FilePath -Path $path -ErrorAction SilentlyContinue))
    {
        Write-Error ('File already exists')
        return
    }

    #make sure the folder exists
    if(-not (Test-FilePath -Path $path -Parent))
    {
        Write-Error (Get-ResourceString InvalidPath $path)
        return
    }

    #get all the assignments in the collection and export to csv file
    $objs = Get-RDPersonalSessionDesktopAssignment -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    
    if( $objs )
    {
        $objs | Export-Csv $path
    }
    else
    {
        Write-Error (Get-ResourceString NoDesktopAssignmentFound )
    }
    return
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Import-PersonalSessionDesktopAssignment {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=390820")]
param(

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $path,
    
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

    if( -not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker) )
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    if( -not (Test-RDSHPersonalCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker) )
    {
        Write-Error (Get-ResourceString InvalidCollectionOrConnectionBroker $ConnectionBroker, $CollectionName)
        return
    }

    #make sure file exists
    if(-not (Test-FilePath -Path $path))
    {
        Write-Error (Get-ResourceString InvalidPath $path)
        return
    }
    
    #import assignments to the collection
    import-csv $path | `
    ForEach-Object{
        Remove-RDPersonalSessionDesktopAssignment -ConnectionBroker $ConnectionBroker -CollectionName $_.CollectionName -User $_.User -Force -ErrorAction SilentlyContinue | out-null
        Set-RDPersonalSessionDesktopAssignment -ConnectionBroker $ConnectionBroker -CollectionName $_.CollectionName -Name $_.DesktopName -User $_.User  | out-null
    }

    #return the assignments
    Get-RDPersonalSessionDesktopAssignment -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
}
