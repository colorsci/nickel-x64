
Import-Module $PSScriptRoot\Utility.psm1

function Get-Result {

param (
    [Parameter(Mandatory=$true)]
    [Int32]
    $ErrorCode,

    [Parameter(Mandatory=$true)]
    [String]
    $SuccessMessage,

    [Parameter(Mandatory=$true)]
    [String]
    $FailureMessage
)
    $returnStr = $null
    switch($ErrorCode)
    {
        0
             {
                 Write-Verbose($SuccessMessage)
             }

        5
             {
                 $returnStr = [String]::Format("{0} {1}", $FailureMessage, (Get-ResourceString SessionAccessDenied))
             }
             
        21
             {
                 Write-Error($FailureMessage + " " + (Get-ResourceString SessionVMNotRunning))                    
             }

        1168
             {
                 $returnStr = [String]::Format("{0} {1}", $FailureMessage, (Get-ResourceString SessionNotExist))
             }

        1722
             {
                 $returnStr = [String]::Format("{0} {1}", $FailureMessage, (Get-ResourceString HostDoesNotExist))
             }

        default
             {
                 $returnStr = [String]::Format("{0} {1}: {2}.", $FailureMessage, (Get-ResourceString ErrorCode), $ErrorCode)
             }
    }
    return $returnStr
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Get-UserSession {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254076")]
[OutputType("Microsoft.RemoteDesktopServices.Management.RDUserSession[]")]
param (
    [Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $CollectionName,

    [Parameter(Mandatory=$false, Position=1)]
    [String]
    $ConnectionBroker
)
    $ConnectionBrokerInitialized = Initialize-Fqdn $ConnectionBroker -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    if ([string]::IsNullOrEmpty($ConnectionBrokerInitialized))
    {
        Write-Error (Get-ResourceString InvalidFqdn $ConnectionBroker)
        return
    }
    
    $ConnectionBroker = $ConnectionBrokerInitialized

    if (-not (Test-RemoteDesktopDeployment -RDManagementServer $ConnectionBroker))
    {
        Write-Error (Get-ResourceString DeploymentDoesNotExist $ConnectionBroker)
        return
    }

    $collAliasToNameMap=@{}

    if($CollectionName -eq $null)
    {
        $CollectionName="*"
    }

    # Get all the collections and prepare Name TO Alias map
    try
    {
        $rdvmCollections = Get-WmiObject -Class Win32_RDMSVirtualdesktopCollection -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
            -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    }
    catch
    {
        Write-Error ($_.Exception.Message)
        return
    }
    
    # Get all the collections and prepare Name TO Alias map
    try
    {
        $rdshCollections = Get-WmiObject -Class Win32_RDSHCollection -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker `
            -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    }
    catch
    {
        Write-Error ($_.Exception.Message)
        return
    }

    foreach($Collection in $CollectionName)
    {
        $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $Collection, IgnoreCase
        $WildCardMatchesVm = ($rdvmCollections | Where-Object { $WildCard.IsMatch($_.Name) })
        $WildCardMatchesSh = ($rdshCollections | Where-Object { $WildCard.IsMatch($_.Name) })

        if($null -ne $WildCardMatchesVm)
        {
            foreach($match in $WildCardMatchesVm)
            {
                if(-not $collAliasToNameMap.ContainsKey($match.Alias))
                {
                    $collAliasToNameMap.Add($match.Alias, $match.Name)
                }
            }
        }

        if($null -ne $WildCardMatchesSh)
        {
            foreach($match in $WildCardMatchesSh)
            {
                if(-not $collAliasToNameMap.ContainsKey($match.Alias))
                {
                    $collAliasToNameMap.Add($match.Alias, $match.Name)
                }
            }
        }

        if(($null -eq $WildCardMatchesVm) -and ($null -eq $WildCardMatchesSh))
        {
            if(-not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Collection))
            {
                Write-Error (Get-ResourceString CollectionDoesNotExist $Collection)
            }
            else
            {
                Write-Verbose (Get-ResourceString WrnWildcardNoMatches $Collection)
            }
        }
    }

    $wmiQuery = "SELECT * FROM Win32_SessionDirectorySessionEx"
    
    try
    {
        $UserSessions = Get-WmiObject -ErrorAction Stop -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Impersonation Impersonate `
            | Where-Object { $collAliasToNameMap.ContainsKey($_.CollectionAlias) } `
            | ForEach-Object {
                            New-Object Microsoft.RemoteDesktopServices.Management.RDUserSession `
                                -ArgumentList $_.ServerName, $_.SessionId, $_.UserName, $_.DomainName, $_.ServerIPAddress, $_.TSProtocol, `
                                $_.ApplicationType, $_.ResolutionWidth, $_.ResolutionHeight, $_.ColorDepth, $_.CreateTime, $_.DisconnectTime, $_.SessionState, `
                                $collAliasToNameMap[$_.CollectionAlias], $_.CollectionType, $_.UnifiedSessionId, $_.HostServer, $_.IdleTime, $_.RemoteFxEnabled
                         }

        if($UserSessions.Count -ne 0)
        {
            $UserSessions
        }
        else
        {
            Write-Verbose (Get-ResourceString NoUserSessionFound)
        }
    }
    catch
    {
        Write-Error (Get-ResourceString GetSdSessionWmiError $ConnectionBroker)
        return
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Send-UserMessage {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254077")]
param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [String]
    $HostServer,

    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
    [Int32]
    $UnifiedSessionID,

    [Parameter(Mandatory=$true, Position=2)]
    [String]
    $MessageTitle,

    [Parameter(Mandatory=$true, Position=3)]
    [String]
    $MessageBody
)
    $ErrorCode = [Microsoft.RemoteDesktopServices.Management.WTSSessionManagement]::SendMessage( `
              $HostServer, $UnifiedSessionId, $MessageTitle, $MessageBody)

    $ResultStr = Get-Result -ErrorCode $ErrorCode -SuccessMessage (Get-ResourceString MessageSendSuccess) -FailureMessage (Get-ResourceString MessageSendFailure)
    if($ResultStr -ne $null)
    {
        Write-Error $ResultStr
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Invoke-UserLogoff {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254078")]
param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [String]
    $HostServer,

    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
    [Int32]
    $UnifiedSessionID,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)
    $promptMsg = (Get-ResourceString LogoffUsrSessionMsg $UnifiedSessionID,$HostServer)
    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    $ErrorCode = [Microsoft.RemoteDesktopServices.Management.WTSSessionManagement]::LogoffSession($HostServer, $UnifiedSessionId)

    $ResultStr = Get-Result -ErrorCode $ErrorCode -SuccessMessage (Get-ResourceString SessionLogoffSuccess) -FailureMessage (Get-ResourceString SessionLogoffFailure)
    if($ResultStr -ne $null)
    {
        Write-Error $ResultStr
    }
}

# .ExternalHelp RemoteDesktop.psm1-help.xml
function Disconnect-User {
[CmdletBinding(HelpURI="https://go.microsoft.com/fwlink/?LinkId=254079")]
param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [String]
    $HostServer,

    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
    [Int32]
    $UnifiedSessionID,

    [Parameter(Mandatory=$false)]
    [switch]
    $Force
)
    $promptMsg = (Get-ResourceString DisconUsrSessionMsg $UnifiedSessionID,$HostServer)
    if( (-not $Force) -and (-not $PSCmdlet.ShouldContinue($promptMsg, (Get-ResourceString PromptCaption))))
    {
        return
    }

    $ErrorCode = [Microsoft.RemoteDesktopServices.Management.WTSSessionManagement]::DisconnectSession($HostServer, $UnifiedSessionId)
    $ResultStr = Get-Result -ErrorCode $ErrorCode -SuccessMessage (Get-ResourceString SessionDisconnectSuccess) -FailureMessage (Get-ResourceString SessionDisconnectFailure)
    if($ResultStr -ne $null)
    {
        Write-Error $ResultStr
    }
}
