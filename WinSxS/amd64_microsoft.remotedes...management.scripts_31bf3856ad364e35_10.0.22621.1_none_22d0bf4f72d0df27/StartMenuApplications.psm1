
Import-Module $PSScriptRoot\Utility.psm1
Import-Module $PSScriptRoot\RemoteAppPublishing.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-AvailableApp {
[CmdletBinding(DefaultParameterSetName="Session",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254089")]
[OutputType("New-Object Microsoft.RemoteDesktopServices.Management.StartMenuApp[]")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $CollectionName,

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
 
    $commonParams = Get-BoundParameter $PSBoundParameters @{"CollectionName" = "CollectionName";  
                                                            "VirtualDesktopName" = "VirtualDesktopName";
                                                            "ConnectionBroker" = "ConnectionBroker"}

    # Make sure this is updated in case Initialize-Fqdn changed the value                                                            
    $commonParams["ConnectionBroker"] = $ConnectionBroker
 
    # Get-PublishingRDEndpoint validates $CollectionName and $VMName for us
    try
    {
        $endpoint = Get-PublishingRDEndpoint @commonParams
    }
    catch
    {
        Write-Error $_
        return
    }
    
    if($null -eq $endpoint)
    {
        return
    }
    
    try
    {
        if($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
        {
            $activity = Get-ResourceString StartMenuPreparingVmInProgress $endpoint.VMName
            Write-Progress -Activity $activity -PercentComplete 10
        
            $ret = Open-RDVMFirewall -VMName $endpoint.VMName -VMHostName $endpoint.VMHostName
            if(!$ret)
            {
                Write-Error (Get-ResourceString FirewallDisableFailedError $endpoint.VMName)
                return
            }
            
            # This API only works if the VM is running, so it must be called after Open-RDVMFirewall
            $endpointName = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetVirtualMachineFullyQualifiedDomainName($endpoint.VMName, $endpoint.VMHostName)
            
            # Open-RDVMFirewall will often have to turn on the VM, so let this take up a significant chunk of the time
            $activity = Get-ResourceString RetreivingAppsInProgress
            Write-Progress -Activity $activity -PercentComplete 70
        }
        else
        {
            $endpointName = $endpoint.RDSHName
        
            $activity = Get-ResourceString RetreivingAppsInProgress
            Write-Progress -Activity $activity -PercentComplete 25
        }

        Write-Verbose "Fetching start menu apps from endpoint: $endpointName"

        try
        {
            $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

            $workflowAvailableApps = Invoke-Command -Session $workflowSession -ArgumentList @($endpointName) `
            {
                param($endpointName) 
                RDManagement\Get-StartMenuApplications -ServerName $endpointName
            }
        }
        finally
        {
            if($null -ne $workflowSession)
            {
                Remove-PSSession -Session $workflowSession
            }
        }
        
        $activity = Get-ResourceString RetreivingAppsInProgress
        Write-Progress -Activity $activity -PercentComplete 90

        $availableApps = @()
        foreach($app in $workflowAvailableApps)
        {
            $availableApps += New-Object Microsoft.RemoteDesktopServices.Management.StartMenuApp `
                                -ArgumentList $CollectionName, $app.Name, $app.Path, $app.VPath, $app.CommandLineArguments, $app.IconContents, $app.IconIndex, $app.IconPath
        }
    }
    finally
    {
        if($PsCmdlet.ParameterSetName -eq "VirtualDesktop")
        {
            if ( -not (Close-RDVMFirewall -VMName $endpoint.VMName -VMHostName $endpoint.VMHostName) )
            {
                Write-Error (Get-ResourceString FirewallEnableFailedError $endpoint.VMName)
            }
        }
    }
    
    Write-Progress -Activity " " -PercentComplete 100
    
    return $availableApps
}
