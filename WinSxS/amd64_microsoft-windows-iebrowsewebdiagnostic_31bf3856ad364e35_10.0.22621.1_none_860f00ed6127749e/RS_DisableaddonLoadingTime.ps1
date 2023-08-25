# Copyright © 2008, Microsoft Corporation. All rights reserved.

#Localization Data
Import-LocalizedData localizationString
Write-DiagProgress -activity $localizationString.Disable_loadTime_Slowaddon

. .\CL_Utility.ps1

#
# retrive EnabledAddonLoadingTimeHash from xml file
#
$enabledAddonHash = Import-Clixml EnabledAddonHash.xml -ErrorAction Stop
$loadingTimeHash = Import-Clixml EnabledAddonLoadingTimeHash.xml  -ErrorAction Stop

$sortedDictionary = $loadingTimeHash.GetEnumerator() | Sort-Object Value -Descending

$choices = new-object System.Collections.ArrayList  -ErrorAction Stop

foreach($item in $sortedDictionary)
{
    $addonname = GetAddonName $item.Key
    $publishername = GetCertPublisher $item.Key
    if([string]::IsNullOrEmpty($publishername))
    {
        $publishername = GetAddonPublisher $item.Key
        if([string]::IsNullOrEmpty($publishername))
        {
            $publishername = $localizationString.add_onPublisherDefaultValue
        }
        else
        {
            $publishername = $localizationString.add_onPublisherNotVerified + " " + $publishername
        }
    }
    [double]$loadingTime = $item.Value
    $loadingTime = $loadingTime / 1000
    $choices += @{"Name" = "$addonname, "+"$publishername, " + $loadingTime + $localizationString.seconds; "Description" = $localizationString.add_onName + " $addonname, " + $localizationString.add_onPublisher + " $publishername, " + $localizationString.add_onLoadTime + " $loadingTime"+$localizationString.seconds; "Value" = $item.Key}

}

$values = Get-Diaginput -id IT_DisableLoadingTimeaddon -choice $choices

if($values -eq $null)
{
    return
}

if(-not(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext"))
{
    New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext"  -ErrorAction Stop
}

if(-not(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings"))
{
    New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings"  -ErrorAction Stop
}

$ObjectArray = DisableAddon $values

if($ObjectArray.count -gt 0)
{
    $ObjectArray  | select-object -Property @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id SlowAddOnDisabling -name $localizationString.Resolver_name_slowAddOnDisabling
}