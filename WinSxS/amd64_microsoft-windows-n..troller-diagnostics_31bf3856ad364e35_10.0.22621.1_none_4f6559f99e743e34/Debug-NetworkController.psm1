# Copyright (C) Microsoft Corporation.  All rights reserved.
$Script:AllDeviceCredential = "*"

function Get-NetworkControllerDeploymentInfo
{
    [CmdletBinding()]
    param(
        [string][parameter(Mandatory=$true, HelpMessage="One Network controller Node Name/IP")]$NetworkController,
        [System.Management.Automation.PSCredential][parameter(Mandatory=$false, HelpMessage="Credential to use for Network Controller. Specify in case of Kerberos deployment.")]$Credential = $null,
        [String][parameter(Mandatory=$false, HelpMessage="The URI to be used for Network Controller REST APIs. Specify in case of wild card certificate deployment.")]$RestURI = $null,
        [String][parameter(Mandatory=$false, HelpMessage="Certificate thumbprint to use for Network Controller. Specify in case of certificate deployment.")]$CertificateThumbprint = $null
    )
    # Connect to the NC machine and gather deployment info
    $psSession = GetPSSession $NetworkController $Credential
    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Network Controller " $NetworkController
        return
    }

    $NCInfo = Invoke-Command -Session $psSession -ScriptBlock {
        Import-Module NetworkController -Force -ErrorAction SilentlyContinue
        $Details = Get-NetworkController
        $Nodes = Get-NetworkControllerNode | Select-Object Server -ExpandProperty Server
        $LogInfo = Get-NetworkControllerDiagnostic
        [pscustomobject]@{Nodes=$Nodes;Details=$Details;LogInfo=$LogInfo}
    }
    RemovePSSession $psSession

    # get the client certificate thumbprint which is present on the machine
    $clientCert = $null
    if(($NCInfo.Details.ClientCertificateThumbprint -ne $null) -and ($NCInfo.Details.ClientCertificateThumbprint.Count -gt 0))
    {
        $machineCerts = Get-ChildItem Cert:\CurrentUser\My
        if(($machineCerts -ne $null) -and ($machineCerts.Count -gt 0))
        {
            foreach($cert in $NCInfo.Details.ClientCertificateThumbprint)
            {
                if($machineCerts.Where{$_.ThumbPrint -eq $cert}.Count -gt 0)
                {
                    $clientCert = $cert
                    break
                }
            }
        }

        if($clientCert -eq $null)
        {
            $str = "Client authentication certificate not found for current user." + [Environment]::UserName
            Write-Host $str
        }
    }

    # get the NC URI for REST
    $NCURL = $null
    if($RestURI -eq $null -or $RestURI -eq "")
    {
        # get the floating IP
        $RestIPAddress = $NCInfo.Details.RestIPAddress
        if($RestIPAddress)
        {
            $splits = $RestIPAddress.Split('/') # the ip is of the form ip/networkaddress
            if (($splits -ne $null) -and ($splits.Count -gt 1))
            {
                $floatingIP = $splits[0]
            }
        }
        else
        {
            $floatingIP = $NetworkController
        }

        if(($NCInfo.Details.ServerCertificate -ne $null) -and ($NCInfo.Details.ServerCertificate.DnsNameList -ne $null) -and ($NCInfo.Details.ServerCertificate.DnsNameList.Count -gt 0))
        {
            # in case of SSL certificate the URL must be the internationalized common name of the certificate
            # we need to see which DnsName in this list is valid and resolve to the floating IP
            $ncIpAddr = $null
            foreach($dnsName in $NCInfo.Details.ServerCertificate.DnsNameList)
            {
                if ($RestIPAddress)
                {
                    try
                    {
                        $ip = [IPAddress]::parse($dnsName.Punycode)
                        $ips = @($ip)
                    }
                    catch
                    {
                        $ips = Resolve-DnsName -Name $dnsName.Punycode -ErrorAction SilentlyContinue
                        if($ips -ne $null)
                        {
                            if ($ips -isnot [System.Array])
                            {
                                $ips = @($ips)
                            }
                        }
                    }
                    if ($ips.Where{$floatingIP -eq $_.IPAddressToString}.Count -gt 0)
                    {
                        $ncIpAddr = $dnsName.Punycode
                        break
                    }
                }
                else
                {
                    $ncIpAddr = $dnsName.Punycode
                    break
                }
            }

            if($ncIpAddr -eq $null)
            {
                $str = "Failed to discover Connection URI for Network Controller on computer " + $NetworkController + " Use RestURI parameter."
                Write-Host $str
            }
            else
            {
                $NCURL = "https://" + $ncIpAddr
            }
        }
        else
        {
            $NCURL = "http://" + $floatingIP
        }
    }
    else
    {
        if($RestURI.StartsWith("http"))
        {
            $NCURL = $RestURI
        }
        else
        {
            $str = "Connection URI entered is invalid. " + $RestURI
            Write-Host $str
        }
    }

    if ($NCInfo.LogInfo -ne $null)
    {
        $logLocation = $NCInfo.LogInfo.DiagnosticLogLocation
    }

    $output = @{}
    $output.Add("NetworkControllerURI", $NCURL)
    $output.Add("ClientCert", $clientCert)
    $output.Add("DiagnosticLogLocation", $logLocation)
    $output.Add("Nodes", $NCInfo.Nodes)
    
    return $output
}


function Get-NetworkControllerManagedDevices
{
param(
    [String][parameter(Mandatory=$true, HelpMessage="The URI to be used for Network Controller REST APIs. Specify in case of wild card certificate deployment.")]$RestURI = $null,
    [System.Management.Automation.PSCredential][parameter(Mandatory=$false, HelpMessage="Credential to use for Network Controller. Specify in case of Kerberos deployment.")]$Credential = $null,
    [String][parameter(Mandatory=$false, HelpMessage="Certificate thumbprint to use for Network Controller. Specify in case of certificate deployment.")]$CertificateThumbprint = $null
    )
    $NCURL = $RestURI
    $clientCert = $CertificateThumbprint

    $deviceDict = @{}

    $hosts = GetRESTOutput "$NCURL/networking/v1/servers" $Credential $clientCert
    $deviceDict = GetAllManagementIPs $hosts.Value -getAllIpsForResource $true

    $virtualServers = GetRESTOutput "$NCURL/networking/v1/VirtualServers" $Credential $clientCert
    $deviceDict += GetAllManagementIPs $virtualServers.Value -getAllIpsForResource $true

    $gateways = GetRESTOutput "$NCURL/networking/v1/Gateways" $Credential $clientCert
    $deviceDict += GetAllManagementIPs $gateways.Value -getAllIpsForResource $true

    $muxes = GetRESTOutput "$NCURL/networking/v1/LoadBalancerMuxes" $Credential $clientCert
    $deviceDict += GetAllManagementIPs $muxes.Value -getAllIpsForResource $true

    return $deviceDict
}


