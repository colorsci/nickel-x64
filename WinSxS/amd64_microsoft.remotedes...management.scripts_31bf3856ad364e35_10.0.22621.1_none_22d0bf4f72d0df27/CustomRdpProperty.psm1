Import-Module $PSScriptRoot\Utility.psm1

function Get-CollectionCustomRdpProperty {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)
    # All input parameters are validated in the caller
    # We can assume that all of the connection brokers have the same custom RDP properties (if not, the system is misconfigured), so we only have to query one of them
    try 
    {
        $wmiObj = Get-WmiObject -Namespace "root\cimv2\TerminalServices" -Class Win32_RDCentralPublishedDeploymentSettings -Filter "PublishingFarm='$CollectionAlias'" `
                                -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    } 
    catch 
    { 
        throw (Get-ResourceString GetCustomRdpPropertiesWmiError $CollectionName, $_)
    }

    if ($wmiObj -eq $null) 
    {
	    throw (Get-ResourceString GetCustomRdpPropertiesInvalidCollectionError $CollectionName)
    } 
    
    return $wmiObj.CustomRDPSettings
}

function Set-CollectionCustomRdpProperty {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [string]
    $CustomRdpProperty,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)
    # All input parameters except $CustomRdpProperty are validated in the caller

    $brokerList = Get-RDServer -ConnectionBroker $ConnectionBroker -Role RDS-CONNECTION-BROKER

    if (-not $brokerList) 
    {
        throw (Get-ResourceString GetListOfConnectionBrokersFailed)
    }
    
    Test-CanSetCustomRdpProperty -CollectionName $CollectionName -CollectionAlias $CollectionAlias -ConnectionBroker $brokerList.Server
    # Throws an error if the test fails, let the caller handle it.

    $commonParams = Get-BoundParameter $PSBoundParameters @{"CollectionName"="CollectionName"; "CollectionAlias"="CollectionAlias"; "CustomRdpProperty"="CustomRdpProperty"}

    $errors = @()

    foreach ($broker in $brokerList) 
    {
        try
        {
            Set-CollectionCustomRdpPropertyOnBroker -ConnectionBroker $broker.Server @commonParams
        }
        catch
        {
            # We should try and update as many brokers as possible
            $errors += $_
        }
    }
    
    return $errors
}

function Test-CanSetCustomRdpProperty {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,
    
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [string[]]
    $ConnectionBroker
)

    # All input parameters are validated in the caller
    $offlineBrokers = @()
    $misconfiguredBrokers = @()

    foreach ($broker in $ConnectionBroker) 
    {
        # Test if the broker WMI is up
        try 
        {
            $wmiObj = Get-WmiObject -Namespace "root\cimv2\TerminalServices" -Class Win32_RDCentralPublishedDeploymentSettings -Filter "PublishingFarm='$CollectionAlias'" `
                                    -ComputerName $broker -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
        } 
        catch 
        { 
            # WMI Error - assume the broker is offline
            Write-Debug (Get-ResourceString GetCustomRdpPropertiesWmiError $CollectionName, $_)
            $offlineBrokers += $broker
            continue
        }

        if ($wmiObj -eq $null) 
        {
    	    # Missing collection - the broker is misconfigured
            Write-Debug (Get-ResourceString GetCustomRdpPropertiesInvalidCollectionError $CollectionName)
            $misconfiguredBrokers += $broker
            continue
        } 
    }
    
    if (($offlineBrokers.Length -gt 0) -or ($misconfiguredBrokers.Length -gt 0))
    {
        throw (Get-ResourceString SetCustomRdpPropertiesInvalidBrokers $CollectionName, ([System.String]::Join(", ", $offlineBrokers)), ([System.String]::Join(", ", $misconfiguredBrokers)))
    }
}

