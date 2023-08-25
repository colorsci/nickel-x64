
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\CustomRdpProperty.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-VirtualDesktopCollectionConfiguration {
[CmdletBinding(DefaultParameterSetName="General",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254111")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionGeneralProperties")]
[OutputType("System.Security.Principal.SecurityIdentifier")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionUserProfileDisksProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionClientProperties")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionVirtualDesktopsProperties")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,

    [Parameter(ParameterSetName="VirtualDesktopConfiguration", Mandatory=$true)]
    [switch]
    $VirtualDesktopConfiguration,
    
    [Parameter(ParameterSetName="UserGroups", Mandatory=$true)]
    [switch]
    $UserGroups,

    [Parameter(ParameterSetName="Client", Mandatory=$true)]
    [switch]
    $Client,
    
    [Parameter(ParameterSetName="UserProfileDisks", Mandatory=$true)]
    [switch]
    $UserProfileDisks,

    [string]
    $ConnectionBroker
)
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)

    if ([string]::IsNullOrEmpty($ConnectionBroker)) {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }     
  
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {       
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    # Get collection alias
    $wmiNamespace = "root\cimv2\rdms"; 
    $wmiQuery = "SELECT * FROM Win32_RDMSVirtualDesktopCollection WHERE Name='" + $CollectionName + "'";

    try {
        $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

        if ($wmiObj -eq $null) {
	    Write-Error (Get-ResourceString ErrorRetrievingCollection $CollectionName)
            return
        }   

    } catch { 
         Write-Error( Get-ResourceString LookupCollectionWmiError $_)
         return
    }

    $CollectionAlias = $wmiObj.Alias

    $vmFarmSettingsXml = [xml]$wmiObj.VmFarmSettings

    switch ($PsCmdlet.ParameterSetName)
    {
        "General"
        {
            try
            {
                $customRdpProperties = Get-CollectionCustomRdpProperty -CollectionName $CollectionName -CollectionAlias $CollectionAlias -ConnectionBroker $ConnectionBroker
            }
            catch
            {
                Write-Error $_
                return
            }
        
            $saveDelay = [UInt64]$vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='SaveDelay']").Attributes["Value"].Value
            
            # Convert SaveDelay from milliseconds to minutes
            $saveDelay /= (60 * 1000)
            $rdCollectionType = 0
            $autoAssignPersonalDesktop = $false
            
            Get-RDVirtualDesktopCollectionType -BackEndCollectionType $wmiObj.Type -IsManaged $wmiObj.IsManaged ([ref] $rdCollectionType) ([ref] $autoAssignPersonalDesktop)
            
            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionGeneralProperties `
                -ArgumentList $wmiObj.CollectionDescription, $autoAssignPersonalDesktop, $rdCollectionType, $saveDelay, $customRdpProperties
        }
        
        "UserGroups"
        {
            $securityGroups = $wmiObj.SecurityDescriptor
           
            Get-UserGroupsFromSecurityDescriptor($securityGroups)
        }
        
        "UserProfileDisks"
        {
            $userVHDSettingXml = [xml]$wmiObj.UserVHDSetting
        
            $isUserVHDEnabledXml = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdProfRoamingEnabled']")
            if ($isUserVHDEnabledXml -ne $null)
            {
                $isUserVHDEnabled = 0 -eq [System.String]::Compare($isUserVHDEnabledXml.Attributes["Value"].Value, "true", $true)
            }
            
            if ($isUserVHDEnabled)
            {
                $userVHDShare = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdShareUrl']").Attributes["Value"].Value
                $userVHDXml = [xml]($vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdProfRoamingPolicy']").Attributes["Value"].Value)
                
                if ($userVHDXml -ne $null)
                {
                    $incFolderLocations = $userVHDXml.UvhdRoamingPolicy.Include.Folder
                    $excFolderLocations = $userVHDXml.UvhdRoamingPolicy.Exclude.Folder
                    $incFileLocations = $userVHDXml.UvhdRoamingPolicy.Include.File
                    $excFileLocations = $userVHDXml.UvhdRoamingPolicy.Exclude.File
                }
                
                $diskSize = ([int64]$userVHDSettingXml.SelectSingleNode("/UVHDTemplateSetting/DiskSize").InnerText / 1GB)
            }
        
            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionUserProfileDisksProperties `
                -ArgumentList $incFolderLocations, $excFolderLocations, $incFileLocations, $excFileLocations, $userVHDShare, $isUserVHDEnabled, $diskSize
        }

        "Client"
        {
            try
            {
                try 
                {
                    $getPropResult = $wmiObj.GetInt32Property("DeviceRedirectionOptions")
                    
                    if ($getPropResult.ReturnValue -ne 0)
                    {
                        Write-Error( Get-ResourceString FailedToGetDeviceRedirectionOptions $getPropResult.ReturnValue)
                    }
    
                    $intDeviceRedirectionOptions = $getPropResult.Value
                }
                catch [System.Management.ManagementException]
                {
                    # An exception is expected if the property has not been set yet
                    $intDeviceRedirectionOptions = 0
                }
    
                try
                {
                    $deviceRedirectionOptions = [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]$intDeviceRedirectionOptions
                }
                catch
                {
                    Write-Error (Get-ResourceString FailedToGetDeviceRedirectionOptions $_)
                    $deviceRedirectionOptions = [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]::None
                }
    
                try
                {
                    $getPropResult = $wmiObj.GetInt32Property("MaxMonitors")  
    
                    if ($getPropResult.ReturnValue -ne 0)
                    {
                        Write-Error( Get-ResourceString FailedToGetMaxMonitors $getPropResult.ReturnValue)
                    }
    
                    $maxMonitors = $getPropResult.Value
                }
                catch [System.Management.ManagementException]
                {
                    # An exception is expected if the property has not been set yet
                    $maxMonitors = 0
                }
    
                try
                {
                    $getPropResult = $wmiObj.GetInt32Property("RedirectClientPrinter")
    
                    if ($getPropResult.ReturnValue -ne 0)
                    {
                        Write-Error( Get-ResourceString FailedToGetRedirectClientPrinter $getPropResult.ReturnValue)
                    }
    
                    $redirectClientPrinter = $getPropResult.Value
                }
                catch [System.Management.ManagementException]
                {
                    # An exception is expected if the property has not been set yet
                    $redirectClientPrinter = 0
                }
            }
            catch
            {
                Write-Error( Get-ResourceString FailedToRetrieveClientProperties $_ )
                return
            }
            
            New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionClientProperties `
                -ArgumentList $deviceRedirectionOptions, ($maxMonitors -gt 1), $redirectClientPrinter
     
        }
        
        "VirtualDesktopConfiguration"
        {
            if($wmiObj.IsManaged)
            {
                $wmiQuery = "SELECT * FROM Win32_RDMSCollectionProperties WHERE Alias='$CollectionAlias'"
                try
                { 
                    $collPropWmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop    
                }
                catch
                {
                    Write-Error (Get-ResourceString ErrorRetrievingRDMSCollection $_)
                    return
                }
                
                $provisioningProperties = $collPropWmiObj.GetProvisioningProperties()
    
                $vmTemplateExportLocation = $provisioningProperties.MasterVmLocation

                if($wmiObj.IsHA)
                {                
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSanStorage
                    $centralStorageLocation = $provisioningProperties.LocalVmLocation
                }
                elseif($provisioningProperties.RunFromSMB -and !$provisioningProperties.SMBStreaming)
                {                
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::CentralSmbShareStorage
                    $centralStorageLocation = $provisioningProperties.SMBLocation
                }
                else
                {
                    $storageType = [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]::LocalStorage
                
                    $localVMCreationLocation = $provisioningProperties.LocalVmLocation
                    if(!$localVMCreationLocation)
                    {             
                        $localVMCreationLocation = "default"
                    }
                
                    if(!$vmTemplateExportLocation)
                    {                
                        $vmTemplateExportLocation = "default"
                    }
                }
    
                New-Object Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionVirtualDesktopsProperties `
                    -ArgumentList $provisioningProperties.VmDomain, $provisioningProperties.VmOU, $storageType, $centralStorageLocation, $localVMCreationLocation, `
                        $collPropWmiObj.ReferenceVirtualDesktopName, $collPropWmiObj.ReferenceVirtualDesktopHost, $vmTemplateExportLocation, $provisioningProperties.NamePrefix, $provisioningProperties.NameStartIndex 
            }
        }
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-VirtualDesktopCollectionConfiguration {
[CmdletBinding(DefaultParameterSetName="General",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254112")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,
    
    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string]
    $CollectionDescription,
    
    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]
    $ClientDeviceRedirectionOptions,
    
    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $RedirectAllMonitors,
    
    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $RedirectClientPrinter,    

    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [int]
    $SaveDelayMinutes,
    
    [Parameter(ParameterSetName="General", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $UserGroups,

    [Parameter(ParameterSetName="General", Mandatory=$false)]
    [bool]
    $AutoAssignPersonalVirtualDesktopToUser,

    [Parameter(ParameterSetName="General", Mandatory=$false)]
    [bool]
    $GrantAdministrativePrivilege,
    
    [Parameter(ParameterSetName="General", ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string]
    $CustomRdpProperty,
    
    [Parameter(ParameterSetName="DisableUserProfileDisks", Mandatory=$true)]
    [switch]
    $DisableUserProfileDisks,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$true)]
    [switch]
    $EnableUserProfileDisks,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $IncludeFolderPath,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $ExcludeFolderPath,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $IncludeFilePath,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $ExcludeFilePath,

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateRange(1,9999)]
    [int]
    $MaxUserProfileDiskSizeGB,    

    [Parameter(ParameterSetName="EnableUserProfileDisks", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $DiskPath,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)
    
    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)

    if ([string]::IsNullOrEmpty($ConnectionBroker)) {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {       
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }
    #if the uservhd path is null - skip the test
    if(-not [string]::IsNullOrEmpty($DiskPath))
    {
        #check UserVhd path is not in use
        if (Test-UserVhdPathInUse -UserVhdPath $DiskPath -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker)
        {
            Write-Error (Get-ResourceString FolderPathInUse $DiskPath)
            return
        }
        #check UserVhd path has Everyone - warn the admin if true
        if(Test-EveryoneInUserVhdPath -UserVhdPath $DiskPath)
        {
              Write-Warning (Get-ResourceString EveryoneHasAccess $DiskPath)
        }
    }

    # Get collection alias
    $wmiNamespace = "root\cimv2\rdms";
 
    $wmiQuery = "SELECT * FROM Win32_RDMSVirtualDesktopCollection WHERE Name='" + $CollectionName + "'";

    try {
        $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

        if ($wmiObj -eq $null) {
            Write-Error (Get-ResourceString ErrorRetrievingCollection $CollectionName)
            return
        }   

    } catch { 
         Write-Error( Get-ResourceString LookupCollectionWmiError $_)
         return
    }

    $CollectionAlias = $wmiObj.Alias

    $vmFarmSettingsXml = [xml]$wmiObj.VmFarmSettings

    # Handle properties that are written directly to the WMI object
    $writeWmi = $false
    
    if($PSBoundParameters.ContainsKey("CollectionDescription"))
    {
        $wmiObj.CollectionDescription = $CollectionDescription
        $writeWmi = $true
    }
    
    if($PSBoundParameters.ContainsKey("SaveDelayMinutes"))
    {
        # Convert from minutes to milliseconds
        $saveDelayInMilliseconds = [UInt64]$SaveDelayMinutes * 60 * 1000
    
        $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='SaveDelay']").Attributes["Value"].Value = $saveDelayInMilliseconds
          
        $wmiObj.VmFarmSettings = $vmFarmSettingsXml.InnerXml
        $writeWmi = $true
    }
    
    if($PSBoundParameters.ContainsKey("UserGroups"))
    {      
        # Handle if the user explicitly set empty array or null (e.g. "-UserGroups @()")
        if(($null -eq $UserGroups) -or ($UserGroups.Count -eq 0))
        {
            Write-Error (Get-ResourceString ErrVmCollectionRequiresUserGroups)
            return
        }
        else
        {  
            $securityDescriptor = Get-SecurityDescriptorFromUserGroup($UserGroups)
            if($null -eq $securityDescriptor)
            {
                Write-Error (Get-ResourceString InvalidUserGroupNoErr $UserGroups)
                return
            }
            
            $wmiObj.SecurityDescriptor = $securityDescriptor
            $writeWmi = $true
        }
    }

    if($PSBoundParameters.ContainsKey("AutoAssignPersonalVirtualDesktopToUser"))
    {
        switch($wmiObj.Type)
        {
            2
                {
                    if($AutoAssignPersonalVirtualDesktopToUser)
                    {
                        $wmiObj.Type = 3
                        $writeWmi = $true
                    }
                }
            3
                {
                    if(-not $AutoAssignPersonalVirtualDesktopToUser)
                    {
                        $wmiObj.Type = 2
                        $writeWmi = $true
                    }
                }
            default
                {
                    Write-Warning (Get-ResourceString WrnAutoAssignNotApplicable)
                }
        }
    }
    
    if($PSBoundParameters.ContainsKey("GrantAdministrativePrivilege"))
    {
        if($wmiObj.Type -lt 2)
        {
            if($GrantAdministrativePrivilege)
            {
                Write-Warning (Get-ResourceString WrnGrantAdminNotApplicable)
            }
        }
        else
        {
            if($wmiObj.IsUserAdmin -ne $GrantAdministrativePrivilege)
            {
                $wmiObj.IsUserAdmin = $GrantAdministrativePrivilege
                $writeWmi = $true
            }
        }
    }

    if ($writeWmi)
    {
        try {

            $wmiObj.Put() | Out-Null

        } catch [Exception] {

            Write-Error (Get-ResourceString ErrorWritingVDColProps $_.Exception.Message)
            return
        }

        # Must fetch new instance of WMI object to call methods below
        try {
            $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

            if ($wmiObj -eq $null) {
        	    Write-Error (Get-ResourceString ErrorRetrievingCollection $CollectionName)
                return
            }   

        } catch { 
             Write-Error( Get-ResourceString LookupCollectionWmiError $_)
             return
        }
    }
    
    # Handle properties that require calling methods on the WMI object
    # (it is important that this be done *after* calling Put on the WMI object - otherwise it seems the changes from the method calls can get overwritten

    if($PSBoundParameters.ContainsKey("ClientDeviceRedirectionOptions")) {

        try {

            $retProperty = $wmiObj.SetInt32Property("DeviceRedirectionOptions", $ClientDeviceRedirectionOptions)

            if ($retProperty.ReturnValue -ne 0) {
                Write-Error( Get-ResourceString FailedToSetDeviceRedirectionOptions $retProperty.ReturnValue )
            }
        } catch {
            Write-Error( Get-ResourceString FailedToSetDeviceRedirectionOptions $_)
            return
        }
    }
    
    if($PSBoundParameters.ContainsKey("RedirectClientPrinter"))
    {
        try {
            $retProperty = $wmiObj.SetInt32Property("RedirectClientPrinter", $RedirectClientPrinter)
        
            if ($retProperty.ReturnValue -ne 0) {
                Write-Error( Get-ResourceString FailedToSetRedirectClientPrinter $retProperty.ReturnValue )
            }
        } catch {
            Write-Error( Get-ResourceString FailedToSetRedirectClientPrinter $_)
            return
        }
    }
    
    if($PSBoundParameters.ContainsKey("RedirectAllMonitors"))
    {
        if($RedirectAllMonitors)
        {
            $maxMonitors = 2
        }
        else
        {
            $maxMonitors = 1
        }

        try {
        
            $retProperty = $wmiObj.SetInt32Property("MaxMonitors", $maxMonitors)

            if ($retProperty.ReturnValue -ne 0) {
                Write-Error( Get-ResourceString FailedToSetMaxMonitors $retProperty.ReturnValue )
            }

        } catch {
            Write-Error( Get-ResourceString FailedToSetMaxMonitors $_)
            return
        }    

    }

    
    try {
        # Handle UVHD Properties
        $optionalParameters = Get-BoundParameter $PSBoundParameters @{"MaxUserProfileDiskSizeGB" = "DiskSize"; "DiskPath" = "UserVhdShare"; "IncludeFilePath" = "IncludeFileLocation"; "ExcludeFilePath" = "ExcludeFileLocation"; "IncludeFolderPath" = "IncludeFolderLocation"; "ExcludeFolderPath" = "ExcludeFolderLocation"}
        if ($PSBoundParameters["EnableUserProfileDisks"])
        {
            $optionalParameters["DiskSize"] *= 1GB
            $wasUserProfileDisksEnabled = $false
    
            $wasUserProfileDisksEnabledXml = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdProfRoamingEnabled']")
            if ($wasUserProfileDisksEnabledXml -ne $null)
            {
                $wasUserProfileDisksEnabled = 0 -eq [System.String]::Compare($wasUserProfileDisksEnabledXml.Attributes["Value"].Value, "true", $true)
            }
        
            #TODO: Should we support changing RemapMode?
            #RemapMode=2: applies when the cmdlet is called with IncludeFolderLocation and/or IncludeFileLocation parameters
            #RemapMode=0 (default): applies in all other cases: ExcludeFileLocation, ExcludeFolderLocation only and no cmdlets
            $optionalParameters["RemapMode"] = 0
            if($optionalParameters["IncludeFileLocation"] -ne $null -or $optionalParameters["IncludeFolderLocation"] -ne $null)
            {
                $optionalParameters["RemapMode"] = 2
            }
                                  
            if ($wasUserProfileDisksEnabled )
            {
                $optionalParameters.Remove("DiskSize")
            
                # We should only specify a path if it is different than the current one
                $currentUserVHDShare = $vmFarmSettingsXml.SelectSingleNode("/Farm/Metadata[@Name='UvhdShareUrl']").Attributes["Value"].Value
                if($optionalParameters.ContainsKey("UserVhdShare") -and ($currentUserVHDShare -eq $optionalParameters["UserVhdShare"]))
                {
                    $optionalParameters.Remove("UserVhdShare")
                }

                $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
           

                Invoke-Command -Session $workflowSession -ArgumentList $ConnectionBroker, $CollectionAlias, $optionalParameters `
                {
                    param($ConnectionBroker, $CollectionAlias, $optionalParameters ) 
                    RDManagement\Set-UserDataVHDSetting -RDMSServer $ConnectionBroker -CollectionAlias $CollectionAlias @optionalParameters
                } | Out-Null            
                
            }
            else
            {
                $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

         
                Invoke-Command -Session $workflowSession -ArgumentList $ConnectionBroker, $CollectionAlias, $optionalParameters `
                {
                    param($ConnectionBroker, $CollectionAlias, $optionalParameters ) 
                    RDManagement\Enable-UserDataVHD -RDMSServer $ConnectionBroker -CollectionAlias $CollectionAlias -DiskType 1 @optionalParameters
                } | Out-Null
            }
        }

        if ($PSBoundParameters["DisableUserProfileDisks"])
        {
            # Disable-UserDataVHD assumes it is running locally on the ConnectionBroker machine, so we need to powershell-remote to the ConnectionBroker
            $workflowSession = New-PSSession -ComputerName $ConnectionBroker -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
            Invoke-Command -Session $workflowSession -ArgumentList @($CollectionAlias) `
            {
                param($CollectionAlias) 
                RDManagement\Disable-UserDataVHD -CollectionAlias $CollectionAlias
            } | Out-Null
        }

    } catch {

        Write-Error( Get-ResourceString ExceptionDisablingUserVHD $_ )

    } finally {

        if($null -ne $workflowSession)
        {
            Remove-PSSession -Session $workflowSession
        }
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

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-PersonalVirtualDesktopPatchSchedule {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254113")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule[]")]
param (
    [Parameter(Mandatory=$false)]
    [string]
    $VirtualDesktopName,

    [Parameter(Mandatory=$false)]
    [string]
    $ID,

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

    if ($PSBoundParameters["VirtualDesktopName"])
    {
        $result = Confirm-PersonalVirtualDesktop $VirtualDesktopName $ConnectionBroker
        if ($null -ne $result)
        {
            Write-Error $result
            return
        }
    }
    
    $wmiNamespace = "root\cimv2"

    $filterStrings = @()
    
    if ($PSBoundParameters["VirtualDesktopName"])
    {
        $filterStrings += "TargetName='" + $VirtualDesktopName + "'"
    }
    
    if ($PSBoundParameters["ID"])
    {
        $filterStrings += "TaskIdentifier='" + $ID+ "'"
    }

    $wmiFilter = $filterStrings -join " and "
    
    try
    {
        $wmiObjs = Get-WmiObject -Namespace $wmiNamespace -Class "Win32_RdvTargetTaskSchedule" -Filter $wmiFilter -ComputerName $ConnectionBroker -Authentication PacketPrivacy  -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString LookupTaskWmiError ($wmiFilter,$_))
        return
    }

    foreach ($wmiObj in $wmiObjs)
    {
        $patchDeadline = $wmiObj.ConvertToDateTime($wmiObj.TaskDeadline)
        $patchStartTime = $wmiObj.ConvertToDateTime($wmiObj.TaskStartTime)
        $patchEndTime = $wmiObj.ConvertToDateTime($wmiObj.TaskEndTime)
        New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule `
            -ArgumentList $wmiObj.TargetName, $wmiObj.TaskContext, $patchDeadline, $patchStartTime, $patchEndTime, $wmiObj.TaskIdentifier, $wmiObj.TaskLabel, $wmiObj.TaskPlugin, $wmiObj.TaskStatus
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Remove-PersonalVirtualDesktopPatchSchedule {
[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254114")]
param (
    [Parameter(Mandatory=$false)]
    [string]
    $VirtualDesktopName,

    [Parameter(Mandatory=$false)]
    [string]
    $ID,

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

    if ($PSBoundParameters["VirtualDesktopName"])
    {
        $result = Confirm-PersonalVirtualDesktop $VirtualDesktopName $ConnectionBroker
        if ($null -ne $result)
        {
            Write-Error $result
            return
        }
    }

    if ($PSBoundParameters["ID"])
    {  
        $promptMsg = (Get-ResourceString RemovePatch)
    }
    else
    {  
        $promptMsg = (Get-ResourceString RemovePatches)
    }
    

    if( -not ($PSCmdlet.ShouldProcess( $promptMsg, $promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }
    
    $wmiNamespace = "root\cimv2"

    $filterStrings = @()
    
    if ($PSBoundParameters["VirtualDesktopName"])
    {
        $filterStrings += "TargetName='" + $VirtualDesktopName + "'"
    }
    
    if ($PSBoundParameters["ID"])
    {
        $filterStrings += "TaskIdentifier='" + $ID+ "'"
    }

    $wmiFilter = $filterStrings -join " and "

    $wmiObjs = Get-WmiObject -Namespace $wmiNamespace -Class "Win32_RdvTargetTaskSchedule" -Filter $wmiFilter -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if ($wmiObjs -eq $null)
    {
        # Specified item(s) not present
        
        if ($PSBoundParameters["ID"])
        {
            Write-Error (Get-ResourceString TaskNotFound $PSBoundParameters["ID"])
        }
        
        return
    }

    try
    {
        $wmiObjs | Remove-WmiObject
    }
    catch
    {
        Write-Error (Get-ResourceString RemoveTaskWmiError ($wmiFilter,$_))
        return
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-PersonalVirtualDesktopPatchSchedule {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254115")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule")]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopName,

    [Parameter(Mandatory=$false)]
    [string]
    $ID,

    [Parameter(Mandatory=$false)]
    [byte []]
    $Context,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $Deadline,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $StartTime,

    [Parameter(Mandatory=$false)]
    [DateTime]
    $EndTime,

    [Parameter(Mandatory=$false)]
    [string]
    $Label,
    
    [Parameter(Mandatory=$false)]
    [string]
    $Plugin,

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

    $result = Confirm-PersonalVirtualDesktop $VirtualDesktopName $ConnectionBroker
    if ($null -ne $result)
    {
        Write-Error $result
        return
    }

    $wmiNamespace = "root\cimv2"
    
    if ($PSBoundParameters["ID"])
    {
        # See if task already exists
        $wmiFilter = "TargetName='" + $VirtualDesktopName + "' AND " + "TaskIdentifier='" + $ID+ "'"
        $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Class "Win32_RdvTargetTaskSchedule" -Filter $wmiFilter -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue
        
        if ($null -ne $wmiObj)
        {
            Write-Error (Get-ResourceString CreateTaskAlreadyExistsError $ID)
            return
        }
    }

    # Get the class so that we can call a static instance
    
    $scope = New-Object System.Management.ManagementScope
    $scope.Path = '\\'+$ConnectionBroker+'\root\cimv2:Win32_RdvTargetTaskSchedule'
    $scope.Options.Authentication = [system.Management.AuthenticationLevel]::PacketPrivacy
    $scope.Options.Impersonation = [system.Management.ImpersonationLevel]::Impersonate

    try
    {
        $classInst = new-Object System.Management.ManagementClass($scope, $scope.Path, $null)

        $wmiObj = $classInst.CreateInstance()
    }
    catch
    {
        Write-Error (Get-ResourceString CreateTaskWmiError $_)
        return
    }
    
    
    if ($PSBoundParameters["ID"])
    {
        $wmiObj.TaskIdentifier = $ID
    }
    else
    {
        $wmiObj.TaskIdentifier = [System.Guid]::NewGuid().ToString()
    }

    $wmiObj.TargetName = $VirtualDesktopName
    
    $optionalParameters = Get-BoundParameter $PSBoundParameters "Context", "Deadline", "StartTime", "EndTime", "Label", "Plugin"
    
    $wmiObj = Set-RDTaskWmiObj $wmiObj -UseDefaults @optionalParameters

    try
    {
        $wmiObj.Put() | Out-Null
    }
    catch
    {
        Write-Error (Get-ResourceString CreateTaskWmiError $_)
        return
    }
    
    $patchDeadline = $wmiObj.ConvertToDateTime($wmiObj.TaskDeadline)
    $patchStartTime = $wmiObj.ConvertToDateTime($wmiObj.TaskStartTime)
    $patchEndTime = $wmiObj.ConvertToDateTime($wmiObj.TaskEndTime)
    New-Object Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule `
        -ArgumentList $wmiObj.TargetName, $wmiObj.TaskContext, $patchDeadline, $patchStartTime, $patchEndTime, $wmiObj.TaskIdentifier, $wmiObj.TaskLabel, $wmiObj.TaskPlugin, Unknown

}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-PersonalVirtualDesktopPatchSchedule {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254116")]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $VirtualDesktopName,

    [Parameter(Mandatory=$true)]
    [string]
    $ID,

    [Parameter(Mandatory=$false)]
    [byte []]
    $Context,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $Deadline,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $StartTime,

    [Parameter(Mandatory=$false)]
    [DateTime]
    $EndTime,

    [Parameter(Mandatory=$false)]
    [string]
    $Label,
    
    [Parameter(Mandatory=$false)]
    [string]
    $Plugin,

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

    $result = Confirm-PersonalVirtualDesktop $VirtualDesktopName $ConnectionBroker
    if ($null -ne $result)
    {
        Write-Error $result
        return
    }

    $wmiNamespace = "root\cimv2"
    
    # See if task already exists
    $wmiFilter = "TargetName='" + $VirtualDesktopName + "' AND " + "TaskIdentifier='" + $ID+ "'"
    $wmiObj = Get-WmiObject -Namespace $wmiNamespace -Class "Win32_RdvTargetTaskSchedule" -Filter $wmiFilter -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction SilentlyContinue

    if($null -eq $wmiObj)
    {
        Write-Error (Get-ResourceString LookupTaskWmiError ($ID,$null))
        return
    }

    $optionalParameters = Get-BoundParameter $PSBoundParameters "Context", "Deadline", "StartTime", "EndTime", "Label", "Plugin"
    
    $wmiObj = Set-RDTaskWmiObj $wmiObj  @optionalParameters
    
    try
    {
        $wmiObj.Put() | Out-Null
    }
    catch
    {
        Write-Error (Get-ResourceString ModifyTaskWmiError $_)
        return
    }
}