function Debug-NetworkController
{
    [CmdletBinding()]
    param(
        [string][parameter(Mandatory=$true, HelpMessage="One Network controller Node Name/IP")]$NetworkController,
        [Switch][parameter(Mandatory=$false, HelpMessage="Setup Diagnostics. Will retrieve diagnostics information by default.")]$SetupDiagnostics = $false,
        [bool][parameter(Mandatory=$false, HelpMessage="Include Host Agent and NC Traces")]$IncludeTraces = $true,
        [string][parameter(Mandatory=$false,HelpMessage="Complete Path to the Output Directory")]$OutputDirectory = (Get-Location).Path,
        [System.Management.Automation.PSCredential][parameter(Mandatory=$false, HelpMessage="Credential to use for Network Controller. Specify in case of Kerberos deployment.")]$Credential = $null,
        [String][parameter(Mandatory=$false, HelpMessage="The URI to be used for Network Controller REST APIs. Specify in case of wild card certificate deployment.")]$RestURI = $null,
        [String][parameter(Mandatory=$false, HelpMessage="Certificate thumbprint to use for Network Controller. Specify in case of certificate deployment.")]$CertificateThumbprint = $null,
        [Hashtable][parameter(Mandatory=$false, HelpMessage="List of device Credentials. Specify if device credentials are different then Network Controller.")]$DeviceCredentials,
        [Switch][parameter(Mandatory=$false, HelpMessage="Exclude SLB State information.")]$ExcludeSlbState = $false
    )
    # Set up eventing
    try { Stop-Transcript -ErrorAction Ignore | Out-Null } catch {}

    $logfile = $OutputDirectory + "\NCDiagnostics.log"
    Start-Transcript -Path $logFile -Append -ErrorAction Ignore

    $ncInfo = Get-NetworkControllerDeploymentInfo -NetworkController $NetworkController -Credential $Credential -RestURI $RestURI -CertificateThumbprint $CertificateThumbprint
    $NCURL = $ncInfo.NetworkControllerURI
    $clientCert = $ncInfo.ClientCert

    if ($ncInfo.NetworkControllerURI -eq $null)
    {
        Write-Host "Please use -RestURI".
        return 
    }

    if ($ncInfo.DiagnosticLogLocation -ne $null)
    {
        Write-Host "NetworkController Log Location " $ncInfo.DiagnosticLogLocation
    }
    else
    {
        Write-Host "NetworkController Log Location is local to each node"
    }

    if ($DeviceCredentials -eq $null -or $DeviceCredentials.Count -eq 0 -or $DeviceCredentials.GetType().Name -ne [System.Collections.Hashtable])
    {
        $DeviceCredentials = @{}
        $DeviceCredentials.Add($Script:AllDeviceCredential, $Credential)
    }

    # get hosts connected to NC.
    $hosts = GetRESTOutput "$NCURL/networking/v1/servers" $Credential $clientCert
    $hosts = GetAllManagementIPs $hosts.Value

    # get virtualServers connected to NC.
    $virtualServers = GetRESTOutput "$NCURL/networking/v1/VirtualServers" $Credential $clientCert
    $vsDict=@{}
    foreach ($vs in $virtualServers.value)
    {
        $vsDict.Add($vs.resourceRef, $vs)
    }

    # Connection info closest to the object gets used
    $gateways = GetRESTOutput "$NCURL/networking/v1/Gateways" $Credential $clientCert
    $gatewayDict = GetAllManagementIPs $gateways.Value
    [System.Collections.ArrayList]$gwVs=@()
    foreach ($gw in $gateways.value)
    {
        if (-not $gatewayDict.Contains($gw.resourceRef))
        {
            if ($vsDict.ContainsKey($gw.properties.virtualServer.resourceRef) -eq $true)
            {
                $gwVs.Add($vsDict[$gw.properties.virtualServer.resourceRef]) | Out-Null
            }
        }
    }
    $gateways = GetAllManagementIPs $gwVs
    foreach ($gw in $gatewayDict.GetEnumerator())
    {
        $gateways.Add($gw.Key, $gw.Value)
    }

    $muxes = GetRESTOutput "$NCURL/networking/v1/LoadBalancerMuxes" $Credential $clientCert
    $muxDict = GetAllManagementIPs $muxes.Value
    [System.Collections.ArrayList]$muxVs=@()
    foreach ($mux in $muxes.value)
    {
        if (-not $muxDict.Contains($mux.resourceRef))
        {
            if ($vsDict.ContainsKey($mux.properties.virtualServer.resourceRef) -eq $true)
            {
                $muxVs.Add($vsDict[$mux.properties.virtualServer.resourceRef]) | Out-Null
            }
        }
    }
    $muxes = GetAllManagementIPs $muxVs
    foreach ($mux in $muxDict.GetEnumerator())
    {
        $muxes.Add($mux.Key, $mux.Value)
    }


    if($SetupDiagnostics -eq $true)
    {
        # Setup Diagnostics data on all NC nodes
        SetupDiagnosticsDataForNC $ncInfo.Nodes $Credential

        # Setup Diagnostics data on all hosts
        SetupDiagnosticsDataForServers $hosts.Values $DeviceCredentials

        # Setup Diagnostics data on all Gateways
        SetupDiagnosticsDataForGateways $gateways.Values $DeviceCredentials

        # Setup Diagnostics data on all Muxes
        SetupDiagnosticsDataForMuxes $muxes.Values $DeviceCredentials
    }
    else
    {
        # Get Diagnostics data from all NC nodes
        CollectDiagnosticsDataFromNC -nodes $ncInfo.Nodes -includeTraces $IncludeTraces -outputDirectory $OutputDirectory -NCURL $NCURL -credential $Credential -certificateThumbPrint $clientCert -excludeSlbState $ExcludeSlbState

        # Get Diagnostics data from all hosts
        CollectDiagnosticsDataFromServers $hosts.Values $IncludeTraces $OutputDirectory $DeviceCredentials

        # Get Diagnostics data from all Gateways
        CollectDiagnosticsDataFromGateways $gateways.Values $IncludeTraces $OutputDirectory $DeviceCredentials

        # Get Diagnostics data from all Muxes
        CollectDiagnosticsDataFromMuxs $muxes.Values $IncludeTraces $OutputDirectory $DeviceCredentials

        if ($ncInfo.DiagnosticLogLocation -ne $null -and $IncludeTraces -eq $true)
        {
            $shareName = $ncInfo.DiagnosticLogLocation

            if ($shareName  -gt 4 -and $shareName.SubString(0,5).Equals("file:"))
            {
                $shareName = $shareName.SubString(5) -replace '/','\'
            }
            Write-Host "Copying shared logs from" $shareName
            Copy-Item -Path $shareName -Destination "$outputDirectory\\SharedLogs" -Recurse
        }
    }

    Stop-Transcript
}