function Update-AllCollectionsCustomRdpPropertiesOnBroker {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $NewConnectionBroker,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ExistingConnectionBroker 
)
    # Parameters are validated in the caller
    
    $maxTotalWaitInMinutes = 5
    $maxWaitBetweenRetriesInSeconds = 30
    
    $endTime = (Get-Date).AddMinutes($maxTotalWaitInMinutes)

    $wasSuccessful = $false
    $attempts = 0;
    while ((Get-Date) -lt $endTime)
    {
        $attempts++
    
        try
        {
            $rdshCollections = @(Get-WmiObject Win32_RDSHCollection -Namespace root\cimv2\Rdms -ComputerName $ExistingConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop)
            $vmCollections = @(Get-WmiObject Win32_RDMSVirtualDesktopCollection -Namespace root\cimv2\Rdms -ComputerName $ExistingConnectionBroker -Authentication PacketPrivacy -ErrorAction Stop)            
        }
        catch
        {
            throw (Get-ResourceString LookupCollectionWmiError $_)
        }

        try
        {    
            foreach($coll in $rdshCollections)
            {
                Write-Verbose (Get-ResourceString UpdatingCollectionCustomRdpPropertyOnBroker $coll.Name, $NewConnectionBroker)
                $customRdpProperty = Get-CollectionCustomRdpProperty -CollectionName $coll.Name -CollectionAlias $coll.Alias -ConnectionBroker $ExistingConnectionBroker
                Set-CollectionCustomRdpPropertyOnBroker -CollectionName $coll.Name -CollectionAlias $coll.Alias -CustomRdpProperty $customRdpProperty -ConnectionBroker $NewConnectionBroker
            }
        }
        catch
        {                
            Write-Debug(Get-ResourceString SetCollectionCustomRdpPropertyFailure $NewConnectionBroker, $attempts, $_)
            Start-Sleep -Seconds ([math]::min([math]::pow(2,$attempts), $maxWaitBetweenRetriesInSeconds))
            continue
        }

        try
        { 
            foreach($coll in $vmCollections)
            {
                Write-Verbose (Get-ResourceString UpdatingCollectionCustomRdpPropertyOnBroker $coll.Name, $NewConnectionBroker)
                $customRdpProperty = Get-CollectionCustomRdpProperty -CollectionName $coll.Name -CollectionAlias $coll.Alias -ConnectionBroker $ExistingConnectionBroker
                Set-CollectionCustomRdpPropertyOnBroker -CollectionName $coll.Name -CollectionAlias $coll.Alias -CustomRdpProperty $customRdpProperty -ConnectionBroker $NewConnectionBroker
            }
        }
        catch
        {                                
            Write-Debug(Get-ResourceString SetCollectionCustomRdpPropertyFailure $NewConnectionBroker, $attempts, $_)
            Start-Sleep -Seconds ([math]::min([math]::pow(2,$attempts), $maxWaitBetweenRetriesInSeconds))
            continue
        }
        
        # If we get here, then we have successfully written to every collection
        $wasSuccessful = $true
        break
    }

    if (!$wasSuccessful)
    {
        throw (Get-ResourceString UpdateCustomRdpPropertyFailure $NewConnectionBroker)
    }
}

function Set-CollectionCustomRdpPropertyOnBroker {

param (
    [Parameter(Mandatory=$true)]
    [string]
    $CollectionName,

    [Parameter(Mandatory=$true)]
    [string]
    $CollectionAlias,
    
    [Parameter(Mandatory=$true)]
    [string]
    $CustomRdpProperty,
    
    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionBroker
)
    # All input parameters are validated in caller
    
    try 
    {
        $wmiObj = Get-WmiObject -Namespace "root\cimv2\TerminalServices" -Class Win32_RDCentralPublishedDeploymentSettings -Filter "PublishingFarm='$CollectionAlias'" `
                                -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop
    } 
    catch 
    { 
        throw (Get-ResourceString SetCustomRdpPropertiesWmiError $CollectionName, $ConnectionBroker, $_)
    }

    if ($wmiObj -eq $null) 
    {
	    throw (Get-ResourceString SetCustomRdpPropertiesInvalidCollectionError $CollectionName, $ConnectionBroker)
    }
    
    # Make sure that the RDP string ends with a newline (the rest of the system assumes it does when other values are appended)
    if (!$CustomRdpProperty.EndsWith("`n"))
    {
        $CustomRdpProperty += "`n"
    }
    
    # Users are not allowed to remove "use redirection server name" property from the custom RDP properties, add it back in if they try
    $requiredProperty = "use redirection server name"
    if ($wmiObj.CustomRDPSettings.ToLower().Contains($requiredProperty) -and !$CustomRdpProperty.ToLower().Contains($requiredProperty))
    {
        $CustomRdpProperty += "use redirection server name:i:1`n"
    }
    
    $wmiObj.CustomRDPSettings = $CustomRdpProperty
    
    try
    {
        $wmiObj.Put() | Out-Null
    }
    catch
    {
        throw (Get-ResourceString SetCustomRdpPropertiesWmiError $CollectionName, $ConnectionBroker, $_)
    }
    
    Write-Verbose (Get-ResourceString SetCustomRdpPropertiesForBrokerSuccess $ConnectionBroker)
}