function Set-RDTaskWmiObj {

param (
    [Parameter(Mandatory=$true)]
    [PSObject]
    $wmiObj,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $UseDefaults,

    [Parameter(Mandatory=$false)]
    [byte []]
    $Context,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $Deadline,
    
    [Parameter(Mandatory=$false)]
    [DateTime]
    $StartTime,

    [Parameter(Mandatory=$false)]
    [DateTime]
    $EndTime,

    [Parameter(Mandatory=$false)]
    [string]
    $Label,
    
    [Parameter(Mandatory=$false)]
    [string]
    $Plugin
)

    # Must use min/max values common to PowerShell, WMI, and SQL
    $minDateTime = "19010101000001.000000-480"
    $maxDateTime = "99991231000000.000000-480"
    
    if ($PSBoundParameters["Context"])
    {
        $wmiObj.TaskContext = $Context
    }
    elseif ($UseDefaults)
    {
        $wmiObj.TaskContext = @()
    }
    
    if ($PSBoundParameters["Deadline"])
    {
        $wmiObj.TaskDeadline = $wmiObj.ConvertFromDateTime($Deadline)
    }
    elseif ($UseDefaults)
    {
        $wmiObj.TaskDeadline = $minDateTime
    }
    
    if ($PSBoundParameters["StartTime"])
    {
        $wmiObj.TaskStartTime = $wmiObj.ConvertFromDateTime($StartTime)
    }
    elseif ($UseDefaults)
    {
        $wmiObj.TaskStartTime = $minDateTime
    }
    
    if ($PSBoundParameters["EndTime"])
    {
        $wmiObj.TaskEndTime = $wmiObj.ConvertFromDateTime($EndTime)
    }
    elseif ($UseDefaults)
    {
        $wmiObj.TaskEndTime = $maxDateTime
    }
    
    if ($PSBoundParameters["Label"])
    {
        $wmiObj.TaskLabel = $Label
    }
    elseif (($UseDefaults) -or ($null -eq $wmiObj.TaskLabel))
    {
        $wmiObj.TaskLabel = ""
    }
    else
    {
        # Without this assignment, TaskLabel is lost when it gets to the WMI provider, causing an "invalid parameter" error
        $wmiObj.TaskLabel = $wmiObj.TaskLabel
    }
    
    if ($PSBoundParameters["Plugin"])
    {
        $wmiObj.TaskPlugin = $Plugin
    }
    elseif ($UseDefaults)
    {
        $wmiObj.TaskPlugin = Get-ResourceString DefaultPatchPluginName
    }
    
    $wmiObj
}


function Confirm-PersonalVirtualDesktop {

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $VirtualDesktopName,

    [Parameter(Mandatory=$true, Position=1)]
    [string]
    $ConnectionBroker
)

    try
    {
        $vm = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter "Name='$VirtualDesktopName'"
    }
    catch 
    {
        return (Get-ResourceString FailedToFindVirtualDesktopWmi ($VirtualDesktopName,$_))
    }

    if($null -eq $vm)
    {
        return (Get-ResourceString FailedToFindVirtualDesktop $VirtualDesktopName)
    }

    $wmiFilter = "Alias='" + $vm.CollectionAlias +"'"
    try
    {
        $coll= Get-WmiObject -Class "Win32_RDMSVirtualDesktopCollection" -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
                -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                -Filter $wmiFilter
    }
    catch 
    {
        return (Get-ResourceString VmCollectionNotFound ($VirtualDesktopName,$_))
    }

    if ($coll.Type -ne 2 -and $coll.Type -ne 3)
    {
        return (Get-ResourceString ErrorNotPDPool $VirtualDesktopName)
    }
    
    return $null
}