#region Utility functions
function GetPSSession
{
    param($computerName, $credential)

    $psSession = $null
    if($credential -ne $null)
    {
        $psSession = New-PSSession -ComputerName $computerName -Credential $credential
    }
    else
    {
        $psSession = New-PSSession -ComputerName $computerName
    }
    return $psSession
}

function GetSystemDrive
{
    param ($psSession)
    $systemDrive = Invoke-Command -Session $psSession -ScriptBlock{
                        return $env:SystemDrive
                        }
    return $systemDrive
}

function RemovePSSession
{
    param($session)
    Remove-PSSession $session
}

function CreatePSDrive
{
    param($credential, $path)

    try 
    {
        if($credential -ne $null)
        {
            New-PSDrive -Name S -PSProvider filesystem -Root $path -Credential $credential -Scope Global | Out-Null
        }
        else
        {
            New-PSDrive -Name S -PSProvider filesystem -Root $path -Scope Global | Out-Null
        }
    }
    catch
    {
        Write-Host "Failed to map the remote path $path"
    }
}

function RemovePSDrive
{
    Remove-PSDrive -Name S -ErrorAction SilentlyContinue
}

function GetAllManagementIPs
{
    param($resources, [bool]$getAllIpsForResource)

    $ips = @{}

    foreach($resource in $resources)
    {
        $connections = $resource.properties.connections.Where{$_.managementAddresses -ne $null -and $_.managementAddresses.Count -gt 0}
        if($connections -ne $null -and $connections.Count -gt 0)
        {
            $connection = $connections.Where{$_.credentialType -eq 'UsernamePassword'}
            if($connection -eq $null -or $connection.Count -eq 0)
            {
                $connection = $connections[0]
            }
            else
            {
                $connection = $connection[0]
            }

            if ($getAllIpsForResource -eq $true)
            {
                $managementIPAddress = $connection.managementAddresses
            }
            else
            {
                $managementIPAddress = $connection.managementAddresses[0]
            }

            if(-not $ips.Contains($managementIPAddress))
            {
                $ips.Add($resource.resourceRef, $managementIPAddress)
            }
        }
    }
    return $ips
}

function GetRESTOutput
{
    param($Url, $credential, $clientCert)

    if($clientCert)
    {
        $restOutput = Invoke-RestMethod "$Url" -CertificateThumbprint $clientCert -UseBasicParsing
    }
    elseif($credential)
    {
        $restOutput = Invoke-RestMethod "$Url" -Credential $credential -UseBasicParsing
    }
    else
    {
        $restOutput = Invoke-RestMethod "$Url" -UseBasicParsing -UseDefaultCredentials
    }

    return $restOutput
}

function InvokeWebRequest
{
    param($Url, $headers, $content, $method, $body, $credential, $clientCert)

    if($credential)
    {
        $result = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $Url -Body $body -DisableKeepAlive -Credential $credential -UseBasicParsing
    }
    elseif($clientCert)
    {
        $result = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $Url -Body $body -DisableKeepAlive -CertificateThumbprint $clientCert -UseBasicParsing
    }
    else
    {
        $result = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $Url -Body $body -DisableKeepAlive -UseBasicParsing -UseDefaultCredentials
    }
    return $result
}


function InvokeREST
{
    param($BaseUrl, $BaseType, $OutputFolder, $Credential, $ClientCert, $ResourceId)

    $_baseType = $BaseType;
    if ($ResourceId -ne $nul)
    {
        $_baseType += "/$ResourceId"
    }

    $URL = "$BaseUrl/$_baseType"

    $restOutput = GetRESTOutput $URL $Credential $ClientCert

    $BaseTypePath=$BaseType.Replace('/', '-')
    $restOutput | ConvertTo-Json -Depth 10 >> "$OutputFolder/$BaseTypePath.Json"

    return $restOutput
}

function CollectRESTDataFromNC
{
    param($NCURI, $Destination, $Credential, $ClientCert)

    $BaseUrl = "$NCURI/Networking/v1"

    InvokeREST $BaseUrl "accessControlLists" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "credentials" $Destination $Credential $ClientCert $null 
    InvokeREST $BaseUrl "servers" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "virtualServers" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "logicalnetworks" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "macPools" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "virtualnetworks" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "networkinterfaces" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "publicIpAddresses" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "loadBalancerMuxes" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "loadBalancers" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "gatewaypools" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "gateways" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "virtualgateways" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "routetables" $Destination $Credential $ClientCert $null
    InvokeREST $BaseUrl "virtualnetworkmanager" $Destination $Credential $ClientCert "configuration"
    try
    {
        # This is an optional resource
        InvokeREST $BaseUrl "loadbalancermanager" $Destination $Credential $ClientCert "config"
    }
    catch {}
}

