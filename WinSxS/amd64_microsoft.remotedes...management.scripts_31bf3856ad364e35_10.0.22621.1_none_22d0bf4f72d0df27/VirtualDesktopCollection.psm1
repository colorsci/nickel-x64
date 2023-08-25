
Import-Module $PSScriptRoot\Utility.psm1


# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-VirtualDesktopCollection {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254090")]
param(
#switch for collection type
    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [switch]
    $PooledManaged,

    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [switch]
    $PersonalManaged,

    [Parameter(Mandatory=$true, ParameterSetName="PooledUnmgd")]
    [switch]
    $PooledUnmanaged,

    [Parameter(Mandatory=$true, ParameterSetName="PersonalUnmgd")]
    [switch]
    $PersonalUnmanaged,
#common params
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$false)]
    [string]
    $Description,

    [Parameter(Mandatory=$false)]
    [string[]]
    $UserGroups,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

#Unmanaged collection Params
    [Parameter(Mandatory=$true, ParameterSetName="PooledUnmgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalUnmgd")]
    [string[]]
    $VirtualDesktopName,

#Managed collection Params
    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [string]
    $VirtualDesktopTemplateName,

    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [string]
    $VirtualDesktopTemplateHostServer,

    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [Hashtable]
    $VirtualDesktopAllocation,

    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]
    $StorageType,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $CentralStoragePath,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $LocalStoragePath,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [string]
    $VirtualDesktopTemplateStoragePath,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $Domain,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $OU="",

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $CustomSysprepUnattendFilePath,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $VirtualDesktopNamePrefix,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [switch]
    $DisableVirtualDesktopRollback,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [ValidateRange(31,365)]
    [int]
    $VirtualDesktopPasswordAge,

#shared coll params
    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PooledUnmgd")]
    [string]
    $UserProfileDiskPath,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PooledUnmgd")]
    [ValidateRange(1,9999)]
    [int]
    $MaxUserProfileDiskSizeGB=40,
   
