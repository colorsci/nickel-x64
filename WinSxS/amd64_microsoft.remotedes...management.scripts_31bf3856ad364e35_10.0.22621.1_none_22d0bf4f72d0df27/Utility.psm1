Import-LocalizedData -BindingVariable _script_resource -filename Resources.psd1
$_dll_resource = New-Object System.Resources.ResourceManager Microsoft.RemoteDesktopServices.Management.Activities.RDManagementResources

function Get-BoundParameter {

[CmdletBinding(DefaultParametersetName="NoMap")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [object]
    $BoundParameters,
    
    [Parameter(Mandatory=$true, Position=1, ParameterSetName="NoMap")]
    [String[]]
    $ParameterName,
    
    [Parameter(Mandatory=$true, Position=1, ParameterSetName="Map")]
    [Hashtable]
    $ParameterMap
)

    $params = @{}
    
    switch ($PsCmdlet.ParameterSetName)
    {
        "NoMap"     {
                        $ParameterName | ?{$BoundParameters.ContainsKey($_)} | %{$params[$_] = $BoundParameters[$_]}
                        break
                    }
        "Map"     {
                        $ParameterMap.Keys | ?{$BoundParameters.ContainsKey($_)} | %{$params[$ParameterMap[$_]] = $BoundParameters[$_]}
                        break
                    }
    }
    
    return $params
}

function Get-RawResourceString {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $Id
)

    $resourceString = $null

    if ($_script_resource[$Id])
    {
        $resourceString = $_script_resource[$Id]
    }
    else
    {
        $resourceString = $_dll_resource.GetString($Id)
    }

    $resourceString
}

function Get-ResourceString {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $Id,
    
    [Parameter(Mandatory=$false)]
    [object[]]
    $Parameter
)

    $resourceString = Get-RawResourceString($Id)
    $resourceString -f $Parameter
}

function Test-RDManagementServer {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $RDManagementServer,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]
    $Credential
    
)
    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    
    $isRdms = Invoke-Command -ScriptBlock {(Get-Service RDMS -ErrorAction SilentlyContinue) -ne $null} `
                                 -ComputerName $RDManagementServer `
                                 -ErrorAction SilentlyContinue `
                                 @userContext

    if (-not $isRdms)
    {
        Write-Debug (Get-ResourceString RdmsRoleNotInstalled $RDManagementServer)
        return $false
    }
    
    $notRunningServices = Invoke-Command -ScriptBlock {@(Get-Service -Name WinRM, 'MSSQL$MICROSOFT##WID', RDMS, TScPubRPC, WinMgmt | where Status -ne Running | foreach DisplayName) } `
                                            -ComputerName $RDManagementServer `
                                            @userContext
    
    if ($notRunningServices.Count -gt 0)
    {
        Write-Debug (Get-ResourceString RdmsServicesNotRunning ($notRunningServices -join ", "))
        return $false
    }
    
    $rdmsActiveStatus = Invoke-Command  -ScriptBlock {
                                            $wmic = [WMICLASS]"ROOT\cimv2\rdms:Win32_RDMSEnvironment"
                                            $activeServer = $wmic.GetActiveServer().ServerName
                                            
                                            $localServer = [System.Net.Dns]::GetHostEntry("localhost").HostName
                                            
                                            New-Object PSObject -Property @{Active = ($activeServer -eq $localServer); ActiveServer = $activeServer} } `
                                        -ComputerName $RDManagementServer `
                                        @userContext
                                        
    if (-not $RdmsActiveStatus.Active)
    {
        Write-Debug (Get-ResourceString RdmsServerIsNotActive $RdmsActiveStatus.ActiveServer)
        return $false
    }
    
    return $true
}

function Test-SessionDesktopDeployment {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $RDManagementServer,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]
    $Credential,
    
    [switch]
    $IgnoreHealthCheck
)
    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    
    if ((-not $IgnoreHealthCheck) -and (-not (Test-RDManagementServer -RDManagementServer $RDManagementServer @userContext)))
    {
        return $false
    }

    $isWin10OrLater = Test-IsWindows10OrLater($RDManagementServer) 

    try
    {
        $hasRdshServers = $true

        if( $isWin10OrLater )
        {
            $RdshServers = Invoke-WmiMethod -Namespace ROOT\cimv2\rdms -Class Win32_RDMSJoinedNode -Name GetJoinedNodeCount -ArgumentList 2 -ComputerName $RDManagementServer @userContext
            if( ($RdshServers -eq $null) -or ($RdshServers.Count -eq 0) )
            {
                $hasRdshServers = $false
            }
        }
        else
        {
            $hasRdshServers = Invoke-Command  -ScriptBlock { @(Get-WmiObject -Namespace ROOT\cimv2\rdms -Class Win32_RDMSJoinedNode | where IsRdsh).Count -gt 0 } `
                                                -ComputerName $RDManagementServer `
                                                @userContext
        }
        
                                        
        if( -not $hasRdshServers)
        {
            Write-Debug (Get-ResourceString SessionDeploymentDoesNotExist $RDManagementServer)
            return $false
        }

        return $true
    }
    catch
    {
         Write-Debug "RDManagementServer $RDManagementServer exception in Win32_RDMSJoinedNode call"
    }

    
    return $true
}

function Test-VirtualDesktopDeployment {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $RDManagementServer,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]
    $Credential,
    
    [switch]
    $IgnoreHealthCheck
        
)
    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    
    if ((-not $IgnoreHealthCheck) -and (-not (Test-RDManagementServer -RDManagementServer $RDManagementServer @userContext)))
    {
        return $false
    }

     $isWin10OrLater = Test-IsWindows10OrLater($RDManagementServer)

    try
    { 
        if($isWin10OrLater)
        {
            $hasRdvhServers = $true

            $RdvhServers = Invoke-WmiMethod -Namespace ROOT\cimv2\rdms -Class Win32_RDMSJoinedNode -Name GetJoinedNodeCount -ArgumentList 4 -ComputerName $RDManagementServer @userContext
                                            
            if( ($RdvhServers -eq $null) -or ($RdvhServers.Count -eq 0) )
            {
                $hasRdvhServers = $false
            }
        }
        else
        {
            #use old method 
            $hasRdvhServers = Invoke-Command  -ScriptBlock { @(Get-WmiObject -Namespace ROOT\cimv2\rdms -Class Win32_RDMSJoinedNode | where IsRdvh).Count -gt 0 } `
                                        -ComputerName $RDManagementServer `
                                        @userContext
            
        }   
     
                                        
        if( -not $hasRdvhServers)
        {
            Write-Debug (Get-ResourceString VirtualDeploymentDoesNotExist $RDManagementServer)
            return $false
        }
    
        return $true
    }
    catch 
    {
        Write-Debug "RDManagementServer $RDManagementServer exception in Win32_RDMSJoinedNode call"
    }


    return $true
}


function Test-RemoteDesktopDeployment {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $RDManagementServer,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]
    $Credential,
    
    [switch]
    $IgnoreHealthCheck
        
)

    $params = Get-BoundParameter $PSBoundParameters "Credential", "Force"    
    
    if ((-not $IgnoreHealthCheck) -and (-not (Test-RDManagementServer -RDManagementServer $RDManagementServer @params)))
    {
        return $false
    }
    
    if(-not (Confirm-ValidHostname($RDManagementServer)))
    {
        return $false
    }

    $deploymentExists = (Test-VirtualDesktopDeployment -ErrorAction SilentlyContinue -IgnoreHealthCheck -RDManagementServer $RDManagementServer @params) -or `
                        (Test-SessionDesktopDeployment -ErrorAction SilentlyContinue -IgnoreHealthCheck -RDManagementServer $RDManagementServer @params)
                        
    if(-not $deploymentExists)
    {
        Write-Debug (Get-ResourceString DeploymentDoesNotExist $RDManagementServer)
        return $false
    }
    
    return $true
}

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


