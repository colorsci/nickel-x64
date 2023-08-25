# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.Disable_Defectiveaddon

#retrive DefectiveAddonParaHash from xml file
$DefectiveAddonParaHash = Import-Clixml DefectiveAddonParaHash.xml

$choices = new-object System.Collections.ArrayList -ErrorAction Stop

foreach($key in $DefectiveAddonParaHash.keys)
{
    $addonname = GetAddonName $key
    $publishername = GetCertPublisher $key
    if([string]::IsNullOrEmpty($publishername))
    {
        $publishername = GetAddonPublisher $key
        if([string]::IsNullOrEmpty($publishername))
        {
            $publishername = $localizationString.add_onPublisherDefaultValue
        }
        else
        {
            $publishername = $localizationString.add_onPublisherNotVerified + " " + $publishername
        }
    }
    $choices += @{"Name" = "$addonname, "+$publishername; "Description" = $localizationString.add_onName + " $addonname, " + $localizationString.add_onPublisher + " $publishername"; "Value" = "$key"}
}

if($choices -ne $null -and $choices.count -lt 1)
{
    return
}

$values = Get-Diaginput -id IT_Disableaddon -choice $choices

if($values -eq $null)
{
    return
}

if(-not(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext"))
{
    New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext" -ErrorAction Stop
}

if(-not(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings"))
{
    New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings" -ErrorAction Stop
}


$ObjectArray = DisableAddon $values

if($ObjectArray.count -gt 0)
{
    $ObjectArray  | select-object -Property @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id ProblematicAddOnDisabling -name $localizationString.Resolver_name_ProblematicAddOnDisabling
}