function CollectNetworkControllerState
{
    param($NCURI, $Destination, $credential, $clientCert)

    $headers = @{"Accept"="application/json"}
    $content = "application/json; charset=UTF-8"
    $network = "$NCURI/Networking/v1"
    $ncStateRetry = 3

    $method = "Put"
    $uri = "$network/diagnostics/networkcontrollerstate"
    $body = '{"properties": { }}'

    try
    {
        $result = InvokeWebRequest -Headers $headers -Content $content -Method $method -Url $uri -Body $body -credential $credential -clientCert $clientCert
        $totalWait=0
        do 
        {
            $totalWait += $ncStateRetry
	        Insert-TimedSleep -Seconds $ncStateRetry -DisplayMessage ">>> Waiting for NetworkController State collection ..." 
            $tempResult = InvokeREST $network "diagnostics/networkcontrollerstate" $Destination $Credential $ClientCert 
        }
        until (($tempResult.properties.provisioningState) -ne "Updating" -or $totalWait -gt $ncStateRetry*20)
    }
    catch
    {
      Write-Host "Failed to retrieve Network Controller State"
    }
}

function CollectSlbState
{
    param($NCURI, $Destination, $credential, $clientCert)

    $headers = @{"Accept"="application/json"}
    $content = "application/json; charset=UTF-8"
    $network = "$NCURI/Networking/v1"
    $slbStateRetry = 30

    $method = "Put"
    $uri = "$network/diagnostics/slbstate"
    $body = '{"properties": { }}'

    try
    {
        $result = InvokeWebRequest -Headers $headers -Content $content -Method $method -Url $uri -Body $body -credential $credential -clientCert $clientCert
        $resultObject = ConvertFrom-Json  $result.Content
        $operationId=$resultObject.properties.operationId
        $totalWait=0
        do 
        {
            $totalWait += $slbStateRetry
	        Insert-TimedSleep -Seconds $slbStateRetry -DisplayMessage ">>> Waiting for Slb State collection (OperationId $operationId)..." 
            $tempResult = InvokeREST $network "diagnostics/slbstateResults" $Destination $Credential $ClientCert $operationId 
        }
        until (($tempResult.properties.provisioningState) -ne "Updating" -or $totalWait -gt $slbStateRetry*20)
    }
    catch
    {
      Write-Host "Failed to retrieve Network Controller SLB State"
    }
}

function CollectDiagnosticsDataFromGateway
{
    param ($gateway, $DestinationPath, $IncludeTraces, $credential)

    $psSession = GetPSSession $gateway $credential

    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Gateway " $gateway
        return
    }

    $sys = GetSystemDrive $psSession

    $path = "\\$gateway\" + $sys.Replace(":","$")

    CreatePSDrive -Credential $credential -Path $path

    Write-Host "Collecting Diagnostics data from Gateway " $gateway

    md $DestinationPath -ErrorAction SilentlyContinue | Out-Null

    Invoke-Command -Session $psSession -ArgumentList $IncludeTraces,$sys -ScriptBlock  {
        param
        (
            [bool][parameter(Mandatory=$false)]$IncludeTraces = $true,
            [string]$sys
        )

        if($IncludeTraces -eq $true)
        {
            try
            {
                # Reset Logman
                logman stop GatewayTrace | Out-Null
                logman start GatewayTrace | Out-Null
            }
            catch
            {
                # do nothing
            }
        }

        $OutDirectory = "$sys\NCDiagnostics"
        md $OutDirectory -ErrorAction SilentlyContinue | Out-Null

        # Collect information
        $compartments = Get-NetCompartment 
        $compartments | fl * > "$OutDirectory\NetCompartment.txt"
        Get-NetIpInterface -IncludeAllCompartments | fl * > "$OutDirectory\NetIpInterface.txt"
        Get-NetRoute -IncludeAllCompartments | fl * > "$OutDirectory\NetRoutes.txt"
        Get-NetIpAddress -IncludeAllCompartments | fl * > "$OutDirectory\NetIPAddress.txt"
        Get-VpnS2SInterface | fl * > "$OutDirectory\VpnS2SInterface.txt"
        Get-RemoteAccess| fl * > "$OutDirectory\RemoteAccess.txt"
        Get-BGPRouter | fl * > "$OutDirectory\BGPRouter.txt"
        $gwService = Get-Service GatewayService
        if ($gwService.Status -eq "Running")
        {
            Get-GatewayTunnel | fl * > "$OutDirectory\GatewayTunnels.txt"
            Get-GatewayRoutingDomain | fl * > "$OutDirectory\GatewayRoutingDomain.txt"
        }

        Remove-Item "$OutDirectory\BGPPeer.txt" -ErrorAction SilentlyContinue
        Remove-Item "$OutDirectory\BGPRouteInfo.txt" -ErrorAction SilentlyContinue
        Remove-Item "$OutDirectory\BGPCustomRoute.txt" -ErrorAction SilentlyContinue

        foreach ($c in $compartments)
        {
            if ($c.CompartmentId -eq 1)
            {
                Get-BGPPeer | fl * >> "$OutDirectory\BGPPeer.txt"
                Get-BGPRouteInformation -Type All | fl * >> "$OutDirectory\BGPRouteInfo.txt"
                Get-BGPCustomRoute | fl * >> "$OutDirectory\BGPCustomRoute.txt"
            }
            else
            {
                $RoutingDomain = $c.CompartmentDescription
                Get-BGPPeer -RoutingDomain $RoutingDomain | fl * >> "$OutDirectory\BGPPeer.txt"
                Get-BGPRouteInformation -Type All -RoutingDomain $RoutingDomain | fl * >> "$OutDirectory\BGPRouteInfo.txt"
                Get-BGPCustomRoute -RoutingDomain $RoutingDomain | fl * >> "$OutDirectory\BGPCustomRoute.txt"
            }
        }
        #WFP state takes filename as input
        netsh wfp show state "$OutDirectory\wfpState.xml" | Out-Null

        #Collect IKE/Operational events
        wevtutil epl Microsoft-Windows-IKE/Operational "$OutDirectory\IkeOperational.evtx" /ow:true
    }

    if($IncludeTraces)
    {
        Copy-Item  -Recurse -Path S:\Windows\tracing -Destination $DestinationPath -ErrorAction SilentlyContinue
    }

    Copy-Item -Path S:\NCDiagnostics -Destination $DestinationPath -Recurse -ErrorAction SilentlyContinue
    RemovePSDrive
    RemovePSSession $psSession
}