function Get-RDSHPersonalCollectionFromName {
param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)

    $personalColl = Get-SessionCollectionFromName $CollectionName $ConnectionBroker

    if($null -eq $personalColl)
    {
        return $null
    }

    #
    # verify type of collection is personal
    if( ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_MANUAL_PERSONAL_SESSION.value__ -ne $personalColl.Type) -and 
        ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_AUTO_PERSONAL_SESSION.value__ -ne $personalColl.Type) )
    {
        return $null
    }

    return $personalColl
}

function Test-ServerSupportPersonalDesktopCollection {
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Server
)

    $srv = Get-WmiObject -class Win32_OperatingSystem -ComputerName $Server  -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if( $srv -ne $null -and $srv.Version)
    {
        $separators=[char[]]('.')
        $versionparts = $srv.Version.Split($separators)
        [int]$major = [convert]::ToInt32($versionparts[0], 10)
        [int]$minor = [convert]::ToInt32($versionparts[1], 10)
        [int]$build = [convert]::ToInt32($versionparts[2], 10)

        if($major -ge 10)
        {
            return $true;
        }
    }

    return $false

}

function Test-Fqdn {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $Fqdn
    
)

    $uri = New-Object System.Uri "http://$Fqdn"
    if ($uri.IsAbsoluteUri)
    {
        $uriHost = $uri.Host
        if (($uriHost -eq $Fqdn) -and  $Fqdn.Contains('.') -and (-not $Fqdn.EndsWith('.')) -and ($Fqdn.Length -lt 255))
        {
            return $true
        }
    }
    
    Write-Debug (Get-ResourceString InvalidFqdn $Fqdn)
    return $false
}

function Initialize-Fqdn {

param (

    [Parameter(Mandatory=$false)]
    [string]
    $Fqdn
    
)
    if ((-not $PSBoundParameters["Fqdn"]) -or ([string]::IsNullOrEmpty($Fqdn)))
    {
        return [System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName
    }
    else
    {
        if (Test-Fqdn($Fqdn))
        {
            return $Fqdn
        }
        else
        {
            return $null
        }
    }
}

function Test-FilePath {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $Path,
    
    [switch]
    $Parent,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]
    $Credential
    
)

    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    
    if ($Parent)
    {
        $parentDirectory = Split-Path $Path
        if (-not $parentDirectory) { $parentDirectory = "." }
        if (Test-Path -Path $parentDirectory -ErrorAction SilentlyContinue @userContext)
        {
            return $true
        }
    }
    else
    {
        if (Test-Path -Path $Path -ErrorAction SilentlyContinue @userContext)
        {
            return $true
        }
    }
    
    Write-Debug (Get-ResourceString InvalidPath $Path)
    return $false
}

