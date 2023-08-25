#---------------------------------------#
# ClusterAwareUpdating.ps1              #
# Discovery file for CAU BPA            #
# Copyright (c) Microsoft Corporation.  #
#---------------------------------------#

# --------------------------------------------------------------------------#
# Name        : Param Block                                                 #
# Description : Defines the Input parameters expected from the user,        #
#               default is empty string                                     #
#               These come up as dynamic parameters for the model           #
# --------------------------------------------------------------------------#
param
(
    [parameter(Mandatory=$false)]
    [String] $ClusterName = [String]::Empty,
    [String] $ProgressPipeName = [String]::Empty
)


Import-LocalizedData -BindingVariable _system_translations -filename ClusterAwareUpdating.psd1

$windir = [Environment]::GetFolderPath( [Environment+SpecialFolder]::Windows )
. $windir\System32\BestPractices\v1.0\Models\Microsoft\Windows\ClusterAwareUpdating\caucommon.ps1

$appdata=[Environment]::GetFolderPath( [Environment+SpecialFolder]::ApplicationData )
$appdataCAU=[Environment]::GetFolderPath( [Environment+SpecialFolder]::ApplicationData )+"\CAU"
if (!(Test-Path -path $appdataCAU))
{
    New-Item $appdataCAU -type directory
}

Set-Variable E_ACCESSDENIED -option Constant -value -2147024891

#
# ------------------
# FUNCTIONS - START
# ------------------
#

