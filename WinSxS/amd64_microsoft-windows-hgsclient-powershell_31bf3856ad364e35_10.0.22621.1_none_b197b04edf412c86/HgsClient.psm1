$script:regKey_HgsClient = "HKLM:\SOFTWARE\Microsoft\HgsClient"
$script:regValue_HostKeyThumbprint = "HostKeyThumbprint"
$script:regValue_HostKeyGenerated = "HostKeyGenerated"
$script:certStore_localMachineMy = "Cert:\LocalMachine\My"
$script:cert_subject = "HGS Client Host Key"
$script:cert_keyAlgorithm = "RSASSA-PSS"
$script:hostKey_generated = 1
$script:hostKey_provided = 2
$script:eventLog_provider = "Microsoft-Windows-HostGuardianService-Client"
$script:eventId_set = 5000
$script:eventId_remove = 5001

#
# Localized Data table for the format strings
#
Import-LocalizedData -BindingVariable msgTable

function Validate-UriParameter
{
    param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [String]
        $Name
    )

    # Failing due to a disallowed null URI should happen separately
    if (-not [string]::IsNullOrEmpty($Name))
    {
        New-Object System.Uri $Name
    }

    return $true
}

function New-HgsGuardian
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory=$true, ParameterSetName="AcceptCertificates")]
        [ValidateNotNullOrEmpty()]
        [String]
        $SigningCertificate,

        [Parameter(ParameterSetName="AcceptCertificates")]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $SigningCertificatePassword,

        [Parameter(Mandatory=$true, ParameterSetName="AcceptCertificates")]
        [ValidateNotNullOrEmpty()]
        [String]
        $EncryptionCertificate,

        [Parameter(ParameterSetName="AcceptCertificates")]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $EncryptionCertificatePassword,

        [Parameter(ParameterSetName="AcceptCertificates")]
        [Parameter(ParameterSetName="ByThumbprints")]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $AllowExpired,

        [Parameter(ParameterSetName="AcceptCertificates")]
        [Parameter(ParameterSetName="ByThumbprints")]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $AllowUntrustedRoot,

        [Parameter(Mandatory=$true, ParameterSetName="GenerateCertificates")]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $GenerateCertificates,

        [Parameter(Mandatory=$true, ParameterSetName="ByThumbprints")]
        [ValidateNotNullOrEmpty()]
        [String]
        $SigningCertificateThumbprint,

        [Parameter(Mandatory=$true, ParameterSetName="ByThumbprints")]
        [ValidateNotNullOrEmpty()]
        [String]
        $EncryptionCertificateThumbprint
    )

    Process
    {
        if ($PSCmdlet.ShouldProcess($Name))
        {
            if ($PSCmdlet.ParameterSetName -eq "AcceptCertificates")
            {
                $SigningCertificate = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($SigningCertificate)
                $EncryptionCertificate = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($EncryptionCertificate)

                $DecryptedSigningCertificatePassword = $null
                $DecryptedEncryptionCertificatePassword = $null

                if ($SigningCertificatePassword -ne $null)
                {
                    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SigningCertificatePassword)
                    $DecryptedSigningCertificatePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($ptr)
                }

                if ($EncryptionCertificatePassword -ne $null)
                {
                    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($EncryptionCertificatePassword)
                    $DecryptedEncryptionCertificatePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($ptr)
                }

                $args = @{
                    Name                          = $Name;
                    SigningCertificate            = $SigningCertificate;
                    SigningCertificatePassword    = $DecryptedSigningCertificatePassword;
                    EncryptionCertificate         = $EncryptionCertificate;
                    EncryptionCertificatePassword = $DecryptedEncryptionCertificatePassword;
                    AllowExpired                  = $AllowExpired.IsPresent;
                    AllowUntrustedRoot            = $AllowUntrustedRoot.IsPresent;
                }

                (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName NewByAcceptCertificates -Arguments $args -Confirm:$false).CmdletOutput
            }
            elseif ($PSCmdlet.ParameterSetName -eq "ByThumbprints")
            {
                $args = @{
                    Name                            = $Name;
                    SigningCertificateThumbprint    = $SigningCertificateThumbprint;
                    EncryptionCertificateThumbprint = $EncryptionCertificateThumbprint;
                    AllowExpired                    = $AllowExpired.IsPresent;
                    AllowUntrustedRoot              = $AllowUntrustedRoot.IsPresent;
                }

                (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName NewByCertificateThumbprints -Arguments $args -Confirm:$false).CmdletOutput
            }
            elseif ($PSCmdlet.ParameterSetName -eq "GenerateCertificates")
            {
                $args = @{Name=$Name;GenerateCertificates=$GenerateCertificates.IsPresent}
                (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName NewByGenerateCertificates -Arguments $args -Confirm:$false).CmdletOutput
            }
        }
    }
}

