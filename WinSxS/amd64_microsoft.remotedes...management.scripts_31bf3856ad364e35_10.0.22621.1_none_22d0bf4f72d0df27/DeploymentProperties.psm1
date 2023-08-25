
Import-Module $PSScriptRoot\Utility.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-LicenseConfiguration {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254063")]
[OutputType("Microsoft.RemoteDesktopServices.Management.LicensingSetting[]")]
param (

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker

)

    $userContext = Get-BoundParameter $PSBoundParameters "Credential"

    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker @userContext))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    
    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -ComputerName $ConnectionBroker -EnableNetworkAccess

    $LicenseSettings = Invoke-Command -Session $M3PSession `
    {     
        RDManagement\Get-LicenseSettings -ManagementServer .
    } -ErrorVariable GetRDCertErrors -WarningAction SilentlyContinue 

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }  

    $LicenseSettings | ForEach-Object {
        New-Object Microsoft.RemoteDesktopServices.Management.LicensingSetting `
        -ArgumentList $_.LicenseMode, $_.LicenseServers
        }
}

function Test-LicenseServer {

param (

    [Parameter(Mandatory=$true)]
    [string]
    $Server
    
)

    $service = Get-WmiObject -Namespace root\cimv2 -ComputerName $Server -Authentication PacketPrivacy -Class Win32_Service -Filter "Name = 'TermServLicensing'" -ErrorAction SilentlyContinue
    if ($service)
    {
        return $true
    }
    
    
    $service = Invoke-Command -ComputerName $Server -ScriptBlock {Get-WmiObject -Namespace root\cimv2 -Class Win32_Service -Filter "Name = 'TermServLicensing'"} -ErrorAction SilentlyContinue
    if ($service)
    {
        return $true
    }
    
    $false
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-LicenseConfiguration {
[cmdletBinding(DefaultParameterSetName="ModePS",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254064")]
param (

    [Parameter(Mandatory=$true,ParameterSetName="ModePS")]
    [Parameter(Mandatory=$true, ParameterSetName="BothPS")]
    [Microsoft.RemoteDesktopServices.Management.LicensingMode]
    $Mode,
    
    [Parameter(Mandatory=$true, ParameterSetName="LicenseServerPS")]
    [Parameter(Mandatory=$true, ParameterSetName="BothPS")]
    [AllowEmptyCollection()]
    [string[]]
    $LicenseServer = @(),
    
    [Parameter(Mandatory=$false)]
    [switch]
    $Force,
    
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker

)

    # Validate Parameters
    if ($Mode -eq [Microsoft.RemoteDesktopServices.Management.LicensingMode]::NotConfigured)
    {
        Write-Error (Get-ResourceString InvalidLicensingMode)
        return
    }

    $message = Get-ResourceString WarnChangingLicenseSettingsMessage

    if((-not $Force) -and !$PSCmdlet.ShouldContinue($message,""))
    {
        return
    }
    
    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker @userContext))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $licenseSetting = Get-LicenseConfiguration -ConnectionBroker $ConnectionBroker
   
    $optionalParameters = Get-BoundParameter $PSBoundParameters @{"Mode" = "LicenseMode"; "LicenseServer" = "LicenseServers"; "Credential" = "PSCredential"}

    $ModeSpecified = $optionalParameters["LicenseMode"]

    if (-not $ModeSpecified)
    {
        if ($licenseSetting.Mode -eq [Microsoft.RemoteDesktopServices.Management.LicensingMode]::NotConfigured)
        {
            Write-Error (Get-ResourceString LicensingModeNotConfigured)
            return
        }
    
        $optionalParameters["LicenseMode"] = $licenseSetting.Mode
    }
    
    if ((-not $Force) -and ($LicenseServer.Count -ne 0))
    {
        $invalidServer = @($LicenseServer | ?{-not (Test-LicenseServer $_)})
        if ($invalidServer)
        {
            $message = Get-ResourceString InvalidLicenseServer ($invalidServer -join ",")
            $caption = Get-ResourceString PromptCaption
            if(!$PSCmdlet.ShouldContinue($message, $caption))
            {
                return
            }
        }
    }

    #If Mode is provided but LicenseServer is not provided then load the license servers value from RDMS DB. Only LicenseServer empty list is used without specifying Mode will clear the license servers
    if($ModeSpecified -and (-not $optionalParameters["LicenseServers"]) -and $licenseSetting.LicenseServer.Count -gt 0)
    {
        $optionalParameters["LicenseServers"] = $licenseSetting.LicenseServer
    }
  
    $tempProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"

    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

    $LicenseSettings = Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker, $optionalParameters)`
    {     
        param($ConnectionBroker, $optionalParameters)
        RDManagement\Set-LicenseSettings -ManagementServer $ConnectionBroker @optionalParameters
    } -ErrorVariable SetRDLicensingErrors -WarningAction SilentlyContinue 

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }  
   
    $ProgressPreference = $tempProgressPreference
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-DeploymentGatewayConfiguration {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254065")]
[OutputType("Microsoft.RemoteDesktopServices.Management.CustomGatewaySettings")]
[OutputType("Microsoft.RemoteDesktopServices.Management.GatewaySettings")]
param (
    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker
)
    #
    # validate that ConnectionBroker is a valid RDMS server
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
        try
        {
            $gatewayUsageRes = Invoke-WmiMethod -Class "Win32_RDMSDeploymentSettings" -Namespace "root\cimv2\rdms" `
                                                -Name "GetInt32Property" -ArgumentList @("DeploymentGatewayUsage") `
                                                -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop
            if ($gatewayUsageRes.ReturnValue -ne 0 ) {
                Write-Error ( Get-ResourceString GetGatewayUsageFailed $gatewayUsageRes.ReturnValue)
                return   
            }
            
            $gatewayUsage = $gatewayUsageRes.Value
        }
        catch [System.Management.ManagementException]
        {
            # An exception is expected if the property has not been set yet
            $gatewayUsage = 0
        }                    
        
        try
        {
            $gatewayNameRes = Invoke-WmiMethod -Class "Win32_RDMSDeploymentSettings" -Namespace "root\cimv2\rdms" `
                                               -Name "GetStringProperty" -ArgumentList @("DeploymentGatewayName") `
                                               -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

            if ($gatewayNameRes.ReturnValue -ne 0) {
                Write-Error ( Get-ResourceString GetGatewayNameFailed $gatewayNameRes.ReturnValue)
                return
            }
            
            $gatewayName = $gatewayNameRes.Value
        }
        catch [System.Management.ManagementException]
        {
            # An exception is expected if the property has not been set yet
            $gatewayName = ""
        }
        
        try
        {
            $authModeRes = Invoke-WmiMethod -Class "Win32_RDMSDeploymentSettings" -Namespace "root\cimv2\rdms" `
                                            -Name "GetInt32Property" -ArgumentList @("DeploymentGatewayAuthMode") `
                                            -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

            if ($authModeRes.ReturnValue -ne 0) {
                Write-Error ( Get-ResourceString GetGatewayAuthModeFailed $authModeRes.ReturnValue)
                return
            }
            
            $authMode = $authModeRes.Value
        }
        catch [System.Management.ManagementException]
        {
            # An exception is expected if the property has not been set yet
            $authMode = 0
        }
        
        try
        {
            $useCachedCredsRes = Invoke-WmiMethod -Class "Win32_RDMSDeploymentSettings" -Namespace "root\cimv2\rdms" `
                                                  -Name "GetInt32Property" -ArgumentList @("DeploymentGatewayUseCachedCreds") `
                                                  -ComputerName $ConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop

            if ($useCachedCredsRes.ReturnValue -ne 0) {
                Write-Error ( Get-ResourceString GetGatewayUseCachedCredsFailed $useCachedCredsRes.ReturnValue)
                return
            }
            
            $useCachedCreds = $useCachedCredsRes.Value
        }
        catch [System.Management.ManagementException]
        {
            # An exception is expected if the property has not been set yet
            $useCachedCreds = 0
        }
    }
    catch
    {
        Write-Error (Get-ResourceString GetGatewayPropertiesWmiError $_)
        return
    }
    
    $bypassLocal = $false
                      
    if($gatewayUsage -eq 1)
    {
        $gatewayUsage = 2
        $bypassLocal = $true
    }
    
    if($gatewayUsage -eq [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom)
    {
        New-Object Microsoft.RemoteDesktopServices.Management.CustomGatewaySettings `
            -ArgumentList $gatewayUsage, $gatewayName, $authMode, $useCachedCreds, $bypassLocal
    }
    else # mode is Automatic or DoNotUse
    {
        New-Object Microsoft.RemoteDesktopServices.Management.GatewaySettings `
            -ArgumentList $gatewayUsage
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-DeploymentGatewayConfiguration {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254066")]
param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateSet(
     [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::DoNotUse,
     [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom,
     [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Automatic
     )]
     [Microsoft.RemoteDesktopServices.Management.GatewayUsage]
    $GatewayMode,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [string]
    $GatewayExternalFqdn,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Microsoft.RemoteDesktopServices.Management.GatewayAuthMode]
    $LogonMethod,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $UseCachedCredentials,
    
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [bool]
    $BypassLocal,

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
    
    $message = Get-ResourceString WarnChangingGatewaySettingsMessage

    if((-not $Force) -and !$PSCmdlet.ShouldContinue($message,""))
    {
        return
    }
      
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }    

    if (-not [System.String]::IsNullOrEmpty($GatewayExternalFqdn))
    {
        if (-not (Test-Fqdn($GatewayExternalFqdn))) {
            Write-Error (Get-ResourceString InvalidServerNameFormat $GatewayExternalFqdn )
            return
        }
    }
    
    $expectedCustomSettings = @{"GatewayExternalFqdn" = "GatewayExternalFqdn"; "LogonMethod" = "LogonMethod"; "UseCachedCredentials" = "UseCachedCredentials"; "BypassLocal" = "BypassLocal" }
    $customSettings = Get-BoundParameter $PSBoundParameters $expectedCustomSettings
    
    if (($GatewayMode -ne [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom) -and ($customSettings.Count -gt 0))
    {
        $disallowedProperties = $expectedCustomSettings.Keys -Join ", "
        Write-Error (Get-ResourceString ErrorCustomGatewayProperties $GatewayMode, $disallowedProperties)
        return
    }
    elseif (($GatewayMode -eq [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom) -and ($customSettings.Count -ne $expectedCustomSettings.Count))
    {
        $requiredProperties = $expectedCustomSettings.Keys -Join ", "
        Write-Error (Get-ResourceString ErrorMissingCustomGatewayProperties $requiredProperties)
        return
    }

    [int]$actualGatewayMode = $GatewayMode
    if(($GatewayMode -eq 2) -and $BypassLocal)
    {
        $actualGatewayMode = 1
    }
    
    $actualCustomSettings = $customSettings = Get-BoundParameter $PSBoundParameters @{"GatewayExternalFqdn" = "GatewayName"; "LogonMethod" = "GatewayAuthMode"; "UseCachedCredentials" = "GatewayUseCachedCredentials" }

    try
    {
        $workflowSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $workflowSession -ArgumentList @($ConnectionBroker, $actualGatewayMode, $actualCustomSettings) `
        {
            param($ConnectionBroker, $actualGatewayMode, $actualCustomSettings) 
            RDManagement\Set-RDPGatewaySetting -RDMSServer $ConnectionBroker -GatewayUsage $actualGatewayMode @actualCustomSettings
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
