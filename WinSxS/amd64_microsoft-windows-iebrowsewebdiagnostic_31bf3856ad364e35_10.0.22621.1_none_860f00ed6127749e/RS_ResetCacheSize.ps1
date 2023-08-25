# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.reset_cachelimitvalue

$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content"

$valuename = "CacheLimit"

$CacheLimitproperty = GetItemPropertyValue $reg_path $valuename
if ($CacheLimitproperty -eq $null)
{
    return
}

$cacheLimit = $CacheLimitproperty.$valuename

if($cacheLimit -lt 51200)
{
    Set-ItemProperty -path $reg_path -name $valuename -value "51200" -ErrorAction Stop

}

if($cachelimit -gt 256000)
{
    Set-ItemProperty -path $reg_path -name $valuename -value "256000" -ErrorAction Stop
}

$CacheLimitproperty  = GetItemPropertyValue $reg_path $valuename

$regitemvalue_original = $cacheLimit

$regitemvalue_reset = $CacheLimitproperty.$valuename

$regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

if ($regitem -ne $null)
{
    $regitem | select-object -Property @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id cachelimitvalue -name $localizationString.Report_name_cachelimitvalue
}