function CollectDiagnosticsDataFromGateways
{
    param($Gateways, $includeTraces, $outputDirectory, $deviceCredentials)

    Write-Host "Collecting Diagnostics data from Gateways"

    foreach($Gateway in $Gateways)
    {
        $credential = GetCredentialsForDevice -mgmtIp $Gateway -deviceCreds $deviceCredentials
        $DestinationPath = [System.IO.Path]::Combine($outputDirectory, "Gateway-$Gateway")
        CollectDiagnosticsDataFromGateway $Gateway $DestinationPath $includeTraces $credential
    }
}

function CollectDiagnosticsDataFromMux
{
    param ($mux, $DestinationPath, $IncludeTraces, $credential)

    $psSession = GetPSSession $mux $credential

    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Mux " $mux
        return
    }

    $sys = GetSystemDrive $psSession

    $path = "\\$mux\" + $sys.Replace(":","$")

    CreatePSDrive -Credential $credential -Path $path

    Write-Host "Collecting Diagnostics data from Mux " $mux

    md $DestinationPath -ErrorAction SilentlyContinue | Out-Null

    Invoke-Command -Session $psSession -ArgumentList $IncludeTraces,$sys -ScriptBlock  {
        param
        (
            [bool][parameter(Mandatory=$false)]$IncludeTraces = $true,
            [string]$sys
        )

        if($IncludeTraces -eq $true)
        {
            try
            {
                # Reset Logman
                logman stop MuxTrace | Out-Null
                logman start MuxTrace | Out-Null
            }
            catch
            {
                # do nothing
            }
        }

        $OutDirectory = "$sys\NCDiagnostics"
        md $OutDirectory -ErrorAction SilentlyContinue | Out-Null

        # Collect information
        Get-NetIpInterface -IncludeAllCompartments | fl * > "$OutDirectory\NetIpInterface.txt"
        Get-NetRoute -IncludeAllCompartments | fl * > "$OutDirectory\NetRoutes.txt"
        Get-NetIpAddress -IncludeAllCompartments | fl * > "$OutDirectory\NetIPAddress.txt"
    }

    if($IncludeTraces)
    {
        Copy-Item  -Recurse -Path S:\Windows\tracing -Destination $DestinationPath -ErrorAction SilentlyContinue
    }

    Copy-Item -Path S:\NCDiagnostics -Destination $DestinationPath -Recurse -ErrorAction SilentlyContinue
    RemovePSDrive
    RemovePSSession $psSession
}

function CollectDiagnosticsDataFromMuxs
{
    param($Muxes, $includeTraces, $outputDirectory, $deviceCredentials)

    Write-Host "Collecting Diagnostics data from Muxes"

    foreach($Mux in $Muxes)
    {
        $credential = GetCredentialsForDevice -mgmtIp $Mux -deviceCreds $deviceCredentials
        $DestinationPath = [System.IO.Path]::Combine($outputDirectory, "Mux-$Mux")
        CollectDiagnosticsDataFromMux $Mux $DestinationPath $includeTraces $credential
    }
}

function CollectDiagnosticsDataFromServer
{
    param ($server, $DestinationPath, $IncludeTraces, $credential)

    $psSession = GetPSSession $server $credential

    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Host " $server
        return
    }

    Write-Host "Collecting Diagnostics data from Host " $server

    md $DestinationPath -ErrorAction SilentlyContinue | Out-Null

    $sys = GetSystemDrive $psSession

    $path = "\\$server\" + $sys.Replace(":","$")

    CreatePSDrive -Credential $credential -Path $path

    Invoke-Command -Session $psSession -ArgumentList $IncludeTraces, $sys -ScriptBlock  {
        param
        (
            [bool][parameter(Mandatory=$false)]$IncludeTraces = $true,
            [string]$sys
        )

        function CollectPortPolicies
        {
            $vfpCtrlExe = "$sys\windows\system32\vfpctrl.exe"
            $switches = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_VirtualEthernetSwitch
            foreach ($switch in $switches)
            {
                try
                {
                    $ports = Get-CimAssociatedInstance -InputObject $switch -ResultClassName Msvm_EthernetSwitchPort -Association Msvm_SystemDevice
                    echo "Policy for Switch : " $switch.ElementName
                    foreach ($port in $ports)
                    {
                        $portGuid = $port.Name
                        echo "Policy for port : " $portGuid
                        & $vfpCtrlExe /list-space  /port $portGuid
                        & $vfpCtrlExe /list-mapping  /port $portGuid
                        & $vfpCtrlExe /list-rule  /port $portGuid
                        & $vfpCtrlExe /port $portGuid /get-port-state
                    }
                }
                catch
                {
                    # do nothing
                }
            }
        }

        $editionId = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID

        if($IncludeTraces -eq $true)
        {
            try
            {
                if ($editionId.EditionID -eq 'ServerDatacenterNano')
                {
                    try { tracelog -flush HostAgentTrace | Out-Null} catch {}
                }
                else
                {
                    # Reset Logman
                    logman stop HostAgentTrace | Out-Null
                    logman start HostAgentTrace | Out-Null
                }
            }
            catch
            {
                # do nothing
            }
        }

        $OutDirectory = "$sys\NCDiagnostics"
        md $OutDirectory -ErrorAction SilentlyContinue | Out-Null

        $service=Get-Service NCHostAgent
        $OvsdbClientExe = "$env:SystemRoot\System32\ovsdb-client.exe"

        if (($service.Status -ne "Stopped") -And ((Test-Path $OvsdbClientExe) -eq $true))
        {
            & $OvsdbClientExe dump tcp:127.0.0.1:6641 ms_vtep > "$OutDirectory\ovsdb_ms_vtep.txt"
            & $OvsdbClientExe dump tcp:127.0.0.1:6641 ms_firewall > "$OutDirectory\ovsdb_ms_firewall.txt"
            & $OvsdbClientExe dump tcp:127.0.0.1:6641 ms_service_insertion > "$OutDirectory\ovsdb_ms_service_insertion.txt"
        }


        # Collect VFP Port policies
        CollectPortPolicies > "$OutDirectory\vfp_policy.txt"

        # Collect additional information
        ipconfig /allcompartments /all > "$OutDirectory\ipconfigall.txt"
        $netAdapter = Get-NetAdapter
        $netAdapter | ft > "$OutDirectory\networkadapters.txt"
        $netAdapter | fl * >> "$OutDirectory\networkadapters.txt"
        Get-VMNetworkAdapter -All > "$OutDirectory\vmnetworkadapters.txt"
        Get-netipaddress -IncludeAllCompartments > "$OutDirectory\netipaddress.txt"
        Get-netroute -IncludeAllCompartments > "$OutDirectory\netroute.txt"
        Get-VMNetworkAdapterVlan > "$OutDirectory\vmnetworkadaptersvlan.txt"
        Get-vm | Get-VMNetworkAdapter | fl * >> "$OutDirectory\vmnetworkadapters.txt"
        Get-VMNetworkAdapterIsolation | fl * > "$OutDirectory\vmnetworkadapterisolation.txt"
        $vSwitch = Get-VMSwitch 
        $vSwitch | ft > "$OutDirectory\vmswitches.txt"
        $vSwitch | fl * >> "$OutDirectory\vmswitches.txt"
    }

    if($IncludeTraces)
    {
        Copy-Item  -Recurse -Path S:\Windows\tracing -Destination $DestinationPath -ErrorAction SilentlyContinue
    }

    Copy-Item -Path S:\NCDiagnostics -Destination $DestinationPath -Recurse -ErrorAction SilentlyContinue
    RemovePSDrive
    RemovePSSession $psSession
}

