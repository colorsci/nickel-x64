# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.restore_IEconnection

$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

$ObjectArray = new-object System.Collections.ArrayList -ErrorAction Stop

$MaxConnectionsPerServerproperty = GetItemPropertyValue $reg_path "MaxConnectionsPerServer"

if($MaxConnectionsPerServerproperty -ne $null)
{
    $MaxConnectionsPerServer = $MaxConnectionsPerServerproperty."MaxConnectionsPerServer"

    if(($MaxConnectionsPerServer -lt 2) -or ($MaxConnectionsPerServer -gt 6))
    {
        $regitemvalue_original = $MaxConnectionsPerServer

        $regitemvalue_reset = $localizationString.Removed

        $valuename = "MaxConnectionsPerServer"

        $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

        $ObjectArray.add($regitem)

        Remove-ItemProperty -path $reg_path "MaxConnectionsPerServer" -force
    }
}

$MaxConnectionsPer1_0Serverproperty = GetItemPropertyValue $reg_path "MaxConnectionsPer1_0Server"

if($MaxConnectionsPer1_0Serverproperty -ne $null)
{
    $MaxConnectionsPer1_0Server = $MaxConnectionsPer1_0Serverproperty."MaxConnectionsPer1_0Server"

    if(($MaxConnectionsPer1_0Server -lt 2) -or ($MaxConnectionsPer1_0Server -gt 6))
    {
        $regitemvalue_original = $MaxConnectionsPer1_0Server

        $regitemvalue_reset = $localizationString.Removed

        $valuename = "MaxConnectionsPer1_0Server"

        $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

        $ObjectArray.add($regitem)

        Remove-ItemProperty -path $reg_path "MaxConnectionsPer1_0Server" -force
    }
}

if($ObjectArray.count -gt 0)
{
    $ObjectArray  | select-object -Property @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id MaxConnectionsPerServervalue -name $localizationString.Report_name_MaxConnectionsPerServer_remove
}

