
# 
#   This source file contains function to script live migration of virtual machines in a VDI deployment.
#   It uses RDV WMI for live migration for this operation. For shared pool, it ensures that the locally
#   cached copy of Gold Image exists on the destination host. If this script is executed from any other
#   server than source hyper-v host, it needs administrator credentials to perform the operations due to
#   credentials delegation issue. Using those credentials, it creates a remote power-shell session on the 
#   source hyper-v host and executes a script block that performs live migration in that session.
#
#   For live migration from remote server, we need to enable client mode credssp for powershell. That 
#   needs to be enabled by administrator separately. 
#
#   The following command needs to be executed on the source hyper-v host:
#       Enable-WSManCredSSP -role server -Force
# 
#   And the following command needs to be executed on this machine:
#       Enable-WSManCredSSP -role client -delegate * -Force > $null
#   
#   Known issues:
#   - This script does not enable incoming live migration on the hyper-v hosts.
#   - Error reporting need to be better. 
#   - When the gold is cached as part of this script, for some reason, the file is not immediately 
#     accessible after the copy. This needs to be investigated.
#


Import-Module $PSScriptRoot\Utility.psm1

# This function performs live migration of virtual machine when this command is issued on source hyper-v host.
function Move-VirtualDesktopLocal
{
    param (
        [string] $SourceHost,
        [string] $DestinationHost,
        [string] $Name
    )

    # Move virtual machine from source host (local) to destination host.
    Write-Host ( Get-ResourceString MovingVirtualDesktop $Name, $SourceHost, $DestinationHost )
    $RetVal = Invoke-WmiMethod -Class Win32_RdvhManagement -Namespace root\cimv2\TerminalServices `
                               -computername $SourceHost -Name RdvMigrateVmToDifferentHost `
                               -ArgumentList @($DestinationHost, $Name) -Authentication PacketPrivacy 
    if ( $RetVal.ReturnValue -NE 0 ) {
        Write-Host ( Get-ResourceString MovingVirtualDesktopFailed )
    }
    else {
        Write-Host ( Get-ResourceString MovingVirtualDesktopSucceeded )
    }
}

# This function performs live migration of virtual machine when this command is issued from a remote server.
function Move-VirtualDesktopRemote 
{
    param (
        [string] $SourceHost,
        [string] $DestinationHost,
        [string] $Name,
        [System.Management.Automation.PSCredential] $Credential
    )
    
    if ( $NULL -eq $Credential )
    {
        Write-Host ( Get-ResourceString MoveOperationRequiresCredentials )
        $Credential = Get-Credential
    }
    
    Write-Host ( Get-ResourceString MovingVirtualDesktop $Name, $SourceHost, $DestinationHost )

    # Create remote session to the remote computer using the credentials and spefiying a CredSSP authentication
    $powershellRemoteSession = New-PSSession -computername $SourceHost -Credential $credential -EnableNetworkAccess `
                               -Authentication CredSSP -Erroraction:stop
    
    try
    {
        Invoke-Command -Session $powershellRemoteSession `
                       -ArgumentList ($SourceHost, $DestinationHost, $Name) -ScriptBlock {
            # This script block will get remotely executed
            param(
                [string] $SourceHost,
                [string] $DestinationHost,
                [string] $Name
            )
            
            # Define the Move-VirtualDesktopInternal function to execute on the remote computer
            function Move-VirtualDesktopInternal
            {
                param(
                    [string] $SourceHost,
                    [string] $DestinationHost,
                    [string] $Name
                )
                
                $RetVal = Invoke-WmiMethod -Class Win32_RdvhManagement -Namespace root\cimv2\TerminalServices `
                                           -computername $SourceHost -Name RdvMigrateVmToDifferentHost `
                                           -ArgumentList @($DestinationHost, $Name) -Authentication PacketPrivacy 
                if ( $RetVal.ReturnValue -NE 0 ) {
                    Write-Host ( "Moving virtual desktop Failed" )
                }
                else {
                    Write-Host ( "Moving virtual desktop Succeeded" )
                }
            }
            
            # Migrate the VM to the destination
            Move-VirtualDesktopInternal -SourceHost:$SourceHost -DestinationHost:$DestinationHost -Name:$Name
        }
    }
    finally
    {
        # Cleanup the powershell remote session
        Remove-PSSession $powershellRemoteSession
    }
}