function CollectDiagnosticsDataFromServers
{
    param ($servers, $IncludeTraces, $DestinationPath, $deviceCredentials)

    Write-Host "Collecting Diagnostics data from Hosts"

    foreach($Server in $Servers)
    {
        $credential = GetCredentialsForDevice -mgmtIp $Server -deviceCreds $deviceCredentials
        $DestinationPath = [System.IO.Path]::Combine($outputDirectory, "Host-$Server")
        CollectDiagnosticsDataFromServer $Server $DestinationPath $includeTraces $credential
    }
}

function CollectDiagnosticsDataFromNCNode
{
    param ($node, $DestinationPath, $includeTraces, $credential)

    $psSession = GetPSSession $node $credential

    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to NC Node " $node
        return
    }

    Write-Host "Collecting Diagnostics data from NC Node " $node

    $sys = GetSystemDrive $psSession

    $path = "\\$node\" + $sys.Replace(":","$")

    CreatePSDrive -Credential $credential -Path $path

    md $DestinationPath -ErrorAction SilentlyContinue | Out-Null
    
    Invoke-Command -Session $psSession -ArgumentList $IncludeTraces,$sys -ScriptBlock  {
        param
        (
            [bool][parameter(Mandatory=$false)]$IncludeTraces = $true,
            [string]$sys
        )

    
        if($IncludeTraces -eq $true)
        {
            try
            {
                # Reset Logman
                logman stop NetworkControllerTrace | Out-Null
                logman start NetworkControllerTrace | Out-Null
            }
            catch
            {
                # do nothing
            }
        }

        $OutDirectory = "$sys\NCDiagnostics"
        md $OutDirectory -ErrorAction SilentlyContinue | Out-Null

        # Collect information
        Get-NetworkControllerReplica -AllReplicas > "$OutDirectory\NetworkControllerReplica.txt"
        Get-NetIpInterface -IncludeAllCompartments | fl * > "$OutDirectory\NetIpInterface.txt"
        Get-NetIpAddress -IncludeAllCompartments | fl * > "$OutDirectory\NetIPAddress.txt"
        #pick up manifests
        Copy-Item -Path $sys\Windows\NetworkController\ApplicationManifest.xml -Destination "$OutDirectory" -ErrorAction SilentlyContinue
        Copy-Item -Path $sys\Windows\NetworkController\ClusterManifest.xml -Destination "$OutDirectory" -ErrorAction SilentlyContinue
        # Get Application and Cluster manifests from Service Fabric
        $cluster = Connect-ServiceFabricCluster
        if ($cluster)
        {
            $NCUri = "fabric:/NetworkController"
            Get-ServiceFabricClusterManifest > "$OutDirectory\ClusterManifest.xml"
            Get-ServiceFabricClusterHealth > "$OutDirectory\ClusterHealth.txt"
            Get-ServiceFabricApplicationHealth -ApplicationName $NCUri > "$OutDirectory\AppHealth.txt"
            $NCServices = Get-ServiceFabricService -ApplicationName $NCUri
            $NCServices > "$OutDirectory\NCServices.txt"
            foreach ($service in $NCServices)
            {
                $serviceTypeName=$service.ServiceTypeName
                Get-ServiceFabricServiceHealth -ServiceName $service.ServiceName.AbsoluteUri > "$OutDirectory\$serviceTypeName.txt"
                $partation = Get-ServiceFabricPartition -ServiceName $service.ServiceName.AbsoluteUri 
                $replicas = Get-ServiceFabricReplica -PartitionId $partation.PartitionId
                $replicas >> "$OutDirectory\$serviceTypeName.txt" 
                foreach ($replica in $replicas)
                {
                    if ($replica.ReplicaId)
                    {
                        Get-ServiceFabricReplicaHealth -PartitionId $partation.PartitionId -ReplicaOrInstanceId $replica.ReplicaId >> "$OutDirectory\$serviceTypeName.txt"
                    }
                    else
                    {
                        Get-ServiceFabricReplicaHealth -PartitionId $partation.PartitionId -ReplicaOrInstanceId $replica.InstanceId >> "$OutDirectory\$serviceTypeName.txt"
                    }
                }
            }
        }
    }

    Copy-Item  -Path "S:\NCDiagnostics" -Destination $outputDirectory -Recurse -ErrorAction SilentlyContinue

    if($includeTraces -eq $true)
    {
        Copy-Item  -Path "S:\Windows\tracing" -Destination $DestinationPath -Recurse -ErrorAction SilentlyContinue
        Copy-Item  -Path "S:\ProgramData\Service Fabric\Log\ApplicationCrashDumps" -Destination "$DestinationPath\ApplicationCrashDumps" -Recurse -ErrorAction SilentlyContinue
        Copy-Item  -Path "S:\ProgramData\Service Fabric\Log\CrashDumps" -Destination "$DestinationPath\CrashDumps" -Recurse -ErrorAction SilentlyContinue
    }

    RemovePSDrive
    RemovePSSession $psSession
}

