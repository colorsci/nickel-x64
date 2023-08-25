
Import-Module $PSScriptRoot\Utility.psm1

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-Certificate {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254046")]
[OutputType("Microsoft.RemoteDesktopServices.Management.Certificate[]")]
param (

    [Parameter(Mandatory=$false, Position=0)]
    [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
    $Role,

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

    $optionalParameters = Get-BoundParameter $PSBoundParameters "Role"   
    
    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -ComputerName $ConnectionBroker @userContext -EnableNetworkAccess

    $RDCerts = Invoke-Command -Session $M3PSession -ArgumentList @($optionalParameters)`
    {     
        param($optionalParameters )
        RDManagement\Get-RemoteDesktopCertificate @optionalParameters 
    } -ErrorVariable GetRDCertErrors -WarningAction SilentlyContinue 

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }  

    $RDCerts | ForEach-Object {

        $level =  Get-ResourceString CertificateLevelUnknown
        $Subject = $_.Subject
        $SubjectAlternateName = $_.SubjectAlternateName
        $IssuedBy = $_.IssuedBy
        $IssuedTo = $_.IssuedTo

        if($_.NotAfter -ne [DateTime]::MinValue)
        {
            $NotAfter = $_.NotAfter
        } 

        $Thumbprint = $_.Thumbprint

        if($_.Level -eq [Microsoft.RemoteDesktopServices.Common.CertificateLevel]::NotConfigured)
        {
            $level = Get-ResourceString CertificateLevelNotConfigured;
            $NotAfter = $null
        }
        if($_.Level -eq [Microsoft.RemoteDesktopServices.Common.CertificateLevel]::Untrusted)
        {
            $level = Get-ResourceString CertificateLevelUntrusted;
        }
        if($_.Level -eq [Microsoft.RemoteDesktopServices.Common.CertificateLevel]::Trusted)
        {
            $level = Get-ResourceString CertificateLevelTrusted;
        }

        if ($_.Role.value -eq "RDGateway")
        {
            $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess
            $servers = Invoke-Command -Session $M3PSession -ArgumentList @($ConnectionBroker,$optionalParams)`
            {     
                param($ConnectionBroker,$optionalParams)
                RDManagement\Get-RDMSJoinedNode -ManagementServer $ConnectionBroker -Roles RDS-GATEWAY
            } -ErrorVariable GetRDServerErrors -WarningAction SilentlyContinue 
            if($null -ne $M3PSession)
            {
                Remove-PSSession -Session $M3PSession
            } 

            if ($servers -eq $null)
            {
                $level = Get-ResourceString CertificateLevelUnknown
                $Subject = $SubjectAlternateName = $IssuedBy = $IssuedTo = $NotAfter = $Thumbprint = $null
            }
        }

        New-Object Microsoft.RemoteDesktopServices.Management.Certificate `
        -ArgumentList $Subject, $SubjectAlternateName, $IssuedBy, $IssuedTo, $NotAfter, $Thumbprint, $_.Role, $level
            
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function New-Certificate {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254047")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
    $Role,
    
    [Parameter(Mandatory=$true)]
    [string]
    $DnsName,

    [Parameter(Mandatory=$false)]
    [string]
    $ExportPath,

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]
    $Password,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)
    $userContext = Get-BoundParameter $PSBoundParameters "Credential"



    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    if ($Role -eq "RDGateway")
    {
        $gateway = Get-RDServer -ConnectionBroker $ConnectionBroker -Role @("RDS-GATEWAY")
        if ($gateway -eq $null)
        {
            Write-Error (Get-ResourceString GatewayDoesNotExist)
            return
        }
    }

    if ($Role -eq "RDWebAccess")
    {
        $webaccess = Get-RDServer -ConnectionBroker $ConnectionBroker -Role @("RDS-WEB-ACCESS")
        if ($webaccess -eq $null)
        {
            Write-Error (Get-ResourceString WebAccessDoesNotExist)
            return
        }
    }

    if (-not (Test-Fqdn -Fqdn $DnsName))
    {
        Write-Error (Get-ResourceString InvalidFqdn $DnsName)
        return                            
    }
                        
    if ($ExportPath)
    {
        if(($ExportPath.EndsWith("\")) -Or ($ExportPath.EndsWith(":")))
        {
            Write-Error (Get-ResourceString InvalidPath $ExportPath)
            return
        }
        
        if (-not (Test-FilePath -Path $ExportPath -Parent @userContext))
        {
            Write-Error (Get-ResourceString InvalidPath $ExportPath)
            return
        }
        
        $fileName = split-path $ExportPath -Leaf
        
        if( -not ($fileName.ToLower().EndsWith(".pfx")))
        {
            Write-Error (Get-ResourceString InvalidPath $ExportPath)
            return
        }
    }
        
    $params = Get-BoundParameter $PSBoundParameters @{
                        "Role" = "Role"
                        "ExportPath" = "Path"
                        "Password" = "Password"
                        "DnsName" = "Name"
                        "ConnectionBroker" = "RDManagementServer"
                        "Credential" = "PSCredential"
                        }
    
    $message = Get-ResourceString WarnCreatingAndConfiguringCertMessage $Role

    if((-not $Force) -and !$PSCmdlet.ShouldContinue($message,""))
    {
        return
    }

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker @userContext))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }
    

    $tempProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"

    $workflowSuccess = $true

    try {

        $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

        Invoke-Command -Session $M3PSession -ArgumentList @($params)`
        {     
            param($params)
            RDManagement\Set-RDCertificate @params 

        } -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null

    } catch {

        $workflowSuccess = $false

    } finally {
    
        if($null -ne $M3PSession)
        {
            Remove-PSSession -Session $M3PSession            
        }
    }

    if ($workflowSuccess) {
        Get-RDCertificate -Role $Role -ConnectionBroker $ConnectionBroker
    }  
    
    $ProgressPreference = $tempProgressPreference    
    
    return
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Set-Certificate {

[CmdletBinding(DefaultParametersetName="Reapply",
HelpURI="https://go.microsoft.com/fwlink/?LinkId=254048")]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
    $Role,
    
    [Parameter(Mandatory=$false, ParameterSetName="Import")]
    [string]
    $ImportPath,

    [Parameter(Mandatory=$false, ParameterSetName="Thumbprint")]
    [string]
    $Thumbprint,

    [Parameter(Mandatory=$false, ParameterSetName="Import")]
    [Parameter(Mandatory=$false, ParameterSetName="Reapply")]
    [System.Security.SecureString]
    $Password,

    [Parameter(Mandatory=$false)]
    [string]
    $ConnectionBroker,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)

    $userContext = Get-BoundParameter $PSBoundParameters "Credential"
    
    # Validate Parameters
    if ($Role -eq [Microsoft.RemoteDesktopServices.Common.CertificateRole]::None)
    {
        Write-Error (Get-ResourceString InvalidCertificateRole)
        return
    }

    if([string]::IsNullOrEmpty($ConnectionBroker))
    {
        $ConnectionBroker = [Microsoft.RemoteDesktopServices.Common.CommonUtility]::GetLocalhostFullyQualifiedDomainname()
    }

    if ($Role -eq "RDGateway")
    {
        $gateway = Get-RDServer -ConnectionBroker $ConnectionBroker -Role @("RDS-GATEWAY")
        if ($gateway -eq $null)
        {
            Write-Error (Get-ResourceString GatewayDoesNotExist)
            return
        }
    }

    if ($Role -eq "RDWebAccess")
    {
        $webaccess = Get-RDServer -ConnectionBroker $ConnectionBroker -Role @("RDS-WEB-ACCESS")
        if ($webaccess -eq $null)
        {
            Write-Error (Get-ResourceString WebAccessDoesNotExist)
            return
        }
    }

    switch ($PsCmdlet.ParameterSetName)
    {
        "Import"   {
                        if (($ImportPath) -and (-not (Test-FilePath -Path $ImportPath @userContext)))
                        {
                            Write-Error (Get-ResourceString InvalidPath $ImportPath)
                            return
                        }
                        if (($ImportPath) -and (-not ($ImportPath.EndsWith(".pfx"))))
                        {
                            Write-Error (Get-ResourceString InvalidPfxFile $ImportPath)
                            return
                        }
 
                        $params = Get-BoundParameter $PSBoundParameters @{
                                            "Role" = "Role"
                                            "ImportPath" = "Path"
                                            "Password" = "Password"
                                            "ConnectionBroker" = "RDManagementServer"
                                            "Credential" = "PSCredential"
                                            }
                        break
                    }
        "Reapply"   {
                        $certs = Get-RDCertificate -Role $Role -ConnectionBroker $ConnectionBroker
                        $levelNotconfigured = Get-ResourceString CertificateLevelNotConfigured
                        if ($certs.Level -eq $levelNotconfigured)
                        {
                            Write-Error (Get-ResourceString CertificateNotConfigured $Role)
                            return
                        }
                        
                        $params = Get-BoundParameter $PSBoundParameters @{
                                            "Role" = "Role"
                                            "Password" = "Password"
                                            "ConnectionBroker" = "RDManagementServer"
                                            "Credential" = "PSCredential"
                                            }
                        break
                    }

        "Thumbprint" {
                        $params = Get-BoundParameter $PSBoundParameters @{
                                            "Role" = "Role"
                                            "Thumbprint" = "Thumbprint"
                                            "ConnectionBroker" = "RDManagementServer"
                                            "Credential" = "PSCredential"
                                            }
                        break
                    }
    }
    
    
    $message = Get-ResourceString WarnConfiguringCertMessage $Role

    if((-not $Force) -and !$PSCmdlet.ShouldContinue($message,""))
    {
        return
    }
        
    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker @userContext))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }
    

    $tempProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"

    $M3PSession = New-PSSession -ConfigurationName Microsoft.Windows.ServerManagerWorkflows -EnableNetworkAccess

    Invoke-Command -Session $M3PSession -ArgumentList @($params)`
    {     
        param($params)
        RDManagement\Set-RDCertificate @params 

    } -ErrorVariable errors -WarningAction SilentlyContinue | Out-Null

    if($null -ne $M3PSession)
    {
        Remove-PSSession -Session $M3PSession
    }  
    
    $ProgressPreference = $tempProgressPreference
    
    return

}
