
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\RemoteAppIcon.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-RemoteApp {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254068")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RemoteApp[]")]
param (
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)]
    [String]
    $Alias,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $DisplayName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)

    # Validate $ConnectionBroker
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
    
    $appIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "Alias" = "AppAlias" }
    
    try
    {
        $unfilteredWmiApps = Get-AppWmiObject -ConnectionBroker $ConnectionBroker @appIdentifiers
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($PSBoundParameters.ContainsKey("DisplayName"))
    {
        # Filter the apps based on the DisplayName parameter
        $aliasToAppMap = @{}
        
        foreach($name in $DisplayName)
        {
            $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $name, IgnoreCase
            
            $WildCardMatches = ($unfilteredWmiApps | Where-Object { $WildCard.IsMatch($_.DisplayName) })
            
            if($null -ne $WildCardMatches)
            {
                foreach($match in $WildCardMatches)
                {
                    if(-not $aliasToAppMap.ContainsKey($match.AppAlias))
                    {
                        $aliasToAppMap.Add($match.AppAlias, $match)
                    }
                }
            }
            else
            {
                if(-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($name))
                {
                    Write-Verbose (Get-ResourceString CouldNotFindRemoteAppByName $name)
                }
                else
                {
                    Write-Verbose (Get-ResourceString WrnWildcardNoMatches $name)
                }
            }
        }
        
        $wmiApps = $aliasToAppMap.Values
    }
    else
    {
        $wmiApps = $unfilteredWmiApps
    }
                   
    foreach($wmiApp in $wmiApps)
    {
        # user does not have to specify CollectionName in input args, so we may have to fetch it based on the alias
        if(!$PSBoundParameters.ContainsKey("CollectionName"))
        {
            $CollectionName = Get-CollectionNameFromAlias -CollectionAlias $wmiApp.PoolName -ConnectionBroker $ConnectionBroker            
            if($null -eq $CollectionName)
            {
                Write-Error (Get-ResourceString InvalidAppObjectError $wmiApp.AppAlias, $wmiApp.PoolName)
            }
        }

        $userGroups = $null
        if (![System.String]::IsNullOrEmpty($wmiApp.SecurityDescriptor))
        {
            $userGroups = Get-UserGroupsFromSecurityDescriptor $wmiApp.SecurityDescriptor
        }

        New-Object Microsoft.RemoteDesktopServices.Management.RemoteApp `
            -ArgumentList $CollectionName, `
                          $wmiApp.AppAlias, `
                          $wmiApp.DisplayName, `
                          $wmiApp.Folder, `
                          $wmiApp.AppPath, `
                          $wmiApp.VirtualPath, `
                          $wmiApp.CommandLineSetting, `
                          $wmiApp.RequiredCommandLine, `
                          $wmiApp.IconContents, `
                          $wmiApp.IconIndex, `
                          $wmiApp.IconPath, `
                          $userGroups, `
                          $wmiApp.ShowInPortal
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-RemoteApp {
[CmdletBinding(DefaultParameterSetName="Session",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254069")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RemoteApp")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $Alias,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $DisplayName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FilePath,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({$_.Trim().Length -gt 0})]
    [String]
    $FileVirtualPath,

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $ShowInWebAccess = $true,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FolderName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue]
    $CommandLineSetting = [Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue]::DoNotAllow,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $RequiredCommandLine,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $UserGroups,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconPath,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconIndex = 0,
    
    [Parameter(Mandatory=$true, ParameterSetName="VirtualDesktop")]
    [Alias('VMName')]
    [String]
    $VirtualDesktopName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)
    #
    # Do some initial validation
    #
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 0
    
    # Validate $ConnectionBroker
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
    
    $endpointParams = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "VirtualDesktopName" = "VirtualDesktopName"; "ConnectionBroker" = "ConnectionBroker"}
    
    # Make sure ConnectionBroker is up-to-date in case it was changed by Initialize-Fqdn
    $endpointParams["ConnectionBroker"] = $ConnectionBroker
    
    # Get-PublishingRDEndpoint validates $CollectionName and $VirtualDesktopName for us
    try
    {
        $Endpoint = Get-PublishingRDEndpoint @endpointParams
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if ($null -eq $Endpoint)
    {
        return
    }
    
    # Make sure we can safely make any publishing changes on this collection
    if ($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
    {
        $collectionAlias = Get-VMCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    else
    {
        $collectionAlias = Get-SessionCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    
    if($null -eq $collectionAlias)
    {
        # Should not happen since the $CollectionName is validated in Get-PublishingRDEndpoint, but just to be safe...
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        return
    }
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 5
    
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $collectionAlias -IsVmCollection ($PsCmdlet.ParameterSetName -eq "VirtualDesktop") -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }
    
    # Make sure the app does not already exist
    try
    {
        $existingApps = Get-AppWmiObject -ConnectionBroker $ConnectionBroker -CollectionName $CollectionName
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -ne ($existingApps | Where-Object { $_.AppAlias -eq $Alias }))
    {
        Write-Error (Get-ResourceString RemoteAppAlreadyExistsError $Alias, $CollectionName)
        return
    }
    
    $appPropertiesForInitialValidation = Get-BoundParameter $PSBoundParameters @{"DisplayName" = "DisplayName"; "FilePath" = "FilePath"; "FolderName" = "FolderName"; "IconPath" = "IconPath"}
    
    try
    {
        Confirm-ValidRemoteAppPropertiesForSetOrNew @appPropertiesForInitialValidation
    }
    catch
    {
        Write-Error $_
        return
    }
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 10
    
    #
    # Do more thorough validation
    #
    $appProperties = Get-BoundParameter $PSBoundParameters @{"Alias" = "AppAlias";
                                                             "DisplayName" = "DisplayName";
                                                             "ShowInWebAccess" = "ShowInPortal";
                                                             "FolderName" = "Folder";
                                                             "CommandLineSetting" = "CommandLineSetting";
                                                             "RequiredCommandLine" = "RequiredCommandLine";
                                                             "IconPath" = "IconPath";
                                                             "IconIndex" = "IconIndex";
                                                             "FilePath" = "AppPath";
                                                             "FileVirtualPath" = "VirtualPath"}
    
    $appProperties["PoolName"] = $collectionAlias 
        
    # If the user did not pass-in an alias, let's generate one based off the filename
    if(!$appProperties.ContainsKey("AppAlias"))
    {
        $root = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::CreateRemoteAppAlias($appProperties["AppPath"])
        $appProperties["AppAlias"] = $root

        $i = 0
        while($null -ne ($existingApps | Where-Object { $_.AppAlias -eq $appProperties["AppAlias"] }))
        {
            $i++
            $appProperties["AppAlias"] = "$root($i)"
        }
    }
    
    # Validate $AppAlias, since we are creating a new app with this alias, so we don't get any implicit validation with a lookup for the existing app
    try
    {
        Confirm-ValidAppAlias $appProperties["AppAlias"]
    }
    catch
    {
        Write-Error $_
        return
    }
    
    # The workflows accept $null but not "" as a way to specify that the app is not in any folders
    if($appProperties.ContainsKey("Folder") -and ("" -eq $appProperties["Folder"]))
    {
        $appProperties["Folder"] = $null
    }
    
    # The workflows accept " " but not $null to set no required command-line args
    if($appProperties.ContainsKey("RequiredCommandLine") -and [System.String]::IsNullOrEmpty($appProperties["RequiredCommandLine"]))
    {
        $appProperties["RequiredCommandLine"] = " "
    }

    # If virtual path is not specified, assign Path value to it 
    if(!$appProperties.ContainsKey("VirtualPath") -or [System.String]::IsNullOrEmpty($appProperties["VirtualPath"]))
    {
        $appProperties["VirtualPath"] = $appProperties["AppPath"]
    }
    
    # Convert the UserGroups array to a security descriptor
    if($PSBoundParameters.ContainsKey("UserGroups"))
    {
        if(($null -eq $UserGroups) -or ($UserGroups.Count -eq 0))
        {
            # The workflow requires a string with one space in it to represent an empty security descriptor
            $appProperties["SecurityDescriptor"] = " "
        }
        else
        {
            $appProperties["SecurityDescriptor"] = Get-SecurityDescriptorFromUserGroup($UserGroups)
            if($null -eq $appProperties["SecurityDescriptor"])
            {
                Write-Error (Get-ResourceString InvalidUserGroupNoErr $UserGroups)
                return
            }
        }
    }
    
    #
    # $appProperties as of now only has values the user specified. For the workflow we need to specify default values for some of these
    #
    
    # for these properties, the default is specified in the params, so we can just use the var and the right thing will happen (user input or default)
    $appProperties["ShowInPortal"] = $ShowInWebAccess
    $appProperties["CommandLineSetting"] = $CommandLineSetting
    $appProperties["IconIndex"] = $IconIndex
   
    # The default is a little more complex here...
    if(!$appProperties.ContainsKey("IconPath"))
    {
        $appProperties["IconPath"] = $appProperties["AppPath"]
    }
    
    try
    {
        if($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
        {
            $activity = Get-ResourceString NewAppPreparingVmInProgress $Endpoint.VMName
            Write-Progress -Activity $activity -PercentComplete 15
        
            # Open firewall for 1) fetching icon contents (if necessary), and 2) fetching FTAs in the publishing workflow
            $ret = Open-RDVMFirewall -VMName $Endpoint.VMName -VMHostName $Endpoint.VMHostName
            if(!$ret)
            {
                Write-Error (Get-ResourceString FirewallDisableFailedError $Endpoint.VMName)
                return
            }
            
            # This API only works if the VM is running, so it must be called after Open-RDVMFirewall
            $endpointName = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetVirtualMachineFullyQualifiedDomainName($Endpoint.VMName, $Endpoint.VMHostName)
        }
        else
        {
            $endpointName = $Endpoint.RDSHName
        }
        
        Write-Verbose "Fetching FTAs and Icon contents from endpoint: $endpointName"
        
        # Generate the Icon Contents based off the icon path & index
        # If we've gotten this far, we know that IconPath cannot be null or empty
        $activity = Get-ResourceString GetAppIconInProgress
        Write-Progress -Activity $activity -PercentComplete 50
        
        try
        {
            $appProperties["IconContents"] = Get-RemoteAppIconContent -MachineName $endpointName -IconPath $appProperties["IconPath"] -IconIndex $appProperties["IconIndex"]
        }
        catch
        {
            Write-Error $_
            return
        }
        
        if($null -eq $appProperties["IconContents"])
        {
            # There was some problem getting the icon, and the workflows require that apps have a valid icon
            return
        }
        elseif($appProperties["IconContents"].Count -eq 0)
        {
            Write-Error (Get-ResourceString RemoteAppValidIconRequiredError)
            return
        }
        
        $activity = Get-ResourceString PublishingAppsInProgress
        Write-Progress -Activity $activity -PercentComplete 80
        
        # Create the app
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
        
        Invoke-Command -Session $workflowSession -ArgumentList @($endpointName, $ConnectionBroker, $appProperties) `
        {
            param($endpointName, $ConnectionBroker, $appProperties)
            RDManagement\Publish-RemoteApplication -VirtualMachine $endpointName -RDMSServer $ConnectionBroker @appProperties
        } | Out-Null
        
    }
    finally
    {
        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
        
        if($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
        {
            # We've already done all the important work, and Close-RDVMFirewall
            if( -not (Close-RDVMFirewall -VMName $Endpoint.VMName -VMHostName $Endpoint.VMHostName) )
            {
                Write-Error (Get-ResourceString FirewallEnableFailedError $endpoint.VMName)
            }
        }
    }
    
    $activity = Get-ResourceString PublishingAppsInProgress
    Write-Progress -Activity $activity -PercentComplete 95
    
    try
    {
        $createdApp= Get-AppWmiObject -ConnectionBroker $ConnectionBroker -CollectionAlias $appProperties["PoolName"] -AppAlias $appProperties["AppAlias"]
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -eq $createdApp)
    {
        Write-Error (Get-ResourceString NewRemoteAppDoesNotExist $CollectionName, $appProperties["AppAlias"])
        return
    }
    
    $userGroups = $null
    if (![System.String]::IsNullOrEmpty($createdApp.SecurityDescriptor))
    {
        $userGroups = Get-UserGroupsFromSecurityDescriptor $createdApp.SecurityDescriptor
    }
        
    Write-Progress -Activity " " -PercentComplete 100
        
    New-Object Microsoft.RemoteDesktopServices.Management.RemoteApp `
        -ArgumentList $CollectionName, `
                      $createdApp.AppAlias, `
                      $createdApp.DisplayName, `
                      $createdApp.Folder, `
                      $createdApp.AppPath, `
                      $createdApp.VirtualPath, `
                      $createdApp.CommandLineSetting, `
                      $createdApp.RequiredCommandLine, `
                      $createdApp.IconContents, `
                      $createdApp.IconIndex, `
                      $createdApp.IconPath, `
                      $userGroups, `
                      $createdApp.ShowInPortal
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-RemoteApp {
[CmdletBinding(DefaultParameterSetName="Session",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254070")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $Alias,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $DisplayName,

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FilePath,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    [ValidateScript({$_.Trim().Length -gt 0})]
    $FileVirtualPath,

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $ShowInWebAccess,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FolderName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue]
    $CommandLineSetting,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $RequiredCommandLine,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $UserGroups,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconPath,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconIndex,
    
    [Parameter(Mandatory=$true, ParameterSetName="VirtualDesktop")]
    [Alias('VMName')]
    [String]
    $VirtualDesktopName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)

    #
    # Do some initial validations
    #
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 0

    # Validate $ConnectionBroker
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

    $endpointParams = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "VirtualDesktopName" = "VirtualDesktopName"; "ConnectionBroker" = "ConnectionBroker"}
    
    # Make sure ConnectionBroker is up-to-date in case it was changed by Initialize-Fqdn
    $endpointParams["ConnectionBroker"] = $ConnectionBroker
    
    # Get-PublishingRDEndpoint validates $CollectionName and $VirtualDesktopName for us
    try
    {
        $endpoint = Get-PublishingRDEndpoint @endpointParams
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if ($null -eq $endpoint)
    {
        return
    }
    
    # Make sure we can safely make any publishing changes on this collection
    if ($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
    {
        $collectionAlias = Get-VMCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    else
    {
        $collectionAlias = Get-SessionCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    
    if($null -eq $collectionAlias)
    {
        # Should not happen since the $CollectionName is validated in Get-PublishingRDEndpoint, but just to be safe...
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        return
    }
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 5
    
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $collectionAlias -IsVmCollection ($PsCmdlet.ParameterSetName -eq "VirtualDesktop") -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }

    # Make sure the app already exists
    $appIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "Alias" = "AppAlias"}
    
    try
    {
        $ExistingApp = Get-AppWmiObject -ConnectionBroker $ConnectionBroker @appIdentifiers
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -eq $ExistingApp)
    {
        Write-Error (Get-ResourceString RemoteAppDoesNotExist $CollectionName, $Alias)
        return
    }

    $appPropertiesForInitialValidation = Get-BoundParameter $PSBoundParameters @{"DisplayName" = "DisplayName"; "FilePath" = "FilePath"; "FolderName" = "FolderName"; "IconPath" = "IconPath"}
    
    try
    {
        Confirm-ValidRemoteAppPropertiesForSetOrNew @appPropertiesForInitialValidation
    }
    catch
    {
        Write-Error $_
        return
    }

    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 20

    #
    # Do more thorough validation
    #
    $appProperties = Get-BoundParameter $PSBoundParameters @{"Alias" = "AppAlias";
                                                             "DisplayName" = "DisplayName";
                                                             "ShowInWebAccess" = "ShowInPortal";
                                                             "FolderName" = "Folder";
                                                             "CommandLineSetting" = "CommandLineSetting";
                                                             "RequiredCommandLine" = "RequiredCommandLine";
                                                             "IconPath" = "IconPath";
                                                             "IconIndex" = "IconIndex";
                                                             "FilePath" = "AppPath";
                                                             "FileVirtualPath" = "VirtualPath"}
    
    $appProperties["PoolName"] = $collectionAlias

    # The workflows accept $null but not "" as a way to specify that the app is not in any folders
    if($appProperties.ContainsKey("Folder") -and ("" -eq $appProperties["Folder"]))
    {
        $appProperties["Folder"] = $null
    }
    
    # The workflows accept " " but not $null to set no required command-line args
    if($appProperties.ContainsKey("RequiredCommandLine") -and [System.String]::IsNullOrEmpty($appProperties["RequiredCommandLine"]))
    {
        $appProperties["RequiredCommandLine"] = " "
    }
    
    # Convert the UserGroups array to a security descriptor
    if($PSBoundParameters.ContainsKey("UserGroups"))
    {
        if(($null -eq $UserGroups) -or ($UserGroups.Count -eq 0))
        {
            # The workflow requires a string with one space in it to represent an empty security descriptor
            $appProperties["SecurityDescriptor"] = " "
        }
        else
        {
            $appProperties["SecurityDescriptor"] = Get-SecurityDescriptorFromUserGroup($UserGroups)
            if($null -eq $appProperties["SecurityDescriptor"])
            {
                Write-Error (Get-ResourceString InvalidUserGroupNoErr $UserGroups)
                return
            }
        }
    }
    
    #
    # Fill in the appProperties map with any missing parameters
    #

    $shouldUpdateIconContents = $appProperties.ContainsKey("IconIndex") -or $appProperties.ContainsKey("IconPath")

    if(!$appProperties.ContainsKey("DisplayName")) 
    {
        $appProperties["DisplayName"] = $ExistingApp.DisplayName
    }
    if(!$appProperties.ContainsKey("ShowInPortal")) 
    {
        $appProperties["ShowInPortal"] = $ExistingApp.ShowInPortal
    }
    if(!$appProperties.ContainsKey("Folder")) 
    {
        $appProperties["Folder"] = $ExistingApp.Folder
    }
    if(!$appProperties.ContainsKey("CommandLineSetting")) 
    {
        $appProperties["CommandLineSetting"] = $ExistingApp.CommandLineSetting
    }
    if(!$appProperties.ContainsKey("RequiredCommandLine")) 
    {
        if([System.String]::IsNullOrEmpty($ExistingApp.RequiredCommandLine))
        {
            # The workflow requires a string with one space in it to represent an empty required command-line
            $appProperties["RequiredCommandLine"] = " "
        }
        else
        {
            $appProperties["RequiredCommandLine"] = $ExistingApp.RequiredCommandLine
        }
    }
    if(!$appProperties.ContainsKey("SecurityDescriptor")) 
    {
        if([System.String]::IsNullOrEmpty($ExistingApp.SecurityDescriptor))
        {
            # The workflow requires a string with one space in it to represent an empty security descriptor
            $appProperties["SecurityDescriptor"] = " "
        }
        else
        {
            $appProperties["SecurityDescriptor"] = $ExistingApp.SecurityDescriptor
        }
    }
    if(!$appProperties.ContainsKey("IconPath")) 
    {
        $appProperties["IconPath"] = $ExistingApp.IconPath
    }
    if(!$appProperties.ContainsKey("IconIndex")) 
    {
        $appProperties["IconIndex"] = $ExistingApp.IconIndex
    }
    if(!$appProperties.ContainsKey("AppPath")) 
    {
        $appProperties["AppPath"] = $ExistingApp.AppPath
    }
    if(!$appProperties.ContainsKey("VirtualPath")) 
    {
        $appProperties["VirtualPath"] = $ExistingApp.VirtualPath
    }
    
    if($shouldUpdateIconContents) 
    {
        $activity = Get-ResourceString GetAppIconInProgress
        Write-Progress -Activity $activity -PercentComplete 40
    
        # If we've gotten this far, then we know IconPath is not null
        try
        {
            $appProperties["IconContents"] = Get-RDIconContent -Endpoint $Endpoint -IsVDI ($PsCmdlet.ParameterSetName -eq "VirtualDesktop") -IconPath $appProperties["IconPath"] -IconIndex $appProperties["IconIndex"]
        }
        catch
        {
            Write-Error $_
            return
        }
        
        if($appProperties["IconContents"].Count -eq 0)
        {
            # for RemoteApps, we need a valid icon
            Write-Error (Get-ResourceString RemoteAppValidIconRequiredError)
            return
        }
    }
    else 
    {
        $appProperties["IconContents"] = $ExistingApp.IconContents
    }

    # Update the app
    $activity = Get-ResourceString UpdatingAppInProgress
    Write-Progress -Activity $activity -PercentComplete 75
    
    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $appProperties) `
        {
            param($ConnectionBroker, $appProperties) 
            RDManagement\Update-PublishedApplication -RDMSServer $ConnectionBroker @appProperties
        } | Out-Null
    }
    finally
    {
        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
    
    Write-Progress -Activity " " -PercentComplete 100
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-RemoteApp {
[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254071")]
param (
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $Alias,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)

    # Validate $ConnectionBroker
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
    
    $appIdentifiers = Get-BoundParameter $PSBoundParameters @{
                        "Alias" = "AppAlias"
                        "CollectionName" = "PoolName"}
    
    # Verify CollectionName                    
    $appIdentifiers["PoolName"] = Get-CollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    if($null -eq $appIdentifiers["PoolName"])
    {
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        return
    }
    
    # Make sure we can safely make any publishing changes on this collection
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $appIdentifiers["PoolName"] -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }
    
    # Verify AppAlias
    try
    {
        $app = Get-AppWmiObject -ConnectionBroker $ConnectionBroker -CollectionAlias $appIdentifiers["PoolName"] -AppAlias $appIdentifiers["AppAlias"]
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -eq $app)
    {
        Write-Error (Get-ResourceString RemoteAppDoesNotExist $CollectionName, $appIdentifiers["AppAlias"])
        return
    }
    
    $shouldProcessMsg = Get-ResourceString ConfirmRemoveRemoteAppMsg $appIdentifiers["AppAlias"], $CollectionName
    
    if($PSCmdlet.ShouldProcess($shouldProcessMsg))
    {
        if($Force -or $PSCmdlet.ShouldContinue("", ""))
        {  
            # Unpublish the app
            try
            {
                $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $appIdentifiers) `
                {
                    param($ConnectionBroker, $appIdentifiers) 
                    RDManagement\Remove-PublishedApplication -RDMSServer $ConnectionBroker @appIdentifiers
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
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-FileTypeAssociation {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254072")]
[OutputType("Microsoft.RemoteDesktopServices.Management.FileTypeAssociation[]")]
param (
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
    [String]
    $AppAlias,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $AppDisplayName,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FileExtension,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)

    # Validate $ConnectionBroker
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

    $ftaIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "AppAlias" = "AppAlias"; "FileExtension" = "FileExtension"}

    try
    {
        $unfilteredWmiFtas = Get-FtaWmiObject -ConnectionBroker $ConnectionBroker @ftaIdentifiers 
    }
    catch
    {
        Write-Error $_
        return
    }

    if($PSBoundParameters.ContainsKey("AppDisplayName"))
    {
        # First get the list of matching apps, so that we can get a list of app aliases to match the FTA objects against
        $appIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "AppAlias" = "AppAlias" }

        try
        {
            $unfilteredWmiApps = Get-AppWmiObject -ConnectionBroker $ConnectionBroker @appIdentifiers
        }
        catch
        {
            Write-Error $_
            return
        }

        # Filter the apps based on the DisplayName parameter
        $appAliasList = @()
        
        foreach($name in $AppDisplayName)
        {
            $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $name, IgnoreCase
            
            $WildCardMatches = ($unfilteredWmiApps | Where-Object { $WildCard.IsMatch($_.DisplayName) })
            
            if($null -ne $WildCardMatches)
            {
                foreach($match in $WildCardMatches)
                {
                    if(-not $appAliasList.Contains($match.AppAlias))
                    {
                        $appAliasList += $match.AppAlias
                    }
                }
            }
            else
            {
                if(-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($name))
                {
                    Write-Verbose (Get-ResourceString CouldNotFindRemoteAppByName $name)
                }
                else
                {
                    Write-Verbose (Get-ResourceString WrnWildcardNoMatches $name)
                }
            }
        }
        
        $wmiFtas = $unfilteredWmiFtas | Where-Object { $appAliasList.Contains($_.AppAlias) }
    }
    else
    {
        $wmiFtas = $unfilteredWmiFtas
    }

    foreach($wmiFta in $wmiFtas)
    {
        # user does not have to specify CollectionName in input args, so we may have to fetch it based on the alias
        if(!$PSBoundParameters.ContainsKey("CollectionName"))
        {
            $CollectionName = Get-CollectionNameFromAlias -CollectionAlias $wmiFta.PoolName -ConnectionBroker $ConnectionBroker            
            if($null -eq $CollectionName)
            {
                Write-Error (Get-ResourceString InvalidFtaObjectError $wmiFta.ExtName, $wmiApp.PoolName)
            }
        }
    
        New-Object Microsoft.RemoteDesktopServices.Management.FileTypeAssociation `
            -ArgumentList $CollectionName, $wmiFta.AppAlias, $wmiFta.ExtName, $wmiFta.ProgIdHint, $wmiFta.IsPublished, $wmiFta.IconContents, $wmiFta.IconIndex, $wmiFta.IconPath                   
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-FileTypeAssociation {
[CmdletBinding(DefaultParameterSetName="Session",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254073")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $AppAlias,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]
    $FileExtension,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $IsPublished,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconPath,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String]
    $IconIndex,
    
    [Parameter(Mandatory=$true, ParameterSetName="VirtualDesktop")]
    [Alias('VMName')]
    [String]
    $VirtualDesktopName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $ConnectionBroker
)
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 0
    
    # Validate $ConnectionBroker
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

    $endpointParams = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName"; "VirtualDesktopName" = "VirtualDesktopName"; "ConnectionBroker" = "ConnectionBroker"}
    
    # Make sure ConnectionBroker is up to date in case it was changed by Initialize-Fqdn
    $endpointParams["ConnectionBroker"] = $ConnectionBroker
    
    $ftaIdentifiers = Get-BoundParameter $PSBoundParameters @{"AppAlias" = "AppAlias"; "FileExtension" = "FileExtension"}
    
    # Get-PublishingRDEndpoint validates $CollectionName and $VirtualDesktopName for us
    try
    {
        $endpoint = Get-PublishingRDEndpoint @endpointParams
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if ($null -eq $endpoint)
    {
        return
    }

    if ($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
    {
        $ftaIdentifiers["CollectionAlias"] = Get-VMCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    else # Session Collection
    {        
        $ftaIdentifiers["CollectionAlias"] = Get-SessionCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    
    if($null -eq $ftaIdentifiers["CollectionAlias"])
    {
        # Should not happen since this is validated in Get-PublishingRDEndpoint, but just to be safe...
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        return
    }

    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 5

    # Make sure we can safely make any publishing changes on this collection
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $ftaIdentifiers["CollectionAlias"] -IsVmCollection ($PsCmdlet.ParameterSetName -eq "VirtualDesktop") -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }

    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 20

    try
    {
        $existingFta = Get-FtaWmiObject -ConnectionBroker $ConnectionBroker @ftaIdentifiers
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -eq $existingFTA)
    {
        Write-Error (Get-ResourceString SetFtaDoesNotExistError $CollectionName, $AppAlias, $FileExtension)
        return
    }

    $ftaProperties = Get-BoundParameter $PSBoundParameters @{"IsPublished" = "IsPublished"; "IconPath" = "IconPath"; "IconIndex" = "IconIndex"}
    
    # Add in properties that we don't support changing
    $ftaProperties["PoolName"] = $ftaIdentifiers["CollectionAlias"]
    $ftaProperties["AppAlias"] = $existingFTA.AppAlias
    $ftaProperties["ExtName"] = $existingFTA.ExtName
    $ftaProperties["ProgIdHint"] = $existingFTA.ProgIdHint
    $ftaProperties["IsPrimaryHandler"] = $existingFTA.IsPrimaryHandler
    
    # Of the properties we do support changing, validate any ones that were passed-in, and fill in the rest with their current value
    $shouldUpdateIconContents = $ftaProperties.ContainsKey("IconIndex") -or $ftaProperties.ContainsKey("IconPath")
    
    if(!$ftaProperties.ContainsKey("IsPublished"))  # no validation required
    {
        $ftaProperties["IsPublished"] = $existingFTA.IsPublished
    }
    
    if($ftaProperties.ContainsKey("IconPath")) 
    {
        # If there isn't any file at this path, we will get an error later. But we can at least do some basic validation that it looks like a valid path...
        if(![System.String]::IsNullOrEmpty($ftaProperties["IconPath"]) -and !(Test-Path -LiteralPath $ftaProperties["IconPath"] -IsValid))
        {
            Write-Error (Get-ResourceString InvalidIconPath $ftaProperties["IconPath"])
            return
        }
    }
    else
    {
        $ftaProperties["IconPath"] = $existingFTA.IconPath
    }
    
    if(!$ftaProperties.ContainsKey("IconIndex")) # no validation required (if there is not actually an icon at this index we will get an error later)
    {
        $ftaProperties["IconIndex"] = $existingFTA.IconIndex
    }
    
    if($shouldUpdateIconContents)
    {
        $activity = Get-ResourceString GetFtaIconInProgress
        Write-Progress -Activity $activity -PercentComplete 40
    
        try
        {
            $ftaProperties["IconContents"] = Get-RDIconContent -Endpoint $endpoint -IsVDI ($PsCmdlet.ParameterSetName -eq "VirtualDesktop") -IconPath $ftaProperties["IconPath"] -IconIndex $ftaProperties["IconIndex"]
        }
        catch
        {
            $ftaProperties["IconContents"] = @()
            Write-Warning $_
        }
    }
    else
    {
        $ftaProperties["IconContents"] = $existingFTA.IconContents
    }

    # Commit the changes
    $activity = Get-ResourceString UpdateFtaInProgress
    Write-Progress -Activity $activity -PercentComplete 80

    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $ftaProperties) `
        {
            param($ConnectionBroker, $ftaProperties) 
            RDManagement\Set-FileTypeAssociation -RDMSServer $ConnectionBroker @ftaProperties
        } | Out-Null
    }
    finally
    {
        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
    
    Write-Progress -Activity " " -PercentComplete 100
}

##############################################################
######################Helper functions #######################
##############################################################


function Get-PublishingRDEndpoint {
[CmdletBinding(DefaultParameterSetName="Session")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDEndpoint")]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $CollectionName,

    [Parameter(Mandatory=$true, ParameterSetName="VirtualDesktop")]
    [String]
    $VirtualDesktopName,

    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    if ($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
    {
        # Validate $CollectionName
        try
        {
            $vmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -Filter "Name='$CollectionName'" `
                        -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            throw (Get-ResourceString LookupCollectionWmiError $_)
        }

        if($null -eq $vmColl)
        {
            throw (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        }
    
        #Validate $VirtualDesktopName
        try
        {
            $vm = Get-WmiObject Win32_RDMSVirtualDesktop -Namespace "root\cimv2\rdms" -Filter "CollectionAlias='$($vmColl.Alias)' AND Name='$VirtualDesktopName'" `
                        -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            throw (Get-ResourceString GetVirtDesktopFailed $_)
        }

        if ($null -eq $vm)
        {
            throw (Get-ResourceString VMNotFoundInCollectionError $VirtualDesktopName, $CollectionName)
        }

        $VMHostName = $vm.HostName
    }
    else # Session Collection
    {
        # Validate $CollectionName
        try
        {
            $rdshColl = Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -Filter "Name='$CollectionName'" `
                        -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch
        {
            throw (Get-ResourceString LookupCollectionWmiError $_)
        }
        
        if ($null -eq $rdshColl)
        {
            throw (Get-ResourceString RDSHCollectionNotFoundTryVdi $CollectionName)
        }
        
        # Pick the first RDSH that is up & accepting connections
        try
        {
            $sessionHosts = Get-WmiObject Win32_RDSHServer -Namespace "root\cimv2\rdms" -Filter "CollectionAlias='$($rdshColl.Alias)'" `
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

        foreach ($rdsh in $sessionHosts)
        {
            # Make a simple WMI query that should work to test if the RDSH server is accepting WMI calls...
            # Since we expect this to sometimes fail, I have set the ErrorAction to "SilentlyContinue". This suppresses
            # all errors, and lets us just do a simple check against the return object to verify success
            $res = Get-WmiObject -Class Win32_TSSystemInfo -Namespace "root\cimv2\TerminalServices" `
                                 -ComputerName $rdsh.Name -Authentication PacketPrivacy -ErrorAction SilentlyContinue
                
            if ($null -ne $res)
            {
                $RDSHName = $rdsh.Name
                break
            }
        }
        
        if ($null -eq $RDSHName)
        {
            throw (Get-ResourceString NoRunningSessionHostsFoundInCollectionError $CollectionName)
        }
    }
    
    return New-Object Microsoft.RemoteDesktopServices.Management.RDEndpoint -ArgumentList $RDSHName, $VMHostName, $VirtualDesktopName
}

function Get-AppWmiObject {

param (
    
    [Parameter(Mandatory=$false)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $CollectionAlias,
    
    [Parameter(Mandatory=$false)]
    [String]
    $AppAlias,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    # Assumes ConnectionBroker has been validated in the caller

    $appIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionAlias" = "PoolName"; "AppAlias" = "AppAlias"}
    if(!$appIdentifiers.ContainsKey("PoolName") -and $PSBoundParameters.ContainsKey("CollectionName"))
    {
        # Even though the WMI parameter is called "PoolName", it actually takes the collection *alias*
        $appIdentifiers["PoolName"] = Get-CollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
        if($null -eq $appIdentifiers["PoolName"])
        {
            throw (Get-ResourceString CollectionDoesNotExist $CollectionName)
        }
    }
    
    # Build a WMI filter string to only fetch the app(s) requested, based on the optional input parameters
    $filterStrings = @()
    foreach ($param in $appIdentifiers.Keys)
    {
        $filterStrings += "$param='" + $appIdentifiers[$param] + "'"
    }
    $filter = $filterStrings -join " AND "
    
    try
    {
        $wmiApps = Get-WMIObject -class "Win32_RDMSPublishedApplication" -namespace "root\cimv2\rdms" -filter $filter `
                                 -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        throw (Get-ResourceString GetRemoteAppsWmiError $_)
    }

    return $wmiApps
}

function Get-FtaWmiObject {

param (
    
    [Parameter(Mandatory=$false)]
    [String]
    $CollectionName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $CollectionAlias,
    
    [Parameter(Mandatory=$false)]
    [String]
    $AppAlias,
    
    [Parameter(Mandatory=$false)]
    [String]
    $FileExtension,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ConnectionBroker
)

    # Assumes ConnectionBroker has been validated in the caller

    $ftaIdentifiers = Get-BoundParameter $PSBoundParameters @{"CollectionAlias" = "PoolName"; "AppAlias" = "AppAlias"; "FileExtension" = "ExtName"}
    if(!$ftaIdentifiers.ContainsKey("PoolName") -and $PSBoundParameters.ContainsKey("CollectionName"))
    {
        # Even though the WMI parameter is called "PoolName", it actually takes the collection *alias*
        $ftaIdentifiers["PoolName"] = Get-CollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
        if($null -eq $ftaIdentifiers["PoolName"])
        {
            throw (Get-ResourceString CollectionDoesNotExist $CollectionName)
        }
    }
    
    # Build a WMI filter string to only fetch the FTA(s) requested, based on the optional input parameters
    $filterStrings = @()
    foreach ($param in $ftaIdentifiers.Keys)
    {
        $filterStrings += "$param='" + $ftaIdentifiers[$param] + "'"
    }
    $filter = $filterStrings -join " AND "
    
    try
    {
        $wmiFtas = Get-WMIObject -class "Win32_RDMSFileTypeAssociation" -namespace "root\cimv2\rdms" -filter $filter `
                                 -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        throw (Get-ResourceString GetFtasWmiError $_)
    }

    return $wmiFtas
}

# Returns $null on fatal error
function Get-RDIconContent {

param (
    [Parameter(Mandatory=$true)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $IconPath,
    
    [Parameter(Mandatory=$true)]
    [Int32]
    $IconIndex,
    
    [Parameter(Mandatory=$true)]
    [Microsoft.RemoteDesktopServices.Management.RDEndpoint]
    $Endpoint,
    
    [Parameter(Mandatory=$true)]
    [bool]
    $IsVDI
)
    $iconContents = @()

    # If the path is empty, just return an empty array to clear out the icon contents. Otherwise...
    if(![System.string]::IsNullOrEmpty($IconPath)) 
    {
        try
        {
            if($IsVDI)
            {
                $ret = Open-RDVMFirewall -VMName $Endpoint.VMName -VMHostName $Endpoint.VMHostName
                if(!$ret)
                {
                    throw (Get-ResourceString FirewallDisableFailedError $Endpoint.VMName)
                }
                
                # This API only works if the VM is running, so it must be called after Open-RDVMFirewall
                $EndpointName = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetVirtualMachineFullyQualifiedDomainName($Endpoint.VMName, $Endpoint.VMHostName)
            }
            else
            {
                $EndpointName = $Endpoint.RDSHName
            }
            
            Write-Verbose "Fetching icon contents from endpoint: $EndpointName"
        
            $iconContents = Get-RemoteAppIconContent -MachineName $EndpointName -IconPath $IconPath -IconIndex $IconIndex
            # Throws an exception upon error, the caller will handle it.
            if($null -eq $iconContents)
            {
                # There was some problem getting the icon, so clear it out.
                $iconContents = @()
            }
        }
        finally
        {
            if($IsVDI)
            {
                # We've already fetched the icon, and Close-RDVMFirewall
                if ( -not (Close-RDVMFirewall -VMName $Endpoint.VMName -VMHostName $Endpoint.VMHostName) )
                {
                    throw (Get-ResourceString FirewallEnableFailedError $Endpoint.VMName)
                }
            }
        }
    }
    
    return $iconContents
}

function Confirm-ValidAppAlias {

param (
    [Parameter(Mandatory=$true, Position=0)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $AppAlias
)

    $invalidChars = @('*', '?', '"', ':', '<', '>', '|', '\', '/', "'")

    # We could use the built-in mandatory parameter validation on this helper method to enforce that it is not null or empty, but the error message it makes
    # is not very helpful to end-users, so we'll handle it in code:
    if([System.String]::IsNullOrEmpty($AppAlias))
    {
        $isValid = $false
    }
    else
    {
        $index = $AppAlias.IndexOfAny($invalidChars)
        
        # Returns -1 if none of the characters are found
        $isValid = ($index -eq -1)
    }
    
    if(!$isValid)
    {
        $invalidCharsString = [System.String]::Join(' ', $invalidChars)
        throw (Get-ResourceString RemoteAppInvalidAlias $AppAlias, $invalidCharsString)
    }
}

function Confirm-ValidRemoteAppPropertiesForSetOrNew {

param (
    [Parameter(Mandatory=$false)]
    [String]
    $DisplayName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $FilePath,
    
    [Parameter(Mandatory=$false)]
    [String]
    $FolderName,
    
    [Parameter(Mandatory=$false)]
    [String]
    $IconPath
)

    $invalidNameAndFolderChars = [System.IO.Path]::GetInvalidFileNameChars()
    if($PSBoundParameters.ContainsKey("DisplayName"))
    {
        $maxDisplayNameLength = 256
        if([System.String]::IsNullOrEmpty($DisplayName) -or ($DisplayName.Length -gt $maxDisplayNameLength) -or (-1 -ne $DisplayName.IndexOfAny($invalidNameAndFolderChars)))
        {
            $invalidNameCharsString = [System.String]::Join(' ', $invalidNameAndFolderChars)
            throw (Get-ResourceString RemoteAppInvalidDisplayName $DisplayName, $maxDisplayNameLength, $invalidNameCharsString)
        }
    }
    
    if($PSBoundParameters.ContainsKey("FilePath"))
    {
        if([System.String]::IsNullOrEmpty($FilePath) -or !(Test-Path -LiteralPath $FilePath -IsValid))
        {
            throw (Get-ResourceString RemoteAppInvalidAppPath $FilePath)
        }
    }
    
    if($PSBoundParameters.ContainsKey("FolderName"))
    {
        if(![System.String]::IsNullOrEmpty($FolderName))
        {
            $maxFolderLength = 64
            
            $invalidFolderChars = '<>:"/\|?*'
            if(($FolderName.Length -gt $maxFolderLength) -or (-1 -ne $FolderName.IndexOfAny($invalidFolderChars)) -or ("." -eq $FolderName) -or (".." -eq $FolderName))
            {
                $invalidFolderCharsString = [System.String]::Join(' ', $invalidNameAndFolderChars)
                throw (Get-ResourceString RemoteAppInvalidFolder $FolderName, $maxFolderLength, $invalidFolderChars)
            }
            
            $FolderNameChars = $FolderName.ToCharArray()
            
            foreach ($c in $FolderNameChars)
            {
                $asc = $c -as [System.Int32]
                if ($asc -le 31)
                {
                    throw (Get-ResourceString RemoteAppInvalidFolderLowChars $FolderName)
                }
            }
        }
    }
    
    if($PSBoundParameters.ContainsKey("IconPath"))
    {
        if([System.String]::IsNullOrEmpty($IconPath) -or !(Test-Path -LiteralPath $IconPath -IsValid))
        {
            throw (Get-ResourceString InvalidIconPath $IconPath)
        }
    }
}