function Get-CollectionAlias {

param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $RDManagementServer

)
 
    $existingIdList = New-Object System.Collections.Generic.List[string]

    #get list of all the collections and prepare an alias list
    try
    {
        $poolList = Get-WmiObject -Namespace root\cimv2\terminalservices -Class Win32_RDCentralPublishedFarm -ComputerName $RDManagementServer -ErrorAction Stop `
                    -Authentication PacketPrivacy -Impersonation Impersonate
    }
    catch
    {
        Write-Debug $_.Exception
        return $null
    }

    foreach($pool in $poolList)
    {
        $existingIdList.Add($pool.Alias)
    }

    #genrate ID and verify it is not used by an existing collection
    $id = Remove-InvalidCollectionChars($CollectionName)
    $tempId=$id
    for($i=0; $existingIdList.Contains($tempId); $i++)
    {
        $tempId=$id+$i
    }

    $id=$tempId
    Write-Debug ("Generated collection alias: " + $id)

    return $id
}

function Remove-InvalidCollectionChars($PoolName)
{
    $name = $PoolName.Trim()
    if($name.Length -gt 16)
    {
        $name=$name.SubString(0,16)
    }
    [string]$alias= ""
    $nameChars=$name.ToCharArray()
    foreach($char in $nameChars)
    {
        if( ( ($char -ge [char]'a') -and ([char]'z' -ge $char)) -or
             ( ($char -ge [char]'A') -and ([char]'Z' -ge $char)) -or
             ( ($char -ge [char]'0') -and ([char]'9' -ge $char)) -or
             ($char -eq [char]'-') -or ($char -eq [char]'_') -or ($char -eq [char]' '))
        {
            $alias+=$char.ToString()
        }
    }
    $alias=$alias.Trim()
    if([System.string]::IsNullOrEmpty($alias))
    {
        $alias="farm"
    }
    return ([string]($alias.Replace(' ','_')))
}

function ConvertTo-Sid
{
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $NtAccount,
    
    [Parameter(Mandatory=$false, ParameterSetName="Domain", Position=1)]
    [string]
    $NtDomain
)
    try
    {
        if ($PsCmdlet.ParameterSetName -eq "Domain")
        {
            $acc = new-object system.security.principal.NtAccount($NtDomain, $NtAccount)
        }
        else
        {
            $acc = new-object system.security.principal.NtAccount($NTaccount)
        }
    
        $acc.Translate([system.security.principal.securityidentifier])
    }
    catch
    {
        return $null
    }
}

function ConvertTo-NtAccount ([string]$sid) 
{
    (new-object system.security.principal.securityidentifier($sid)).translate([system.security.principal.ntaccount])
}

#verifies if a collection with same name already exists
function Confirm-CollectionNameDoesNotExist{

param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $RDMgmtServer
)

    Write-Debug ("Validating Input Collection Name: " + $CollectionName)

    #validate that a VM collection with same name does not exist
    try
    {
        $coll = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $RDMgmtServer  -ErrorAction Stop `
         -Authentication PacketPrivacy -Impersonation Impersonate -Filter "Name='$CollectionName'"            
    }
    catch
    {
        Write-Debug $_.Exception
        return $false
    }

    if($null -ne $coll)
    {
        Write-Debug (Get-ResourceString RDVHCollectionAlreadyExist)
        return $false
    }

    #validate that a RDSH collection with same name does not exist
    try
    {
        $rdshColl = Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -ComputerName $RDMgmtServer  -ErrorAction Stop `
         -Authentication PacketPrivacy -Impersonation Impersonate -Filter "Name='$CollectionName'"            
    }
    catch
    {
        Write-Debug $_.Exception
        return $false
    }

    if($null -ne $rdshColl)
    {
        Write-Debug (Get-ResourceString RDSHCollectionAlreadyExist)
        return $false
    }
    return $true
}

#verifies if the specified input is a valid host name
function Confirm-ValidHostname{

param(
    [Parameter(Mandatory=$true)]
    [string]
    $Hostname
)

    Write-Debug ("Validating Hostname: " + $Hostname)

    $uriType = [System.Uri]::CheckHostName($Hostname)

    if ($uriType -eq "Unknown")
    {
	    Write-Debug (Get-ResourceString InvalidHostname $Hostname)

        return $false
    }

    return $true
}

function Get-UserGroupsFromSecurityDescriptor{
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $SecurityDescriptor
)
    $userGroups = New-Object System.Collections.Generic.List[string]

    $parts = $SecurityDescriptor.Split(( '(', ')' ));

    foreach ($entry in $parts)
    {
        if ([System.String]::IsNullOrEmpty($entry))
        {
            continue;
        }

        $index = $entry.LastIndexOf(';');
        if ( 0 -gt $index )
        {
            #no ; found, try next
            continue;
        }

        $sid = $entry.Substring($index + 1);
        if ([System.String]::IsNullOrEmpty($sid))
        {
            #no SID found
            continue;
        }

        try
        {
            $groupName = ConvertTo-NtAccount($sid)
        }
        catch
        {
            Write-Warning (Get-ResourceString UnableToMapSid $sid, $_)
            $groupName = $sid
        }
        
        $userGroups.Add($groupName)
    }
    return $userGroups
}

# Returns $null upon error to convert
function Get-SecurityDescriptorFromUserGroup {

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string[]]
    $UserGroups
)
    
    $sddl = "O:WDG:WDD:ARP"
    foreach($userGroup in $UserGroups)
    {
        $sid = ConvertTo-Sid($userGroup)
        if( $null -eq $sid )
        {
            Write-Debug (Get-ResourceString InvalidUserGroup $userGroup, $_)
            return $null
        }

        $sddl += "(A;CIOI;CCLCSWLORCGR;;;" + $sid.ToString() + ")"
    }

    return $sddl
}

function Get-CollectionAliasFromName {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    $res = Get-SessionCollectionAliasFromName @PSBoundParameters
    
    if($null -eq $res)
    {
        $res = Get-VMCollectionAliasFromName @PSBoundParameters
    }

    return $res
}

function Get-SessionCollectionFromName {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ($null -eq $ConnectionBroker)
    {
        return $null
    }
    
    try
    {
        $rdshColl = Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -Filter "Name='$CollectionName'" `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString LookupCollectionWmiError $_)
    }

    return $rdshColl
}

function Get-SessionCollectionAliasFromName {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    $rdshColl = Get-SessionCollectionFromName $CollectionName $ConnectionBroker
    if($null -eq $rdshColl)
    {
        return $null
    }
    else
    {
        return $rdshColl.Alias
    }
}

function Get-VMCollectionAliasFromName {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    try
    {
        $vmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -Filter "Name='$CollectionName'" `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString LookupCollectionWmiError $_)
        return $null
    }

    if($null -eq $vmColl)
    {
        return $null
    }
    else
    {
        return $vmColl.Alias
    }
}

function Get-CollectionNameFromAlias {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    $res = Get-SessionCollectionNameFromAlias @PSBoundParameters
    
    if($null -eq $res)
    {
        $res = Get-VMCollectionNameFromAlias @PSBoundParameters
    }

    return $res
}

function Get-SessionCollectionNameFromAlias {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    try
    {
        $rdshColl = Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -Filter "Alias='$CollectionAlias'" `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString LookupCollectionWmiError $_)
        return $null
    }

    if($null -eq $rdshColl)
    {
        return $null
    }
    else
    {
        return $rdshColl.Name
    }
}

function Get-VMCollectionNameFromAlias {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    try
    {
        $vmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -Filter "Alias='$CollectionAlias'" `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString LookupCollectionWmiError $_)
        return $null
    }

    if($null -eq $vmColl)
    {
        return $null
    }
    else
    {
        return $vmColl.Name
    }
}

function Open-RDVMFirewall {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $VMName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $VMHostName
)
    # VMName and VMHostName should be validated by the caller

    try
    {
        $ret = Invoke-WmiMethod -Class "Win32_RDVHManagement" -namespace "root\cimv2\TerminalServices" `
                                -Name "RdvSetupVMPermissions" -ArgumentList @($VMName) `
                                -ComputerName $VMHostName -Authentication PacketPrivacy -Impersonation Impersonate `
                                -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString FirewallDisableFailedWmiError $VMName, $_)
        return $false
    }

    if ($ret.ReturnValue -ne 0)
    {
        Write-Debug (Get-ResourceString FirewallDisableFailedErrorCode $VMName, $ret.ReturnValue)
        return $false
    }
    
    return $true
}