function Export-HgsGuardian
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([void])]
    param(
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Guardian")]
        [Microsoft.Management.Infrastructure.CimInstance]
        $InputObject,

        [Parameter(ValueFromPipelineByPropertyName=$true, Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("FilePath")]
        [System.String]
        $Path
    )

    Process
    {
        $Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        $args = @{InputObject=$InputObject;Path=$Path}
        Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName Export -Arguments $args | Out-Null
    }
}

function Import-HgsGuardian
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("FilePath")]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Switch]
        $AllowExpired,

        [Switch]
        $AllowUntrustedRoot
    )

    Process
    {
        if($PSCmdlet.ShouldProcess($Name))
        {
            $Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)

            if($Name)
            {
                $args = @{AllowExpired=$AllowExpired.IsPresent;AllowUntrustedRoot=$AllowUntrustedRoot.IsPresent;Name=$Name;Path=$Path}
            }
            else
            {
                $args = @{AllowExpired=$AllowExpired.IsPresent;AllowUntrustedRoot=$AllowUntrustedRoot.IsPresent;Path=$Path}
            }

            (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName Import -Arguments $args -Confirm:$false).CmdletOutput
        }
    }
}

function Remove-HgsGuardian
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', DefaultParameterSetName='NameViaString')]
    [OutputType([System.Int32])]
    param(
        [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = "NameViaString")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$true, ParameterSetName = "NameViaGuardian")]
        [ValidateNotNullOrEmpty()]
        [Alias("Guardian")]
        [Microsoft.Management.Infrastructure.CimInstance]
        $InputObject
    )

    Process
    {
        if ($PSCmdlet.ParameterSetName -eq "NameViaGuardian")
        {
            $Name = $InputObject.Name
        }

        if($PSCmdlet.ShouldProcess($Name))
        {
            $args = @{Name = $Name}
            (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsGuardian -MethodName Remove -Arguments $args -Confirm:$false).CmdletOutput
        }
    }
}

function Grant-HgsKeyProtectorAccess
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsKeyProtector")]
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $KeyProtector,

        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, ParameterSetName="InputObject")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Guardian,

        [Parameter(Mandatory=$true, ParameterSetName="FriendlyName")]
        [ValidateNotNullOrEmpty()]
        [String]
        $GuardianFriendlyName,

        # Specifies whether allow untrusted root certificate
        [Switch]
        $AllowUntrustedRoot,

        # Specifies whether allow expired certificate
        [Switch]
        $AllowExpired
    )

    Process
    {

        if ($GuardianFriendlyName)
        {
            $Guardian = Get-HgsGuardian $GuardianFriendlyName
        }

        if($Guardian)
        {
            $args = @{KeyProtector=$KeyProtector; Guardian=$Guardian; AllowUntrustedRoot=$AllowUntrustedRoot.IsPresent; AllowExpired=$AllowExpired.IsPresent}

            (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsKeyProtector -MethodName Grant -Arguments $args).CmdletOutput
        }
    }
}

function Revoke-HgsKeyProtectorAccess
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsKeyProtector")]
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $KeyProtector,

        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, ParameterSetName="InputObject")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Guardian,

        [Parameter(Mandatory=$true, ParameterSetName="FriendlyName")]
        [ValidateNotNullOrEmpty()]
        [String]
        $GuardianFriendlyName
    )

    Process
    {
        if ($GuardianFriendlyName)
        {
            $Guardian = Get-HgsGuardian $GuardianFriendlyName
        }

        if($Guardian)
        {
            $args = @{KeyProtector=$KeyProtector; Guardian=$Guardian}

            (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsKeyProtector -MethodName Revoke -Arguments $args).CmdletOutput
        }
    }
}

function New-HgsKeyProtector
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Owner,

        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Hgs/MSFT_HgsGuardian")]
        [Parameter(ValueFromPipeline=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Guardian,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $AllowExpired,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $AllowUntrustedRoot
    )

    Process
    {
        $args = @{
            Owner                         = $Owner;
            Guardian                      = $Guardian;
            AllowExpired                  = $AllowExpired.IsPresent;
            AllowUntrustedRoot            = $AllowUntrustedRoot.IsPresent;
        }

        (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsKeyProtector -MethodName NewByGuardians -Arguments $args).CmdletOutput
    }
}