function CollectDiagnosticsDataFromNC
{
    param($nodes, $includeTraces, $outputDirectory, $NCURL, $credential, $certificateThumbPrint, $clientCert, $excludeSlbState)

    Write-Host "Collecting Diagnostics data from NC Nodes"
    
    $RestDestinationPath = [System.IO.Path]::Combine($outputDirectory, "NCDiagnostics")
    md $RestDestinationPath -ErrorAction SilentlyContinue | Out-Null

    CollectNetworkControllerState $NCURL $RestDestinationPath $credential $clientCert

    foreach($node in $nodes)
    {
        $DestinationPath = [System.IO.Path]::Combine($outputDirectory, "NCNode-$node")
        CollectDiagnosticsDataFromNCNode $node $DestinationPath $includeTraces $credential
    }

    CollectRESTDataFromNC $NCURL $RestDestinationPath $credential $clientCert | Out-Null

    if ($excludeSlbState -eq $false)
    {
        CollectSlbState $NCURL $RestDestinationPath $credential $clientCert
    }
}

function StartLogmanGateway
{
    param($gateway, $credential)
    $psSession = GetPSSession $gateway $credential
    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Gateway " $gateway
        return
    }

    Write-Host "Enabling Logging on Gateway " $gateway

    Invoke-Command -Session $psSession -ScriptBlock{
        $flags=0x0

        #Critical = 1, Error = 2, Warning = 3, Information = 4, Verbose = 5
        $level=3

        $guids = (pwd).path+"\guids.txt"

        # BGPProvider
        Out-File -InputObject "{EB171376-3B90-4169-BD76-2FB821C4F6FB} $flags $level" -FilePath $guids -Encoding ascii
        # RRASProvider
        Out-File -InputObject "{24989972-0967-4E21-A926-93854033638E} $flags $level" -FilePath $guids -Append -Encoding ascii
        # GwmHealthMonitorProvider
        Out-File -InputObject "{F3F35A3B-6D33-4C32-BC81-21513D8BD708} $flags $level" -FilePath $guids -Append -Encoding ascii

        $sys = $env:SystemDrive

        try { logman stop GatewayTrace | Out-Null} catch {}
        try { logman delete GatewayTrace | Out-Null} catch {}

        Write-Host "logman create trace GatewayTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\GatewayTrace"
        logman create trace GatewayTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\GatewayTrace
        
        Write-Host "logman start GatewayTrace"
        logman start GatewayTrace
    }
    RemovePSSession $psSession
}

function StartLogmanMux
{
    param($mux, $credential)
    $psSession = GetPSSession $mux $credential
    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Mux " $mux
        return
    }

    Write-Host "Enabling Logging on Mux " $mux

    Invoke-Command -Session $psSession -ScriptBlock{
        $flags=0x0

        #Critical = 1, Error = 2, Warning = 3, Information = 4, Verbose = 5
        $level=3

        $guids = (pwd).path+"\guids.txt"

        # Mux Provider
        Out-File -InputObject "{6c2350f8-f827-4b74-ad0c-714a92e22576} $flags $level" -FilePath $guids -Encoding ascii

        $sys = $env:SystemDrive

        try { logman stop MuxTrace | Out-Null} catch {}
        try { logman delete MuxTrace | Out-Null} catch {}

        Write-Host "logman create trace MuxTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\MuxTrace"
        logman create trace MuxTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\MuxTrace
        
        Write-Host "logman start MuxTrace"
        logman start MuxTrace
    }
    RemovePSSession $psSession
}

function StartLogmanHostAgent
{
    param($server, $credential)
    $psSession = GetPSSession $server $credential
    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to Server " $server
        return
    }

    Write-Host "Enabling Logging on Host " $server

    Invoke-Command -Session $psSession -ScriptBlock{

        $editionId = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID
        $bNano = $false
        if ($editionId.EditionID -eq 'ServerDatacenterNano')
        {
            $bNano=$true
        }

        $flags=0x0

        #Critical = 1, Error = 2, Warning = 3, Information = 4, Verbose = 5
        $level=3

        $guids = (pwd).path+"\guids.txt"

        # HostAgentProvider
        Out-File -InputObject "{28F7FB0F-EAB3-4960-9693-9289CA768DEA} $flags $level" -FilePath $guids -Encoding ascii
        # HostAgentVNetPluginProvider
        Out-File -InputObject "{A6527853-5B2B-46E5-9D77-A4486E012E73} $flags $level" -FilePath $guids -Append -Encoding ascii

        $sys = $env:SystemDrive

        if ($bNano)
        {
            try { tracelog -stop HostAgentTrace | Out-Null} catch {}
            try { del $sys\windows\Tracing\HostAgentTrace.etl | Out-Null} catch {}
            
            tracelog -start HostAgentTrace -f $sys\windows\Tracing\HostAgentTrace.etl -guid $guids -flag $flags -level $level -cir 100 -b 10000
        }
        else
        {
            try { logman stop HostAgentTrace | Out-Null} catch {}
            try { logman delete HostAgentTrace | Out-Null} catch {}

            Write-Host "logman create trace HostAgentTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\HostAgentTrace"
            logman create trace HostAgentTrace -pf $guids -bs 10000 -f bincirc -Max 100 --v -ow -o $sys\windows\Tracing\HostAgentTrace

            Write-Host "logman start HostAgentTrace"
            logman start HostAgentTrace
        }
    }
    RemovePSSession $psSession
}