function Close-RDVMFirewall {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $VMName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $VMHostName
)
    # VMName and VMHostName should be validated by the caller

    try
    {
        $ret = Invoke-WmiMethod -Class "Win32_RDVHManagement" -namespace "root\cimv2\TerminalServices" `
                                -Name "RdvUndoVMPermissions" -ArgumentList @($VMName) `
                                -ComputerName $VMHostName -Authentication PacketPrivacy -Impersonation Impersonate `
                                -ErrorAction Stop
    }
    catch
    {
        Write-Debug (Get-ResourceString FirewallEnableFailedWmiError $VMName, $_)
        return $false
    }
                            
    if ($ret.ReturnValue -ne 0)
    {
        Write-Debug (Get-ResourceString FirewallEnableFailedErrorCode $VMName, $ret.ReturnValue)
        return $false
    }
                     
    return $true
}


#
# Returns string in distinguishedName format for the specified OU: OU=ITServices,DC=redmond,DC=corp,DC=microsoft,DC=com
# if the specified OrganizationalUnit is not a valid distinguishedName.
# If no orgunit is specified, it looks up default compouters container

function Get-DistinguishedName {
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Domain,

    [Parameter(Mandatory=$false)]
    [String]
    $OrganizationalUnit
)

    try
    {
        # Check if the specified OU is already in distinguished name format.
        #   see if we can use a proper API
        $distinguishedNameFormat = (($OrganizationalUnit.ToLower().StartsWith("ou=")) -or `
                                    ($OrganizationalUnit.ToLower().StartsWith("cn=computers")) )

        $distinguishedName = $null

        if ($distinguishedNameFormat -eq $true)
        {
            Write-Debug "Validating OU already specified in distinguished name format."
            $ldapString = "LDAP://" + $organizationalUnit
            $distinguishedName = ([ADSI]$ldapString).distinguishedName
        }

        if ($distinguishedName -eq $null)
        {
        
            if( ([string]::IsNullOrEmpty($OrganizationalUnit)) -or 
                (0 -eq [string]::Compare($OrganizationalUnit,'computers',$true)) )
            {
                $filter = "(&(CN=computers))"
            }
            else
            {
                $filter = "(&(objectClass=organizationalUnit)(OU="+$OrganizationalUnit+"))"        
            }
            $ldapDomain = "LDAP://" + $Domain
            $directoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ldapDomain)
            $ouSearch = New-Object System.DirectoryServices.DirectorySearcher($directoryEntry)
            $ouSearch.Filter = $filter
            $distinguishedName = $ouSearch.Findall() | %{([ADSI]($_.Path)).distinguishedName}
        }

        Write-Debug ("Distinguished Name: " + $distinguishedName)
    }
    catch
    {
        Write-Verbose $_.Exception.Message
    }
    return $distinguishedName
}

function Test-PathWritable {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $Path
)
    
    $writable = $true
    
    $filename = [System.IO.Path]::GetRandomFileName()
    
    try
    {
        $file = [System.IO.File]::Create([System.IO.Path]::Combine($Path, $filename), 1, [System.IO.FileOptions]::DeleteOnClose)
        $file.Close()
    }
    catch
    {
        $writable = $false
    }
    
    return $writable
}

function Test-PathNotInUse {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $Path,
    
    [Parameter(Mandatory=$true)]
    [String]
    $RDMgmtServer
)
    
    #validate that a VM collection with same path does not exist
    
    $vmCollections = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $RDMgmtServer -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if ($null -ne $vmCollections)
    {
        foreach ($coll in $vmCollections)
        {
            $vmFarmSettingsXml = [xml]$coll.VmFarmSettings
            $userVHDSettingXml = [xml]$coll.UserVHDSetting
            
            $isUserVHDEnabledXml = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdProfRoamingEnabled']")
            if ($isUserVHDEnabledXml -ne $null)
            {
                $isUserVHDEnabled = $isUserVHDEnabledXml.Attributes["Value"].ValueAsBoolean
            }
            
            if ($isUserVHDEnabled)
            {
                $userVHDShare = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdShareUrl']").Attributes["Value"].Value
                
                if ($userVHDShare -eq $Path)
                {
                    return $false
                }
            }

        }
    }
        
    #validate that a RDSH collection with same path does not exist
    
    $rdshCollections = Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -ComputerName $RDMgmtServer -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if ($null -ne $rdshCollections)
    {
        foreach ($coll in $rdshCollections)
        {
            $isUserVHDEnabled = $coll.GetInt32Property("IsUserVHDEnabled").Value
            if ($isUserVHDEnabled -eq 1)
            {
                $userVHDShare = $coll.GetStringProperty("UserVHDShare").Value

                if ($userVHDShare -eq $Path)
                {
                    return $false
                }
            }
        }
    }
    
    return $true
}

function Get-RDManagementServerDomain{

param(
    [Parameter(Mandatory=$true)]
    [string]
    $HostName
)

    try
    {
        $compObject = Get-WmiObject Win32_ComputerSystem -ComputerName $HostName -ErrorAction Stop
    }
    catch 
    {
        Write-Debug (Get-ResourceString FailedToGetComputerObjectWmi $HostName,$_.Exception.Message)
        return $null
    }

    return ($compObject.Domain)
}


#This is an internal function to get the collection type
function Get-RDVirtualDesktopCollectionType
{
param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]
    $BackEndCollectionType,

    [Parameter(Mandatory=$true, Position=1)]
    [int]
    $IsManaged,

    [Parameter(Mandatory=$true, Position=2)]
    [ref][int]
    $CollectionType,

    [Parameter(Mandatory=$true, Position=3)]
    [ref][int]
    $AutoAssignPersonalDesktop
)
    $AutoAssignPersonalDesktop.Value = $false
    $CollectionType.Value = 0

    if ($BackEndCollectionType -eq 1)
    {
        if ($IsManaged)
        {
            $CollectionType.Value = 1; #PooledManaged
        }
        else
        {
            $CollectionType.Value = 2; #PooledUnManaged
        }
    }
    elseif ($BackEndCollectionType -eq 2)
    {
        if ($IsManaged)
        {
            $CollectionType.Value = 3; #PersonalManaged
        }
        else
        {
            $CollectionType.Value = 4; #PersonalUnmanaged
        }
    }
    elseif ($BackEndCollectionType -eq 3)
    {
        if ($IsManaged)
        {
            $CollectionType.Value = 3; #PersonalManaged
        }
        else
        {
            $CollectionType.Value = 4; #PersonalUnmanaged
        }
        $AutoAssignPersonalDesktop.Value = $true
    }    
}

