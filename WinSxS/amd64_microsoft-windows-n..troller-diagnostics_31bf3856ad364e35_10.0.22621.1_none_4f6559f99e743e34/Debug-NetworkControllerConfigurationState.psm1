# Copyright (C) Microsoft Corporation.  All rights reserved.

function Debug-NetworkControllerConfigurationState
{
    [CmdletBinding()]
    Param (
        [string]
        [parameter(Mandatory = $true)]
        $NetworkController,
        [string]
        [parameter(Mandatory = $false)]
        $ResourceId="",
        [string]
        [parameter(Mandatory = $false)]
        $ResourceType="",
        [System.Management.Automation.PSCredential]
        [parameter(Mandatory=$false)]
        $Credential = $null,
        [String]
        [parameter(Mandatory=$false)]
        $RestURI = $null,
        [String]
        [parameter(Mandatory=$false)] 
        $CertificateThumbprint = $null
        )

    $headers = @{"Accept"="application/json"}
    $content = "application/json; charset=UTF-8"
    $network = "https://$($NetworkController)/Networking/v1"
    $timeout = 10
    $method = "Get"

    $ncInfo = Get-NetworkControllerDeploymentInfo -NetworkController $NetworkController -Credential $Credential -RestURI $RestURI -CertificateThumbprint $CertificateThumbprint
    $NCURL = $ncInfo.NetworkControllerURI
    $clientCert = $ncInfo.ClientCert

    $resTypes = @("accessControlLists", "servers", "virtualNetworks", "networkInterfaces", "virtualGateways", "loadbalancerMuxes", "Gateways")
   
    if ([string]::IsNullOrEmpty($ResourceType) -eq $false)
    {
        $resTypes = @("$($ResourceType)");
    }

    foreach ($resType in $resTypes)
    {
        try
        {

            if($clientCert -ne $null)
            {
               $resources = Invoke-RestMethod -Headers $headers -ContentType $content -Method $method -Uri $network/$resType -DisableKeepAlive -UseBasicParsing -CertificateThumbprint $clientCert
            }
            elseif($credential -ne $null)
            {
                $resources = Invoke-RestMethod -Headers $headers -ContentType $content -Method $method -Uri $network/$resType -DisableKeepAlive -UseBasicParsing -Credential $credential 
            }
            else
            {
               $resources = Invoke-RestMethod -Headers $headers -ContentType $content -Method $method -Uri $network/$resType -DisableKeepAlive -UseBasicParsing
            }

            Write-Output "Fetching ResourceType:     $($resType)";
            
            foreach ($resource in $resources.value)
            {

                if ([string]::IsNullOrEmpty($ResourceId) -eq $false)
                {
                    if ([string]::Compare($ResourceId, $resource.resourceId) -ne 0)
                    {
                        continue;
                    }
                }

                $fullUri = $network + $resource.resourceRef

                if($clientCert -ne $null)
                {
                    $a = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $fullUri -DisableKeepAlive -UseBasicParsing  -CertificateThumbprint $clientCert
                }
                elseif($credential -ne $null)
                {
                    $a = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $fullUri -DisableKeepAlive -UseBasicParsing  -Credential $credential 
                }
                else
                {
                    $a = Invoke-WebRequest -Headers $headers -ContentType $content -Method $method -Uri $fullUri -DisableKeepAlive -UseBasicParsing 
                }

                $myObj =  $a.Content | ConvertFrom-Json
                
                if ($myObj -ne $null)
                {
                    if ($myObj.properties.ConfigurationState -ne $null)
                    {
                        if($myObj.properties.ConfigurationState.Status -eq "Success")
                        {
                            continue;
                        }

                        Write-Output "---------------------------------------------------------------------------------------------------------";
                        Write-Output "ResourcePath:     $($fullUri)";
                        Write-Output "Status:           $($myObj.properties.ConfigurationState.Status)";

                        if ($myObj.properties.ConfigurationState.detailedInfo -ne $null)
                        {
                            foreach($errorInfo in $myObj.properties.ConfigurationState.detailedInfo)
                            {
                                Write-Output " "   
                                Write-Output "Source:           $($errorInfo.source)";
                                Write-Output "Code:             $($errorInfo.code)";
                                Write-Output "Message:          $($errorInfo.message)";
                            }
                        }

                        Write-Output "----------------------------------------------------------------------------------------------------------";
                    }
                }

            }
        }
        catch
        {
            Write-Host $_
        }
    }
}

Export-ModuleMember -Function Debug-NetworkControllerConfigurationState