# This function ensures that Gold VHD is cached at the destination host before live migrate operation.
# It calls RDVH WMI for that - that WMI copies the gold VHD from the specified Base VM Location OR simply
# returns if the gold copy already exists.
function Copy-GoldLocally
{
    param(
        [string] $DestinationHost,
        [string] $BaseVmLocation,
        [string] $CollectionName,
        [string] $LocalCacheLocation
    )
                
    try
    {
        $RetVal = Invoke-WmiMethod -Class Win32_RdvhManagement -Name RdvCopyBaseVmLocally `
                                   -ComputerName $DestinationHost -Namespace 'root\cimv2\TerminalServices' `
                                   -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop `
                                   -ArgumentList ($BaseVmLocation, $CollectionName, $LocalCacheLocation)
    }
    catch 
    {
        Write-Error $_.Exception.Message
    }
}
            
# .ExternalHelp RemoteDesktop.psm1-help.xml
function Move-VirtualDesktop 
{
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254067")]
    # Parameters
    param (
        # Specify name of the Source host in this parameter.
        [Parameter(Mandatory=$true)]
        [String]
        $SourceHost,

        # Specify name of the Destination host in this parameter.
        [Parameter(Mandatory=$true)]
        [String]
        $DestinationHost,
    
        # Specify name of the Virtual Desktop in this parameter.
        [Parameter(Mandatory=$true)]
        [String]
        $Name,

        # Specify name of the Connection Broker Server in this parameter.
        # Optional parameter, default value is local host.
        [Parameter(Mandatory=$false)]
        [string]
        $ConnectionBroker,
    
        # Specify valid credentials in this parameter.
        # Optional parameter, default value is NULL.
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]
        $Credential = $NULL
    )

    $ConnectionBroker = Initialize-Fqdn($ConnectionBroker)
    if ([string]::IsNullOrEmpty($ConnectionBroker))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }

    # verify deployment
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    # Verify the source host is FQDN and is among the deployment RDS-Virtualization hosts
    if( -not ( Test-Fqdn( $SourceHost ) ) )
    {
        Write-Error ( Get-ResourceString InvalidServerNameFormat $SourceHost )
        return $false
    }

    # Verify the destination host is FQDN and is among the deployment RDS-Virtualization hosts
    if( -not ( Test-Fqdn( $DestinationHost) ) )
    {
        Write-Error ( Get-ResourceString InvalidServerNameFormat $DestinationHost )
        return $false
    }

    $vmHostServerList = Get-RDServer -Role RDS-VIRTUALIZATION -ConnectionBroker $ConnectionBroker    
    $vmHostNameList = New-Object System.Collections.Generic.List[string]
    foreach( $hostName in $vmHostServerList )
    {
        $vmHostNameList.Add( $hostName.Server.ToLower( [System.Globalization.CultureInfo]::CurrentCulture ) )
    }

    if ( -not ( $vmHostNameList.Contains( $SourceHost.ToLower([System.Globalization.CultureInfo]::CurrentCulture) ) ) )
    {
        Write-Error ( Get-ResourceString InvalidRdvhRoleNotFoundGeneric $SourceHost )
        return $false
    }
   
    if ( -not ( $vmHostNameList.Contains( $DestinationHost.ToLower([System.Globalization.CultureInfo]::CurrentCulture) ) ) )
    {
        Write-Error ( Get-ResourceString InvalidRdvhRoleNotFoundGeneric $DestinationHost )
        return $false
    }

    # Get the RDS Virtual Desktop object from the VM name.
    try
    {
        $VirtualDesktop = Get-WmiObject -Class "Win32_RDMSVirtualDesktop" -Namespace "root\cimv2\rdms" `
                                        -ComputerName $ConnectionBroker -Authentication PacketPrivacy `
                                        -Impersonation Impersonate -ErrorAction Stop `
                         | Where-Object -FilterScript {$_.Name -eq $Name}
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if ( $NULL -eq $VirtualDesktop )
    {
        Write-Host ( Get-ResourceString VirtualDesktopNotFound $Name )
        return
    }

    # Get the RDMS Collection properties object from the RDMS Virtual Desktop object.
    try
    {
        $CollProps = Get-WmiObject -Class "Win32_RDMSCollectionProperties" -Namespace "root\cimv2\rdms" `
                                   -ComputerName $ConnectionBroker -Authentication PacketPrivacy `
                                   -Impersonation Impersonate -ErrorAction Stop `
                    | Where-Object -FilterScript {$_.Alias -eq $VirtualDesktop.CollectionAlias}
    }
    catch
    {
        $errMsg = $_.Exception.Message
    }

    if ( $null -eq $CollProps )
    {
        Write-Error ( Get-ResourceString VmCollectionPropNotFound )
        return
    }

    try
    {
        $ProvProps=$CollProps.GetProvisioningProperties()
    }
    catch
    {
        Write-Error ( $_.Exception.Message )
    }

    if ( -not $ProvProps )
    {
        Write-Error ( Get-ResourceString VmCollectionProvPropNotFound )
        return
    }

    $GoldCacheLocation = $NULL
    if ( $ProvProps.LocalGoldVmLocation )
    {
        $GoldCacheLocation = $ProvProps.LocalGoldVmLocation
    }

    if ( ( $ProvProps.PoolVhdType -eq 'DiffDisk' ) -and ( !$ProvProps.RunFromSMB ) )
    {
        Write-Host ( Get-ResourceString EnsuringGoldCacheExists $DestinationHost )
        Copy-GoldLocally -DestinationHost:$DestinationHost -BaseVmLocation:$ProvProps.MasterVmLocation `
                        -CollectionName:$VirtualDesktop.CollectionAlias -LocalCacheLocation:$GoldCacheLocation

        Sleep 5
    }

    # Check if the source hyper-v host is same as local host, where script is being executed.
    if ( $SourceHost.StartsWith([System.Net.Dns]::GetHostName(),[StringComparison]::OrdinalIgnoreCase) )
    {
        # Start the migration locally
        Move-VirtualDesktopLocal -SourceHost:$SourceHost -DestinationHost:$DestinationHost -Name:$Name
    }
    else
    {
        # Start the migration remotely 
        Move-VirtualDesktopRemote -SourceHost:$SourceHost -DestinationHost:$DestinationHost -Name:$Name `
                                   -Credential:$Credential
    }
}