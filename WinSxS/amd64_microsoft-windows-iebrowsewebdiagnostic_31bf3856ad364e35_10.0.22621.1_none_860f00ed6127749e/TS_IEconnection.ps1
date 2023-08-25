# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName IEBrowseWeb_TroubleShooter

. .\CL_Utility.ps1

function CheckIEserverconnections
{
    Write-DiagProgress -activity $localizationString.Check_IEserverconnections

    [bool]$result = $true
    $reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    $MaxConnectionsPerServerproperty = GetItemPropertyValue $reg_path "MaxConnectionsPerServer"
    if($MaxConnectionsPerServerproperty -ne $null)
    {
        $MaxConnectionsPerServer = $MaxConnectionsPerServerproperty."MaxConnectionsPerServer"
        if(($MaxConnectionsPerServer -lt 2) -or ($MaxConnectionsPerServer -gt 6))
        {
            $result = $false
        }
    }
    $MaxConnectionsPer1_0Serverproperty = GetItemPropertyValue $reg_path "MaxConnectionsPer1_0Server"
    if($MaxConnectionsPer1_0Serverproperty -ne $null)
    {
        $MaxConnectionsPer1_0Server = $MaxConnectionsPer1_0Serverproperty."MaxConnectionsPer1_0Server"
        if(($MaxConnectionsPer1_0Server -lt 2) -or ($MaxConnectionsPer1_0Server -gt 6))
        {
            $result = $false
        }
    }
    return $result
}

if((CheckIEserverconnections) -eq $false)
{
    Update-DiagRootCause -id RC_serverconnectionsnumber -Detected $true
} else {
    Update-DiagRootCause -id RC_serverconnectionsnumber -Detected $false
}