#personal coll params
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalUnmgd")]
    [switch]
    $AutoAssignPersonalVirtualDesktopToUser,

    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [Parameter(Mandatory=$false, ParameterSetName="PersonalUnmgd")]
    [switch]
    $GrantAdministrativePrivilege,

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

    #verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    #Verify that collection with same name does not exist
    Write-Verbose (Get-ResourceString VerifyingInput)
    if(-not (Confirm-CollectionNameDoesNotExist -CollectionName $CollectionName -RDMgmtServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString RDVHCollectionAlreadyExist)
        return
    }

    #verify IF User VHD path is given is not already used in the deployment
    if($PSBoundParameters["UserProfileDiskPath"])
    {   
        #check UserVhd path is not in use     
        if (Test-UserVhdPathInUse -UserVhdPath $UserProfileDiskPath -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker)
        {
            Write-Error (Get-ResourceString FolderPathInUse $UserProfileDiskPath)
            return
        }
        #check UserVhd path has Everyone - warn the admin if true
        if(Test-EveryoneInUserVhdPath -UserVhdPath $UserProfileDiskPath)
        {
              Write-Warning (Get-ResourceString EveryoneHasAccess $UserProfileDiskPath)
        }
    }

    if(-not ($PSBoundParameters["Domain"]))
    {
        $Domain = Get-RDManagementServerDomain($ConnectionBroker)        
        if(-not $Domain)
        {
            Write-Error (Get-ResourceString FailedToGetComputerObject $ConnectionBroker)
            return
        }
    }
    #Handle if the user explicitly set empty array or null (e.g. "-UserGroups @()")
    if($null -eq $UserGroups)
    {
        # find domain users name
        
        $UserGroups = ConvertTo-NtAccount([microsoft.remotedesktopservices.common.commonutility]::GetCurrentDomainUserSid())
    }
    elseif($UserGroups.Count -eq 0)
    {
        Write-Error (Get-ResourceString ErrVmCollectionRequiresUserGroups)
        return
    }
    
    #Prepare Security descriptor for all the user Groups, also does the validation by converting them to Sids
    $secDesc=Get-SecurityDescriptorFromUserGroup($UserGroups)
    if(-not $secDesc)
    {
        Write-Error (Get-ResourceString InvalidUserGroupNoErr $UserGroups)
        return
    }

    #set collection type depending on switch param and AutoAssign
    $type=1
    if( ($PSBoundParameters["PooledManaged"]) -or
        ($PSBoundParameters["PooledUnmanaged"]) )
    {
        $type=1
    }
    elseif ($AutoAssignPersonalVirtualDesktopToUser)
    {
        $type=3
    }
    else
    {
        $type=2
    }

    #Generate Unique collection ID, For now reuse Name
    $alias = Get-CollectionAlias -CollectionName $CollectionName -RDManagementServer $ConnectionBroker
    if([string]::IsNullOrEmpty($alias))
    {
        Write-Error (Get-ResourceString CannotCreateCollectionAlias)
        return
    }

    #check if managed or Unmanaged
    $managed = $false
    if( ($PSBoundParameters["PooledManaged"]) -or
        ($PSBoundParameters["PersonalManaged"]) )
    {
        $managed = $true
    }

    if(-not ($managed))
    {
        $UnmgdVmHostList = New-Object System.Collections.Generic.List[string]
        #verify the input list of unamanged VMs
        if (-not (Test-UnmanagedVmList -VirtualDesktopList $VirtualDesktopName -ConnectionBroker $ConnectionBroker -UnmgdVmHostList $UnmgdVmHostList))
        {
            return
        }

        #create Unmanaged Collection WMI instance
        Write-Verbose (Get-ResourceString CreatingRdvhCollection $CollectionName)

        $scope = New-Object System.Management.ManagementScope
        $scope.Path = '\\'+$ConnectionBroker+'\root\cimv2\RDMS:Win32_RDMSVirtualDesktopCollection'
        $scope.Options.Authentication = [system.Management.AuthenticationLevel]::PacketPrivacy
        $scope.Options.Impersonation = [system.Management.ImpersonationLevel]::Impersonate

        $classInst = new-Object System.Management.ManagementClass($scope, $scope.Path, $null)
        
        try
        {
            $vmColl= $classInst.CreateInstance()

            $vmColl.Name=$CollectionName
            $vmColl.Alias=$alias
            $vmColl.IsHA=$false
            $vmColl.IsManaged=$false
            $vmColl.IsUserAdmin=$GrantAdministrativePrivilege
            $vmColl.SecurityDescriptor=$secDesc
            $vmColl.ShowInPortal=$true
            $vmColl.Type=$type
            $vmColl.CollectionDescription=$Description
            $putRes = $vmColl.Put()
        }
        catch
        {
            $errMsg = $_.Exception.Message
        }

        if( -not $putRes )
        {
            Write-Error (Get-ResourceString CreateRdvhCollectionFailed $errMsg)
            return
        }


        #join virtual machines to collection
        Add-RDVirtualDesktopToCollection $CollectionName -VirtualDesktopName $VirtualDesktopName -ConnectionBroker $ConnectionBroker | Out-Null

        #set the default RDP properties for the collection
        Update-CollectionPropertiesToDefault -CollectionName $CollectionName -IsVMCollection $true -ConnectionBroker $ConnectionBroker

        if($PSBoundParameters["UserProfileDiskPath"])
        {        
            Write-Verbose "Enabling user profile disks"
            try
            {
                $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                Invoke-Command -Session $workflowSession -ArgumentList $ConnectionBroker, $alias, $UserProfileDiskPath, $MaxUserProfileDiskSizeGB `
                {
                    param($ConnectionBroker, $alias, $UserProfileDiskPath, $MaxUserProfileDiskSizeGB ) 
                    RDManagement\Enable-UserDataVHD -RDMSServer $ConnectionBroker -CollectionAlias $alias -UserVhdShare $UserProfileDiskPath `
                        -DiskSize ([UInt64]($MaxUserProfileDiskSizeGB*1GB)) -DiskType 1 -RemapMode 0
                } | Out-Null
            }
            catch
            {
                Write-Error (Get-ResourceString FailedToEnableUvhd)
            }
            finally
            {
                if($workflowSession)
                {
                    Remove-PSSession -Session $workflowSession
                }
            }
        }

        #return object for the created collection
        Get-RDVirtualDesktopCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
        return
    }


    #Call the Util fn to verify domain and OU
    # this fn will convert the OU to the DN if only OU name is specified in non-distinguished name format
    if( ($PSBoundParameters["OU"]))
    {
        $OU = Get-DistinguishedName -Domain $Domain -OrganizationalUnit $OU
        if(-not $OU)
        {
            Write-Error (Get-ResourceString InvalidDomainOrOU $Domain, $OU)
            return
        }
        Write-Verbose ("Testing OU permissions")
        if(-not (Test-RDOUAccess -Domain $Domain -OU $OU -ConnectionBroker $ConnectionBroker))
        {
            if($Force)
            {
                Write-Warning (Get-ResourceString WrnOUAccessNotGranted $OU)
            }
            else
            {
                if(-not $PSCmdlet.ShouldContinue((Get-ResourceString ShouldContinueOUAccessNotGranted $OU), ""))
                {
                    return
                }
            }
        }
    }
    else
    {
        #call the Get-DistinguishedName to verify the domain only
        $computersOU = Get-DistinguishedName -Domain $Domain -OrganizationalUnit "Computers"
        if(-not $computersOU)
        {
            Write-Error (Get-ResourceString InvalidDomainOrOU $Domain, $OU)
            return
        } 

        if(-not (Test-RDOUAccess -Domain $Domain -OU $computersOU -ConnectionBroker $ConnectionBroker))
        {
            if($Force)
            {
                Write-Warning (Get-ResourceString WrnOUAccessNotGranted $computersOU)
            }
            else
            {
                if(-not $PSCmdlet.ShouldContinue((Get-ResourceString ShouldContinueOUAccessNotGranted $computersOU), ""))
                {
                    return
                }
            }
        }
    }
    

    #Trim the Naming prefix for auto created VMs
    if (-not ($VirtualDesktopNamePrefix))
    {
        $VirtualDesktopNamePrefix = ($alias+"-")
        Write-Verbose ("No virtual desktop name prefix specified, using collection alias: "+$VirtualDesktopNamePrefix)
    }
    if($VirtualDesktopNamePrefix.Length -gt 11)
    {
        $VirtualDesktopNamePrefix=$VirtualDesktopNamePrefix.Substring(0,11)
        Write-Verbose ("Name prefix exceeds max length--Trimmed virtual desktop name prefix: "+$VirtualDesktopNamePrefix)
    }

    #set the machine password expiry registry keys for all the hosts only when Rollback is enabled!
    #hence applicable only to PooledManaged
    if (($PSBoundParameters["VirtualDesktopPasswordAge"]))
    {
        if ( -not($PSBoundParameters["PooledManaged"]) -or ($DisableVirtualDesktopRollback))
        {
            Write-Error (Get-ResourceString InvalidHostConfigurationSetting "VirtualDesktopPasswordAge")
            return
        }
    }

    #validate input managed VM collection params
    $validateParams=Get-BoundParameter $PSBoundParameters @{
                                        "CollectionName" = "CollectionName"
                                        "VirtualDesktopTemplateHostServer"="VirtualDesktopTemplateHostServer"
                                        "VirtualDesktopTemplateName"="VirtualDesktopTemplateName"
                                        "CustomSysprepUnattendFilePath"="CustomUnattend"
                                        "StorageType"="StorageType"
                                        "LocalStoragePath"="LocalStoragePath"
                                        "CentralStoragePath"="CentralStoragePath"
                                        "VirtualDesktopTemplateStoragePath"="VmTemplateStoragePath"
                                        "UserProfileDiskPath"="UvhdSharePath"
                                        "MaxUserProfileDiskSizeGB"="UvhdSize"
                                        }
    if( -not (Test-ManagedParam @validateParams -Type $type -VmNamePrefix $VirtualDesktopNamePrefix `
                -VmDistribution $VirtualDesktopAllocation -ConnectionBroker $ConnectionBroker))
    {
        return
    }
        

    ##
    ## Setup export paths
    ##

    #prepare host name list
    $hostList = New-Object System.Collections.Generic.List[string]
    foreach($hostName in $VirtualDesktopAllocation.Keys)
    {
        $hostList.Add($hostName)
    }
    #Get export root
    $exportRoot = Get-ExportRoot -StorageType $StorageType  -CentralStoragePath $CentralStoragePath -VmTemplateStoragePath $VirtualDesktopTemplateStoragePath -ConnectionBroker $ConnectionBroker
    if(-not $exportRoot)
    {
        return
    }
    #make sure export root is accessible from masterVM host for SAN case
    if($StorageType -eq [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSanStorage)
    {
        if(-not (Test-LocalStoragePath -Path $exportRoot -HostList $VirtualDesktopTemplateHostServer))
        {
            return
        }
    }

    #make sure that Master VM Host server has permissions and access to the export share
    if(-not (Set-ShareProvisioningPermissions -Path $exportRoot -HostList $VirtualDesktopTemplateHostServer))
    {
        return
    }

    # make sure that for local storage the export share has perms for all the host, because export root will be 
    # different from local VM creation path and template Storage paths
    if($StorageType -eq [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::LocalStorage)
    {
        if(-not (Set-ShareProvisioningPermissions -Path $exportRoot -HostList $hostList))
        {
            return
        }

        #make sure that Master VM Host server has permissions and access to the export share
        if(-not (Set-ShareProvisioningPermissions -Path $exportRoot -HostList $VirtualDesktopTemplateHostServer))
        {
            return
        }
    }

    #TODO: ???share the "default" export Root when Storage type is local, OR is it shared by RDMS automatically???
    $exportPath = New-VMExportLocation -ExportRoot $exportRoot -Alias $alias -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer
    if(-not $exportPath)
    {
        return
    }

    #get all host servers in the deployment
    $allHostsList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role "RDS-VIRTUALIZATION"
    $hostNamesList = New-Object System.Collections.Generic.List[string]
    foreach($hostName in $allHostsList.Server)
    {
        $hostNamesList.Add($hostName)
    }

    if(-not $hostNamesList)
    {
        Write-Error ("The RDVHs list is empty!")
        return
    } 
    #Setup paths and constants depending on storage type - give all hosts permissions to the SMB share
    if(-not (Set-StoragePermissions  -StorageType $StorageType -CentralStoragePath $CentralStoragePath -LocalStoragePath $LocalStoragePath `
                            -VmTemplateStoragePath $VirtualDesktopTemplateStoragePath -HostList $hostNamesList))
 
    {
        return
    }

    ##
    ## Prepare Provisioning Parameters
    ##

    #select disk type depending on the pooltype
    $vhdType = "DiffDisk"
    if(1 -ne $type)
    {
        $vhdType = "Clone"
    }

    $runVmFromSmb = 0
    $enableVmStreaming = 0
    $highlyAvailable = $false
    switch($StorageType)
    {
        #[Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::
        LocalStorage
        {
            $smbShare=""
            $runVmFromSmb=0
            $enableVmStreaming=0
        }
        #[Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::
        CentralSmbShareStorage
        {
            $smbShare=$CentralStoragePath
            $runVmFromSmb=1
            $enableVmStreaming=0
            $LocalStoragePath=$null #make sure it is null
        }
        #[Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::
        CentralSanStorage
        {
            $smbShare=""
            $runVmFromSmb=1
            $enableVmStreaming=0
            $LocalStoragePath=$CentralStoragePath
            $highlyAvailable = $true            
        }
    }

    # Setting the password age for the VMs across all the hosts.
    if (($PSBoundParameters["VirtualDesktopPasswordAge"]))
    {
        if (-not (Set-VirtualDesktopHostSetting -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker `
                        -Name "VirtualDesktopPasswordAge" -Value $VirtualDesktopPasswordAge))
        {
            return
        }
    }

    #create provisioning XML
    $provXml = Get-ProvisioningXml -CollectionAlias $alias -Job "Create" -VhdType $vhdType -BaseVmLocation $exportPath `
                    -SmbShare $smbShare -LocalVmCreationPath $LocalStoragePath -LocalGoldCachePath $VirtualDesktopTemplateStoragePath `
                    -RunVmFromSmb $runVmFromSmb -EnableVmStreaming $enableVmStreaming -CustomUnattend $CustomSysprepUnattendFilePath `
                    -Prefix $VirtualDesktopNamePrefix -StartIndex 1 -Domain $Domain -OU $OU -HostList $VirtualDesktopAllocation `
                    -HighlyAvailable $highlyAvailable
    if(-not $provXml)
    {
        return
    }

    ##
    ## Call New-RDVMCollection Workflow
    ##

    #get mapping input params
    $params = Get-BoundParameter $PSBoundParameters @{
                                            "CollectionName" = "Name"
                                            "Description"="Description"
                                            "VirtualDesktopTemplateHostServer"="MasterVmhostServer"
                                            "VirtualDesktopTemplateName"="MasterVmName"
                                            "UserProfileDiskPath"="UserDataVHDShare"
                                            "MaxUserProfileDiskSizeGB"="UserDataVHDDiskSize"
                                            }                                                                                            
    #set EnableRollback input param
    $params["RollbackEnabled"] = [bool](-not $DisableVirtualDesktopRollback)

    #invoke create collection XAML from RDManagement, it does the export, creates collection and rollout VMs
    $workflowSuccess = $true
    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($params, $type, $alias, $highlyAvailable, $exportPath, $secDesc, $provXml, $ConnectionBroker, $GrantAdministrativePrivilege) `
        {
            param($params, $type, $alias, $highlyAvailable, $exportPath, $secDesc, $provXml, $ConnectionBroker, $GrantAdministrativePrivilege) 
            RDManagement\New-RDVMCollection @params -Type $type -Managed $true -CollectionAlias $alias -HighlyAvailable $highlyAvailable `
                            -ExportLocation $exportPath -UserSecurityDescriptor $secDesc `
                            -ProvisioningXml $provXml -RDManagementServer $ConnectionBroker -IsUserAdmin $GrantAdministrativePrivilege
        }| Out-Null
        # TODO: error handling
    }
    catch
    {
        $workflowSuccess=$false
        $errMsg = $_.Exception.Message
    }
    finally
    {
        if($workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
    
    #workflow succeeded, get the collection instance
    if($workflowSuccess)
    {
        $x=Get-RDVirtualDesktopCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
        if($x)
        {
            Update-CollectionPropertiesToDefault -CollectionName $CollectionName -IsVMCollection $true -ConnectionBroker $ConnectionBroker
            #update the ExportInProgress property to default
            try
            {
                $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                        -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                            -Filter "Name='$CollectionName'"
                $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
            }
            catch
            {
                #ignore the error
                Write-Debug ("Failed to set the exportInProgress to default");
            }

            $x
        }
        else
        {
            Write-Error (Get-ResourceString CreateRdvhCollectionFailed $errMsg)
        }
    }
    else
    {
        Write-Error (Get-ResourceString CreateRdvhCollectionFailed $errMsg)
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktopCollection {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254091")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollection[]")]
param(
    [Parameter(Mandatory=$false, Position=0)]
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

    #verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $query=""
    if( -not $CollectionName)
    {
        $query = "Select * from Win32_RDMSVirtualDesktopCollection"
    }
    else
    {
        $query = "Select * from Win32_RDMSVirtualDesktopCollection where Name='"+$CollectionName+"'"
    }
    try
    {
        $rdvmCollections = Get-WmiObject -Query $query -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                        -Impersonation Impersonate -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if(-not $rdvmCollections)
    {
        Write-Verbose (Get-ResourceString RdvmCollectionNotFound)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        if(![string]::IsNullOrEmpty($CollectionName))
        {
            Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        }
        return
    }

    foreach($rdvmColl in $rdvmCollections)
    {
        $securityGroups = Get-UserGroupsFromSecurityDescriptor($rdvmColl.SecurityDescriptor)
        $type = $rdvmColl.Type
        
        $rdCollectionType = 0
        $autoassign = $false
            
        Get-RDVirtualDesktopCollectionType -BackEndCollectionType $rdvmColl.Type -IsManaged $rdvmColl.IsManaged ([ref] $rdCollectionType) ([ref] $autoassign)

        #get size and in use counts
        try
        {
            $alias=$rdvmColl.Alias
            $vdObjs = [wmi[]](Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "CollectionAlias='$alias'")
            $size=$vdObjs.Count

            $percentInUse=0

            if($size)
            {
                $currSessions = [wmi[]](Get-WmiObject -Class "Win32_SessionDirectorySessionEx" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "CollectionAlias='$alias'")


                if($currSessions)
                {
                    $percentInUse = [int](($currSessions.Count/$size)*100)
                } 
            }
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }
        New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollection `
                                        -ArgumentList $rdvmColl.Alias, $rdvmColl.Name, $rdvmColl.CollectionDescription, $rdCollectionType, `
                                        $rdvmColl.ShowInPortal, $autoassign, $rdvmColl.IsUserAdmin, $rdvmColl.RollbackEnabled, `
                                        $securityGroups,$size,$percentInUse
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-VirtualDesktopCollection {

[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254092")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
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

    #verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #get all the VMs in the collection
    try
    {
        $alias = $rdvmColl.Alias
        $vmObjs = Get-WmiObject Win32_RDMSVirtualDesktop -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "CollectionAlias='$alias'"
    }
    catch
    {
        #write the error and try to delete the pool
        Write-Error ($_.Exception.Message)
    }

    $promptMsg = (Get-ResourceString RemoveVmCollMsg $rdvmColl.Name)
    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    #If there are VMs in the pool, clenaup
    if(($vmObjs))
    {
        Write-Verbose (Get-ResourceString RemovingVirtDesktopFromCollection)
			
        #If managed pool start provisioning delete job
        if ($rdvmColl.IsManaged) 
        {
            #verify if there is another job already running
            if(-not (Test-ScheduleProvisioningJob ($rdvmColl)))
            {
                return
            }

            #get Provisioning XML using saved Prov Props for the coll
            $masterLocation=""
            $provXml = Get-ProvXmlForExistingCollection -RdvmColl $rdvmColl -Type $rdvmColl.Type -JobType "Delete" ([ref] $masterLocation) -ConnectionBroker $ConnectionBroker
            if(-not $provXml)
            {
                return
            }

            #start provisioning job
            try
            {
                $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                Invoke-Command -Session $workflowSession -ArgumentList @($rdvmColl.Alias, $provXml, $ConnectionBroker) `
                {
                    param($alias, $provXml, $ConnectionBroker)
                    RDManagement\Start-RDVMRollout -Alias $alias -ProvisioningXml $provXml -ManagementServer $ConnectionBroker
                } | Out-Null
                # TODO: error handling
            }
            catch
            {
                Write-Error (Get-ResourceString DeleteMgdVmFromCollectionFailed $_.Exception.Message)
            }
            finally
            {
                if($workflowSession)
                {
                    Remove-PSSession -Session $workflowSession
                }
            }


            #delete master export location(s)
            Remove-Item ($masterLocation+"\..\__*") -Recurse -Force -ErrorAction SilentlyContinue
        }

        #now for both managed and unmanaged collections, remove vms from collection
        foreach($vm in $vmObjs)
        { 
            $errMsg = $null
            try
            {
                $remRes = $rdvmColl.RemoveVirtualDesktop($vm.Name)
            }
            catch
            {
                $errMsg = $_.Exception.Message
            }
            if(-not $remRes)
            {
                Write-Error (Get-ResourceString DeleteUnmgdVmFromCollectionFailed $vm,$errMsg)
            }
            elseif(0 -ne $remRes.ReturnValue)
            {
                Write-Error (Get-ResourceString DeleteUnmgdVmFromCollectionFailed $vm,$remRes.ReturnValue)
            }
        }
    }

    #remove collection instance
    try
    {
        #todo: check $out
        $delRes = $rdvmColl.Delete()
    }
    catch
    {
        $delErrMsg = $_.Exception.Message
    }
    if($delErrMsg)
    {
        Write-Error (Get-ResourceString DeleteRdvhCollectionFailed $delErrMsg)
        return
    }
    Write-Verbose (Get-ResourceString CollectionDeleted)
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Add-VirtualDesktopToCollection{
[CmdletBinding(DefaultParameterSetName="PooledMgd",
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254093")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true, ParameterSetName="UnManaged")]
    [string[]]
    $VirtualDesktopName,

    [Parameter(Mandatory=$true, ParameterSetName="PooledMgd")]
    [Parameter(Mandatory=$true, ParameterSetName="PersonalMgd")]
    [Hashtable]
    $VirtualDesktopAllocation,

    #The following three applies only to PersonalDesktop collection
    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $VirtualDesktopTemplateName,

    [Parameter(Mandatory=$false, ParameterSetName="PersonalMgd")]
    [string]
    $VirtualDesktopTemplateHostServer,

    [Parameter(Mandatory=$false, ParameterSetName="PooledMgd")]
    [ValidateRange(31,365)]
    [int]
    $VirtualDesktopPasswordAge,
            
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

    #verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #VirtualDesktopPasswordAge is allowed only for pools with rollback enb
    if ($PSBoundParameters["VirtualDesktopPasswordAge"])
    {
        if( -not ($rdvmColl.RollbackEnabled))
        {
            Write-Error (Get-ResourceString InvalidHostConfigurationSetting "VirtualDesktopPasswordAge")
            return
        }
    }
       
    if($rdvmColl.IsManaged)
    {                
        # Verify the virtual machine ditribution
        if(-not ($VirtualDesktopAllocation))
        {
            Write-Error (Get-ResourceString SpecifyVmAllocation)
            return
        }

        if (-not (Test-VmDistribution -VmDistribution $VirtualDesktopAllocation -ConnectionBroker $ConnectionBroker))
        {
            return
        }

        #verify if there is another job already running
        if(-not (Test-ScheduleProvisioningJob ($rdvmColl)))
        {
            return
        }

        # Setting the password age for the VMs across all the hosts.
        if (($PSBoundParameters["VirtualDesktopPasswordAge"]))
        {
            if (-not (Set-VirtualDesktopHostSetting -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker `
                            -Name "VirtualDesktopPasswordAge" -Value $VirtualDesktopPasswordAge))
            {
                return
            }
        }
             
        #we will not support specified new mastervm for shared/temp pools
        if ( (-not($rdvmColl.type -eq 3)) -and (-not($rdvmColl.type -eq 2)))
        {
            if(-not [string]::IsNullOrEmpty($VirtualDesktopTemplateName))
            {
                Write-Error (Get-ResourceString UnsupportedVirtualDesktopTemplateOption "VirtualDesktopTemplateName")
                return
            }  
            if(-not [string]::IsNullOrEmpty($VirtualDesktopTemplateHostServer))
            {
                Write-Error (Get-ResourceString UnsupportedVirtualDesktopTemplateOption "VirtualDesktopTemplateHostServer")
                return
            }    
        }

        #if it a managed personal desktop collection
        if( ($rdvmColl.type -eq 3) -or ($rdvmColl.type -eq 2))
        {        
            #Do we use the existing mastervm or is a new one specified?
            if(-not [string]::IsNullOrEmpty($VirtualDesktopTemplateName))
            {            
                #The check will apply only for pd collections
                if(-not(Test-MasterVm   -VirtualDesktopTemplateName $VirtualDesktopTemplateName `
                            -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer `
                            -ConnectionBroker $ConnectionBroker))
                {
                    return
                }
            
                #get provisioning properties
                try
                {
                    $alias=$rdvmColl.Alias
                    $collProps= Get-WmiObject Win32_RDMSCollectionProperties -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                            -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                            -Filter "Alias='$alias'"
                }
                catch
                {
                    Write-Error ($_.Exception.Message)
                }
                if( -not $collProps )
                {
                    Write-Error (Get-ResourceString VmCollectionPropNotFound)
                    return
                }

                try
                {
                    $provProps=$collProps.GetProvisioningProperties()
                }
                catch
                {
                    Write-Error ($_.Exception.Message)
                }
                if(-not $provProps)
                {
                    Write-Error (Get-ResourceString VmCollectionProvPropNotFound)
                    return
                }

                $oldExportPath = $provProps.MasterVmLocation

                $centralStoragePath = [string]::Empty
                if($rdvmColl.IsHA)
                {
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSanStorage
                    $centralStoragePath = $provProps.LocalVmLocation
                }
                elseif(-not [string]::IsNullOrEmpty($provProps.SMBLocation))
                {
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSmbShareStorage
                    $centralStoragePath = $provProps.SMBLocation
                }
                else
                {
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::LocalStorage
                }
                $vmTemplateStoragePath = $provProps.LocalGoldVmLocation

                #generate Export Path
                $exportRoot = Get-ExportRoot -StorageType $storageType  -CentralStoragePath $centralStoragePath -VmTemplateStoragePath $vmTemplateStoragePath -ConnectionBroker $ConnectionBroker
                if( -not $exportRoot)
                {
                    return
                }

                $exportPath = New-VMExportLocation -ExportRoot $exportRoot -Alias $rdvmColl.Alias -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer
                if(-not $exportPath)
                {
                    return
                }

                #Set Export info so that Get-Status could show export in progress
                try
                {
                    $rdvmColl.SetStringProperty("ExportInProgress",$VirtualDesktopTemplateName)|Out-Null
                }
                catch
                {
                    Write-Verbose ("Failed to set export in progress")
                    #ignore error
                }

                #export the master VM
                try
                {
                    $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

                    $masterVmDetails = Invoke-Command -Session $workflowSession -ArgumentList @($exportPath, $VirtualDesktopTemplateHostServer, $VirtualDesktopTemplateName) `
                                        {
                                            param($exportPath, $VirtualDesktopTemplateHostServer, $VirtualDesktopTemplateName)
                                            RDManagement\Export-MasterVM -ExportLocation $exportPath -VMHostName $VirtualDesktopTemplateHostServer `
                                                -VMName $VirtualDesktopTemplateName -Override $false -SysPrepGeneralize $false
                                        }
                    # TODO: error handling
                }
                catch
                {
                    Write-Error ($_.Exception.Message)
                }
                finally
                {
                    if($workflowSession)
                    {
                        Remove-PSSession -Session $workflowSession
                    }
                }
    
                if(-not $masterVmDetails)
                {
                    Write-Error (Get-ResourceString ErrorExportFailed)

                    #remove export folder
                    Remove-Item $exportPath -Recurse -Force -ErrorAction SilentlyContinue
                    try
                    {
                        $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
                    }
                    catch
                    {
                        Write-Verbose ("Failed to clear export in progress")
                        #ignore error
                    }
                    return
                }

                #save Master VM details
                $collProps.ReferenceVirtualDesktopName = $VirtualDesktopTemplateName
                $collProps.ReferenceVirtualDesktopHost = $VirtualDesktopTemplateHostServer
                $collProps.ReferenceVirtualDesktopOsversion = $masterVmDetails.OSVersion
                $collProps.ReferenceVirtualDesktopArchitecture = $masterVMDetails.ProcessorArchitecture
                $collProps.ReferenceVirtualDesktopGuid = $masterVMDetails.VirtualMachineGuid
                $collProps.ReferenceVirtualDesktopRamsizeMB = $masterVMDetails.Memory
                $collProps.ReferenceVirtualDesktopRemoteFX = $masterVMDetails.RemoteFX

                $adapterNames = New-Object System.Collections.Generic.List[string]
                foreach($adapter in $masterVmDetails.VirtualSwitch)
                {
                    $adapterNames.Add($adapter)
                }
                $collProps.ReferenceVirtualDesktopAdapters = $adapterNames

                try
                {
                    $putRes = $collProps.Put()
                }
                catch
                {
                    Write-Error ($_.Exception.Message)
                }
                if(-not $putRes)
                {
                    Write-Error(Get-ResourceString FailedToSaveVmCollProp)
                    #remove export folder
                    Remove-Item $exportPath -Recurse -Force -ErrorAction SilentlyContinue
                    try
                    {
                        $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
                    }
                    catch
                    {
                        Write-Verbose ("Failed to clear export in progress")
                        #ignore error
                    }
                    return
                }            
            }
        }

        # get provisioning XML, also makes sure all the VMHost have permission on the shares
        $provXml = Get-ProvXmlForExistingCollection -RdvmColl $rdvmColl -Type $rdvmColl.Type -JobType "Update" `
                    -CustomMasterVmLocation $exportPath -VmDistribution $VirtualDesktopAllocation -CheckStoragePerms $true -ConnectionBroker $ConnectionBroker
        if(-not $provXml)
        {
            try
            {
                $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
            }
            catch
            {
                Write-Verbose ("Failed to clear export in progress")
                #ignore error
            }
            return
        }

        try
        {
            $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
        }
        catch
        {
            Write-Verbose ("Failed to clear export in progress")
            #ignore error
        }
        #start provisioning job
        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            Invoke-Command -Session $workflowSession -ArgumentList @($rdvmColl.Alias, $provXml, $ConnectionBroker) `
            {
                param($alias, $provXml, $ConnectionBroker)
                RDManagement\Start-RDVMRollout -Alias $alias -ProvisioningXml $provXml -ManagementServer $ConnectionBroker
            } | Out-Null
            # TODO: error handling
        }
        catch
        {
            Write-Error (Get-ResourceString AddVmToRdvhCollectionFailed $_.Exception.Message)
        }
        finally
        {
            if($workflowSession)
            {
                Remove-PSSession -Session $workflowSession
            }
        }

        # cleanup old export path, old export path will only be non-null if 
        # new template was exported for PD pools
        if ($oldExportPath)
        {
            Remove-Item $oldExportPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        $jobStatus=Get-RDVirtualDesktopCollectionJobStatus $CollectionName -ConnectionBroker $ConnectionBroker
        if(-not $jobStatus)
        {
            return
        }
	    $virtualDesktopStatus= ($jobStatus.VirtualDesktopStatus | Sort -property VirtualDesktopName)
        foreach($vmStatus in $virtualDesktopStatus)
        {
            if(![string]::IsNullOrEmpty( $vmStatus.Error ))
            {
                continue
            }
            $vm=$vmStatus.VirtualDesktopName
            try
            {
                Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$vm'" | `
                    ForEach-Object {
                            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktop `
                                -ArgumentList $_.Name, $CollectionName, $_.HostName,  $_.VMState, $_.Status
                            }
            }
            catch
            {
                Write-Warning (Get-ResourceString FailedToGetVirtualDesktop $vm,$_.Exception.Message)
            }
        }
    }
    else
    {
        if (-not ($VirtualDesktopName))
        {
            Write-Error (Get-ResourceString SpecifyVmList)
            return
        }

        if (-not (Test-UnmanagedVmList -VirtualDesktopList $VirtualDesktopName -ConnectionBroker $ConnectionBroker))
        {
            return
        }

        foreach($vm in $VirtualDesktopName)
        {
            Write-Verbose ( Get-ResourceString AddingVmToCollection $vm )
            $errMsg=$null
            try
            {
                $addRes = $rdvmColl.AddVirtualDesktop($vm)
                Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$vm'" | `
                    ForEach-Object {
                            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktop `
                                -ArgumentList $_.Name, $CollectionName, $_.HostName,  $_.VMState, $_.Status
                         }
            }
            catch
            {
                $errMsg = $_.Exception.Message
            }
            if(-not $addRes)
            {
                Write-Error (Get-ResourceString AddUnmgdVmFailed $vm,$errMsg)
            }
            elseif(0 -ne $addRes.ReturnValue)            
            {
                Write-Error (Get-ResourceString AddUnmgdVmFailed $vm,$addRes.ReturnValue)
            }
            elseif($errMsg)
            {
                Write-Warning (Get-ResourceString FailedToGetVirtualDesktop $vm,$errMsg)
            }
        }
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Update-VirtualDesktopCollection {

[CmdletBinding(DefaultParameterSetName="Now",SupportsShouldProcess=$true,
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254094")]
param(
#common params
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateName,

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateHostServer,

    [Parameter(Mandatory=$false)]
    [switch]
    $DisableVirtualDesktopRollback,

    [Parameter(Mandatory=$false)]
    [ValidateRange(31,365)]
    [int]
    $VirtualDesktopPasswordAge,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force,

#Selective Params
    [Parameter(Mandatory=$true, ParameterSetName="OnUserLogoff")]
    [DateTime]
    $StartTime,
    
    [Parameter(Mandatory=$true, ParameterSetName="OnUserLogoff")]
    [Parameter(Mandatory=$true, ParameterSetName="OnSchedule")]
    [DateTime]
    $ForceLogoffTime
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    #verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is managed and shared
    if(-not ($rdvmColl.IsManaged))
    {
        Write-Error (Get-ResourceString RecreateErrorNotManagedVmCollection)
        return
    }
    
    if( 1 -ne $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString RecreateErrorNotSharedVmCollection)
        return
    }

    if ($PSBoundParameters["VirtualDesktopPasswordAge"])
    {
        if( -not ($rdvmColl.RollbackEnabled))
        {
            Write-Error (Get-ResourceString InvalidHostConfigurationSetting "VirtualDesktopPasswordAge")
            return
        }
    }

    switch($PsCmdlet.ParameterSetName)
    {
        "OnUserLogoff"
        {
            if($StartTime -gt $ForceLogoffTime)
            {
                Write-Error (Get-ResourceString ErrStartTimeGTLogoffTime)
                return
            }
        }
        "OnSchedule"
        {
            $StartTime = $ForceLogoffTime
        }
        "Now"
        {
            $StartTime = Get-Date
            $ForceLogoffTime = $StartTime
        }
    }

    if(-not(Test-MasterVm   -VirtualDesktopTemplateName $VirtualDesktopTemplateName `
                -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer `
                -ConnectionBroker $ConnectionBroker))
    {
        return
    }


    #get provisioning properties
    try
    {
        $alias=$rdvmColl.Alias
        $collProps= Get-WmiObject Win32_RDMSCollectionProperties -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "Alias='$alias'"
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    if( -not $collProps )
    {
        Write-Error (Get-ResourceString VmCollectionPropNotFound)
        return
    }

    try
    {
        $provProps=$collProps.GetProvisioningProperties()
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    if(-not $provProps)
    {
        Write-Error (Get-ResourceString VmCollectionProvPropNotFound)
        return
    }

    #all validations are complete, now prompt
    $promptMsg = (Get-ResourceString UpdateVmCollMsg $rdvmColl.Name)
    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    #verify if there is another job already running
    if(-not (Test-ScheduleProvisioningJob ($rdvmColl)))
    {
        return
    }

    #determine storage
    $centralStoragePath = [string]::Empty
    if($rdvmColl.IsHA)
    {
        $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSanStorage
        $centralStoragePath = $provProps.LocalVmLocation
    }
    elseif(-not [string]::IsNullOrEmpty($provProps.SMBLocation))
    {
        $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSmbShareStorage
        $centralStoragePath = $provProps.SMBLocation
    }
    else
    {
        $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::LocalStorage
    }
    $vmTemplateStoragePath = $provProps.LocalGoldVmLocation

    #generate Export Path
    $exportRoot = Get-ExportRoot -StorageType $storageType  -CentralStoragePath $centralStoragePath -VmTemplateStoragePath $vmTemplateStoragePath -ConnectionBroker $ConnectionBroker
    if( -not $exportRoot)
    {
        return
    }

    $exportPath = New-VMExportLocation -ExportRoot $exportRoot -Alias $rdvmColl.Alias -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer
    if(-not $exportPath)
    {
        return
    }

    if ($PSBoundParameters["VirtualDesktopPasswordAge"])
    {
        #set the value
        if (-not (Set-VirtualDesktopHostSetting -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker `
                        -Name "VirtualDesktopPasswordAge" -Value $VirtualDesktopPasswordAge))
        {
            return
        }
    }

    #Set Export info so that Get-Status could show export in progress
    try
    {
        $rdvmColl.SetStringProperty("ExportInProgress",$VirtualDesktopTemplateName)|Out-Null
    }
    catch
    {
        Write-Verbose ("Failed to set export in progress")
        #ignore error
    }

    #export the master VM
    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        $masterVmDetails = Invoke-Command -Session $workflowSession -ArgumentList @($exportPath, $VirtualDesktopTemplateHostServer, $VirtualDesktopTemplateName) `
                            {
                                param($exportPath, $VirtualDesktopTemplateHostServer, $VirtualDesktopTemplateName)
                                RDManagement\Export-MasterVM -ExportLocation $exportPath -VMHostName $VirtualDesktopTemplateHostServer `
                                    -VMName $VirtualDesktopTemplateName -Override $false -SysPrepGeneralize $false
                            }
        # TODO: error handling
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    finally
    {
        if($workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
    }
    
    if(-not $masterVmDetails)
    {
        Write-Error (Get-ResourceString ErrorExportFailed)
        try
        {
            $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
        }
        catch
        {
            Write-Verbose ("Failed to clear export in progress")
            #ignore error
        }
        return
    }

    #save Master VM details
    $collProps.ReferenceVirtualDesktopName = $VirtualDesktopTemplateName
    $collProps.ReferenceVirtualDesktopHost = $VirtualDesktopTemplateHostServer
    $collProps.ReferenceVirtualDesktopOsversion = $masterVmDetails.OSVersion
    $collProps.ReferenceVirtualDesktopArchitecture = $masterVMDetails.ProcessorArchitecture
    $collProps.ReferenceVirtualDesktopGuid = $masterVMDetails.VirtualMachineGuid
    $collProps.ReferenceVirtualDesktopRamsizeMB = $masterVMDetails.Memory
    $collProps.ReferenceVirtualDesktopRemoteFX = $masterVMDetails.RemoteFX

    $adapterNames = New-Object System.Collections.Generic.List[string]
    foreach($adapter in $masterVmDetails.VirtualSwitch)
    {
        $adapterNames.Add($adapter)
    }
    $collProps.ReferenceVirtualDesktopAdapters = $adapterNames
    
    try
    {
        $putRes = $collProps.Put()
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    if(-not $putRes)
    {
        Write-Error(Get-ResourceString FailedToSaveVmCollProp)
        try
        {
            $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
        }
        catch
        {
            Write-Verbose ("Failed to clear export in progress")
            #ignore error
        }
        return
    }

    $vhdType = "DiffDisk"
    # generate provisioning XML
    $provXml = Get-ProvisioningXml -CollectionAlias $rdvmColl.Alias -Job "Patch" -VhdType $vhdType -BaseVmLocation $exportPath `
                    -SmbShare $provProps.SMBLocation -LocalVmCreationPath $provProps.LocalVmLocation -LocalGoldCachePath $provProps.LocalGoldVmLocation `
                    -RunVmFromSmb $provProps.RunFromSMB -EnableVmStreaming $provProps.SMBStreaming `
                    -Prefix $provProps.NamePrefix -StartIndex $provProps.NameStartIndex -Domain $provProps.VmDomain -OU $provProps.VmDomain -HostList $VmDistribution `
                    -HighlyAvailable $rdvmColl.IsHA
    if(-not $provXml)
    {
        Write-Error(Get-ResourceString FailedToSaveVmCollProp)
        try
        {
            $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
        }
        catch
        {
            Write-Verbose ("Failed to clear export in progress")
            #ignore error
        }
        return
    }

    #update Rollback
    try
    {
        if($DisableVirtualDesktopRollback)
        {
            $rdvmColl.RollbackEnabled = $false
        }
        else
        {
            $rdvmColl.RollbackEnabled = $true
        }
        $putRes = $rdvmColl.Put();
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if( -not $putRes )
    {
        Write-Error (Get-ResourceString ModifyRollbackEnableFailed $errMsg)
        #non-fatal error, very unlikey, do not return
    }

    #Call Schedule Patch
    try
    {
        #get rdvmColl again
        $coll = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"

        $out = $coll.SchedulePatch([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($StartTime.ToUniversalTime()), `
             [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($ForceLogoffTime.ToUniversalTime()), $provXml)
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    try
    {
        $coll.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
    }
    catch
    {
        Write-Verbose ("Failed to clear export in progress")
        #ignore error
    }

    if( (-not $out) -or (0 -ne $out.ReturnValue) )
    {
        Write-Error(Get-ResourceString FailedToScheduleVmCollRecreate)
        return
    }

    Write-Verbose (Get-ResourceString ScheduledVmCollRecreate )
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktop {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254095")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktop[]")]
param(
    [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
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

    $collAliasToNameMap=@{}

    if($CollectionName -eq $null)
    {
        $CollectionName="*"
    }

    # Get all the collections and prepare Name TO Alias map
    try
    {
        $rdvmCollections = Get-WmiObject -Class Win32_RDMSVirtualdesktopCollection -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
            -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    }
    catch
    {
        Write-Error ($_.Exception.Message)
        return
    }
    
    foreach($Collection in $CollectionName)
    {
        $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $Collection, IgnoreCase
        
        # Virtual Desktops that are not part of any collection will also be included if $Collection matches or equal to an empty string
        if($WildCard.IsMatch(""))
        {
            if(-not $collAliasToNameMap.ContainsKey(""))
            {
                $collAliasToNameMap.Add("", "")
            }
        }

        $WildCardMatches = ($rdvmCollections | Where-Object { $WildCard.IsMatch($_.Name) })

        if($null -ne $WildCardMatches)
        {
            foreach($match in $WildCardMatches)
            {
                if(-not $collAliasToNameMap.ContainsKey($match.Alias))
                {
                    $collAliasToNameMap.Add($match.Alias, $match.Name)
                }
            }
        }
        else
        {
            if(-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Collection))
            {
                if(-not [String]::IsNullOrEmpty($Collection))
                {
                    Write-Error (Get-ResourceString SpecifiedVmCollNotFound $Collection)
                }
            }
            else
            {
                Write-Verbose (Get-ResourceString WrnWildcardNoMatches $Collection)
            }
        }
    }

    $wmiQuery = "Select * from Win32_RDMSVirtualDesktop"
    try
    {
        $VirtualDesktops = Get-WmiObject -Namespace "root\cimv2\rdms" -Query $wmiQuery -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
            | Where-Object { $collAliasToNameMap.ContainsKey($_.CollectionAlias) } `
            | ForEach-Object {
                            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktop `
                                -ArgumentList $_.Name, $collAliasToNameMap[$_.CollectionAlias], $_.HostName,  $_.VMState, $_.Status
                         } `
            | Sort CollectionName,virtualDesktopName

        if($VirtualDesktops.Count -ne 0)
        {
            $VirtualDesktops
        }
        else
        {
            Write-Verbose (Get-ResourceString NoVirtualDesktopsFound)
        }
    }
    catch
    {
        Write-Error (Get-ResourceString GetVirtDesktopFailed $_.Exception.Message)
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-VirtualDesktopFromCollection {
[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254096")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string[]]
    $VirtualDesktopName,

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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #validate each of the VM specified exists and is member of specified collection
    if( -not (Test-CollectionMemberVmList -CollectionAlias $rdvmColl.Alias -VirtualDesktopList $VirtualDesktopName -ConnectionBroker $ConnectionBroker))
    {
        return
    }

    $promptMsg = (Get-ResourceString RemoveVmsFromCollMsg)

    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    #remove virtual desktop from collection
    foreach($vm in $VirtualDesktopName)
    {
        try
        {
            $result = $rdvmColl.RemoveVirtualDesktop($vm)
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if (($result) -and ($result.ReturnValue -eq 0))
        {
            Write-Verbose (Get-ResourceString VirtualDesktopRemoved $vm, $CollectionName)
        }
        else
        {
            Write-Error (Get-ResourceString FailedToRemoveVirtualDesktop $vm, $CollectionName)
        }
    }

    #for managed collections, clean up the vm by running provisioning job
    if( $rdvmColl.IsManaged )
    {
        #verify if there is another job already running
        if(-not (Test-ScheduleProvisioningJob ($rdvmColl)))
        {
            return
        }

        $provXml = Get-ProvXmlForExistingCollection -RdvmColl $rdvmColl -Type $rdvmColl.Type -JobType "Delete" -VmList $VirtualDesktopName `
                        -ConnectionBroker $ConnectionBroker
        if(-not $provXml)
        {
            return
        }

        #start provisioning job
        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            Invoke-Command -Session $workflowSession -ArgumentList @($rdvmColl.Alias, $provXml, $ConnectionBroker) `
            {
                param($alias, $provXml, $ConnectionBroker)
                RDManagement\Start-RDVMRollout -Alias $alias -ProvisioningXml $provXml -ManagementServer $ConnectionBroker
            } | Out-Null
            # TODO: error handling
        }
        catch 
        {
            Write-Error (Get-ResourceString DeleteVirtualDesktopFailed)
        }
        finally
        {
            if($workflowSession)
            {
                Remove-PSSession -Session $workflowSession
            }
        }
    }
}

#Gets current provisioning job state, also updates the latest job state by retrieving report once

# .ExternalHelp RemoteDesktop.psm1-help.xml
function 
Get-VirtualDesktopCollectionJobStatus{
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254097")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionJobStatus")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                        -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is managed
    if(-not ($rdvmColl.IsManaged))
    {
        Write-Error (Get-ResourceString FailedToGetStatusNotManaged)
        return
    }

    try
    {
        $res = $rdvmColl.GetInt32Property("CollectionState")
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }
    if(-not $res)
    {
        Write-Error (Get-ResourceString FailedToGetCollectionState $errMsg)
        return
    }
    if( 0 -ne $res.ReturnValue )
    {
        Write-Error (Get-ResourceString FailedToGetCollectionState $res.ReturnValue)
        return        
    }
    $status = $res.Value

    $res = $null

    #see if collection state is exportInProgress.
    if(Test-ExportInProgress($rdvmColl))
    {
        try
        {
            $getStrPropRes = Invoke-WmiMethod -Name GetStringProperty -ArgumentList "ExportInProgress" -InputObject $rdvmColl `
                        -ErrorAction Stop
            $exportInProgress = $getStrPropRes.Value 
        }
        catch
        {
            Write-Verbose ("Failed to get exportInProgress property")
        }
        $jobStatus = New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionExportStatus `
                -ArgumentList $CollectionName, $exportInProgress
    }
    # else, for patch schedule\cancelled status, retrieve patch schedule details
    elseif (($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_SCHEDULED) -or
        ($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_CANCELLED))
    {
        try
        {
            $patchProp = $rdvmcoll.GetPatchProperties();
        }
        catch 
        {
            Write-Error $_.Exception.Message
        }
        if(-not $patchProp)
        {
            Write-Error (Get-ResourceString FailedToGetRecreateProps)
            return $false
        }

        $startTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($patchProp.StartTime)
        $logoffTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($patchProp.ForceLogOffTime)
        $jobStatus = New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionUpdateJobStatus `
        -ArgumentList $CollectionName, $status, $startTime, $logoffTime
    }
    #for all other status , parse the report
    else
    {
        #get JOB ID, refresh JOB report
        try
        {
            $res = $rdvmColl.GetStringProperty("ProvisioningJobId")
            $jobGuid = $res.Value

            $getReportRes = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktopCollection -Name ProvisioningJobGetReport -ComputerName $ConnectionBroker `
                        -Namespace 'root\cimv2\rdms' -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                        -ArgumentList ($jobGuid) 
        }
        catch
        {
            $errMsg = $_.Exception.Message
        }
        if(-not $res)
        {
            Write-Error (Get-ResourceString FailedToGetCollectionJobId $errMsg)
            return
        }
        if( 0 -ne $res.ReturnValue )
        {
            Write-Error (Get-ResourceString FailedToGetCollectionJobId $res.ReturnValue)
            return        
        }
        if((-not $getReportRes) -or (0 -ne $getReportRes.returnValue))
        {
            Write-Error (Get-ResourceString FailedToGetJobReport)
            if($errMsg)
            {
                Write-Error $errMsg
                return
            }
            if(0 -ne $getReportRes.returnValue)
            {
                Write-Error $getReportRes.returnValue
            }            
            return
        }
        #retrieve collection state again
        try
        {
            $res = $rdvmColl.GetInt32Property("CollectionState")
        }
        catch
        {
            $errMsg = $_.Exception.Message
        }
        if(-not $res)
        {
            Write-Error (Get-ResourceString FailedToGetCollectionState $errMsg)
            return
        }
        if( 0 -ne $res.ReturnValue )
        {
            Write-Error (Get-ResourceString FailedToGetCollectionState $res.ReturnValue)
            return        
        }
        $status = $res.Value


        try
        {
            $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
        }
        catch
        {
            Write-Verbose ("Failed to clear export in progress")
            #ignore error
        }

        try
        {
            $jobReport = New-Object Microsoft.RemoteDesktopServices.Management.Cmdlets.RolloutJobReport

            # parse job report
            $jobReport.ParseReportAndUpdateVMStatus($getReportRes.JobReportXml)

            # create Job status object
            $jobStatus = New-Object  Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionJobStatus -ArgumentList `
                $CollectionName, $status, $jobReport.JobStartTime, $jobReport.JobLastModifiedTime, $jobReport.TotalRequested, `
                ($jobReport.PercentComplete.ToString() + '%'), $jobReport.TotalFailed, $jobReport.VmStatusMap.ToArray()
        }
        catch
        {
            Write-Error ((Get-ResourceString FailedToGetJobReport) + " " + $_.Exception.Message)
            return
        }
    }
    
    return ($jobStatus)
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Stop-VirtualDesktopCollectionJob{
[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254098")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                        -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is managed and shared
    if(-not ($rdvmColl.IsManaged))
    {
        Write-Error (Get-ResourceString FailedToGetStatusNotManaged)
        return
    }

    #confirm
    $promptMsg = (Get-ResourceString StopProvJobMsg)
    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }
    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    $jobStatus = Get-RDVirtualDesktopCollectionJobStatus $CollectionName -ConnectionBroker $ConnectionBroker
    if($null -eq $jobStatus)
    {
        return
    }
    $status = $jobStatus.Status

    if( ($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::CREATE_VIRTUAL_DESKTOP_INPROGRESS) -or 
        ($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::ADD_VIRTUAL_DESKTOP_INPROGRESS) -or 
        ($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_VIRTUAL_DESKTOP_INPROGRESS) )
    {
        #get job id and cancel it
        try
        {
            $res = $rdvmColl.GetStringProperty("ProvisioningJobId")
            $jobGuid = $res.Value
            $cancelResult =  Invoke-WmiMethod -Class Win32_RDMSVirtualDesktopCollection -Name ProvisioningJobCancel -ComputerName $ConnectionBroker `
                     -Namespace 'root\cimv2\rdms' -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                     -ArgumentList ($jobGuid) 
        }
        catch
        {
            $errMsg = $_.Exception.Message            
        }
        if(-not $res)
        {
            Write-Error (Get-ResourceString FailedToGetCollectionJobId $errMsg)
            return
        }
        if( 0 -ne $res.ReturnValue )
        {
            Write-Error (Get-ResourceString FailedToGetCollectionJobId $res.ReturnValue)
            return        
        }
        if(-not $cancelResult)
        {
            Write-Error (Get-ResourceString FailedToCancelCollJob $errMsg)
            return
        }
        if( 0 -ne $cancelResult.ReturnValue )
        {
            Write-Error (Get-ResourceString FailedToCancelCollJob $res.ReturnValue)
            return        
        }
        #refresh state
        $jobStatus = Get-RDVirtualDesktopCollectionJobStatus $CollectionName -ConnectionBroker $ConnectionBroker
    }
    elseif($status -eq  [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_SCHEDULED)
    {
        #cancel scheduled patch
        try
        {
            $cancelResult = $rdvmColl.CancelPatch()
        }
        catch
        {
            $errMsg = $_.Exception.Message            
        }
        if(-not $cancelResult)
        {
            Write-Error (Get-ResourceString FailedToCancelCollJob $errMsg)
            return
        }
        if( 0 -ne $cancelResult.ReturnValue )
        {
            Write-Error (Get-ResourceString FailedToCancelCollJob $res.ReturnValue)
            return    
        }

        #refresh state
        $jobStatus = Get-RDVirtualDesktopCollectionJobStatus $CollectionName -ConnectionBroker $ConnectionBroker
    }
    else
    {
        Write-Error (Get-ResourceString ErrCollectionJobCancelInvalidState $status.ToString())
        return
    }
    return $jobStatus
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-PersonalVirtualDesktopAssignment{
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254099")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $User,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $VirtualDesktopName,

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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is personal
    if( 1 -eq $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString PDAssignErrorNotPDPool)
        return
    }

    #verify user name and get domain and user name
    $sid = ConvertTo-Sid($user)
    if(-not $sid)
    {
        Write-Error (Get-ResourceString InvalidUserName)
        return
    }
    $separators=[char[]]('\')
    $userParts = $User.Split($separators)
    $userDomain = $userParts[0]
    $userName = $userParts[1]

    $newPD = $null

    #a virtual desktop name is specified, verify it
    try
    {
        $newPD= Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "Name='$VirtualDesktopName'"
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    if($null -eq $newPD)
    {
        Write-Error (Get-ResourceString FailedToFindVirtualDesktop $VirtualDesktopName)
        return
    }

    if([string]::Compare($rdvmColl.Alias, $newPD.CollectionAlias, $true))
    {
        Write-Error(Get-ResourceString VirtDesktopNotAMemeberOfSpecifiedPool $VirtualDesktopName)
        return
    }

    if(-not ([System.String]::IsNullOrEmpty($newPD.UserDomain) -or [System.String]::IsNullOrEmpty($newPD.UserName)))
    { 
        Write-Error (Get-ResourceString UserAlreadyAssigned $newPD.UserDomain, $newPD.UserName)
        return
    }

    if( [Microsoft.RemoteDesktopServices.Management.VirtualDesktopProvisioningStatus]::FAILED.value__ -eq $newPD.Status )
    {
        Write-Error (Get-ResourceString FailedToFindVirtualDesktop $VirtualDesktopName)
        return;
    }


    #call static method "Win32_RDMSVirtualDesktop::GetVirtualDesktopAssignedToUser"
    try
    {
        $out = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktop -Name GetVirtualDesktopAssignedToUser -ArgumentList ($rdvmColl.Alias,$userDomain,$userName) `
             -ComputerName $ConnectionBroker -Namespace "root\cimv2\rdms" `
             -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop 
    }
    catch
    {
        #ignore error
    }


    $alreadyAssigned = ( ($null -ne $out) -and (0 -eq $out.ReturnValue) -and (-not [string]::IsNullOrEmpty($out.VMName)))

    #if already assigned a desktop, get the desktop instance and clear assignment
    if( $alreadyAssigned )
    {
        try
        {
            $vmName = $out.VMName
	    $remRes = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktop -Name RemoveUserAssignment -ArgumentList ($vmName) `
             -ComputerName $ConnectionBroker -Namespace "root\cimv2\rdms" `
             -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
        }
        catch
        {
            Write-Error ($_.Exception.Message)
        }
        if( (-not $remRes) -or (0 -ne $remRes.ReturnValue))
        {
            Write-Error (Get-ResourceString FailedToRemovePDAssignment)
            return
        }
    }

    #get the desktop instance for Admin specified desktop
    # and call SetUserAssignment 
    try
    {
        $setRes = $newPD.SetUserAssignment($userName, $userDomain)
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    if((-not $setRes) -or (0 -ne $setRes.ReturnValue))
    {
        Write-Error (Get-ResourceString FailedToSetPDAssignment)
    }
    else
    {
        Write-Verbose (Get-ResourceString SetPDAssignSuccess $User,$VirtualDesktopName,$CollectionName )
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-PersonalVirtualDesktopAssignment{
[CmdletBinding(DefaultParameterSetName="RemoveByUser", SupportsShouldProcess=$true,
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254100")]
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
    $VirtualDesktopName,

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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is personal
    if( 1 -eq $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString PDAssignErrorNotPDPool)
        return
    }

    if( $PSBoundParameters["User"] )
    {
        #verify user name and get domain and user name
        $sid = ConvertTo-Sid($user)
        if(-not $sid)
        {
            Write-Error (Get-ResourceString InvalidUserName)
            return
        }
        $separators=[char[]]('\')
        $userParts = $User.Split($separators)
        $userDomain = $userParts[0]
        $userName = $userParts[1]

        #call static method "Win32_RDMSVirtualDesktop::GetVirtualDesktopAssignedToUser"
        try
        {
            $out = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktop -Name GetVirtualDesktopAssignedToUser -ArgumentList ($rdvmColl.Alias,$userDomain,$userName) `
                    -ComputerName $ConnectionBroker -Namespace "root\cimv2\rdms" `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        $alreadyAssigned = (($null -ne $out) -and (0 -eq $out.ReturnValue) -and (-not [string]::IsNullOrEmpty($out.VMName)))

        #if not already assigned a desktop, return
        if( -not $alreadyAssigned )
        {
            Write-Error (Get-ResourceString PDAssignErrorNoCurrentAssignment)
            return
        }

        $vmName = $out.VMName
    }
    elseif( $PSBoundParameters["VirtualDesktopName"] )
    {
        try
        {
            $currentPD = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$VirtualDesktopName'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if($null -eq $currentPD)
        {
            Write-Error (Get-ResourceString FailedToFindVirtualDesktop $VirtualDesktopName)
            return
        }
        if( [string]::Compare( $currentPD.CollectionAlias, $rdvmColl.Alias, $true))
        {
            Write-Error (Get-ResourceString VirtDesktopNotAMemeberOfSpecifiedPool $VirtualDesktopName)
            return
        }
        if( -not ($currentPD.UserName) -or -not($currentPD.UserDomain) )
        {
            Write-Error (Get-ResourceString SpecifiedPDNotAssigned)
            return
        }
        $vmName = $currentPD.Name
        $userDomain = $currentPD.UserDomain
        $userName = $currentPD.UserName

    }
    else
    {
        Write-Verbose ('Unexpected')
        return
    }

    #confirm
    $promptMsg = (Get-ResourceString RemovePDAssignmentMsg ($userDomain + '\' + $userName), $vmName)
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
	$remRes = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktop -Name RemoveUserAssignment -ArgumentList ($vmName) `
             -ComputerName $ConnectionBroker -Namespace "root\cimv2\rdms" `
             -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    if((-not $remRes) -or (0 -ne $remRes.ReturnValue))
    {
        Write-Error (Get-ResourceString FailedToRemovePDAssignment)
        return
    }
    Write-Verbose (Get-ResourceString RemovePDAssignSuccess)
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Get-PersonalVirtualDesktopAssignment{
[CmdletBinding(DefaultParameterSetName="GetByCollection",
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254101")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopAssignment[]")]
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
    $VirtualDesktopName,

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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is personal
    if( 1 -eq $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString PDAssignErrorNotPDPool)
        return
    }

    if( $PSBoundParameters["User"] )
    {
        Write-Verbose ( 'Getting PD assignmet by user name: ' + $User )

        #verify user name and get domain and user name
        $sid = ConvertTo-Sid($user)
        if(-not $sid)
        {
            Write-Error (Get-ResourceString InvalidUserName)
            return
        }
        $separators=[char[]]('\')
        $userParts = $User.Split($separators)
        $userDomain = $userParts[0]
        $userName = $userParts[1]

        #call static method "Win32_RDMSVirtualDesktop::GetVirtualDesktopAssignedToUser"
        try
        {
            $out = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktop -Name GetVirtualDesktopAssignedToUser -ArgumentList ($rdvmColl.Alias,$userDomain,$userName) `
                 -ComputerName $ConnectionBroker -Namespace "root\cimv2\rdms" `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }
        $pdAssigned = (($null -ne $out) -and (0 -eq $out.ReturnValue) -and (-not [string]::IsNullOrEmpty($out.VMName)))

        #if not already assigned a desktop, return
        if( -not $pdAssigned )
        {
            Write-Verbose (Get-ResourceString PDAssignErrorNoCurrentAssignment)
            return
        }

        return (New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopAssignment `
                                        -ArgumentList $out.VMName, $User)
    }
    elseif ( $PSBoundParameters["VirtualDesktopName"] )
    {
        Write-Verbose ('Getting PD assignmet by Virtual Desktop name: ' + $VirtualDesktopName )
        try
        {
            $pd = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$VirtualDesktopName'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if($null -eq $pd)
        {
            Write-Error (Get-ResourceString FailedToFindVirtualDesktop $VirtualDesktopName)
            return
        }
        if( [string]::Compare( $pd.CollectionAlias, $rdvmColl.Alias, $true))
        {
            Write-Error (Get-ResourceString VirtDesktopNotAMemeberOfSpecifiedPool $VirtualDesktopName)
            return
        }
        if( -not ($pd.UserName) -or -not($pd.UserDomain) )
        {
            Write-Verbose (Get-ResourceString SpecifiedPDNotAssigned)
            return
        }

        $userAccount= $pd.UserDomain + '\' + $pd.UserName

        return (New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopAssignment `
                                        -ArgumentList $pd.Name, $userAccount)
    }
    else
    {
        Write-Verbose ('Getting all the PD assignments in the collection: ' + $CollectionName )
        $alias=$rdvmColl.Alias
        try
        {
            $assignedPDs = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "CollectionAlias='$alias' and UserDomain != null and UserName != null"
        }
        catch
        {
            Write-Error ($_.Exception)
        }
        if(-not $assignedPDs)
        {
            Write-Verbose (Get-ResourceString NoAssignedPDFoundInCollection)
            return
        }
        foreach($pd in $assignedPDs)
        {
            $userAccount= $pd.UserDomain + '\' + $pd.UserName
            New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopAssignment `
                                        -ArgumentList $pd.Name, $userAccount
        }
    }
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Export-PersonalVirtualDesktopAssignment {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254102")]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $Path,
    
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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is personal
    if( 1 -eq $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString PDAssignErrorNotPDPool)
        return
    }

    #make sure file does not exist
    if((Test-FilePath -Path $Path -ErrorAction SilentlyContinue))
    {
        Write-Error ('File already exists')
        return
    }

    #make sure the folder exists
    if(-not (Test-FilePath -Path $Path -Parent))
    {
        Write-Error (Get-ResourceString InvalidPath $Path)
        return
    }

    #get all the assignments in the collection and export to csv file
    Get-RDPersonalVirtualDesktopAssignment $CollectionName | Export-Csv $Path
    return
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function
Import-PersonalVirtualDesktopAssignment {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254103")]
param(

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $Path,
    
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

    #verify that collection exists
    try
    {
        $rdvmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$CollectionName'"
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if($null -eq $rdvmColl)
    {
        Write-Error (Get-ResourceString SpecifiedVmCollNotFound $CollectionName)
        if($errMsg)
        {
            Write-Error $errMsg
        }
        return
    }

    #verify it is personal
    if( 1 -eq $rdvmColl.Type)
    {
        Write-Error (Get-ResourceString PDAssignErrorNotPDPool)
        return
    }

    #make sure file exists
    if(-not (Test-FilePath -Path $Path))
    {
        Write-Error (Get-ResourceString InvalidPath $Path)
        return
    }
    
    #import assignments to the collection
    import-csv $Path | `
    ForEach-Object{
        Remove-RDPersonalVirtualDesktopAssignment $CollectionName -VirtualDesktopName $_.VirtualDesktopName -force -ErrorAction SilentlyContinue
        Remove-RDPersonalVirtualDesktopAssignment $CollectionName -User $_.User -force -ErrorAction SilentlyContinue
        $_ | Set-RDPersonalVirtualDesktopAssignment $CollectionName 
    }
    #return the assignments
    Get-RDPersonalVirtualDesktopAssignment $CollectionName
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-VirtualDesktopConcurrency {
[CmdletBinding(DefaultParameterSetName="Default",
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254104")]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Default", Position=0)]
    [ValidateRange(1,100)]
    [int]
    $ConcurrencyFactor,

    [Parameter(Mandatory=$false, ParameterSetName="Default", Position=1)]
    [string[]]
    $HostServer,

    [Parameter(Mandatory=$true, ParameterSetName="Allocation", Position=0)]
    [Hashtable]
    $Allocation,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]
    $BatchSize = 10
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    switch ($PsCmdlet.ParameterSetName)
    {
        "Default"
        {
            if($null -eq $HostServer)
            {
                $HostServer = "*"
            }

            $HostList = (Get-ValidRdvhFromArray -ConfigurationValue $ConcurrencyFactor -HostServer $HostServer -ConnectionBroker $ConnectionBroker)
            foreach($Server in $HostServer)
            {
                if((-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Server)) -and (-not $HostList.ContainsKey($Server)))
                {
                    Write-Error (Get-ResourceString InvalidRdvhRoleNotFoundGeneric $Server)
                }
            }
        }
         
        "Allocation"
        {
            $HostList = (Get-ValidRdvhFromHashtable -Allocation $Allocation -ConnectionBroker $ConnectionBroker)
            foreach($Server in $Allocation.Keys)
            {
                if(-not $HostList.ContainsKey($Server))
                {
                    Write-Error (Get-ResourceString InvalidRdvhRoleNotFoundGeneric $Server)
                }
            }
        }
    }
    
    $JobList = @()
    $ErrInvalidConcurrencyRange = Get-RawResourceString ErrInvalidConcurrencyRange
    $ErrInvalidConcurrencyType = Get-RawResourceString ErrInvalidConcurrencyType
    $ErrSettingConcurrencyFactor = Get-RawResourceString ErrSettingConcurrencyFactor

    foreach($VMHAHost in $HostList.Keys)
    {
        Write-Verbose (Get-ResourceString SettingConcurrencyFactor $VMHAHost)
        $JobList += Start-Job  -scriptblock `
        {
            try
            {
                $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $args[0])
                $VMHAParamKey=$RemoteRegistry.CreateSubKey("SYSTEM\\CurrentControlSet\\Services\\VmHostAgent\\Parameters")
                if($null -ne $args[4])
                {
                    if($args[4].GetType().FullName -eq "System.Int32")
                    {
                        if(($args[4] -ge 1) -and ($args[4] -le 100))
                        {
                            $VMHAParamKey.SetValue("Concurrency", $args[4])
                            $true
                        }
                        else
                        {
                            throw ($args[1] -f $args[4], $args[0])
                        }
                    }
                    else
                    {
                        throw ($args[2] -f $args[4].GetType().FullName, $args[0])
                    }
                }
                elseif($null -ne $VMHAParamKey.GetValue("Concurrency"))
                {
                    $VMHAParamKey.DeleteValue("Concurrency")
                    $false
                }
            }
            catch
            {
                throw ($args[3] -f $args[0], $_.Exception.Message)
            }
        } -ArgumentList $VMHAHost,$ErrInvalidConcurrencyRange,$ErrInvalidConcurrencyType,$ErrSettingConcurrencyFactor,$HostList[$VMHAHost] -Name $VMHAHost

        if($JobList.Length -ge $BatchSize)
        {
            if($JobList.Length -gt 1)
            {
                Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
            }
            else
            {
                Write-Verbose (Get-ResourceString WaitingForJobToComplete)
            }

            $WaitResult = Wait-Job -Job $JobList

            foreach($job in $JobList)
            {
                if($job.State -eq 'Failed')
                {
                    Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
                }
                else
                {
                    $retVal = Receive-Job $job
                    if($retVal)
                    {
                        Write-Verbose (Get-ResourceString SettingConcurrencyFactorSuccess $job.Name)
                    }
                    else
                    {
                        Write-Verbose (Get-ResourceString DeletingConcurrencyFactorSuccess $job.Name)
                    }
                }
            }
            
            $JobList = @()
        }
    }

    if($JobList.Length -gt 0)
    {
        if($JobList.Length -gt 1)
        {
            Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
        }
        else
        {
            Write-Verbose (Get-ResourceString WaitingForJobToComplete)
        }
        
        $WaitResult = Wait-Job -Job $JobList
    
        foreach($job in $JobList)
        {
            if($job.State -eq 'Failed')
            {
                Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
            }
            else
            {
                $retVal = Receive-Job $job
                if($retVal)
                {
                    Write-Verbose (Get-ResourceString SettingConcurrencyFactorSuccess $job.Name)
                }
                else
                {
                    Write-Verbose (Get-ResourceString DeletingConcurrencyFactorSuccess $job.Name)
                }
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktopConcurrency {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254105")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopConcurrency[]")]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string[]]
    $HostServer,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]
    $BatchSize = 10
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if($null -eq $HostServer)
    {
        $HostServer = "*"
    }

    $HostList = (Get-ValidRdvhFromArray -ConfigurationValue 0 -HostServer $HostServer -ConnectionBroker $ConnectionBroker)
    foreach($Server in $HostServer)
    {
        if((-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Server)) -and (-not $HostList.ContainsKey($Server)))
        {
            Write-Error (Get-ResourceString InvalidRdvhRoleNotFoundGeneric $Server)
        }
    }

    $JobList = @()
    $ValidResults = @()

    $ErrReadingConcurrencyFactor = Get-RawResourceString ErrReadingConcurrencyFactor 

    foreach($VMHAHost in $HostList.Keys)
    {
        $JobList += Start-Job  -scriptblock `
        {
            try
            {
                $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $args[0])
                $VMHAParamKey=$RemoteRegistry.CreateSubKey("SYSTEM\\CurrentControlSet\\Services\\VmHostAgent\\Parameters")
                $retVal = $VMHAParamKey.GetValue("Concurrency")
                $retVal
            }
            catch
            {
                throw ($args[1] -f $args[0], $_.Exception.Message)
            }
        } -ArgumentList $VMHAHost,$ErrReadingConcurrencyFactor -Name $VMHAHost


        if($JobList.Length -ge $BatchSize)
        {
            if($JobList.Length -gt 1)
            {
                Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
            }
            else
            {
                Write-Verbose (Get-ResourceString WaitingForJobToComplete)
            }

            $WaitResult = Wait-Job -Job $JobList

            foreach($job in $JobList)
            {
                if($job.State -eq 'Failed')
                {
                    Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
                }
                else
                {
                    $retVal = Receive-Job $job
                    $ValidResults += New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopConcurrency -ArgumentList $job.Name,$retVal
                }
            }
            
            $JobList = @()
        }
    }

    if($JobList.Length -gt 0)
    {
        if($JobList.Length -gt 1)
        {
            Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
        }
        else
        {
            Write-Verbose (Get-ResourceString WaitingForJobToComplete)
        }
        
        $WaitResult = Wait-Job -Job $JobList

        foreach($job in $JobList)
        {
            if($job.State -eq 'Failed')
            {
                Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
            }
            else
            {
                $retVal = Receive-Job $job
                $ValidResults += New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopConcurrency -ArgumentList $job.Name,$retVal
            }
        }
    }

    $ValidResults
}


# .ExternalHelp RemoteDesktop.psm1-help.xml
function Enable-VirtualDesktopADMachineAccountReuse {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254106")]
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

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    try
    {
        foreach ($broker in $brokerList) {

            Write-Debug ("Broker = " + $broker.Server)

            $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $broker.Server)
            $brokerKey=$RemoteRegistry.CreateSubKey("Software\\Microsoft\\Windows NT\\CurrentVersion\\Terminal Server\\Session Broker")
            $brokerKey.SetValue("ReuseVmAdAccount", 1, [Microsoft.Win32.RegistryValueKind]::DWord)
        }
    }
    catch
    {
        Write-Error (Get-ResourceString ErrSettingReuseVmAdAccount $broker.Server, $_.Exception.Message)
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Disable-VirtualDesktopADMachineAccountReuse {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254107")]
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

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    try
    {
        foreach ($broker in $brokerList) {

            Write-Debug ("Broker = " + $broker.Server)

            $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $broker.Server)
            $brokerKey=$RemoteRegistry.CreateSubKey("Software\\Microsoft\\Windows NT\\CurrentVersion\\Terminal Server\\Session Broker")
            if($null -ne $brokerKey.GetValue("ReuseVmAdAccount"))
            {
                $brokerKey.DeleteValue("ReuseVmAdAccount")
            }
        }
    }
    catch
    {
        Write-Error (Get-ResourceString ErrSettingReuseVmAdAccount $broker.Server, $_.Exception.Message)
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Test-VirtualDesktopADMachineAccountReuse {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254108")]
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

    try
    {
        $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ConnectionBroker)
        $brokerKey=$RemoteRegistry.CreateSubKey("Software\\Microsoft\\Windows NT\\CurrentVersion\\Terminal Server\\Session Broker")
        return ([bool]$brokerKey.GetValue("ReuseVmAdAccount"))
    }
    catch
    {
        Write-Error (Get-ResourceString ErrReadingReuseVmAdAccount $ConnectionBroker, $_.Exception.Message)
    }
}

##############################################################
######################Helper functions #######################
##############################################################

function Get-ProvXmlForExistingCollection
{
param(
    [Parameter(Mandatory=$true, Position=0)]
    [Wmi]
    $RdvmColl,

    [Parameter(Mandatory=$true)]
    [int]
    $Type,

    [Parameter(Mandatory=$true)]
    [string]
    $JobType,

    [Parameter(Mandatory=$false, Position=3)]
    [ref]
    $MasterVmLocation,

    [Parameter(Mandatory=$false)]
    [string]
    $CustomMasterVmLocation,

    [Parameter(Mandatory=$false)]
    [hashtable]
    $VmDistribution,

    [Parameter(Mandatory=$false)]
    [string[]]
    $VmList,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory = $false)]
    [bool]
    $CheckStoragePerms = $false
)
    $Alias=$rdvmColl.Alias

    # get provisioning properties
    try
    {
        $collProps = Get-WmiObject Win32_RDMSCollectionProperties -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Alias='$Alias'"
    }
    catch
    {
        Write-Error ($_.Exception.Message)
    }
    if( -not $collProps )
    {
        Write-Error (Get-ResourceString VmCollectionPropNotFound)
        return $null
    }

    try
    {
        $provProps=$collProps.GetProvisioningProperties()
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }
    if(-not $provProps)
    {
        Write-Error (Get-ResourceString VmCollectionProvPropNotFound)
        return $null
    }

    $vhdType = "DiffDisk"
    if(1 -ne $Type)
    {
        $vhdType = "Clone"
    }
    
    $baseVmLocation=""
    if([string]::IsNullOrEmpty($CustomMasterVmLocation))
    {
        if(($MasterVmLocation))
        {
            $MasterVmLocation.Value = $provProps.MasterVmLocation
        }
        $baseVmLocation = $provProps.MasterVmLocation
    }
    else
    {
        $baseVmLocation = $CustomMasterVmLocation;
    }

    # Make sure there is permission for each host on the share
    if($CheckStoragePerms)
    {
        $centralStorage = ""
        $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::LocalStorage
        if($rdvmColl.IsHA)
        {
            $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSanStorage
            $centralStorage = $provProps.LocalVmLocation
        }
        elseif($provProps.RunFromSMB -and !$provProps.SMBStreaming)
        {
            $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSmbShareStorage
            $centralStorage = $provProps.SMBLocation
        }

        if(-not (Set-StoragePermissions  -StorageType $storageType -CentralStoragePath $centralStorage `
                -LocalStoragePath $provProps.LocalVmLocation -VmTemplateStoragePath $provProps.LocalGoldVmLocation `
                -HostList $VmDistribution.Keys ))
        {
            return $null
        }

        #uvhd share perms, if UVHD is enabled
        $farmSettings = [xml]$rdvmColl.VmFarmSettings
        $node = $farmSettings.SelectSingleNode("/Farm/Metadata[@Name='UvhdShareUrl']")
        if($node)
        {
            $uvhdShare = $node.Attributes["Value"].Value
            if(-not (Set-ShareProvisioningPermissions -Path $uvhdShare -HostList $VmDistribution.Keys))
            {
                return $null
            }
        }
    }

    # generate provisioning XML
    $provXml = Get-ProvisioningXml -CollectionAlias $Alias -Job $JobType -VhdType $vhdType -BaseVmLocation $baseVmLocation `
                    -SmbShare $provProps.SMBLocation -LocalVmCreationPath $provProps.LocalVmLocation -LocalGoldCachePath $provProps.LocalGoldVmLocation `
                    -RunVmFromSmb $provProps.RunFromSMB -EnableVmStreaming $provProps.SMBStreaming `
                    -Prefix $provProps.NamePrefix -StartIndex $provProps.NameStartIndex -Domain $provProps.VmDomain -OU $provProps.VmDomain -HostList $VmDistribution `
                    -VmList $VmList -HighlyAvailable $rdvmColl.IsHA

    if(-not $provXml)
    {
        Write-Error (Get-ResourceString FailedToGetProvXml)
    }

    return $provXml
}

function Test-UnmanagedVmList{

Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string[]]
    $VirtualDesktopList,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [System.Collections.Generic.List[string]]
    $UnmgdVmHostList
)

    if(-not ($VirtualDesktopList.Count))
    {
        Write-Error (Get-ResourceString ErrorEmptyVmList)
        return $false
    }
#Verify Each VM

    foreach($vmName in $VirtualDesktopList)
    {
        #exists in current VM list
        try
        {
            $vmObj = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "Name='$vmName'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if(-not ($vmObj))
        {
            Write-Error (Get-ResourceString FailedToFindVirtualDesktop $vmName)
            return $false
        }

        #verify the desktop is not a member of any pool
        if(-not ([string]::IsNullOrEmpty($vmObj.CollectionAlias)))
        {
            Write-Error (Get-ResourceString VirtDesktopAlreadyAMember $vmName, $vmObj.CollectionAlias)
            return $false
        }
        if($null -ne $UnmgdVmHostList)
        {
            if(-not $UnmgdVmHostList.Contains($vmObj.HostName))
            {
                $UnmgdVmHostList.Add($vmObj.HostName)
            }
        }
    }
    return $true
}

function Test-CollectionMemberVmList{

Param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,

    [Parameter(Mandatory=$true, Position=0)]
    [string[]]
    $VirtualDesktopList,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker 
)

    if(-not ($VirtualDesktopList.Count))
    {
        Write-Error (Get-ResourceString ErrorEmptyVmList)
        return $false
    }
#Verify Each VM

    foreach($vmName in $VirtualDesktopList)
    {
        #exists in current VM list
        try
        {
            $vmObj = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "Name='$vmName'"
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }

        if(-not ($vmObj))
        {
            Write-Error (Get-ResourceString FailedToFindVirtualDesktop $vmName)
            return $false
        }

        #verify it is  a member of specified coll
        if(([string]::Compare($vmObj.CollectionAlias,$CollectionAlias,$true)))
        {
            Write-Error (Get-ResourceString VirtDesktopNotAMemeberOfSpecifiedPool $vmName)
            return $false
        }
    }
    return $true
}

function Test-ManagedParam {

param(

    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [int]
    [ValidateRange(1, 3)]
    $Type,

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateName,

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateHostServer,

    [Parameter(Mandatory=$false)]
    [string]
    $CustomUnattend=$null,

    [Parameter(Mandatory=$true)]
    [string]
    $VmNamePrefix,

    [Parameter(Mandatory=$true)]
    [hashtable]
    $VmDistribution,

    [Parameter(Mandatory=$true)]
    [int]
    $StorageType,

    [Parameter(Mandatory=$false)]
    [string]
    $CentralStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $LocalStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $VmTemplateStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $UvhdSharePath,

    [Parameter(Mandatory=$false)]
    [int]
    $UvhdSize,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
    
)
 
    # Validate VmDistribution, this call also Validate that all the host names specified in the distribution
    # are FQDN and are RDVH servers
    if( -not (Test-VmDistribution -VmDistribution $VmDistribution -ConnectionBroker $ConnectionBroker))
    {
        return $false
    }

    #validate that a collection with same VnName prefix does not exist
    try
    {
        $collProperties = Get-WmiObject Win32_RDMSCollectionProperties -Namespace root\cimv2\Rdms -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    }
    catch 
    {
        #ignore  error
    }

    foreach( $collProperty in $collProperties)
    {
        try
        {
            $provProperties = $collProperty.GetProvisioningProperties()
        }
        catch 
        {
            #IGNORE ERROR
        }
        if(-not $provProperties)
        {
            continue
        }

        if(-not [string]::Compare($VmNamePrefix, $provProperties.NamePrefix, $true))
        {
            Write-Error (Get-ResourceString VmNamePrefixAlreadyExists $VmNamePrefix)
            return $false
        }
    }

    #Validate all the input storage paths
    switch($StorageType)
    {
        #local
        1
        {
            if($VmTemplateStoragePath)
            {
                if(-not (Test-LocalStoragePath -Path $VmTemplateStoragePath -HostList $VmDistribution.Keys))
                {
                    return $false
                }
            }
            if($LocalStoragePath)
            {
                if(-not (Test-LocalStoragePath -Path $LocalStoragePath -HostList $VmDistribution.Keys))
                {
                    return $false
                }
            }
        }
        #SMB
        2
        {
            if([string]::IsNullOrEmpty($CentralStoragePath))
            {
                Write-Error(Get-resourceString CentralStorageCanNotBeEmpty)
                return $false
            }
            if( -not (Test-SmbSharePath($CentralStoragePath)))
            {
                return $false
            }
            #if vm template storage path is specified
            #verify it is a share path
            if(-not ([String]::IsNullOrEmpty($VmTemplateStoragePath)))
            {
                if( -not (Test-SmbSharePath($VmTemplateStoragePath)))
                {
                    Write-Verbose ("VirtualDesktopTemplateStoragePath must have same format as that of CentralStoragePath")
                    return $false
                }
            }
        }
        #SAN
        3
        {
            #vierfy central storage path is not empty
            if([string]::IsNullOrEmpty($CentralStoragePath))
            {
                Write-Error(Get-ResourceString CentralStorageCanNotBeEmpty)
                return $false
            }
            if(-not (Test-ClusterStoragePath -Path $CentralStoragePath -HostList $VmDistribution.Keys))
            {
                return $false
            }

            #if vm template storage path is specified
            # verify that it is a cluster storage path
            if(-not ([String]::IsNullOrEmpty($VmTemplateStoragePath)))
            {
                if(-not (Test-ClusterStoragePath -Path $VmTemplateStoragePath -HostList $VmDistribution.Keys))
                {
                    Write-Verbose ("VirtualDesktopTemplateStoragePath must have same format as that of CentralStoragePath")
                    return $false
                }
            }
        }
    }

    # if custom unattend xml file is specified, validate
    if( -not [string]::IsNUllOrEMpty($CustomUnattend))
    {
        if(-not (Test-FilePath -Path $CustomUnattend))
        {
            Write-Error (Get-ResourceString InvalidUnattendFilePath)
            return $false
        }
        $unattend = New-Object xml

        try
        {
            $unattend.Load($CustomUnattend)
            $nsMgr = New-Object System.Xml.XmlNamespaceManager($unattend.NameTable)
            $nsMgr.AddNamespace("wcm", "http://schemas.microsoft.com/WMIConfig/2002/State");
            $nsMgr.AddNamespace("a", "urn:schemas-microsoft-com:unattend");
            $root=$unattend.DocumentElement
        }
        catch
        {
            Write-Error (Get-ResourceString FailedToLoadUnattendFile)
            return $false
        }

        #Make sure computer name and domain join nodes are not present
        $node = $root.SelectSingleNode("//a:*[translate(local-name(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='computername']",$nsMgr)
        if($node)
        {
            Write-Error (Get-ResourceString InvalidUnattendNoCompName)
            return $false 
        }
        $node = $root.SelectSingleNode("//a:*[translate(local-name(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='component' and `
                                              translate(@*,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='microsoft-windows-unattendedjoin']",$nsMgr)
        if($node)
        {
            Write-Error (Get-ResourceString InvalidUnattendNoDomainJoin)
            return $false 
        }
        #todo:?make sure skip OOBE screen settings are in place?
    }

    #validate the master VM
    if(-not(Test-MasterVm   -VirtualDesktopTemplateName $VirtualDesktopTemplateName `
                        -VirtualDesktopTemplateHostServer $VirtualDesktopTemplateHostServer `
                        -ConnectionBroker $ConnectionBroker))
    {
        return $false
    }

    return $true
}


function Test-VmDistribution
{
param(
    [Parameter(Mandatory=$true)]
    [hashtable]
    $VmDistribution,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker 
)
    #validate host and vmcount list
    if( 0 -ge $VmDistribution.Count ) 
    {
        Write-Error (Get-ResourceString SpecifyVmAllocation)
        return $false
    }

    #get list of all VMHosts in the deployment
    $vmHostServerList = Get-RDServer -Role RDS-VIRTUALIZATION -ConnectionBroker $ConnectionBroker
    
    $vmHostNameList = New-Object System.Collections.Generic.List[string]
    foreach($hostName in $vmHostServerList)
    {
        $vmHostNameList.Add($hostName.Server.ToLower([System.Globalization.CultureInfo]::CurrentCulture))
    }

    # Validate each host is fqdn and is an added VMHost
    foreach($hostName in $VmDistribution.Keys)
    {
        if(-not (Test-Fqdn($hostName)))
        {
            Write-Error (Get-ResourceString InvalidRdvhFqdn $hostName)
            return $false
        }
        if(-not ($vmHostNameList.Contains($hostName.ToLower([System.Globalization.CultureInfo]::CurrentCulture))))
        {
            Write-Error (Get-ResourceString InvalidRdvhRoleNotFound $hostName)
            return $false
        }
    }
    #???TODO: Do we need to make sure that the computer is part of a cluster? 
    # Should we allow using non-clustered host with SAN storage?

    return $true
}


function Test-MasterVm{

param(

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateName,

    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateHostServer,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker 
    
)

    #Verify the host is FQDN and is among the deployment RDS-Virtualization hosts
    if(-not (Test-Fqdn($VirtualDesktopTemplateHostServer)))
    {
        Write-Error (Get-ResourceString InvalidRdvhFqdn $VirtualDesktopTemplateHostServer)
        return $false
    }

    $vmHostServerList = Get-RDServer -Role RDS-VIRTUALIZATION -ConnectionBroker $ConnectionBroker    
    $vmHostNameList = New-Object System.Collections.Generic.List[string]
    foreach($hostName in $vmHostServerList)
    {
        $vmHostNameList.Add($hostName.Server.ToLower([System.Globalization.CultureInfo]::CurrentCulture))
    }
    if(-not ($vmHostNameList.Contains($VirtualDesktopTemplateHostServer.ToLower([System.Globalization.CultureInfo]::CurrentCulture))))
    {
        Write-Error (Get-ResourceString InvalidRdvhRoleNotFound $VirtualDesktopTemplateHostServer)
        return $false
    }
   
    try
    {
        $masterVm = Get-WmiObject Win32_TsVm -Namespace root\cimv2\TerminalServices -ComputerName $VirtualDesktopTemplateHostServer `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "VmName='$VirtualDesktopTemplateName'"
    }
    catch 
    {
        Write-Error ($_.Exception.Message)
    }

    if($null -eq $masterVm)
    {
        Write-Error (Get-ResourceString FailedToFindMasterVm $VirtualDesktopTemplateName)
        return $false
    }

    try
    {
        $outParams = $masterVm.QueryOfflineInformation()
    }
    catch [System.Management.Automation.MethodInvocationException]
    {        
        $errMsg = Get-ErrorMsgFromErrCode($_.Exception.InnerException.ErrorCode)
    }
    catch 
    {
        $errMsg = $_.Exception.Message
    }

    if ($errMsg)
    {
        Write-Error (Get-ResourceString FailedToGetMasterVmInfo $errMsg)
        return $false
    }

    if (0 -ne $outParams.ReturnValue)
    {
        $errMsg = Get-ErrorMsgFromErrCode($outParams.ReturnValue)
        Write-Error (Get-ResourceString FailedToGetMasterVmInfo $errMsg)
        return $false
    }
    
    if($outParams.SysPrepImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE')
    {
        Write-Error (Get-ResourceString ErrorMasterVmNotGeneralized)
        return $false
    }
    return $true
}

function Get-ErrorMsgFromErrCode($errCode)
{
    try
    {
        if($errCode -lt 0)
        {
            $errCode = [UInt32]('0x'+('{0:X}'-f $errCode))
        }
        $errCodeToMsg = New-Object Microsoft.RemoteDesktopServices.Management.Cmdlets.RolloutJobReport
        return $errCodeToMsg.GetMessageForError($errCode)
    }
    catch
    {
        return $errCode
    }
}

function Get-ExportRoot
{

param(
    [Parameter(Mandatory=$true)]
    [int]
    $StorageType,

    [Parameter(Mandatory=$false)]
    [string]
    $CentralStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $VmTemplateStoragePath,


    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker

)

    if(1 -eq $StorageType)
    {
        try
        {
            $outParam = Invoke-WmiMethod -class win32_RdmsDeploymentSettings -name GetExportPath `
            -Namespace root\cimv2\rdms -ComputerName $ConnectionBroker -ErrorAction Stop -Authentication PacketPrivacy 
        }
        catch 
        {
            Write-Error ($_.Exception.Message)
        }
        if( (-not $outParam) -or ([String]::IsNullOrEmpty($outParam.DirectoryPath)))
        {
            Write-Error (Get-ResourceString ExportRootNotFound)
            return $null
        }
        if(-not (Test-SmbSharePath -Path $outParam.DirectoryPath -ErrorAction SilentlyContinue))
        {
            Write-Error (Get-ResourceString ExportRootInvalid $outParam.DirectoryPath)
            return $null
        }

        $exportRoot = $outParam.DirectoryPath
    }
    elseif(-not([string]::IsNullOrEmpty($VmTemplateStoragePath)))
    {
        $exportRoot=$VmTemplateStoragePath
    }
    else
    {
        $exportRoot=$CentralStoragePath
    }

    Write-Verbose ("Selected ["+$exportRoot+"] for exporting template")
    return $exportRoot
}


function Get-UNCPath{
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    [string]
    $Hostname
)
    $uncPath = $Path
    $uri = New-Object System.Uri($Path)
    if (-not $uri.IsUnc)
    {
        $Path = $path.Replace(':', '$');
        $uncPath = '\\' + $HostName + '\' + $Path
    }

    return $uncPath
}

function New-VMExportLocation{
param(
    [Parameter(Mandatory=$true)]
    [string]
    $ExportRoot,

    [Parameter(Mandatory=$true)]
    [string]
    $Alias,
    
    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopTemplateHostServer
)

    $uncPath=Get-UNCPath -Path $ExportRoot -Hostname $VirtualDesktopTemplateHostServer

    #if the export location already exists, create new path
    $i=0
    do
    {
        $i++
        $childPath=$Alias+"\IMGS\__"+$i
    }while([System.IO.Directory]::Exists($uncPath+"\"+$childPath) -or `
           [System.IO.File]::Exists($uncPath+"\"+$childPath))
    
    #create directory
    try
    {
        $dir = [System.IO.Directory]::CreateDirectory(($uncPath+"\"+$childPath))
    }
    catch 
    {
        Write-Error (Get-resourceString FailedToCreateFolder ($uncPath+"\"+$childPath), $_.Exception.Message)
        return $null
    }

    #return created path
    return ([string]($ExportRoot+"\"+$childPath))
}

#gets the "Netbios" name using WMI
function Get-NtAccount{
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
        Write-Error (Get-ResourceString FailedToGetComputerObject $HostName, $_.Exception.Message)
        return $null
    }
    return ($compObject.Domain+'\'+$compObject.Name+'$')
}

function Set-PermissionsOnShare{

param(

    [Parameter(Mandatory=$true)]
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    [string]
    $Account

)
    $accSid = ConvertTo-Sid($Account)
    if($null -eq $accSid)
    {
        Write-Error (Get-ResourceString InvalidAccount $Account)
        return $false
    }

    $rights = [System.Security.AccessControl.FileSystemRights]::FullControl
    $dirInfo = New-Object System.IO.DirectoryInfo($Path)
    $dirSecurity = $dirInfo.GetAccessControl()

    $currAccessRules = $dirSecurity.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
    foreach($rule in $currAccessRules)
    {
        if([string]::Compare($rule.IdentityReference.Value, $accSid.Value, $true))
        {
            continue
        }
        $maskedRights = ($rule.FileSystemRights -band $rights)
        if($maskedRights -eq $rights)
        {
            return $true
        }
    }
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Account, $rights, `
                ([System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit), `
                [System.Security.AccessControl.PropagationFlags]::None, [System.Security.AccessControl.AccessControlType]::Allow)
    $modified = $false
    $dirSecurity.ModifyAccessRule([System.Security.AccessControl.AccessControlModification]::Reset, $accessRule, [ref]$modified)
    try
    {
        $dirInfo.SetAccessControl($dirSecurity)
    }
    catch 
    {
        Write-Error (Get-ResourceString FailedToSetFolderPermission $Path,$_.Exception.Message)
        return $false
    }
    return $true
}

function Set-ShareProvisioningPermissions {
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    [string[]]
    $HostList
    )
    $nwAccPermSet = $false
    $nwAcc = ConvertTo-NtAccount('S-1-5-20')
    $pathUri = New-Object System.Uri($Path)

    foreach($host in $HostList)
    {
        $uncPath = Get-UNCPath -Path $Path -Hostname $host
        $shareHostName = (New-Object System.Uri($uncPath)).Host

        $hostAcc = Get-NtAccount($host)
        if(-not $hostAcc)
        {
            return $false
        }
        $account =  $hostAcc

        $shareHostAcc = Get-NtAccount($shareHostName)
        if(-not $shareHostName)
        {
            return $false
        }

        #if the nt account of host on UNC path matches hostName, use nwSid else Use the Host account
        if(-not ([string]::Compare($hostAcc, $shareHostAcc, $true)))
        {
            $account = $nwAcc
            $nwAccPermSet = $true;
            #if the original path is UNC, it implies it is a loopback SMB or Scale-OUT SMB
            # set permission for machine account as well
            if($pathUri.IsUnc)
            {
                if( -not (Set-PermissionsOnShare -Path $uncPath -Account $hostAcc))
                {
                    return $false
                }
            }
        }
        #set permissions on the UNC path
        if( -not (Set-PermissionsOnShare -Path $uncPath -Account $account))
        {
            return $false
        }

        #if path is UNC, set smb permissions on the share as well
        if($pathUri.IsUnc)
        {
            [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GrantFullSmbPermissions($pathUri.Host, $pathUri.Segments[1], (ConvertTo-Sid($account)))
        }
    }
    # always make sure that network service is granted perms on the SMB share
    # for loopback SMB and scale out SMB
    if(-not($nwAccPermSet) -and $pathUri.IsUnc)
    {
        #set permissions on the UNC path
        if( -not (Set-PermissionsOnShare -Path $Path -Account $nwAcc))
        {
            return $false
        }
    }

    return $true
}

function Set-StoragePermissions{

param(
    [Parameter(Mandatory=$true)]
    [int]
    $StorageType,

    [Parameter(Mandatory=$false)]
    [string]
    $CentralStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $LocalStoragePath,

    [Parameter(Mandatory=$false)]
    [string]
    $VmTemplateStoragePath,

    [Parameter(Mandatory=$true)]
    [string[]]
    $HostList
    
)

    Write-Verbose "Setting up permissions on Storage"

    switch($StorageType)
    {
        1
        {
            if( $true -ne [System.String]::IsNullOrEmpty($LocalStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $LocalStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
            if( $true -ne [System.String]::IsNullOrEmpty($VmTemplateStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $VmTemplateStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
        }
        2
        {
            if( $true -ne [System.String]::IsNullOrEmpty($CentralStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $CentralStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
            if( $true -ne [System.String]::IsNullOrEmpty($VmTemplateStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $VmTemplateStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
        }
        3
        {
            if( $true -ne [System.String]::IsNullOrEmpty($CentralStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $CentralStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
            if( $true -ne [System.String]::IsNullOrEmpty($VmTemplateStoragePath) )
            {
                if(-not (Set-ShareProvisioningPermissions -Path $VmTemplateStoragePath -HostList $HostList))
                {
                    return $false
                }
            }
        }
    }
    return $true
}


function Get-ProvisioningXml {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,

    [Parameter(Mandatory=$true)]
    [string]
    $Job,

    [Parameter(Mandatory=$true)]
    [string]
    $VhdType,

    [Parameter(Mandatory=$true)]
    [string]
    $BaseVmLocation,

    [Parameter(Mandatory=$false)]
    [string]
    $SmbShare="",

    [Parameter(Mandatory=$false)]
    [string]
    $LocalVmCreationPath="",

    [Parameter(Mandatory=$false)]
    [string]
    $LocalGoldCachePath="",

    [Parameter(Mandatory=$true)]
    [int]
    $RunVmFromSmb,

    [Parameter(Mandatory=$true)]
    [int]
    $EnableVmStreaming,

    [Parameter(Mandatory=$true)]
    [string]
    $Prefix,

    [Parameter(Mandatory=$true)]
    [int]
    $StartIndex,

    [Parameter(Mandatory=$true)]
    [string]
    $Domain,
    
    [Parameter(Mandatory=$false)]
    [bool]
    $HighlyAvailable=$false,

    [Parameter(Mandatory=$false)]
    [string]
    $OU,

    [Parameter(Mandatory=$false)]
    [string]
    $CustomUnattend=$null,

    [Parameter(Mandatory=$false)]
    [hashTable]
    $HostList=@{},

    [Parameter(Mandatory=$false)]
    [string[]]
    $VmList=[string[]]''
    
)

    $unattendXml=
                "<unattend xmlns='urn:schemas-microsoft-com:unattend' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State'>"+
                    "<settings pass='oobeSystem'>"+
                        "<component name='Microsoft-Windows-Shell-Setup' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' processorArchitecture='x86'>"+
                            "<OOBE>"+
                                "<HideEULAPage>true</HideEULAPage>"+
                                "<SkipMachineOOBE>true</SkipMachineOOBE>"+
                                "<SkipUserOOBE>true</SkipUserOOBE>"+
                                "<ProtectYourPC>3</ProtectYourPC>"+
                                "<NetworkLocation>Work</NetworkLocation>"+
                            "</OOBE>"+
                        "</component>"+
                        "<component name='Microsoft-Windows-Shell-Setup' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' processorArchitecture='amd64'>" +
                            "<OOBE>" +
                                "<HideEULAPage>true</HideEULAPage>" +
                                "<SkipMachineOOBE>true</SkipMachineOOBE>" +
                                "<SkipUserOOBE>true</SkipUserOOBE>" +
                                "<ProtectYourPC>3</ProtectYourPC>" +
                                "<NetworkLocation>Work</NetworkLocation>" +
                            "</OOBE>" +
                        "</component>" +
                    "</settings>" +
                "</unattend>"

    if( -not ([System.string]::IsNullOrEmpty($CustomUnattend)))
    { 
        #assuming the XML has already been validated
        $unattendXml = Get-Content $CustomUnattend
    }

    $action="Stop"
    if ($Job -eq "delete")
    {
        $action = "Continue"
    }

    $hyperVHostList=""
    $i=0
    Foreach ($key in $HostList.Keys)
    {
        $hyperVHost = "<rdvp:HyperVHost>"+
                        "<rdvp:Name>"+$key+"</rdvp:Name>"+
                        "<rdvp:NumberVms>"+$HostList[$key]+"</rdvp:NumberVms>"+
                      "</rdvp:HyperVHost>"
        $hyperVHostList+=$hyperVHost
        $i++
    }

    $selectedVmList='<rdvp:SelectedVms>'
    foreach($vm in $VmList)
    {
        $selectedVmList+=('<rdvp:SelectedVm>'+$vm+'</rdvp:SelectedVm>')
    }
    $selectedVmList+='</rdvp:SelectedVms>'
    $HA="No"
    if($HighlyAvailable)
    {
        $HA="Yes"
    }


    $provXmlTemplate=
           "<?xml version='1.0' encoding='utf-16'?>"+
            "<rdvp:RDVProvisioning xmlns:rdvp='http://www.microsoft.com/rdv/2010/05/'>"+
                "<rdvp:ProvisionPoolRequest>"+
                    "<rdvp:Job>"+
                        "<rdvp:Action>"+$Job+"</rdvp:Action>"+
                        "<rdvp:OnError>"+$action+"</rdvp:OnError>"+
                    "</rdvp:Job>"+
                    "<rdvp:Pool>"+
                        "<rdvp:Name>"+$CollectionAlias+"</rdvp:Name>"+
                        "<rdvp:VhdType>"+$VhdType+"</rdvp:VhdType>"+
                        "<rdvp:Mark_HA>"+$HA+"</rdvp:Mark_HA>"+
                    "</rdvp:Pool>"+
                    "<rdvp:Vm>"+
                        "<rdvp:BaseVmLocation>"+$BaseVmLocation+"</rdvp:BaseVmLocation>"+
                        "<rdvp:SMBShare>"+$SmbShare+"</rdvp:SMBShare>"+
                        "<rdvp:LocalVmCreationPath>"+$LocalVmCreationPath+"</rdvp:LocalVmCreationPath>"+
                        "<rdvp:LocalGoldCachePath>"+$LocalGoldCachePath+"</rdvp:LocalGoldCachePath>"+
                        "<rdvp:RunVMsFromSMB>"+$RunVmFromSmb+"</rdvp:RunVMsFromSMB>"+
                        "<rdvp:EnableVmStreaming>"+$EnableVmStreaming+"</rdvp:EnableVmStreaming>"+
                        "<rdvp:NamingPrefix>"+$Prefix+"</rdvp:NamingPrefix>"+
                        "<rdvp:NamingStartIndex>"+$StartIndex+"</rdvp:NamingStartIndex>"+
                        "<rdvp:Domain>"+$Domain+"</rdvp:Domain>"+
                        "<rdvp:OU>"+$OU+"</rdvp:OU>"+
                        "<rdvp:UnattendXml>"+
                        "<![CDATA["+
                        $unattendXml+
                        "]]>"+
                        "</rdvp:UnattendXml>"+
                    "</rdvp:Vm>"+
                    "<rdvp:HyperVHosts>"+
                        $hyperVHostList+
                    "</rdvp:HyperVHosts>"+
                    $selectedVmList+
                "</rdvp:ProvisionPoolRequest>"+
            "</rdvp:RDVProvisioning>"

    return $provXmlTemplate
}


function Test-SmbSharePath{

param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path
)

    #verify it is a UNC path
    $uri = New-Object System.Uri($Path)
    if (-not ($uri.IsUnc))
    {
        Write-Error (Get-ResourceString InvalidSmbSharePath $Path)
        return $false
    }
    #verify
    if(-not (Test-Path -Path $Path -ErrorAction SilentlyContinue))
    {
        Write-Error (Get-ResourceString UnreacahbleSmbSharePath $Path)
        return $false
    }
    return $true
}


function Test-LocalStoragePath{

param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    [string[]]
    $HostList
)

    #verify it is a local drive path
    $uri = New-Object System.Uri($Path)
    if ($uri.IsUnc)
    {
        Write-Error (Get-ResourceString InvalidLocalStoragePath $Path)
        return $false
    }

    #verify path exists on each server
    foreach($hostName in $HostList)
    {
        $uncPath=Get-UNCPath -Path $Path -Hostname $hostName
        if(-not (Test-Path -Path $uncPath -ErrorAction SilentlyContinue))
        {
            Write-Error (Get-ResourceString UnreachableVmhostLocalPath $Path, $hostName)
            return $false
        }
    }
    return $true
}

function Test-ClusterStoragePath{
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    [string[]]
    $HostList
)
    #verify that central path is in cluster storage format
    $subParts = $Path.Split(([char[]]('\')))
    if( (4 -gt $subParts.Count) -or
        ([string]::Compare($subParts[1],"clusterstorage",$true)))
    {
        Write-Error (Get-resourceString InvalidSanStoragePath)
        return $false
    }

    #verify it is reachable on each host
    if(-not (Test-LocalStoragePath -Path $Path -HostList $HostList))
    {
        return $false
    }
    return $true
}

function Test-ScheduleProvisioningJob{

param(
    [Parameter(Mandatory=$true)]
    [System.Management.ManagementBaseObject]
    $rdvmColl
)

    $jobStatus = Get-RDVirtualDesktopCollectionJobStatus -CollectionName $rdvmColl.Name -ConnectionBroker $ConnectionBroker

    if(-not $jobStatus)
    {
        return $false
    }

    if( ($jobStatus.Status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UNKNOWN) -and
        ($jobStatus.Status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_FAILED) -and
        ($jobStatus.Status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_CANCELLED) -and        
        ($jobStatus.Status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::JOB_COMPLETED) -and
        ($jobStatus.Status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::JOB_ABORTED) )
    {
        Write-Error (Get-ResourceString ErrProvJobAlreadyScheduled)
        return $false
    }

    #see if there is another job running at backend somehow
    try
    {
        $out = Invoke-WmiMethod -Class Win32_RDMSVirtualDesktopCollection -Name ProvisioningEnumerateJobs -ComputerName $ConnectionBroker `
                -Namespace 'root\cimv2\rdms' -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -ArgumentList ($rdvmColl.Alias,0) 
    }
    catch 
    {
        Write-Error $_.Exception.Message
    }
    if((-not $out) -or (0 -ne $out.ReturnValue))
    {
        Write-Error (Get-ResourceString ErrFailedToQueryRunningJob)
        return $false
    }
    if( ($out.JobGuids.Count -gt 0) )
    {
        Write-Error (Get-ResourceString  ErrProvJobAlreadyScheduled)
        return $false
    }

    return $true
}

function Get-ValidRdvhFromArray {
param(
    [Parameter(Mandatory=$true)]
    [int]
    $ConfigurationValue,

    [Parameter(Mandatory=$true)]
    [string[]]
    $HostServer,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)

    $VirtualizationHosts = Get-RDServer $ConnectionBroker -Role RDS-VIRTUALIZATION
    $HostList = New-Object Hashtable([StringComparer]::InvariantCultureIgnoreCase)

    foreach($Server in $HostServer)
    {
        $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $Server, IgnoreCase
        $WildCardMatches = ($VirtualizationHosts | Where-Object { $WildCard.IsMatch($_.Server) })

        if($null -ne $WildCardMatches)
        {
            foreach($match in $WildCardMatches)
            {
                if(-not $HostList.ContainsKey($match.Server))
                {
                    $HostList.Add($match.Server, $ConfigurationValue)
                }
            }
        }
        else
        {
            if([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Server))
            {
                Write-Verbose (Get-ResourceString WrnWildcardNoMatches $Server)
            }
        }
    }

    return $HostList
}

function Get-ValidRdvhFromHashtable {
param(
    [Parameter(Mandatory=$true)]
    [Hashtable]
    $Allocation,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)

    $VirtualizationHosts = Get-RDServer $ConnectionBroker -Role RDS-VIRTUALIZATION
    $HostList = New-Object Hashtable([StringComparer]::InvariantCultureIgnoreCase)

    foreach($Server in $Allocation.Keys)
    {
        $match = ($VirtualizationHosts | Where-Object { $Server.ToLower() -eq $_.Server.ToLower() })

        if($null -ne $match)
        {
            $HostList.Add($match.Server, $Allocation[$Server])
        }
    }

    return $HostList
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-VirtualDesktopIdleCount {
[CmdletBinding(DefaultParameterSetName="Default",
HelpURI="http://go.microsoft.com/fwlink/?LinkId=254109")]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Default", Position=0)]
    [int]
    $IdleCount,

    [Parameter(Mandatory=$false, ParameterSetName="Default", Position=1)]
    [string[]]
    $HostServer,

    [Parameter(Mandatory=$true, ParameterSetName="Allocation", Position=0)]
    [Hashtable]
    $Allocation,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]
    $BatchSize = 10
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ($null -eq $ConnectionBroker)
    {
        return
    }

    switch ($PsCmdlet.ParameterSetName)
    {
        "Default"
        {
            if($null -eq $HostServer)
            {
                $HostServer = "*"
            }

            $HostList = (Get-ValidRdvhFromArray -ConfigurationValue $IdleCount -HostServer $HostServer -ConnectionBroker $ConnectionBroker)
        }
         
        "Allocation"
        {
            $HostList = (Get-ValidRdvhFromHashtable -Allocation $Allocation -ConnectionBroker $ConnectionBroker)
        }
    }

    $JobList = @()
    $ErrInvalidIdleVmCountType = Get-RawResourceString ErrInvalidIdleVmCountType
    $ErrSettingIdleVmCount = Get-RawResourceString ErrSettingIdleVmCount

    foreach($VMHAHost in $HostList.Keys)
    {
        $JobList += Start-Job  -scriptblock `
        {
            try
            {
                $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $args[0])
                $VMHAParamKey=$RemoteRegistry.CreateSubKey("SYSTEM\\CurrentControlSet\\Services\\VmHostAgent\\Parameters")
                if($null -ne $args[3])
                {
                    if($args[3].GetType().FullName -eq "System.Int32")
                    {
                        $VMHAParamKey.SetValue("IdleVmCount", $args[3])
                        $true
                    }
                    else
                    {
                        throw ($args[1] -f $args[3].GetType().FullName, $args[0])
                    }
                }
                elseif($null -ne $VMHAParamKey.GetValue("IdleVmCount"))
                {
                    $VMHAParamKey.DeleteValue("IdleVmCount")
                    $false
                }
            }
            catch
            {
                throw ($args[2] -f $args[0], $_.Exception.Message)
            }
        } -ArgumentList $VMHAHost,$ErrInvalidIdleVmCountType,$ErrSettingIdleVmCount,$HostList[$VMHAHost] -Name $VMHAHost

        if($JobList.Length -ge $BatchSize)
        {
            if($JobList.Length -gt 1)
            {
                Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
            }
            else
            {
                Write-Verbose (Get-ResourceString WaitingForJobToComplete)
            }

            $WaitResult = Wait-Job -Job $JobList

            foreach($job in $JobList)
            {
                if($job.State -eq 'Failed')
                {
                    Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
                }
                else
                {
                    $retVal = Receive-Job $job
                    if($retVal)
                    {
                        Write-Verbose (Get-ResourceString IdleVmCountSetSuccess $job.Name)
                    }
                    else
                    {
                        Write-Verbose (Get-ResourceString IdleVmCountDeleteSuccess $job.Name)
                    }
                    
                }
            }
            
            $JobList = @()
        }
    }


    if($JobList.Length -gt 0)
    {
        if($JobList.Length -gt 1)
        {
            Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
        }
        else
        {
            Write-Verbose (Get-ResourceString WaitingForJobToComplete)
        }
        
        $WaitResult = Wait-Job -Job $JobList
    
        foreach($job in $JobList)
        {
            if($job.State -eq 'Failed')
            {
                Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
            }
            else
            {
                $retVal = Receive-Job $job
                if($retVal)
                {
                    Write-Verbose (Get-ResourceString IdleVmCountSetSuccess $job.Name)
                }
                else
                {
                    Write-Verbose (Get-ResourceString IdleVmCountDeleteSuccess $job.Name)
                }
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktopIdleCount {
[CmdletBinding(HelpURI="http://go.microsoft.com/fwlink/?LinkId=254110")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopIdleCount[]")]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string[]]
    $HostServer,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]
    $BatchSize = 10
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ($null -eq $ConnectionBroker)
    {
        return
    }

    if($null -eq $HostServer)
    {
        $HostServer = "*"
    }

    $HostList = (Get-ValidRdvhFromArray -ConfigurationValue 0 -HostServer $HostServer -ConnectionBroker $ConnectionBroker)

    $JobList = @()
    $ValidResults = @()

    $ErrReadingIdleVmCount = Get-RawResourceString ErrReadingIdleVmCount

    foreach($VMHAHost in $HostList.Keys)
    {
        $JobList += Start-Job  -scriptblock `
        {
            try
            {
                $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $args[0])
                $VMHAParamKey=$RemoteRegistry.CreateSubKey("SYSTEM\\CurrentControlSet\\Services\\VmHostAgent\\Parameters")
                $retVal = $VMHAParamKey.GetValue("IdleVmCount")
                $retVal
            
            }
            catch
            {
                throw ($args[1] -f $args[0], $_.Exception.Message)
            }
        } -ArgumentList $VMHAHost,$ErrReadingIdleVmCount -Name $VMHAHost

        if($JobList.Length -ge $BatchSize)
        {
            if($JobList.Length -gt 1)
            {
                Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
            }
            else
            {
                Write-Verbose (Get-ResourceString WaitingForJobToComplete)
            }

            $WaitResult = Wait-Job -Job $JobList

            foreach($job in $JobList)
            {
                if($job.State -eq 'Failed')
                {
                    Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
                }
                else
                {
                    $retVal = Receive-Job $job
                    $ValidResults += New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopIdleCount -ArgumentList $job.Name,$retVal
                }
            }
            
            $JobList = @()
        }
    }

    if($JobList.Length -gt 0)
    {
        if($JobList.Length -gt 1)
        {
            Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
        }
        else
        {
            Write-Verbose (Get-ResourceString WaitingForJobToComplete)
        }
        
        $WaitResult = Wait-Job -Job $JobList

        foreach($job in $JobList)
        {
            if($job.State -eq 'Failed')
            {
                Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
            }
            else
            {
                $retVal = Receive-Job $job
                $ValidResults += New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopIdleCount -ArgumentList $job.Name,$retVal
            }
        }
    }

    $ValidResults
}


function Set-VirtualDesktopHostSetting {
param(
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $Name,

    [Parameter(Mandatory=$true)]
    [string]
    $Value,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]
    $BatchSize = 10
)

    $VirtualizationHosts = Get-RDServer $ConnectionBroker -Role RDS-VIRTUALIZATION

    $JobList = @()
    $ErrSettingHostConfiguration = Get-RawResourceString ErrSettingHostConfiguration

    foreach($VMHAHost in $VirtualizationHosts)
    {
        $JobList += Start-Job  -scriptblock `
        {
            try
            {
                $RemoteRegistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $args[0])
                $VMHAParamKey=$RemoteRegistry.CreateSubKey("SYSTEM\\CurrentControlSet\\Services\\VmHostAgent\\Parameters" + "\\" + $args[4])
                $VMHAParamKey.SetValue($args[2], $args[3])            
            }
            catch
            {
                throw ($args[1] -f $Name, $args[0], $_.Exception.Message)
            }
        } -ArgumentList $VMHAHost.Server,$ErrSettingHostConfiguration,$Name,$Value,$CollectionName -Name $VMHAHost.Server

        if($JobList.Length -ge $BatchSize)
        {
            if($JobList.Length -gt 1)
            {
                Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
            }
            else
            {
                Write-Verbose (Get-ResourceString WaitingForJobToComplete)
            }

            $WaitResult = Wait-Job -Job $JobList

            foreach($job in $JobList)
            {
                if($job.State -eq 'Failed')
                {
                    Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
                }
                else
                {
                    $retVal = Receive-Job $job
                }
            }
            
            $JobList = @()
        }       
    }    

    if($JobList.Length -gt 0)
    {
        if($JobList.Length -gt 1)
        {
            Write-Verbose (Get-ResourceString WaitingForBatchToComplete $JobList.Length)
        }
        else
        {
            Write-Verbose (Get-ResourceString WaitingForJobToComplete)
        }
        
        $WaitResult = Wait-Job -Job $JobList
    
        foreach($job in $JobList)
        {
            if($job.State -eq 'Failed')
            {
                Write-Error ($job.ChildJobs[0].JobStateInfo.Reason.Message)
            }
            else
            {
                $retVal = Receive-Job $job
            }
        }
    }

    return $true
}

function Test-ExportInProgress{
param(
    [Parameter(Mandatory=$true)]
    [System.Management.ManagementBaseObject]
    $rdvmColl
)
    
    if( ($status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UNKNOWN) -and
        ($status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_FAILED) -and
        ($status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::UPDATE_CANCELLED) -and        
        ($status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::JOB_COMPLETED) -and
        ($status -ne [Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus]::JOB_ABORTED) )
    {
        return $false
    }
    try
    {
        $getExpRes =  Invoke-WmiMethod -Name GetStringProperty -ArgumentList "ExportInProgress" -InputObject $rdvmColl `
                        -ErrorAction Stop
    }
    catch 
    {
        Write-Verbose ("Failed to get exportInProgress property")
    }
    if( $getExpRes -and 
        $getExpRes.ReturnValue -eq 0 -and
        -not [string]::IsNullOrEmpty($getExpRes.Value)
        )
    {
        $exportInProgress = $getExpRes.Value
    }
    else
    {
        return $false
    }

    #make sure that virtual machine is being exported, by querying hyper-V job
    try
    {
        $templateDesktopObj = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "Name='$exportInProgress'"

        $templateVmObj = Get-WmiObject -Class "MSVM_ComputerSystem" -Namespace "root\virtualization\V2" -ComputerName $templateDesktopObj.HostName `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                    -Filter "ElementName='$exportInProgress'"
        $hvTemplateJobList = [wmi[]](Get-WmiObject -Query ('Associators of {'+$templateVmObj.__RELPATH+'} where ResultClass=Msvm_ConcreteJob') `
                    -Namespace "root\virtualization\V2" -ComputerName $templateDesktopObj.HostName `
                    -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop)
        foreach($hvJobs in $hvTemplateJobList)
        {
            if($hvJobs.JobType -eq 62)#62 is export job
            {
                return $true
            }
        }        
    }
    catch
    {
        Write-Verbose ("failed to retrieve the hyperV export job for the tempalte VM:"+$exportInProgress)
    }
    #clear the exportInProgress as no export job found associated with the templateName
    try
    {
        $rdvmColl.SetStringProperty("ExportInProgress",[string]::Empty)|Out-Null
    }
    catch
    {
        Write-Verbose ("Failed to clear export in progress")
        #ignore error
    }
    return $false
}

