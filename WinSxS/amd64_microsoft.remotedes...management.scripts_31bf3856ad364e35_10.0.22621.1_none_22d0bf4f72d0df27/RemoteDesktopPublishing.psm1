
Import-Module $PSScriptRoot\Utility.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-RemoteDesktop {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254074")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDPublishedRemoteDesktop[]")]
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
        $RDDesktopCol = get-wmiobject -ComputerName $ConnectionBroker -namespace "root\cimv2\terminalservices" `
                                      -query "Select * From Win32_RDCentralPublishedRemoteDesktop" `
                                      -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString GetPublishedDesktopsWmiError $_)
        return
    }

    foreach($RDDesktop in $RDDesktopCol) 
    {
        new-object Microsoft.RemoteDesktopServices.Management.RDPublishedRemoteDesktop -ArgumentList $RDDesktop.Name, $RDDesktop.ShowInPortal
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-RemoteDesktop {
[CmdletBinding(SupportsShouldProcess=$true,
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254075")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string]
    $CollectionName,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
    [bool]
    $ShowInWebAccess,
    
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $Force
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

    # Validate $CollectionName
    try
    {
        $vmColl = Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -Filter "Name='$CollectionName'" `
                    -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
    }
    catch
    {
        Write-Error (Get-ResourceString LookupCollectionWmiError $_)
    }
   
    if($null -eq $vmColl)
    {
        $IsVMCollection = $false
        $collectionAlias = Get-SessionCollectionAliasFromName -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    }
    else
    {
        $IsVMCollection = $true
        $collectionAlias = $vmColl.Alias
    }
    
    if($null -eq $collectionAlias)
    {
        Write-Error (Get-ResourceString CollectionDoesNotExist $CollectionName)
        return
    }
    
    $activity = Get-ResourceString VerifyingInput
    Write-Progress -Activity $activity -PercentComplete 5
    
    # Make sure we can safely make publishing changes on this collection
    try
    {
        Test-CollectionOnline -CollectionName $CollectionName -CollectionAlias $collectionAlias -IsVmCollection $IsVMCollection -ConnectionBroker $ConnectionBroker
    }
    catch
    {
        Write-Error $_
        return
    }
    
    # Enforce that cannot have both apps and desktops published from the same collection
    $percentCompleteAfterRemovingApps = 90
    if ($ShowInWebAccess)
    {
        $remoteApps = Get-RDRemoteApp -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker

        if ($remoteApps) 
        {
            #
            # prompt users that allowing desktops to show in rdweb access will remove their published apps
            #

            $whatif = Get-ResourceString WarnUserRemovingAllPublishedAppsWhatif
            $message = Get-ResourceString WarnUserRemovingAllPublishedApps
            $caption = Get-ResourceString WarnUserTitleRemovingPubApps

            if(!$PSCmdlet.ShouldProcess($whatif, $message, $caption))
            {
                return
            }
            
            if(!$Force -and !$PSCmdlet.ShouldContinue($message, $caption))
            {
                return
            }

            #
            # remove remoteapps
            #

            # Make sure it is an array so that we can call .Length
            $remoteApps = @($remoteApps)
            
            $appNum = 0
            $percentComplete = 10
            $progressPerApp = ($percentCompleteAfterRemovingApps - $percentComplete) / $remoteApps.Length
            
            foreach( $remoteApp in $remoteApps) 
            {
                $appNum++
                
                $activity = Get-ResourceString RemovingPubAppsInProgress $appNum, $remoteApps.Length
                Write-Progress -Activity $activity -PercentComplete $percentComplete
            
                # Remove-RDRemoteApp will ensure that the other deployment settings for having a desktop published will be set correctly
                Remove-RDRemoteApp -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -Alias $remoteApp.Alias -Confirm:$false -Force
                
                $percentComplete += $progressPerApp
            }
        }
    }
    
    $activity = Get-ResourceString UpdatingDesktopInProgress
    Write-Progress -Activity $activity -PercentComplete $percentCompleteAfterRemovingApps
    
    # Write the changes
    if($IsVMCollection)
    {
        $vmColl.ShowInPortal = $ShowInWebAccess
        try 
        {
            $vmColl.Put() | Out-Null
        } 
        catch 
        {
            Write-Error (Get-ResourceString ErrorWritingVDColProps $_)
            return
        }
    }
    else
    {
        try
        {
            $session = New-PSSession -ConfigurationName Microsoft.windows.servermanagerworkflows -EnableNetworkAccess
            
            Invoke-Command $session -ArgumentList @($ConnectionBroker,$collectionAlias, $CollectionName, $ShowInWebAccess) `
            {
                param($ConnectionBroker,$CollectionAlias, $CollectionName, $ShowInWebAccess) 
                RDManagement\Set-RDSHCollectionGeneralSetting -RDManagementServer $ConnectionBroker -CollectionAlias $collectionAlias -Name $CollectionName -ShowInWebAccess $ShowInWebAccess
            } | Out-Null
        }
        finally
        {
            if($null -ne $session)
            {
                Remove-PSSession -Session $session -Confirm:$false
            }
        }
    }
    
    Write-Progress -Activity " " -PercentComplete 100
}