function StartLogmanNC
{
    param($node, $credential)
    $psSession = GetPSSession $node $credential
    if($psSession -eq $null)
    {
        Write-Host "Cannot connect to NC Node " $node
        return
    }

    Write-Host "Enabling Logging on NC Node " $node

    Invoke-Command -Session $psSession -ScriptBlock{
        $flags=0x0

        #Critical = 1, Error = 2, Warning = 3, Information = 4, Verbose = 5
        $level=3

        $guids = (pwd).path+"\guids.txt"

        # FrameworkProvider
        Out-File -InputObject "{80355850-c8ed-4336-ade2-6595f9ca821d} $flags $level" -FilePath $guids -Encoding ascii
        # SlbManagerServiceProvider
        Out-File -InputObject "{d304a717-2718-4580-a155-458f8ac12091} $flags $level" -FilePath $guids -Append -Encoding ascii
        # TopologyServiceProvider
        Out-File -InputObject "{90399F0C-AE84-49AF-B46A-19079B77B6B8} $flags $level" -FilePath $guids -Append -Encoding ascii
        # SlbMuxServiceProvider
        Out-File -InputObject "{6c2350f8-f827-4b74-ad0c-714a92e22576} $flags $level" -FilePath $guids -Append -Encoding ascii
        # FirewallServiceProvider
        Out-File -InputObject "{ea2e4e95-2b14-462d-bb78-dee94170804f} $flags $level" -FilePath $guids -Append -Encoding ascii
        # SDNMonServiceProvider
        Out-File -InputObject "{d79293d5-78ba-4687-8cef-4492f1e3abf9} $flags $level" -FilePath $guids -Append -Encoding ascii
        # SDNFNMServiceProvider
        Out-File -InputObject "{77494040-1F07-499D-8553-03DB545C031C} $flags $level" -FilePath $guids -Append -Encoding ascii
        # VSwitchServiceProvider
        Out-File -InputObject "{5C8E3932-E6DF-403D-A3A3-EC6BF6D7977D} $flags $level" -FilePath $guids -Append -Encoding ascii
        # ApiServiceProvider
        Out-File -InputObject "{A1EA8728-5700-499E-8FDD-64954D8D3578} $flags $level" -FilePath $guids -Append -Encoding ascii
        # GatewayManagerProvider
        Out-File -InputObject "{8B0C6DD7-B6D8-48C2-B83E-AFCBBA5B57E8} $flags $level" -FilePath $guids -Append -Encoding ascii
        # ServiceInsertionProvider
        Out-File -InputObject "{C755849B-CF02-4F21-B82B-D92D26A91069} $flags $level" -FilePath $guids -Append -Encoding ascii
        # HelperServiceProvider
        Out-File -InputObject "{f1107188-2054-4758-8a89-8fe5c661590f} $flags $level" -FilePath $guids -Append -Encoding ascii
        # DeploymentProvider
        Out-File -InputObject "{93e14ac2-289b-45b7-b654-db51e293bf52} $flags $level" -FilePath $guids -Append -Encoding ascii

        $sys = $env:SystemDrive

        try { logman stop NetworkControllerTrace | Out-Null} catch {}
        try { logman delete NetworkControllerTrace | Out-Null} catch {}
        
        Write-Host "logman create trace NetworkControllerTrace -pf $guids -bs 10000 -f bincirc -Max 1000 --v -ow -o $sys\windows\Tracing\NetworkControllerTrace"
        logman create trace NetworkControllerTrace -pf $guids -bs 10000 -f bincirc -Max 1000 --v -ow -o $sys\windows\Tracing\NetworkControllerTrace

        Write-Host "logman start NetworkControllerTrace"
        logman start NetworkControllerTrace
    }
    RemovePSSession $psSession
}

function SetupDiagnosticsDataForGateways
{
    param($gateways, $deviceCredentials)
    Write-Host "Enabling Logging on Gateways"
    foreach($gateway in $gateways)
    {
        $credential = GetCredentialsForDevice -mgmtIp $gateway -deviceCreds $deviceCredentials
        StartLogmanGateway $gateway $credential
    }
}

function SetupDiagnosticsDataForMuxes
{
    param($muxes, $deviceCredentials)
    Write-Host "Enabling Logging on Muxes"
    foreach($mux in $muxes)
    {
        $credential = GetCredentialsForDevice -mgmtIp $mux -deviceCreds $deviceCredentials
        StartLogmanMux $mux $credential
    }
}

function SetupDiagnosticsDataForServers
{
    param($Servers, $deviceCredentials)
    Write-Host "Enabling Logging on Servers"
    foreach($Server in $Servers)
    {
        $credential = GetCredentialsForDevice -mgmtIp $Server -deviceCreds $deviceCredentials
        StartLogmanHostAgent $Server $credential
    }
}

function SetupDiagnosticsDataForNC
{
    param($nodes, $credential)
    Write-Host "Enabling Logging on NC Nodes"
    foreach($node in $nodes)
    {
        StartLogmanNC $node $credential
    }
}

function GetCredentialsForDevice
{
    param($mgmtIp, $deviceCreds)

    if ($deviceCreds)
    {
        if ($deviceCreds.ContainsKey($mgmtIp))
        {
            return $deviceCreds[$mgmtIp]
        }
        elseif($deviceCreds.ContainsKey($Script:AllDeviceCredential))
        {
            return $deviceCreds[$Script:AllDeviceCredential]
        }
    }
    return $null
}

function Insert-TimedSleep
{
    param ([Parameter(Mandatory=$True)][int] $Seconds,
           [string] $DisplayMessage = "Sleeping for some time ..."
          )

    Write-Debug "Insert-TimedSleep:Enter"

    foreach($i in (1..$Seconds)) {
        $percentage = $i / $Seconds
        $remaining = New-TimeSpan -Seconds ($Seconds - $i)

        $message = $DisplayMessage+" {0:p0} complete, remaining time {1}" -f $percentage, $remaining
        Write-Progress -Activity $message -PercentComplete ($percentage * 100)
        Start-Sleep 1
    }

    Write-Progress -Activity $message -Status "Ready" -Completed

    Write-Debug "Insert-TimedSleep:Exit"
}

#endregion

Export-ModuleMember -Function Debug-NetworkController
Export-ModuleMember -Function Get-NetworkControllerDeploymentInfo
Export-ModuleMember -Function Get-NetworkControllerManagedDevices