function Set-HgsClientConfiguration
{
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Medium')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [Parameter(ParameterSetName="ChangeToLocalMode")]
        [Switch]
        $EnableLocalMode,

        [Parameter(ParameterSetName="SecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName="FullSecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Validate-UriParameter -Name $_})]
        [System.String]
        $KeyProtectionServerUrl,

        [Parameter(ParameterSetName="SecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName="FullSecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Validate-UriParameter -Name $_})]
        [System.String]
        $AttestationServerUrl,

        [Parameter(ParameterSetName="FullSecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [ValidateScript({Validate-UriParameter -Name $_})]
        [System.String]
        $FallbackKeyProtectionServerUrl,

        [Parameter(ParameterSetName="FullSecureHostingServiceMode", Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [ValidateScript({Validate-UriParameter -Name $_})]
        [System.String]
        $FallbackAttestationServerUrl
    )

    Process
    {
        if ($PSCmdlet.ShouldProcess((HOSTNAME)))
        {
            if($PSCmdlet.ParameterSetName -eq "ChangeToLocalMode")
            {
                (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsClientConfiguration -MethodName SetByChangeToLocalMode -Confirm:$false).CmdletOutput
            }
            elseif($PSCmdlet.ParameterSetName -eq "SecureHostingServiceMode" -or $PSCmdlet.ParameterSetName -eq "FullSecureHostingServiceMode")
            {
                if (-not $FallbackKeyProtectionServerUrl)
                {
                    $FallbackKeyProtectionServerUrl = ""
                }

                if (-not $FallbackAttestationServerUrl)
                {
                    $FallbackAttestationServerUrl = ""
                }

                $args = @{
                    KeyProtectionServerUrl         = $KeyProtectionServerUrl;
                    AttestationServerUrl           = $AttestationServerUrl;
                    FallbackKeyProtectionServerUrl = @($FallbackKeyProtectionServerUrl);
                    FallbackAttestationServerUrl   = @($FallbackAttestationServerUrl);
                }


                (Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsClientConfiguration -MethodName SetBySecureHostingServiceMode -Arguments $args -Confirm:$false).CmdletOutput
            }
        }
    }
}

function Test-HgsClientConfiguration
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param(
        [Parameter(ParameterSetName="Primary")]
        [Switch]
        $UsePrimary,

        [Parameter(ParameterSetName="Fallback", Mandatory=$true)]
        [Switch]
        $UseFallback
    )

    Process
    {
        $clientConfiguration = Get-HgsClientConfiguration -ErrorAction Stop

        if (-not $UseFallback -or $UsePrimary)
        {
            $args = @{
                AttestationServerUrl    = $clientConfiguration.AttestationServerUrl;
            }
        }
        else
        {
            $args = @{
                AttestationServerUrl    = $clientConfiguration.FallbackAttestationServerUrl | Select -First 1;
            }
        }

        if ($args.AttestationServerUrl)
        {
            $results = Invoke-CimMethod -Namespace Root\Microsoft\Windows\Hgs -Class MSFT_HgsClientConfiguration -MethodName IsHostTrusted -Arguments $args -Confirm:$false -ErrorAction Stop

            if ($results)
            {
                [pscustomobject][ordered]@{
                    'AttestationServerUrl'      = $args.AttestationServerUrl;
                    'IsHostGuarded'             = $results.IsHostGuarded;
                    'AttestationOperationMode'  = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationOperationMode]$results.AttestationOperationMode;
                    'AttestationStatus'         = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationStatus]$results.AttestationStatus;
                    'AttestationSubstatus'      = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationSubStatus]$results.AttestationSubstatus
                }
            }
        }
        else
        {
            [pscustomobject][ordered]@{
                    'AttestationServerUrl'      = $args.AttestationServerUrl;
                    'IsHostGuarded'             = $false;
                    'AttestationOperationMode'  = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationOperationMode]::Unknown;
                    'AttestationStatus'         = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationStatus]::NotConfigured;
                    'AttestationSubstatus'      = [Microsoft.PowerShell.Cmdletization.GeneratedTypes.HgsClientConfiguration.AttestationSubStatus]::NoInformation;
                }
        }
    }
}