#
# Function Description:
#
#  This function will update the XML document with CAU data
#
# Arguments:
#
#  $xmlDoc - XmlDocument manipulated
#  $ns - namespace used for the element
#  $CAUPipeServer - CAUPipeServer object to write progress to named pipe
# Return Value:
#
#  none
#
function GetCAUXml($xmlDoc, $ns,$CAUPipeServer)
{
    #severity
    New-Variable "c_SevError" -Value 1 -Option ReadOnly
    New-Variable "c_SevWarning" -Value 2 -Option ReadOnly
    $failedMachines = New-Object System.Collections.ArrayList

    $id=0
    $percentcompleted=0
    #If SelfUpdating role is not present the number of checks decrease
    $totalRules=19

    #Create CAU node
    $cauNode = $xmlDoc.CreateElement("CAU", $ns)
    [void]$xmlDoc.DocumentElement.AppendChild($cauNode)

    [string] $currentRuleTitle = $null # fun fact: because we gave it type [string], PowerShell will convert this to an empty string.
    [string] $currentRuleId = $null # fun fact: because we gave it type [string], PowerShell will convert this to an empty string.

    # This trap will cause the error to be written after executing the trap code. We have
    # another 'trap' here, because execution will continue at the next command /at the same
    # scope level as the trap/.
    #
    # These traps should only occur in the case of an unexpected error. Unfortunately we
    # don't seem to have any good way of communicating such failures to the user. :( The best we
    # can do right now is to just mark the rule as "failed".
    trap
    {
        if( $currentRuleTitle )
        {
            [void] $failedMachines.Add("$([Environment]::MachineName) (internal error)") # <-- not localized...
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $false $c_SevError $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $false)
        }
    }

    $computerName = [System.Net.Dns]::GetHostName()

    # if cluster name is not specified, check if current node is part of cluster
    if(($ClusterName.Trim().Length -eq 0) -OR ($ClusterName -eq $null))
    {
        try
        {
            $Cluster=Get-Cluster
            if($Cluster -ne $null)
            {
               $ClusterName=$Cluster.Name
            }
        }
        catch
        {
            $ClusterName=[String]::Empty
        }
    }

    # --------------------------------------------------------------------------#
    # Rule: check if ClusterName is resolvable
    # --------------------------------------------------------------------------#
    ++$id
    ++$percentcompleted
    $currentRuleTitle = $_system_translations.ClusterNameResolvableCheck_Title
    $currentRuleId = "IsClusterNameResolvable"
    Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
    $IsClusterNameResolvable=$false
    $failedMachines.Clear()
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.

        if(($ClusterName.Trim().Length -eq 0) -OR ($ClusterName -eq $null))
        {
            Write-Error $_system_translations.clusternamenotpresent_message
            $IsClusterNameResolvable = $false
        }
        else
        {
            $IsClusterNameResolvable=IsHostNameResolvable $ClusterName
        }

        if( !$IsClusterNameResolvable )
        {
            [void] $failedMachines.Add($computerName)
        }

        $percentcompleted=PercentCompleted $id $totalRules

        Write-RuleResult $CAUPipeServer $id $_system_translations.ClusterNameResolvableCheck_Title $IsClusterNameResolvable $c_SevError $failedMachines $percentcompleted
        Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsClusterNameResolvable)
    }

    if(!$IsClusterNameResolvable)
    {
        # cluster name is not resolvable
        return
    }

    #write the options selected by user
    Append-XmlElement $xmlDoc $cauNode $ns "ClusterName" $ClusterName

    # assign currentRuleTitle to null to ensure trap doesnt write a failure to report if Get-ServerInClusterStatus throws
    $currentRuleTitle = $null
    $currentRuleId = $null

    #Check if current machine is part of cluster
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.
        $isMachineClusterNode=Get-ServerInClusterStatus $ClusterName $computerName
        Append-XmlElement $xmlDoc $cauNode $ns "IsCurrentMachinePartofCluster" (Formalize-BoolValue $isMachineClusterNode)
    }

    #downlevel cluster check
    # We have an issue with doing Cluster version check when not administrator.
    # We can't do administrator check before Cluster version since most downlevel
    # clusters don't have the WinRM package installed. Fortunately we can get
    # E_ACCESSDENIED from the $error and check that. We'll manipulate the result
    # to show correct error from this call
    $IsClusterSupported=$false
    $RequireAdminCheck=$true
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.
        $IsClusterSupported=!(isDownlevelCluster $ClusterName)
        if($error[0].Exception.ErrorCode -eq $E_ACCESSDENIED)
        {
            # We want to return correct error for ACCESSDENIED
            # and ignore isDownlevelCluster, since we don't really know.
            $IsClusterSupported=$true
            $RequireAdminCheck=$false
        }
    }

    if($IsClusterSupported -eq $false)
    {
        # cluster name is downlevel cluster
        $schemaRuleId=4 #IsWindows8Cluster is the 4th rule in schematron file

        ++$percentcompleted
        $currentRuleTitle = $_system_translations.Windows8ClusterCheck_Title
        $currentRuleId = "IsWindows8Cluster"
        Write-RuleStart $CAUPipeServer $schemaRuleId $currentRuleTitle $percentcompleted
        $failedMachines.Clear()

        [void] $failedMachines.Add($ClusterName)

        $percentcompleted=PercentCompleted $schemaRuleId $totalRules
        Write-RuleResult $CAUPipeServer $schemaRuleId $currentRuleTitle $IsClusterSupported $c_SevError $failedMachines $percentcompleted
        Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsClusterSupported)

        Write-Error $_system_translations.Windows8ClusterCheck_Problem
        return
    }

    $currentRuleTitle = $null
    $currentRuleId = $null

    $nodes=get-clusternode -cluster $ClusterName

    # --------------------------------------------------------------------------#
    # Rule: Check Cluster nodes are configured for remote management via WMIv2
    # --------------------------------------------------------------------------#
    ++$id
    ++$percentcompleted
    $currentRuleTitle = $_system_translations.IsWMIv2ConfiguredCheck_Title
    $currentRuleId = "IsWMIv2Configured"
    Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
    $failedMachines.Clear()
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.
        $IsWMIv2Configured=$true
        foreach($node in $nodes)
        {
            if($node.State -eq 'Down')
            {
                # Offline nodes will not be checked
                # so they won't be counted towards fail count
                continue
            }

            # the assignment is to ensure that the result is not streamed to the output stream
            $testWSManResult=Test-WSMan -computername $node.Name
            if($? -eq $false)
            {
                $IsWMIv2Configured=$false
                [void] $failedMachines.Add($node.Name)
            }
        }

        $percentcompleted=PercentCompleted $id $totalRules
        Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsWMIv2Configured $c_SevError $failedMachines $percentcompleted
        Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsWMIv2Configured)
    }

    # --------------------------------------------------------------------------#
    # Rule: Check if PS remoting is enabled on all nodes
    # --------------------------------------------------------------------------#
    ++$id
    ++$percentcompleted
    $currentRuleTitle = $_system_translations.IsPowershellRemotingEnabledCheck_Title
    $currentRuleId = "IsPowershellRemotingEnabledCheck"
    Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
    $percentcompleted=PercentCompleted $id $totalRules
    $IsPowershellRemotingEnabled=$true
    $failedMachines.Clear()
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.

        foreach($node in $nodes)
        {
            if($node.State -eq 'Down')
            {
                # Offline nodes will not be checked
                # so they won't be counted towards fail count
                continue
            }

            $isEnabled=isPSRemotingEnabled $node.Name
            if($isEnabled -eq $false)
            {
                $IsPowershellRemotingEnabled=$false
                [void] $failedMachines.Add($node.Name)
            }
        }

        Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsPowershellRemotingEnabled $c_SevError $failedMachines $percentcompleted
        Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsPowershellRemotingEnabled)
    }

    # --------------------------------------------------------------------------#
    # Rule: check if cluster is win8 cluster
    # --------------------------------------------------------------------------#
    ++$id
    ++$percentcompleted
    $currentRuleTitle = $_system_translations.Windows8ClusterCheck_Title
    $currentRuleId = "IsWindows8Cluster"
    Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
    $failedMachines.Clear()
    . { # Scoping for 'trap' block--after trap, we'll continue at the next
        # location at the same scope as the trap, meaning we'll skip the rest of
        # this block.
        $os= Get-WmiObject Win32_OperatingSystem -ComputerName $ClusterName        
        $versionNumbers=$os.Version.split(".")
        $majorVersion = [int]$versionNumbers[0]
        $minorVersion = [int]$versionNumbers[1]        
        if ($majorVersion -gt 6 -or ($majorVersion -eq 6 -and $minorVersion -gt 1))
        {
            $clusteriswin8 = $true
        }
        else
        {
            [void] $failedMachines.Add($ClusterName)
            $clusteriswin8 = $false
        }

        $percentcompleted=PercentCompleted $id $totalRules
        Write-RuleResult $CAUPipeServer $id $currentRuleTitle $clusteriswin8 $c_SevError $failedMachines $percentcompleted
        Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $clusteriswin8)
    }


        $currentRuleTitle = $null
        $currentRuleId = $null

        #If SelfUpdating role is not present the number of checks decrease
        #check for CAUResource
        $IsCauRoleInstalled=$false
        $clusterParameter=Get-Cluster $ClusterName | Get-ClusterParameter -Name "CauResourceName" -ErrorVariable Err -ErrorAction SilentlyContinue
        $clusterResourceName = $null
        if($clusterParameter -ne $null)
        {
            $clusterResourceString=$clusterParameter.Value
            if($clusterResourceString -ne $null)
            {
                $clusterResource= get-clusterresource -cluster $ClusterName -name $clusterResourceString
                $clusterResourceName=$clusterResource.Name
                $clusterResourceOwnerNode= $clusterResource.OwnerNode
                $IsCauRoleInstalled=$true
            }
        }

        if($clusterResourceName -eq $null)
        {
            $totalRules=11
        }

        # --------------------------------------------------------------------------#
        # Rule: check if all nodes have net and powershell installed
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.AllNodesHaveNetandPSInstalledCheck_Title
        $currentRuleId = "AllNodesHaveNetandPSInstalled"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $AllNodesHaveNetandPSInstalled=$true
            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                $nodePassed = $true

                #check for .net install
                $value=Get-RemoteHKLM $node "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client" "Install"
                if ($value -ne $null)
                {
                    if ($Value -ne 1)
                    {
                        $nodePassed = $false
                    }
                }
                else
                {
                    $nodePassed = $false
                }

                if($nodePassed)
                {
                    #check for .net version
                    $value=Get-RemoteHKLM $node "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client" "Version"
                    if ($value -ne $null)
                    {
                        if ($value -lt 4.5)
                        {
                            $nodePassed = $false
                        }
                    }
                    else
                    {
                        $nodePassed = $false
                    }
                }

                if($nodePassed)
                {
                    #check for powershell
                    $value=Get-RemoteHKLM $node "SOFTWARE\Microsoft\PowerShell\3" "Install"
                    if ($value -ne $null)
                    {
                        if ($value -ne 1)
                        {
                            $nodePassed = $false
                        }
                    }
                    else
                    {
                        $nodePassed = $false
                    }
                }

                if( !$nodePassed )
                {
                    $AllNodesHaveNetandPSInstalled = $false
                    [void] $failedMachines.Add($node.Name)
                }
            }

            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $AllNodesHaveNetandPSInstalled $c_SevError $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $AllNodesHaveNetandPSInstalled)
        }

        # --------------------------------------------------------------------------#
        # Rule: Check if cluster service is up and running on cluster nodes
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.ClusterupAndRunningCheck_Title
        $currentRuleId = "IsClusterupAndRunning"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $IsClusterupAndRunning=$true
            #check if clusterservice is running on nodes
            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # if node is down, we will consider clussvc not running
                    $IsClusterupAndRunning=$false
                    [void] $failedMachines.Add($node.Name)
                }
                else
                {
                    $isClusterServiceRunning=Check-ServiceStatus $node.Name "clussvc"

                    if(!$isClusterServiceRunning)
                    {
                        $IsClusterupAndRunning=$false
                        [void] $failedMachines.Add($node.Name)
                    }
                }
            }

            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsClusterupAndRunning $c_SevWarning $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsClusterupAndRunning)
        }

        # --------------------------------------------------------------------------#
        # Rule: Check Automatic Updates (AU) setting is not set to auto install
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.IsWUAAgentConfiguredonFixedTimeCheck_Title
        $currentRuleId = "IsWUAAgentConfiguredonFixedTime"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $IsWUAAgentConfiguredonFixedTime=$false
            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                # N.B: Group policy AU settings override local AU settings

                # AU group policy keys
                # "NoAutoUpdate"
                #   1: AU is disabled
                #   0: AU is enabled
                # "AUOptions"
                #   1: AU is disabled
                #   2: Notify on download and install
                #   3: Auto download and notify on install
                #   4: Auto download and scheduled install (BPA rule fails for this setting)
                #   5: Honor local settings on the node

                # Local AU keys
                # "AUOptions"
                #   1: AU is disabled
                #   2: Notify on download and install
                #   3: Auto download and notify on install
                #   4: Auto download and scheduled install  (BPA rule fails for this setting)

                $NoAutoUpdatePolicyKey=Get-RemoteHKLM $node "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate"
                $AUOptionsPolicyKey=Get-RemoteHKLM $node "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions"

                $AUOptionsLocalKey=Get-RemoteHKLM $node "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" "AUOptions"

                $AutoInstallEnabled = $false

                if($NoAutoUpdatePolicyKey -ne $null) # Group policy is set
                {
                    if($NoAutoUpdatePolicyKey -eq 0) # Group policy is enabled
                    {
                        if($AUOptionsPolicyKey -ne $null)
                        {
                            if($AUOptionsPolicyKey -eq 4) # AU set to AutoInstall
                            {
                                $AutoInstallEnabled = $true
                            }
                            elseif($AUOptionsPolicyKey -eq 5) # AU set to honor local settings
                            {
                                if(($AUOptionsLocalKey -ne $null) -AND ($AUOptionsLocalKey -eq 4)) # Local AU configured to AutoInstall
                                {
                                    $AutoInstallEnabled = $true
                                }
                            }
                        }
                    }
                }
                elseif(($AUOptionsLocalKey -ne $null) -AND ($AUOptionsLocalKey -eq 4)) # Local AU configured to AutoInstall
                {
                    $AutoInstallEnabled = $true
                }

                if($AutoInstallEnabled)
                {
                    $IsWUAAgentConfiguredonFixedTime=$true
                    [void] $failedMachines.Add($node.Name)
                }
            }

            $percentcompleted=PercentCompleted $id $totalRules
            # Note that we negate the result when calling Write-Progress, cause the value false is the success case
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle (!$IsWUAAgentConfiguredonFixedTime) $c_SevWarning $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsWUAAgentConfiguredonFixedTime)
        }

        # --------------------------------------------------------------------------#
        # Rule: check if all cluster nodes are uniformly configured to use
        #       the same update source of either a WSUS server, or WU/MU
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.IsNodesconfiguredtoUseSameUpdateSourceCheck_Title
        $currentRuleId = "IsNodesconfiguredtoUseSameUpdateSource"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $IsNodesconfiguredtoUseSameUpdateSource=$true
            $wsusServerNames=New-Object System.Collections.ArrayList
            $WUStatusServerNames=New-Object System.Collections.ArrayList
            $UseWUServerList=New-Object System.Collections.ArrayList
            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                $wsusserverkey=Get-RemoteHKLM $node "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "WUServer"
                $wuStatusServerkey=Get-RemoteHKLM $node "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "WUStatusServer"
                $UseWUServerkey=Get-RemoteHKLM $node "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "UseWUServer"
                if ($wsusserverkey -ne $null)
                {
                    $wsusServerNames.Add($wsusserverkey)
                }
                else
                {
                    $wsusServerNames.Add("<not set>")
                }

                if ($wuStatusServerkey -ne $null)
                {
                    $WUStatusServerNames.Add($wuStatusServerkey)
                }
                else
                {
                    $WUStatusServerNames.Add("<not set>")
                }

                if ($UseWUServerkey -ne $null -AND $UseWUServerkey -eq '1')
                {
                    # We have a policy to use WU Server
                    $UseWUServerList.Add($UseWUServerkey)
                }
                else
                {
                    # $UseWUServerkey -eq 0 OR
                    # No policy is set and regkey is not present
                    $UseWUServerList.Add("<not set>")
                }
            }

            for($i=0; $i -lt $wsusServerNames.Count-1; $i++)
            {
                if($wsusServerNames[$i] -ne $wsusServerNames[$i+1])
                {
                    $IsNodesconfiguredtoUseSameUpdateSource=$false
                }
            }

            for($i=0; $i -lt $WUStatusServerNames.Count-1; $i++)
            {
                if($WUStatusServerNames[$i] -ne $WUStatusServerNames[$i+1])
                {
                    $IsNodesconfiguredtoUseSameUpdateSource=$false
                }
            }

            for($i=0; $i -lt $UseWUServerList.Count-1; $i++)
            {
                if($UseWUServerList[$i] -ne $UseWUServerList[$i+1])
                {
                    $IsNodesconfiguredtoUseSameUpdateSource=$false
                }
            }

            if(!$IsNodesconfiguredtoUseSameUpdateSource)
            {
                foreach($node in $nodes)
                {
                    [void] $failedMachines.Add($node.Name)
                }
            }

            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsNodesconfiguredtoUseSameUpdateSource $c_SevWarning $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsNodesconfiguredtoUseSameUpdateSource)
        }


        # --------------------------------------------------------------------------#
        # Rule: check for firewall rule on cluster nodes
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.IsFirewallRuleforRemoteShutdownPresentonNodes_Title
        $currentRuleId = "IsFirewallRuleforRemoteShutdownPresentonNodes"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $IsFirewallRuleforRemoteShutdownPresentonNodes=$true

            $asm = [System.Reflection.Assembly]::GetAssembly([Microsoft.ClusterAwareUpdating.Commands.InvokeCauRunCommand])
            if($null -ne $asm)
            {
                $stream = $asm.GetManifestResourceStream("FirewallUtil.ps1")
                if($null -ne $stream)
                {
                    $reader = New-Object "System.IO.StreamReader" -ArgumentList @($stream)
                    $firewallUtilScript = $reader.ReadToEnd()
                    $sb = [scriptblock]::Create($firewallUtilScript)
                    . $sb
                }
            }
            if($null -eq (Get-Command 'Test-FirewallRuleGroupAllowsTraffic'))
            {
                throw "Could not load firewall test script."
            }

            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                try
                {
                    [int] $timeoutSeconds = 5
                    $cso = New-CimSessionOption -Protocol Default
                    $cso.Timeout = [TimeSpan]::FromSeconds($timeoutSeconds)

                    $cs = New-CimSession -ComputerName $node.Name -OperationTimeoutSec $timeoutSeconds -SessionOption $cso
                    if($cs -eq $null)
                    {
                        # Machine is currently unreachable
                        continue;
                    }

                    # '@firewallapi.dll,-36751' is the language-neutral way to refer to the 'Remote
                    # Shutdown' firewall rule group. (36751 is IDS_SHUTDOWN_WININIT_GROUP)
                    $trafficAllowed = Test-FirewallRuleGroupAllowsTraffic -GroupName '@firewallapi.dll,-36751' -ProfileName 'Domain' -CimSession $cs -Verbose

                    if(!$trafficAllowed)
                    {
                        $IsFirewallRuleforRemoteShutdownPresentonNodes = $false
                        [void] $failedMachines.Add($node.Name)
                    }
                }
                finally
                {
                    if($cs -ne $null)
                    {
                        Remove-CimSession $cs
                    }
                }
            } # end foreach( $node )

            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsFirewallRuleforRemoteShutdownPresentonNodes $c_SevError $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsFirewallRuleforRemoteShutdownPresentonNodes)
        }

        # --------------------------------------------------------------------------#
        # Rule: check proxy which is set by using Netsh winhttp set proxy
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.IsMachineProxySettoDataCenterLocalProxy_Title
        $currentRuleId = "IsMachineProxy"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            $IsMachineProxy= $true
            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                $winhttpsettings=Get-WinHttpProxy $node
                if(($winhttpsettings -eq $null) -OR ($winhttpsettings.Trim().Length -le 0))
                {
                    #write-error "$node is in error"
                    $IsMachineProxy = $false
                    [void] $failedMachines.Add($node.Name)
                }
            }

            #write-error $IsMachineProxy
            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsMachineProxy $c_SevWarning $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsMachineProxy)
        }

        # --------------------------------------------------------------------------#
        # Rule: Check if CAU cluster role is installed
        # --------------------------------------------------------------------------#
        ++$id
        ++$percentcompleted
        $currentRuleTitle = $_system_translations.CauRoleInstalledCheck_Title
        $currentRuleId = "IsCauRoleInstalled"
        Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
        $failedMachines.Clear()
        . { # Scoping for 'trap' block--after trap, we'll continue at the next
            # location at the same scope as the trap, meaning we'll skip the rest of
            # this block.
            if(!$IsCauRoleInstalled)
            {
                [void] $failedMachines.Add($ClusterName)
            }
            $IsCauRoleEnabled=$false
            $percentcompleted=PercentCompleted $id $totalRules
            Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsCauRoleInstalled $c_SevWarning $failedMachines $percentcompleted
            Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsCauRoleInstalled)
        }


        #############################################################################
        # Rules when CAU cluster resource is installed on the cluster
        #############################################################################

        if($clusterResourceName -ne $null)# Start checks for Self Updating Mode
        {
            $IsCauRoleInstalled=$true
            Append-XmlElement $xmlDoc $cauNode $ns "CAUResourceName" $clusterResourceName

            # This trap will cause the error to be written after executing the trap code.
            # We have another 'trap' here, because execution will continue at the next command /at the
            # same scope level as the trap/.
            trap
            {
                if( $currentRuleTitle )
                {
                    [void] $failedMachines.Add("$([Environment]::MachineName) (internal error)") # <-- not localized...
                    Write-RuleResult $CAUPipeServer $id $currentRuleTitle $false $c_SevError $failedMachines $percentcompleted
                    Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $false)
                }
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if CAUResource is enabled
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.CauRoleEnabledCheck_Title
            $currentRuleId = "IsCauRoleEnabled"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                if($clusterResource.State.ToString() -eq "Online")
                {
                    $IsCauRoleEnabled=$true
                }
                else
                {
                    [void] $failedMachines.Add($ClusterName)
                }
                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsCauRoleEnabled $c_SevWarning $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsCauRoleEnabled)
            }

            $currentRuleTitle = $null
            $currentRuleId = $null
            # --------------------------------------------------------------------------#
            # Fetch CAUResource configuration
            # --------------------------------------------------------------------------#
            $IsWarnAfterLessThanStopAfter=$true
            $cauResource = get-clusterresource -cluster $ClusterName -name $clusterResourceName
            $resourceparameters=get-cauclusterrole -ClusterName $ClusterName
            $badCauParameter=$false
            $stopaftertimespan=$null
            $warnaftertimespan=$null
            $postupdatescriptvalue=$null
            $preupdatescriptvalue=$null
            $startdate=$null
            $daysofweek=$null
            $weeksofmonth=$null
            $caupluginname=$null
            foreach($param in $resourceparameters)
            {
                if($param.Name -eq "stopafter")
                {
                    try
                    {
                        $stopaftertimespan=[System.TimeSpan]$param.Value
                    }
                    catch
                    {
                        $badCauParameter = $true
                    }
                }
                if($param.Name -eq "warnafter")
                {
                    try
                    {
                        $warnaftertimespan=[System.TimeSpan]$param.Value
                    }
                    catch
                    {
                        $badCauParameter = $true
                    }
                }
                if($param.Name -eq "postupdatescript")
                {
                    $postupdatescriptvalue=$param.Value
                }
                if($param.Name -eq "preupdatescript")
                {
                    $preupdatescriptvalue=$param.Value
                }
                if($param.Name -eq "startdate")
                {
                    $startdate=$param.Value
                }
                if($param.Name -eq "daysofweek")
                {
                    $temp= get-clusterparameter -Name "DaysOfWeek" -InputObject $cauResource
                    $daysofweek = $temp.Value
                }
                if($param.Name -eq "weeksofmonth")
                {
                    $temp=get-clusterparameter -Name "weeksofmonth" -InputObject $cauResource
                    $weeksofmonth = $temp.Value
                }
                if($param.Name -eq "caupluginname")
                {
                    $caupluginname=$param.Value
                }
            }

            # --------------------------------------------------------------------------#
            # Get registered plugins on all nodes
            # --------------------------------------------------------------------------#
            $IsCauPluginregisteredonAllNodesinSelfUpdatingMode=$true

            # If plugin name wasn't retrieved, the default plugin is windows update
            if ($caupluginname -eq $null)
            {
                $caupluginname = "Microsoft.WindowsUpdatePlugin"
            }

            $IsSameSetofPluginPresentonAllNodes=$true
            $pluginsfromallNodes = New-Object System.Collections.ArrayList
            $pluginCountfromAllNode=New-Object System.Collections.ArrayList
            #$pluginAstextFiles=New-Object System.Collections.ArrayList

            foreach($node in $nodes)
            {
                if($node.State -eq 'Down')
                {
                    # Offline nodes will not be checked
                    # so they won't be counted towards fail count
                    continue
                }

                $fileName=$appdataCAU+"\plugins_" + $node+".txt"
                $plugins=invoke-command -ComputerName $node {ipmo clusterawareupdating; get-cauplugin}
                #$plugins.Name | out-file -Encoding string $fileName
                if( $plugins -ne $null )
                {
                    $pluginCountfromAllNode.Add($plugins.Count)
                    $pluginsfromallNodes.Add($plugins)
                }
                #$pluginAstextFiles.Add($fileName)
            }

            #look for count of plugin to be same on all nodes
            for($i=0; $i -lt $pluginCountfromAllNode.Count-1; $i++)
            {
                if($pluginCountfromAllNode[$i] -ne $pluginCountfromAllNode[$i+1])
                {
                    $IsSameSetofPluginPresentonAllNodes=$false
                }
            }

            #check same "set of plugins" present on all nodes
            for($i=0; $i -lt $pluginsfromallNodes.Count-1; $i++)
            {
                if($pluginsfromallNodes[$i+1].Name.Count -eq $pluginsfromallNodes[$i].Name.Count)
                {
                    for($j=0; $j -lt $pluginsfromallNodes[$i].Name.Count; $j++)
                    {
                        if($pluginsfromallNodes[$i+1].Name.Contains($pluginsfromallNodes[$i].Name[$j]) -eq $false)
                        {
                            $IsSameSetofPluginPresentonAllNodes=$false
                        }
                    }
                }
                else
                {
                    $IsSameSetofPluginPresentonAllNodes=$false
                }
            }


            # --------------------------------------------------------------------------#
            # Rule: Check if current cau plugin is registered on all cluster nodes
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.IsCauPluginregisteredonAllNodesinSelfUpdatingModeCheck_Title
            $currentRuleId = "IsCauPluginregisteredonAllNodesinSelfUpdatingMode"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.

                for($i=0; $i -lt $pluginsfromallNodes.Count; $i++)
                {
                    $currentPluginRegistered=$true

                    foreach($plugin in $caupluginname)
                    {
                        if (!$pluginsfromallNodes[$i].Name.Contains($plugin))
                        {
                            $currentPluginRegistered = $false;
                            break;
                        }
                    }

                    if($currentPluginRegistered -eq $false)
                    {
                        $IsCauPluginregisteredonAllNodesinSelfUpdatingMode=$false
                        [void] $failedMachines.Add($nodes[$i].Name)
                    }
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsCauPluginregisteredonAllNodesinSelfUpdatingMode $c_SevError $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsCauPluginregisteredonAllNodesinSelfUpdatingMode)
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if same set of plugins are registered on all cluster nodes
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.IsSameSetofPluginPresentonAllNodesCheck_Title
            $currentRuleId = "IsSameSetofPluginPresentonAllNodes"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                if(!$IsSameSetofPluginPresentonAllNodes)
                {
                    [void] $failedMachines.Add($ClusterName)
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsSameSetofPluginPresentonAllNodes $c_SevWarning $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsSameSetofPluginPresentonAllNodes)
            }


            # --------------------------------------------------------------------------#
            # Rule: Check is the configuration for CAU Resource is valid
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.SelfUpdatingOptionsScheduleExpected_Title
            $currentRuleId = "IsSelfUpdatingOptionsScheduleExpected"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                $IsSelfUpdatingOptionsScheduleExpected=$true
                # check if startdate is valid
                if($startdate -ne $null)
                {
                    if(!($startdate -is [DateTime]))
                    {
                        $IsSelfUpdatingOptionsScheduleExpected=$false
                    }
                }

                # check if weeksofmonth is valid, valid values are 1-5 and should be int32
                if($weeksofmonth -ne $null)
                {
                    if (($weeksofmonth -lt 1) -OR ($weeksofmonth -gt 0x1F))
                    {
                        $IsSelfUpdatingOptionsScheduleExpected=$false
                    }

                    if(!(($weeksofmonth -is [system.Int32]) -OR ($weeksofmonth -is [system.UInt32]) -OR ($weeksofmonth -is [System.Int64] )))
                    {
                        $IsSelfUpdatingOptionsScheduleExpected=$false
                    }
                }

                # check if daysofweek is valid, valid values are 0(None)-127(All Days sun,mon,tue,wed,thur,fri,sat) and should be int32
                if($daysofweek -ne $null)
                {
                    if (($daysofweek -lt 0) -OR ($daysofweek -gt 127))
                    {
                        $IsSelfUpdatingOptionsScheduleExpected=$false
                    }

                    if(!(($daysofweek -is [system.Int32]) -OR ($daysofweek -is [system.UInt32]) -OR ($daysofweek -is [System.Int64] )))
                    {
                        $IsSelfUpdatingOptionsScheduleExpected=$false
                    }
                }

                if($badCauParameter -eq $true)
                {
                    $IsSelfUpdatingOptionsScheduleExpected = $false
                }

                if(!$IsSelfUpdatingOptionsScheduleExpected)
                {
                    [void] $failedMachines.Add($ClusterName)
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsSelfUpdatingOptionsScheduleExpected $c_SevError $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsSelfUpdatingOptionsScheduleExpected)
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if owners exist for CAUResource
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.OwnersPresentForCAURoleCheck_Title
            $currentRuleId = "IsOwnersPresentForCAURole"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                $IsOwnersPresentForCAURole=$false

                if($clusterResourceOwnerNode -ne $null)
                {
                    #Is ownerNode present if role installed
                    $IsOwnersPresentForCAURole=$true
                }
                else
                {
                    [void] $failedMachines.Add($ClusterName)
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsOwnersPresentForCAURole $c_SevError $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsOwnersPresentForCAURole)
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if pre and postupdate scripts are accessible
            # --------------------------------------------------------------------------#
            #TODO: Creds?   $clusterResourceOwnerNode
            #should be checked from owner nodes how can we do that ? This is
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.PreandPostUpdateScriptsAccessibleFromOwnersCheck_Title
            $currentRuleId = "IsPreandPostUpdateScriptsAccessibleFromOwners"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                $preupdatescriptcontentsfromAllNode=New-Object System.Collections.ArrayList
                $postupdatescriptcontentsfromAllNode=New-Object System.Collections.ArrayList
                $IsPreandPostUpdateScriptsAccessibleFromOwners=$true

                foreach($node in $nodes)
                {
                    if($node.State -eq 'Down')
                    {
                        # Offline nodes will not be checked
                        # so they won't be counted towards fail count
                        continue
                    }

                    $hasAccess = $true;

                    #check if Pre scripts exists
                    if($preupdatescriptvalue -ne $null)
                    {
                        $prescriptcontent = GetRemoteFileContent $node $preupdatescriptvalue
                        if($prescriptcontent[0]) # First object of content should indicate whether the file exists
                        {
                            $fileName= $appdataCAU+"\prescript_" + $node+".txt"
                            $prescriptcontent | out-file -Encoding string $fileName
                            $preupdatescriptcontentsfromAllNode.Add($fileName)
                        }
                        else
                        {
                            $hasAccess=$false
                            $IsPreandPostUpdateScriptsAccessibleFromOwners = $false;
                        }
                    }

                    #check if Post scripts exists
                    if($postupdatescriptvalue -ne $null)
                    {
                        $postscriptcontent=GetRemoteFileContent $node $postupdatescriptvalue
                        if($postscriptcontent[0]) # First object of content should indicate whether the file exists
                        {
                            $fileName= $appdataCAU+"\postscript_" + $node+".txt"
                            $postscriptcontent | out-file -Encoding string $fileName
                            $postupdatescriptcontentsfromAllNode.Add($fileName)
                        }
                        else
                        {
                            $hasAccess=$false
                            $IsPreandPostUpdateScriptsAccessibleFromOwners = $false;
                        }
                    }

                    if (!$hasAccess)
                    {
                        [void] $failedMachines.Add($node);
                    }
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsPreandPostUpdateScriptsAccessibleFromOwners $c_SevError $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsPreandPostUpdateScriptsAccessibleFromOwners)
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if contents of pre and post update scripts are same
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.PreandPostUpdateScriptsSameonNodes_Title
            $currentRuleId = "IsPreandPostUpdateScriptsSameonNodes"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear();
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                $preUpdateScriptsSameonAllNodes=$true
                if ($preupdatescriptcontentsfromAllNode.Count -gt 0)
                {
                    for( $i=0; $i -lt $preupdatescriptcontentsfromAllNode.Count-1; $i++)
                    {
                        $res=Compare-Object $(get-content $preupdatescriptcontentsfromAllNode[$i]) $(get-content $preupdatescriptcontentsfromAllNode[$i+1])
                        if($res)
                        {
                            #write-error "Post script Comparision Failed"
                            $preUpdateScriptsSameonAllNodes=$false
                        }
                    }
                }

                $postUpdateScriptsSameonAllNodes=$true
                if ($postupdatescriptcontentsfromAllNode.Count -gt 0)
                {
                    for( $i=0; $i -lt $postupdatescriptcontentsfromAllNode.Count-1; $i++)
                    {
                        $res=Compare-Object $(get-content $postupdatescriptcontentsfromAllNode[$i]) $(get-content $postupdatescriptcontentsfromAllNode[$i+1])
                        if($res)
                        {
                            $postUpdateScriptsSameonAllNodes=$false
                        }
                    }
                }

                #cleanup
                for( $i=0; $i -lt $preupdatescriptcontentsfromAllNode.Count; $i++)
                {
                    Remove-Item -Path $preupdatescriptcontentsfromAllNode[$i]
                }

                for( $i=0; $i -lt $postupdatescriptcontentsfromAllNode.Count; $i++)
                {
                    Remove-Item -Path $postupdatescriptcontentsfromAllNode[$i]
                }

                $IsPreandPostUpdateScriptsSameonNodes=$false
                if($postUpdateScriptsSameonAllNodes -AND $preUpdateScriptsSameonAllNodes)
                {
                    $IsPreandPostUpdateScriptsSameonNodes=$true
                }
                else
                {
                    [void] $failedMachines.Add($ClusterName)
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsPreandPostUpdateScriptsSameonNodes $c_SevWarning $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsPreandPostUpdateScriptsSameonNodes)
            }

            # --------------------------------------------------------------------------#
            # Rule: Check if Stop After is greater than WarnAfter
            # --------------------------------------------------------------------------#
            ++$id
            ++$percentcompleted
            $currentRuleTitle = $_system_translations.WarnAfterLessThanStopAfterCheck_Title
            $currentRuleId = "IsWarnAfterLessThanStopAfter"
            Write-RuleStart $CAUPipeServer $id $currentRuleTitle $percentcompleted
            $failedMachines.Clear()
            . { # Scoping for 'trap' block--after trap, we'll continue at the next
                # location at the same scope as the trap, meaning we'll skip the rest of
                # this block.
                if(($stopaftertimespan -ne $null) -AND ($warnaftertimespan -ne $null))
                {
                    if($stopaftertimespan -lt $warnaftertimespan)
                    {
                        $IsWarnAfterLessThanStopAfter=$false
                        [void] $failedMachines.Add($ClusterName)
                    }
                }

                $percentcompleted=PercentCompleted $id $totalRules
                Write-RuleResult $CAUPipeServer $id $currentRuleTitle $IsWarnAfterLessThanStopAfter $c_SevWarning $failedMachines $percentcompleted
                Append-XmlElement $xmlDoc $cauNode $ns $currentRuleId (Formalize-BoolValue $IsWarnAfterLessThanStopAfter)
            }
        }# End checks for Self Updating Mode
}

