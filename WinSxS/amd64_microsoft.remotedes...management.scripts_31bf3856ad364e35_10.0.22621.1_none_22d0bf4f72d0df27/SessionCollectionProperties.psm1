
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\CustomRdpProperty.psm1


$1MinInMilliSeconds = 60000

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-SessionCollectionConfiguration {
[CmdletBinding(DefaultParameterSetName="General",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254080")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionGeneralProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserGroupProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionConnectionProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserProfileDiskProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionSecurityProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance[]")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionClientProperties")]
param (

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,
    
    [Parameter(ParameterSetName="UserGroup", Mandatory=$true)]
    [switch]
    $UserGroup,
    
    [Parameter(ParameterSetName="Connection", Mandatory=$true)]
    [switch]
    $Connection,
    
    [Parameter(ParameterSetName="UserProfileDisk", Mandatory=$true)]
    [switch]
    $UserProfileDisk,

    [Parameter(ParameterSetName="Security", Mandatory=$true)]
    [switch]
    $Security,

    [Parameter(ParameterSetName="LoadBalancing", Mandatory=$true)]
    [switch]
    $LoadBalancing,

    [Parameter(ParameterSetName="Client", Mandatory=$true)]
    [switch]
    $Client,

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

    # Get collection alias
    $wmiNamespace = "root\cimv2\rdms"
    $wmiQuery = "SELECT * FROM Win32_RDSHCollection WHERE Name='" + $CollectionName + "'"
    
    try
    {
        $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString LookupCollectionWmiError $_)
    }
    
    if ($wmiObj -eq $null)
    {
        Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        return
    }

    $CollectionAlias = $wmiObj.Alias

    switch ($PsCmdlet.ParameterSetName)
    {
        "General"
        {
            try
            {
                $customRdpProperties = Get-CollectionCustomRdpProperty -CollectionName $CollectionName -CollectionAlias $wmiObj.Alias -ConnectionBroker $ConnectionBroker
            }
            catch
            {
                Write-Error $_
                return
            }
        
            $collectionDescription = $wmiObj.Description
            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionGeneralProperties `
                -ArgumentList $CollectionName, $collectionDescription, $customRdpProperties
            break;
        }

        "UserGroup"
        {
            $SecurityDescriptor = $wmiObj.GetStringProperty("SecurityDescriptor").Value
        
            $securityGroups = [string[]](Get-UserGroupsFromSecurityDescriptor($SecurityDescriptor))

            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserGroupProperties `
                -ArgumentList $CollectionName, $securityGroups
            break;
        }
        
        "Connection"
        {
            $disconnectedSessionLimit = $wmiObj.GetInt32Property("DisconnectedSessionLimit").Value / $1MinInMilliSeconds
            $brokenConnectionAction = $wmiObj.GetInt32Property("BrokenConnectionAction").Value
            $deleteTempFoldersOnExit = $wmiObj.GetInt32Property("DeleteTempFoldersOnExit").Value
            $enableAutomaticReconnection = $wmiObj.GetInt32Property("EnableAutomaticReconnection").Value
            $activeSessionLimit = $wmiObj.GetInt32Property("ActiveSessionLimit").Value / $1MinInMilliSeconds
            $idleSessionLimit = $wmiObj.GetInt32Property("IdleSessionLimit").Value / $1MinInMilliSeconds
      
            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionConnectionProperties `
                -ArgumentList $CollectionName, $disconnectedSessionLimit, $brokenConnectionAction, $deleteTempFoldersOnExit, $enableAutomaticReconnection, $activeSessionLimit, $idleSessionLimit;
            break;
         }
         
         "UserProfileDisk"
         {
            $isUserVHDEnabled = $wmiObj.GetInt32Property("IsUserVHDEnabled").Value
            if ($isUserVHDEnabled -eq 1)
            {
                $userVhdXml = [xml]$wmiObj.GetStringProperty("UserPolicyXML").Value
                $userVHDShare = $wmiObj.GetStringProperty("UserVHDShare").Value
                $diskSize = ($wmiObj.GetInt32Property("DiskSizeInMB").Value * 1MB) / 1GB

                $incFolderLocations = $userVhdXml.UvhdRoamingPolicy.Include.Folder;
                $excFolderLocations = $userVhdXml.UvhdRoamingPolicy.Exclude.Folder;
                $incFileLocations = $userVhdXml.UvhdRoamingPolicy.Include.File;
                $excFileLocations = $userVhdXml.UvhdRoamingPolicy.Exclude.File;
            }
       
            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserProfileDiskProperties `
                  -ArgumentList $CollectionName, $incFolderLocations, $excFolderLocations, $incFileLocations, $excFileLocations, $userVHDShare, $isUserVHDEnabled, $diskSize;
            break;
         }
         
         "Security"
         {
            $authenticateUsingNLA = $wmiObj.GetInt32Property("AuthenticateUsingNLA").Value
            $encryptionLevel = $wmiObj.GetInt32Property("EncryptionLevel").Value
            $securityLayer = $wmiObj.GetInt32Property("SecurityLayer").Value
         
            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionSecurityProperties `
                -ArgumentList $CollectionName, $authenticateUsingNLA, $encryptionLevel, $securityLayer;
            break;
         }
         
         "LoadBalancing"
         {
            $instanceArray = New-Object System.Collections.Generic.List[Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance];

            $wmiQuery = "SELECT * FROM Win32_RDSHServer WHERE CollectionAlias='" + $CollectionAlias + "'";                 
            $rdshServers = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy

             if ($rdshServers -eq $null)
             {
                 Write-Error (Get-ResourceString NoServersInRDSHCollection $CollectionName)
                 return
             }

             foreach ($server in $rdshServers)
             {
                $wmiQuery = "SELECT * FROM Win32_RDSHServer WHERE Name='" + $server.Name + "'"
                $rdshServer = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy
                $relativeWeight = $rdshServer.GetInt32Property("RelativeWeight").Value
                $sessionLimit = $rdshServer.GetInt32Property("SessionLimit").Value
                $instance = New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance `
                    -ArgumentList $CollectionName, $relativeWeight, $sessionLimit, $server.Name
                $instanceArray.Add($instance);
            }
            
            $instanceArray
            break;
         }
         
         "Client"
         {
            $maxMonitors = $wmiObj.GetInt32Property("MaxMonitors").Value
            $redirectClientPrinter = $wmiObj.GetInt32Property("RedirectClientPrinter").Value
            $useRDEasyPrintDriver = $wmiObj.GetInt32Property("UseRDEasyPrintDriver").Value
            $setClientPrinterAsDefault = $wmiObj.GetInt32Property("SetClientPrinterAsDefault").Value
            
            try
            {
                $deviceRedirectionOptions = [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]($wmiObj.GetInt32Property("DeviceRedirectionOptions").Value)
            }
            catch
            {
                Write-Error (Get-ResourceString FailedToGetDeviceRedirectionOptions $_)
                $deviceRedirectionOptions = [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::None
            }
            
            New-Object Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionClientProperties `
                -ArgumentList $CollectionName, $deviceRedirectionOptions, $maxMonitors, $redirectClientPrinter, $useRDEasyPrintDriver, $setClientPrinterAsDefault;
            break;
         }
     }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-SessionCollectionConfiguration {
[CmdletBinding(DefaultParameterSetName="Default",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254081")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string]
    $CollectionDescription,
    
    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string[]]
    $UserGroup,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]
    $ClientDeviceRedirectionOptions,
    
    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [ValidateRange(1,16)]
    [int]
    $MaxRedirectedMonitors,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $ClientPrinterRedirected,
    
    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $RDEasyPrintDriverEnabled,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $ClientPrinterAsDefault,
    
    [Parameter(ParameterSetName="Default", Mandatory=$false)]
    [bool]
    $TemporaryFoldersPerSession,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [Microsoft.RemoteDesktopServices.Management.RDBrokenConnectionAction]
    $BrokenConnectionAction,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $TemporaryFoldersDeletedOnExit,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $AutomaticReconnectionEnabled,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [int]
    $ActiveSessionLimitMin,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [int]
    $DisconnectedSessionLimitMin,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [int]
    $IdleSessionLimitMin,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [bool]
    $AuthenticateUsingNLA,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [Microsoft.RemoteDesktopServices.Management.RDEncryptionLevel]
    $EncryptionLevel,

    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [Microsoft.RemoteDesktopServices.Management.RDSecurityLayer]
    $SecurityLayer,

    [Parameter(ParameterSetName="DisableUserProfileDisk", Mandatory=$true)]
    [switch]
    $DisableUserProfileDisk,

    [Parameter(ParameterSetName="EnableUserProfileDisk", Mandatory=$true)]
    [switch]
    $EnableUserProfileDisk,

    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string[]]
    $IncludeFolderPath,

    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string[]]
    $ExcludeFolderPath,

    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string[]]
    $IncludeFilePath,

    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string[]]
    $ExcludeFilePath,

    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [ValidateRange(1,9999)]
    [int]
    $MaxUserProfileDiskSizeGB,
    
    [Parameter(ParameterSetName="EnableUserProfileDisk", ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [string]
    $DiskPath,
    
    [Parameter(ParameterSetName="Default", Mandatory=$false)]
    [Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance[]]
    $LoadBalancing,
    
    [Parameter(ParameterSetName="Default", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string]
    $CustomRdpProperty,
    
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

    #if the user vhd path is null - skip the test
    if(-not [string]::IsNullOrEmpty($DiskPath))
    {
        #check UserVhd path is not in use
        if (Test-UserVhdPathInUse -UserVhdPath $DiskPath -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker)
        {
            Write-Error (Get-ResourceString FolderPathInUse $DiskPath)
            return
        }
        #check UserVhd path has Everyone
        if(Test-EveryoneInUserVhdPath -UserVhdPath $DiskPath)
        {
              Write-Warning (Get-ResourceString EveryoneHasAccess $DiskPath)
        }
    }

    # Get collection alias
    $wmiNamespace = "root\cimv2\rdms"
    $wmiQuery = "SELECT * FROM Win32_RDSHCollection WHERE Name='" + $CollectionName + "'"
    
    try
    {
        $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString LookupCollectionWmiError $_)
    }
    
    if ($wmiObj -eq $null)
    {
        Write-Error (Get-ResourceString RDSHCollectionNotFound $CollectionName)
        return
    }

    # Make sure we can safely make changes on this collection
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $wmiObj.Alias -IsVmCollection $false -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }

    $CollectionAlias = $wmiObj.Alias

    if ([Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE]::RD_FARM_RDSH.value__ -ne $wmiObj.Type)
    {
        if( $EnableUserProfileDisk.IsPresent )
        {
            Write-Error (Get-ResourceString NotSupportedSessionDesktopCollection 'EnableUserProfileDisk')
            return
        }

        if( $DisableUserProfileDisk.IsPresent )
        {
            Write-Error (Get-ResourceString NotSupportedSessionDesktopCollection 'DisableUserProfileDisk')
            return
        }

        if( $LoadBalancing )
        {
            Write-Error (Get-ResourceString NotSupportedSessionDesktopCollection 'LoadBalancing')
            return
        }
    }


    # Set up the call to use M3P
    $session = New-PSSession -ConfigurationName Microsoft.windows.servermanagerworkflows -EnableNetworkAccess

    try
    {
        # General Settings
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "Name"; "CollectionDescription" = "Description"; "UserGroup" = "User"}
        if ($optionalParameters.Count -gt 0)
        {
            Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias, $optionalParameters) RDManagement\Set-RDSHCollectionGeneralSetting -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters} | Out-Null
        }

        # Client Settings
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"RDEasyPrintDriverEnabled" = "UseRDEasyPrintDriver"; "ClientPrinterAsDefault" = "SetClientPrinterAsDefault"; "ClientPrinterRedirected" = "RedirectClientPrinter"; "ClientDeviceRedirectionOptions" = "DeviceRedirectionOptions"; "MaxRedirectedMonitors" = "MaxMonitors"}
        if ($optionalParameters.Count -gt 0)
        {
            Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias, $optionalParameters) RDManagement\Set-RDSHCollectionClientSetting -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters} | Out-Null
        }

        # Connection Settings
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"AutomaticReconnectionEnabled" = "EnableAutomaticReconnection"; "ActiveSessionLimitMin" = "ActiveSessionLimit"; "IdleSessionLimitMin" = "IdleSessionLimit"; "DisconnectedSessionLimitMin" = "DisconnectedSessionLimit"; "BrokenConnectionAction" = "BrokenConnectionAction"; "TemporaryFoldersDeletedOnExit" = "DeleteTempFoldersOnExit"; "TemporaryFoldersPerSession" = "UseTempFoldersPerSession"}
        if ($optionalParameters.Count -gt 0)
        {
            $optionalParameters["ActiveSessionLimit"] *= $1MinInMilliSeconds
            $optionalParameters["IdleSessionLimit"] *= $1MinInMilliSeconds
            $optionalParameters["DisconnectedSessionLimit"] *= $1MinInMilliSeconds
            Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias, $optionalParameters) RDManagement\Set-RDSHCollectionConnectionSetting -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters} | Out-Null
        }

        # Security Settings
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"SecurityLayer" = "SecurityLayer"; "EncryptionLevel" = "EncryptionLevel"; "AuthenticateUsingNLA" = "AuthenticateUsingNLA"}
        if ($optionalParameters.Count -gt 0)
        {
            Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias, $optionalParameters) RDManagement\Set-RDSHCollectionSecuritySetting -RDManagementServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters} | Out-Null
        }
        
        # EnableUserProfileDisk Settings
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"MaxUserProfileDiskSizeGB" = "DiskSize"; "DiskPath" = "UserVhdShare"; "IncludeFilePath" = "IncludeFileLocation"; "ExcludeFilePath" = "ExcludeFileLocation"; "IncludeFolderPath" = "IncludeFolderLocation"; "ExcludeFolderPath" = "ExcludeFolderLocation"}
        if ($PSBoundParameters["EnableUserProfileDisk"])
        {
            $wasUserProfileDisksEnabled = $wmiObj.GetInt32Property("IsUserVHDEnabled").Value

            $optionalParameters["DiskSize"] *= 1GB
            
            #RemapMode=2 applies when the cmdlet is called with IncludeFolderLocation and/or IncludeFileLocation parameters
            #RemapMode=0 (default): applies in all other cases: ExcludeFileLocation, ExcludeFolderLocation only and no cmdlets
            $optionalParameters["RemapMode"] = 0
            if($optionalParameters["IncludeFileLocation"] -ne $null -or $optionalParameters["IncludeFolderLocation"] -ne $null)
            {
                $optionalParameters["RemapMode"] = 2
            }
            
            if ($wasUserProfileDisksEnabled )
            {
                $optionalParameters.Remove("DiskSize")
                
                Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias,$optionalParameters) RDManagement\Set-RDSHUserDataVHDSetting -RDMSServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters} | Out-Null
            }
            else
            {
                Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias,$optionalParameters {param($ConnectionBroker,$CollectionAlias,$optionalParameters) RDManagement\Enable-RDSHUserDataVHD -RDMSServer $ConnectionBroker -CollectionAlias $CollectionAlias -DiskType 1 @optionalParameters} | Out-Null
            }
        }

        if ($PSBoundParameters["DisableUserProfileDisk"])
        {
            Invoke-Command $session -ArgumentList $ConnectionBroker,$CollectionAlias  {param($ConnectionBroker,$CollectionAlias) RDManagement\Disable-RDSHUserDataVHD -RDMSServer $ConnectionBroker -CollectionAlias $CollectionAlias } | Out-Null
        }
        
        # Load Balancing Settings
        if ($PSBoundParameters["LoadBalancing"])
        {
            foreach ($lbServer in $LoadBalancing)
            {
                Invoke-Command $session -ArgumentList $ConnectionBroker,$lbServer.SessionHost,$lbServer.SessionLimit,$lbServer.RelativeWeight  {param($ConnectionBroker,$ServerName,$SessionLimit,$RelativeWeight) RDManagement\Set-RDSHServerSetting -RDManagementServer $ConnectionBroker -Name $ServerName -SessionLimit $SessionLimit -RelativeWeight $RelativeWeight } | Out-Null
            }
        }
    }
    Finally
    {
        Remove-PSSession -Session $session
    }
    
    # Custom RDP Properties
    if ($PSBoundParameters["CustomRdpProperty"])
    {
        try
        {
            $customRdpErrors = Set-CollectionCustomRdpProperty -CollectionName $CollectionName -CollectionAlias $CollectionAlias -CustomRdpProperty $CustomRdpProperty -ConnectionBroker $ConnectionBroker
        }
        catch
        {
            Write-Error $_
            return
        }
        
        # If there were errors writing to specific brokers, the errors are aggregated up and returned as an array - let's print them now
        if($customRdpErrors.Length -gt 0)
        {
            foreach($error in $customRdpErrors)
            {
                Write-Error $error
            }
            
            return
        }
    }

}