function Set-HgsClientHostKey
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param(
        [ValidateNotNullOrEmpty()]
        [String]
        $Thumbprint,
        
        [Switch]
        $PassThru
    )

    # Check if a host key is already set
    if (Get-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyThumbprint -ErrorAction SilentlyContinue)
    {
        Write-Error $msgTable.ErrorSetHostKeyAlreadySet -ErrorAction Stop
    }

    if (!$PSCmdlet.ShouldProcess("Set-HgsClientHostKey"))
    {
        return
    }
    
    if ($Thumbprint)
    {
        # If thumbprint was specified by the user, find the cert and update configuration
        $certificate = Get-Item "$script:certStore_localMachineMy\$Thumbprint" -ErrorAction Stop

        if(-not $certificate)
        {
            Write-Error ([string]::Format($msgTable.ErrorSetHostKeyThumbprintInvalid, $Thumbprint)) -ErrorAction Stop
        }

        Set-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyGenerated -Value $script:hostKey_provided
    }
    else
    {
        $subjectSuffix = (Get-WmiObject Win32_ComputerSystem).Name
        # If no parameters were specified by the user, create the cert and update configuration
        $certificate = New-SelfSignedCertificate -KeyAlgorithm $script:cert_keyAlgorithm -Subject "$($script:cert_subject) ($subjectSuffix)" -KeyUsage DigitalSignature -KeyUsageProperty Sign -ErrorAction Stop
        Set-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyGenerated -Value $script:hostKey_generated
    }

    # Certificate private key must be usable
    if(!($certificate.HasPrivateKey))
    {
        Write-Error ([string]::Format($msgTable.ErrorSetHostKeyMissingPrivateKey, $certificate.Thumbprint)) -ErrorAction Stop
    }

    # Update configuration indicating a host key is set (and which)
    Set-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyThumbprint -Value $certificate.Thumbprint
    New-WinEvent -ProviderName $script:eventLog_provider -Id $script:eventId_set -Payload $certificate.Thumbprint 

    if ($PassThru)
    {
        $certificate
    }
}

function Get-HgsClientHostKey
{
    [CmdletBinding(DefaultParameterSetName = "ps")]
    param(
        [Parameter(ParameterSetName = "path")]
        [ValidateNotNullOrEmpty()]
        [Alias("FilePath")]
        [String]
        $Path,

        [Parameter(ParameterSetName = "path")]
        [Switch]
        $Force
    )

    # Key was not set, so cannot be get
    if (!($thumbprint = (Get-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyThumbprint -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty $script:regValue_HostKeyThumbprint))
    {
        Write-Error $msgTable.ErrorGetHostKeyNotSet -ErrorAction Stop
    }

    try {
        $certificate = Get-Item "$script:certStore_localMachineMy\$thumbprint" -ErrorAction Stop        
    }
    catch {
        Write-Error ([string]::format($msgTable.ErrorGetHostKeyNotFound, $thumbprint)) -ErrorAction Stop
    }

    if($Path)
    {
        $additionalParams = @{}
        if (!$Force)
        {
            $additionalParams += @{NoClobber = $true}
        }

        # If path was specified, save (or utilize error) using Export-Certificate and return the FileSystemInfo object to the pipeline
        Export-Certificate -Cert $certificate -FilePath $Path -Type CERT -Force @additionalParams
    }
    else
    {
        # If path was not specified, return the certificate object to the pipeline
        $certificate
    }
}

function Remove-HgsClientHostKey
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param()
    
    if (!($thumbprint = (Get-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyThumbprint -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty $script:regValue_HostKeyThumbprint))
    {
        return
    }

    if (!$PSCmdlet.ShouldProcess("Remove-HgsClientHostKey"))
    {
        return
    }

    $generated = Get-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyGenerated -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $script:regValue_HostKeyGenerated
    Remove-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyThumbprint
    Remove-ItemProperty -Path $script:regKey_HgsClient -Name $script:regValue_HostKeyGenerated
    New-WinEvent -ProviderName $script:eventLog_provider -Id $script:eventId_remove -Payload $thumbprint 
    if ($generated -and ($generated -eq $script:hostKey_generated))
    {
        # If the certificate was generated by Set-HgsClientHostKey, delete it
        try
        {
            Remove-Item "$script:certStore_localMachineMy\$thumbprint" -ErrorAction Stop            
        }
        catch
        {
            Write-Warning $_.Exception.Message
        }
    }
    else
    {
        Write-Warning ([string]::Format($msgTable.WarningRemoveHostKeyProvided, $thumbprint))
    }
}