#
# ------------------
# FUNCTIONS - END
# ------------------
#

#
# ------------------------
# SCRIPT MAIN BODY - START
# ------------------------
#

#
# Initialize to perform querying Role information
#
Setup

#
# Set the Target Namespace to be used by XML
#
$tns="http://schemas.microsoft.com/bestpractices/models/CAU/2011/04"

#
# Create a new XmlDocument
#
$doc = Create-DocumentElement $tns "CAUComposite"

$progress = ($ProgressPipeName -ne $null) -AND ($ProgressPipeName.Trim().Length -ne 0);

try
{
    if($progress)
    {
        #Write-error "Initialize CAUPipeServer"
        call-GenCauPipeServer
        #Write-error "Create named pipe object"
        $CAUPipeServer = New-Object Microsoft.ClusterAwareUpdating.CAUPipeServer -ArgumentList $ProgressPipeName
    }
    else
    {
        Write-Error "No progress."
    }


    GetCAUXml $doc $tns $CAUPipeServer


    #
    # Role Information obtained.
    #
    TearDown

    $doc

    # can be used for testing purpose
    $doc.Save([Environment]::SystemDirectory + "\BestPractices\v1.0\Models\Microsoft\Windows\ClusterAwareUpdating\tempCAUBPA.xml")
}
finally
{
    # Ensure we try to close NamePipe
    if($CAUPipeServer -ne $null)
    {
        $CAUPipeServer.CloseCAUPipe()
    }
}