function Update-CollectionPropertiesToDefault {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false)]
    [bool]
    $IsVMCollection,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    # Parameters are all validated in the caller

    if(!$PSBoundParameters.ContainsKey("IsVMCollection"))
    {
        $collectionAlias = Get-VMCollectionAliasFromName -ConnectionBroker $ConnectionBroker -CollectionName $CollectionName
        
        # Since $CollectionName has already been validated, no need to double-check that we can find the alias of a matching session collection
        $IsVMCollection = ($null -ne $collectionAlias)
    }

    $redirectionOptions = [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::AudioRecording -bOR `
                          [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::AudioVideoPlayback -bOR `
                          [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::SmartCard -bOR `
                          [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::PlugAndPlayDevice -bOR `
                          [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::Drive -bOR `
                          [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::Clipboard

    if($IsVMCollection)
    {
        Set-RDVirtualDesktopCollectionConfiguration -CollectionName $CollectionName `
                                                 -ClientDeviceRedirectionOptions $redirectionOptions `
                                                 -RedirectAllMonitors $true `
                                                 -RedirectClientPrinter $true `
                                                 -ConnectionBroker $ConnectionBroker
    }
    else
    {
        Set-RDSessionCollectionConfiguration -CollectionName $CollectionName `
                                          -ClientDeviceRedirectionOptions $redirectionOptions `
                                          -MaxRedirectedMonitors 16 `
                                          -ClientPrinterRedirected $true `
                                          -RDEasyPrintDriverEnabled $true `
                                          -ClientPrinterAsDefault $true `
                                          -ConnectionBroker $ConnectionBroker
    }
}

function Set-RemoteWebConfig {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $RemoteServer,
        
        [Parameter(Mandatory=$true)]
        [string]
        $workspaceName      
    )

    $results = Invoke-Command -ScriptBlock {
        param($workspaceName)
        try
        {
            $path = echo $env:windir\Web\RDWeb\Web.Config;
            $indentation = 4;        
            $xml = New-Object System.Xml.XmlDocument;
            $xml.Load($path);
            if ($xml.configuration.appSettings.SelectSingleNode("./add[@key=""WorkspaceName""]"))
            {
                $xml.configuration.appSettings.SelectSingleNode("./add[@key=""WorkspaceName""]").Attributes["value"].value = $workspaceName
            }
            else
            {
                $xml.configuration.appSettings.InnerXml += ("<add key=""WorkspaceName"" value=""$workspaceName"" />")
            }
            $encoding = [System.Text.Encoding].UTF8;
            $xmlWriter = New-Object System.Xml.XmlTextWriter $path, $encoding;
            $xmlWriter.Formatting = "indented";
            $xmlWriter.Indentation = $indentation;
            $XmlWriter.Flush();
            $xml.Save($xmlWriter);
            $xmlWriter.Close();
            $res = $true
        }
        catch
        {
            $res = $false
        }
        
        return $res
    }`
    -ComputerName $RemoteServer `
    -ArgumentList $workspaceName

    if (-not $results) {
        return $false
    } 
    return $true
}

function Test-LocalUser{
    $userDomain=[System.Environment]::UserDomainName
    $machineName=[System.Environment]::MachineName
    return !([bool]([String]::Compare($userDomain, $machineName, $true)))
}

# Throws an exception if it cannot contact the server
# Returns false if it can contact the server but cannot find the Web.config file
# Returns true otherwise
function Test-CanSetRemoteWebConfig {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $RemoteServer
)

    $results = Invoke-Command -ScriptBlock {
        $path = echo $env:windir\Web\RDWeb\Web.Config;
        Test-Path -Path $path -PathType Leaf
    } `
    -ComputerName $RemoteServer `
    -ErrorAction Stop
    
    return $results
}

function Test-CollectionOnline {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,
    
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,
    
    [Parameter(Mandatory=$false)]
    [bool]
    $IsVmCollection,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)
    # All parameters are validated in caller
 
    if(!$PSBoundParameters.ContainsKey("IsVmCollection"))
    {
        $temp = Get-VMCollectionAliasFromName -ConnectionBroker $ConnectionBroker -CollectionName $CollectionName
        
        # Since $CollectionName has already been validated, no need to double-check that we can find the alias of a matching session collection
        $IsVMCollection = ($null -ne $temp)
    }
 
    if($IsVmCollection)
    {
        # Nothing to test, this can only go wrong with session collections
        return
    }

    # Get the list of session hosts in this collection
    try
    {
        $sessionHosts = Get-WmiObject Win32_RDSHServer -Namespace "root\cimv2\rdms" -Filter "CollectionAlias='$CollectionAlias'" `
                            -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        throw (Get-ResourceString ErrorWmiSessionCollectionServer $_)
    }

    if ($null -eq $sessionHosts)
    {
        throw (Get-ResourceString NoSessionHostsFoundInCollectionError $CollectionName)
    }
    
    # Callers will catch the exception
    Test-RDSessionHostOnline -SessionHost $sessionHosts -CollectionName $CollectionName
}

function Test-RDSessionHostOnline {

param (
    [Parameter(Mandatory=$true)]
    [System.Management.ManagementObject[]]
    $SessionHost,

    [Parameter(Mandatory=$false)]
    [string]
    $CollectionName
)    
    $offlineSessionHosts = @()
    $misconfiguredSessionHosts = @()

    foreach ($rdsh in $SessionHost)
    {
        # Make a simple WMI query that should work to test if the RDSH server is accepting WMI calls...
        $testWmiClass = "Win32_TSSystemInfo"
        try
        {
            $res = Get-WmiObject -Class $testWmiClass -Namespace "root\cimv2\TerminalServices" `
                                 -ComputerName $rdsh.Name -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            # WMI Error - assume the RDSH is offline
            Write-Debug (Get-ResourceString ErrorRdshOffline $rdsh.Name, $_)
            $offlineSessionHosts += $rdsh.Name
            continue
        }
            
        if ($null -eq $res)
        {
            # If we cannot get an instance of that WMI class, something is seriously wrong with the session host
            Write-Debug (Get-ResourceString ErrorRdshMisconfigured $testWmiClass, $rdsh.Name)
            $misconfiguredSessionHosts += $rdsh.Name
            continue
        }
    }
    
    if (($offlineSessionHosts.Length -gt 0) -or ($misconfiguredSessionHosts.Length -gt 0))
    {
        if ($PSBoundParameters["CollectionName"])
        {
            throw (Get-ResourceString ErrorInvalidSessionHostsCollection $CollectionName, ([System.String]::Join(", ", $offlineSessionHosts)), ([System.String]::Join(", ", $misconfiguredSessionHosts)))
        }
        else
        {
            throw (Get-ResourceString ErrorInvalidSessionHosts ([System.String]::Join(", ", $offlineSessionHosts)), ([System.String]::Join(", ", $misconfiguredSessionHosts)))
        }
    }
 }

function Test-UserVhdPathInUse {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $UserVhdPath,

     [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    #get all RDSH collections in the deployment
    $allRdshCol = Get-RDSessionCollection -ConnectionBroker $ConnectionBroker

    foreach ($rdshCol in $allRdshCol)
    {
        #get the UserVhd if exists
         $rdshProps = Get-RDSessionCollectionConfiguration -ConnectionBroker $ConnectionBroker -CollectionName $rdshCol.CollectionName -UserProfileDisk
         if(-not [string]::IsNullOrEmpty($rdshProps.DiskPath))
         {
             if($rdshProps.DiskPath -eq $UserVhdPath -and $CollectionName -ne $rdshProps.CollectionName)
             {
                 Write-Debug (Get-ResourceString FolderPathInUse $UserVhdPath)
                 return $true
             }
         }
    }

    #get all VM collections in the deploymnet
    $allVmCol = Get-RDVirtualDesktopCollection -ConnectionBroker $ConnectionBroker

    foreach ($vmCol in $allVmCol)
    {
        #get the UserVhd if exists
        $vmProps =  Get-RDVirtualDesktopCollectionConfiguration -ConnectionBroker $ConnectionBroker -CollectionName $vmCol.CollectionName -UserProfileDisk
        if(-not [string]::IsNullOrEmpty($vmProps.DiskPath))
        {
            if($vmProps.DiskPath -eq $UserVhdPath -and $CollectionName -ne $vmProps.CollectionName)
            {
                Write-Debug (Get-ResourceString FolderPathInUse $UserVhdPath)
                return $true
            }
        }
    }
    return $false
}

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole))
{
    $nonElevatedMessage = Get-ResourceString NonElavatedMessage
    Write-Warning $nonElevatedMessage
}


#will verify if Everyone has Read or Full Control permissions UserVHD path and warn the admin
function Test-EveryoneInUserVhdPath {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $UserVhdPath
)   
    $objUser = ConvertTo-NtAccount(Get-ResourceString SidEveryone)

    #get ACLs for given UserVhd path
    $acls = Invoke-Command -ScriptBlock {Get-Acl -Path $UserVhdPath | select -expand access}
    foreach($acl in $acls)
    {
        if($objUser.Value -eq $acl.IdentityReference)
        {
            if($acl.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow -and ($acl.FileSystemRights -eq [System.Security.AccessControl.FileSystemRights]::FullControl -or [System.Security.AccessControl.FileSystemRights]::Read) )
            {
                Write-Debug (Get-ResourceString EveryoneHasAccess $UserVhdPath)
                return $true
            }
        }
    }
    return $false
}

#will update the connection strings when the database access is lost (for both dedicated and shared configurations)
#admin should always provide the primary connection string
function Update-DBConnStringNoDatabaseAccess{
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
    $OnSpecifiedBrokerOnly
)   
    #DatabaseConnectionString cannot be null or empty 
    if(([string]::IsNullOrEmpty($DatabaseConnectionString)))
    {
        $error = Get-ResourceString InvalidDatabaseConnStr
        Write-Error $error
        return $false
    }

    #if it is not shared database(SQL/database authentication) configuration DatabaseSecondaryConnectionString is not supported
    if([Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDedicatedDatabaseServerConfiguration($ConnectionBroker))
    {
         if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
         {            
            $error = Get-ResourceString DoNotSetSecondaryDatabaseConnStr
            Write-Error $error
            return $false
         }
    }

    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'
    
    #$DatabaseConnectionString is required
    $otherParams.Add("DatabaseConnectionString", $DatabaseConnectionString)

    if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
    {
        $otherParams.Add("DatabaseSecondaryConnectionString", $DatabaseSecondaryConnectionString)
    }
    else
    {
        $DatabaseSecondaryConnectionString = $null
    }

    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None  

    # Parameter validations    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::SetDatabaseConnectionString, 
                            $null,
                            0, 
                            $ConnectionBroker,
                            [ref]$FailedServers,
                            $otherParams)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
        Write-Error $error
        return $false
    }

    try
    {
        #set the connection strings only on current broker - this is to fix DB not accessible due to password expiration
        $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

        if([string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
        {              
            $SbServiceProp.SBDbSecondaryConnectionString = $null
        } 
        else
        {
            $SbServiceProp.SBDbSecondaryConnectionString = $DatabaseSecondaryConnectionString          
        }
        $SbServiceProp.SBDbConnectionString = $DatabaseConnectionString
        $SbServiceProp.Put() | Out-Null
    

        #we need to restart the broker service at this point to make sure all initialization passes and
        #we can set the connection strings on all brokers in the deployment
        $msg = ( Get-ResourceString RestartingTSSDISService $ConnectionBroker)
        Write-Information $msg -InformationAction Continue

        Invoke-Command -ComputerName $ConnectionBroker {Restart-Service "tssdis" -Force}

        #restart RD Management (rdms) service on all brokers
        $msg = (Get-ResourceString RestartingRDMSService $ConnectionBroker)
        Write-Information $msg -InformationAction Continue

        Invoke-Command -ComputerName $ConnectionBroker {Restart-Service "rdms" -Force}

        #restart RD Publishing (tscpubrpc) service on all brokers
        $msg = (Get-ResourceString RestartingTSCPUBRPCService $ConnectionBroker)
        Write-Information $msg -InformationAction Continue

        Invoke-Command -ComputerName $ConnectionBroker {Restart-Service "tscpubrpc" -Force}

        #update connections strings in RDMS database (only on the current broker which after restoring the DB connection wactive broker)
        $activeBroker = Invoke-WmiMethod -Path ROOT\cimv2\rdms:Win32_RDMSEnvironment -Name GetActiveServer -ComputerName $ConnectionBroker -Authentication PacketPrivacy 
        if($activeBroker.ServerName.ToUpper().Equals($ConnectionBroker.ToUpper()))
        {
            #if this one fails - the connection string is still not good
            $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
    
            #reset primary connection string - is required
            $wmic.SetConnectionString($DatabaseConnectionString) | Out-Null
            #secondary connection string is optional
            if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
            {        
                $wmic.SetSecondaryConnectionString($DatabaseSecondaryConnectionString) | Out-Null
            }
        }      
    }
    catch
    {
        $error= (Get-ResourceString FailedUpdatingConnStringsOnBroker $ConnectionBroker)
        Write-Error $error
        Write-Error $_.Exception.Message  
         
        return $false 
    }

    #check if we want to update the connections strings only on the specified broker
    if($OnSpecifiedBrokerOnly)
    {
        $msg = (Get-ResourceString SuccessfullyUpdatedConnStringsOnBroker $ConnectionBroker)
        Write-Information $msg -InformationAction Continue
        return $true
    }
    else
    {
        try
        {   #get all brokers in the deployment
            $msg = Get-ResourceString UpdateDatabaseConnStringsOnAllBrokers
            Write-Information $msg -InformationAction Continue

            #get the active broker server - at this point we do not know if the broker the admin runs the cmdlet on is the actual active one
            $activeBroker = Invoke-WmiMethod -Path ROOT\cimv2\rdms:Win32_RDMSEnvironment -Name GetActiveServer -ComputerName $ConnectionBroker -Authentication PacketPrivacy 

            #get the broker list - this should not fail now as the update was successful on the given broker server
            $brokerList = Get-RDServer -ConnectionBroker $activeBroker.ServerName -Role RDS-CONNECTION-BROKER

            #if we have more than the specified broker in the deployment
            if($brokerList.Count -gt 1)
            {
                #set the new connection strings on all brokers in the deployment
                foreach ($broker in $brokerList) 
                {
                    try
                    {
                        if(!$broker.Server.ToUpper().Equals($ConnectionBroker.ToUpper()))
                        {
                            $msg = (Get-ResourceString UpdatingDBConnStringsOnBroker $broker.Server)
                            Write-Information $msg -InformationAction Continue

                            $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker.Server -Authentication PacketPrivacy -ErrorAction Stop

                            if([string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
                            {              
                                $SbServiceProp.SBDbSecondaryConnectionString = $null
                            } 
                            else
                            {
                                $SbServiceProp.SBDbSecondaryConnectionString = $DatabaseSecondaryConnectionString          
                            }
                            $SbServiceProp.SBDbConnectionString = $DatabaseConnectionString
                            $SbServiceProp.Put() | Out-Null

                            #restart RD Connectrion Broker (tssdis) service on all brokers
                            $msg = (Get-ResourceString RestartingTSSDISService $broker.Server)
                            Write-Information $msg -InformationAction Continue

                            Invoke-Command -ComputerName $broker.Server {Restart-Service "tssdis" -Force}

                            #restart RD Management (rdms) service on all brokers
                            $msg = (Get-ResourceString RestartingRDMSService $broker.Server)
                            Write-Information $msg -InformationAction Continue

                            Invoke-Command -ComputerName $broker.Server {Restart-Service "rdms" -Force}

                            #restart RD Publishing (tscpubrpc) service on all brokers
                            $msg = (Get-ResourceString RestartingTSCPUBRPCService $broker.Server)
                            Write-Information $msg -InformationAction Continue

                            Invoke-Command -ComputerName $broker.Server {Restart-Service "tscpubrpc" -Force}

                            $msg = (Get-ResourceString DoneUpdatingConnStringsOnBroker $broker.Serverr)
                            Write-Information $msg -InformationAction Continue
                       }
                        #update connections strings in RDMS database (only on the active broker)
                       if($activeBroker.ServerName.ToUpper().Equals($broker.Server.ToUpper()))
                       {
                            $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $broker.Server -Authentication PacketPrivacy
    
                            #reset primary connection string - is required
                            $wmic.SetConnectionString($DatabaseConnectionString) | Out-Null
                            #secondary connection string is optional
                            if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
                            {        
                                $wmic.SetSecondaryConnectionString($DatabaseSecondaryConnectionString) | Out-Null
                            }
                       }      
                    }
                    catch
                    {
                        $failedBrokers = $failedBrokers + ";" + $broker.Server
                        $exceptionError =  $exceptionError + ";" + $_.Exception.Message     
                        Write-Debug (Get-ResourceString FailedUpdatingConnStringsOnBrokers $broker.Server)               
                        Write-Debug $_.Exception.Message                        
                    }                   
                } 
            }
        }
        catch
        {
            Write-Error $_.Exception.Message           
            return $false 
        }
    }
    if($failedBrokers.Count -ne 0)
    {
         $error = (Get-ResourceString FailedUpdatingConnStringsOnBrokers $failedBrokers)
         Write-Error $error
    }
    else
    {
        $msg = Get-ResourceString SuccessfullyUpdatedConnStringsAllBrokers
        Write-Information $msg -InformationAction Continue
        return $true
    }
}

#will update connection strings when we still have database access - for both dedicated and shared database configurations
function Update-DBConnStringWithDatabaseAccess{
param (
 
    [Parameter(Mandatory=$false, Position=0)]
    [String]
    $DatabaseConnectionString,

    [Parameter(Mandatory=$false, Position=1)]
    [String]
    $DatabaseSecondaryConnectionString,

    [Parameter(Mandatory=$false, Position=2)]
    [String]
    $ConnectionBroker
)   
    
    $isWin10OrLater = Test-IsWindows10OrLater($ConnectionBroker)    
    $otherParams = New-Object 'System.Collections.Generic.Dictionary[String,Object]'

    if($isWin10OrLater)
    {        
        #DatabaseSecondaryConnectionString is supported only on Windows 2016 and later deployment    
        if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
        {
            $otherParams.Add("DatabaseSecondaryConnectionString", $DatabaseSecondaryConnectionString)
        }
        else
        {
            $DatabaseSecondaryConnectionString = $null
        } 
    }
 
        
    if(![string]::IsNullOrEmpty($DatabaseConnectionString))
    {
        $otherParams.Add("DatabaseConnectionString", $DatabaseConnectionString)
    }
    else
    {
         $DatabaseConnectionString = $null
    }


    [Microsoft.RemoteDesktopServices.Common.DeploymentValidations] $result = [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None  

    # Parameter validations
    
    $FailedServers = $null
    $result = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::ValidateDeployment(
                            [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentAction]::SetDatabaseConnectionString, 
                            $null,
                            0, 
                            $ConnectionBroker,
                            [ref]$FailedServers,
                            $otherParams)
    
    if ($result -ne [Microsoft.RemoteDesktopServices.Common.DeploymentValidations]::None)
    {
        $error = [Microsoft.RemoteDesktopServices.Management.Activities.DeploymentVerification]::GetErrorMessage($result, 0)
        Write-Error $error
        return $false
    }

    #set the connectioon strings on all brokers in the deployment
    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    $oldDbConnStringList = New-Object 'System.Collections.Generic.Dictionary[String,Object]'
    $oldDbSecondaryConnStringList = New-Object 'System.Collections.Generic.Dictionary[String,Object]'

    try
    {
        foreach ($broker in $brokerList) 
        {
            Write-Debug ("Broker = " + $broker.Server)

            $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker.Server -Authentication PacketPrivacy -ErrorAction Stop

             if(Test-IsWindows10OrLater($broker.Server))
             {
                if(![string]::IsNullOrEmpty($DatabaseConnectionString) -and [string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
                {               
                    $oldDbConnString = $SbServiceProp.SBDbConnectionString
                    $SbServiceProp.SBDbConnectionString = $DatabaseConnectionString
                    $SbServiceProp.SBDbSecondaryConnectionString = $null
                    $SbServiceProp.Put() | Out-Null              
                    $oldDbConnStringList.Add($broker.Server, $oldDbConnString)
                } 

                if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString) -and [string]::IsNullOrEmpty($DatabaseConnectionString))
                { 
                    $oldDbSecondaryConnString = $SbServiceProp.SBDbSecondaryConnectionString
                    $SbServiceProp.SBDbSecondaryConnectionString = $DatabaseSecondaryConnectionString
                    $SbServiceProp.SBDbConnectionString = $null
                    $SbServiceProp.Put() | Out-Null              
                    $oldDbSecondaryConnStringList.Add($broker.Server, $oldDbSecondaryConnString)
                }   
                if(![string]::IsNullOrEmpty($DatabaseConnectionString) -and ![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))  
                {
                    $oldDbSecondaryConnString = $SbServiceProp.SBDbSecondaryConnectionString
                    $oldDbConnString = $SbServiceProp.SBDbConnectionString
                    $SbServiceProp.SBDbSecondaryConnectionString = $DatabaseSecondaryConnectionString
                    $SbServiceProp.SBDbConnectionString = $DatabaseConnectionString
                    $SbServiceProp.Put() | Out-Null              
                    $oldDbConnStringList.Add($broker.Server, $oldDbConnString)
                    $oldDbSecondaryConnStringList.Add($broker.Server, $oldDbSecondaryConnString)
                }
             }
             else
             {
                #DatabaseConnectionString cannot be null for legacy Windows OS: Windows 2012 R2 or Windows 2012
                $oldDbConnString = $SbServiceProp.SBDbConnectionString
                $SbServiceProp.SBDbConnectionString = $DatabaseConnectionString
                $SbServiceProp.Put() | Out-Null              
                $oldDbConnStringList.Add($broker.Server, $oldDbConnString)
             }          
        }

        #update connections strings in RDMS database (only on the active broker)
        if($isWin10OrLater)
        {
            $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
            $OldRdmsPrimaryConnStr = $wmic.GetConnectionString().ConnectionString
            $OldRdmsSecondaryConnStr = $wmic.GetSecondaryConnectionString().SecondaryConnectionString

            if(![string]::IsNullOrEmpty($DatabaseConnectionString))
            {
                $wmic.SetConnectionString($DatabaseConnectionString) | Out-Null
            }
            if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
            {        
                $wmic.SetSecondaryConnectionString($DatabaseSecondaryConnectionString) | Out-Null
            }
        }
        else
        {
            #update connections strings in RDMS database
            $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy
            $OldRdmsPrimaryConnStr = $wmic.GetStringProperty('DatabaseConnectionString')
            #DatabaseConnectionString cannot be null for legacy Windows OS: Windows 2012 R2 or Windows 2012
            $wmic.SetStringProperty('DatabaseConnectionString',$DatabaseConnectionString) | Out-Null 
        }     
    }
    catch
    {
        Write-Error $_.Exception.Message        

        # Reset values in case of failure
        foreach ($broker in $oldDbConnStringList.Keys) 
        {
            Write-Debug ("Resetting Broker = " + $broker.Server)

            $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker.Server -Authentication PacketPrivacy -ErrorAction SilentlyContinue
          
            if(![string]::IsNullOrEmpty($DatabaseConnectionString))
            {
                $SbServiceProp.SBDbConnectionString = $oldDbConnStringList[$broker.Server]
                $SbServiceProp.Put() | Out-Null
            }
        }

        #DatabaseSecondaryConnectionString is supported only on Windows 2016 and later deployments
        if(Test-IsWindows10OrLater($ConnectionBroker))
        {
            foreach ($broker in $oldDbSecondaryConnStringList.Keys) 
            {
                Write-Debug ("Resetting Broker = " + $broker.Server)

                $SbServiceProp = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $broker.Server -Authentication PacketPrivacy -ErrorAction SilentlyContinue
                if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
                {
                    $SbServiceProp.SBDbSecondaryConnectionString = $oldDbSecondaryConnStringList[$broker.Server]               
                    $SbServiceProp.Put() | Out-Null
                }
            }
        }
       
        #reset values for RDMS as well (on active broker only)
        $wmic = gwmi -Namespace ROOT\cimv2\rdms -Class Win32_RDMSDeploymentSettings -List -ComputerName $ConnectionBroker -Authentication PacketPrivacy

         if(Test-IsWindows10OrLater($ConnectionBroker))
         {            
            if(![string]::IsNullOrEmpty($OldRdmsPrimaryConnStr))
            {
                $wmic.SetConnectionString($OldRdmsPrimaryConnStr) | Out-Null
            }
            if(![string]::IsNullOrEmpty($OldRdmsSecondaryConnStr))
            {        
                $wmic.SetSecondaryConnectionString($OldRdmsSecondaryConnStr) | Out-Null
            }
         }
         else
         {
            $wmic.SetStringProperty('DatabaseConnectionString', $OldRdmsPrimaryConnStr) | Out-Null
         }

        return $false
    }
    finally
    {
    }

    return $true
}

function Test-IsWindows10OrLater {
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Server
)

    $srv = Get-WmiObject -class Win32_OperatingSystem -ComputerName $Server -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if( $srv -ne $null -and $srv.Version)
    {
        $separators=[char[]]('.')
        $versionparts = $srv.Version.Split($separators)
        [int]$major = [convert]::ToInt32($versionparts[0], 10)

        if($major -ge 10)
        {
            return $true;
        }
    }

    return $false
}


function Test-BrokerServersMatchOSVersion {
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$true, Position=1)]
    [string]
    $BrokerToAdd
)

    $srv1 = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue
    $srv2 = Get-WmiObject -class Win32_OperatingSystem -ComputerName $BrokerToAdd -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if( $srv1 -ne $null -and $srv1.Version)
    {
        $separators=[char[]]('.')
        $versionparts = $srv1.Version.Split($separators)
        [int]$major1 = [convert]::ToInt32($versionparts[0], 10)
        [int]$minor1 = [convert]::ToInt32($versionparts[1], 10)
    }
    
    if( $srv2 -ne $null -and $srv2.Version)
    {
        $separators=[char[]]('.')
        $versionparts = $srv2.Version.Split($separators)
        [int]$major2 = [convert]::ToInt32($versionparts[0], 10)
        [int]$minor2 = [convert]::ToInt32($versionparts[1], 10)
    }

    if(($major1 -eq $major2) -and ($minor2 -eq $minor2))
    {
        return $true
    }
    else
    {
        return $false
    }
}

function Test-DatabaseNameMatch {
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false, Position=1)]
    [string]
    $DatabaseConnectionString,

    [Parameter(Mandatory=$false, Position=2)]
    [string]
    $DatabaseSecondaryConnectionString
)
    
    $secConnString = $null
    $primaryConnString = $null 

    $obj = Get-WMIObject Win32_SessionBrokerServiceProperties -Namespace root\cimv2 -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    #get primary connection string to test
    if(![string]::IsNullOrEmpty($DatabaseConnectionString))
    {
       $primaryConnString = $DatabaseConnectionString
    }
    else
    {    
        #check if has been previously set
        if(![string]::IsNullOrEmpty($obj.SBDbConnectionString))
        {
            $primaryConnString = $obj.SBDbConnectionString
        }
    }       
    
    #get secondary connection string to test
    if(![string]::IsNullOrEmpty($DatabaseSecondaryConnectionString))
    {
        $secConnString = $DatabaseSecondaryConnectionString
    }
    else
    {
        #check if has been previously set
        if(![string]::IsNullOrEmpty($obj.SBDbSecondaryConnectionString))
        {
            $secConnString = $obj.SBDbSecondaryConnectionString
        }
    }       

    if(![string]::IsNullOrEmpty($secConnString) -and ![string]::IsNullOrEmpty($primaryConnString))
    {
        #both connection strings are given - check the database name matches
        if(![Microsoft.RemoteDesktopServices.Common.DeploymentModel]::IsDatabaseNameMatching($primaryConnString, $secConnString))
        {          
            return $false
        }
    }
    
    return $true;
}
