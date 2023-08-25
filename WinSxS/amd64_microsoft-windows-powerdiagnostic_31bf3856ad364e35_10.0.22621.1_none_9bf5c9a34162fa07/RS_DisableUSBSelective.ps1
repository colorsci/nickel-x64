# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.reset_USBSelective

$subgroupguid = "2a737441-1930-4402-8d77-b2bebba308a3"
$settingguid = "48e6b7a6-50f5-4782-a5d4-53bb8f07e226"
$ACvalue = GetDefaultpowersetting $true $subgroupguid $settingguid
$DCvalue = GetDefaultpowersetting $false $subgroupguid $settingguid
$AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
$DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid

$ObjectArray = new-object System.Collections.ArrayList

if($AC_settingvalue -ne $ACvalue)
{
    $res = Setpowersetting $true $subgroupguid $settingguid $ACvalue
    #if reset AC value successfully
    if($res -eq 0)
    {
        $AC_settingvalue_original = $AC_settingvalue

        $AC_settingvalue_reset = Getpowersetting $true $subgroupguid $settingguid

        $AC_setting = New-Object -TypeName System.Management.Automation.PSObject

        Add-Member -InputObject $AC_setting -MemberType NoteProperty -Name "AC_settingvalue_original"  -Value $AC_settingvalue_original
        Add-Member -InputObject $AC_setting -MemberType NoteProperty -Name "AC_settingvalue_reset"-Value $AC_settingvalue_reset

        $ObjectArray.add($AC_setting)
    }
    $res.tostring() | convertto-xml | Update-DiagReport -id USBSelective_AC_result -name $localizationString.Report_name_USBSelective_AC_result -verbosity Debug
}

if(($DC_settingvalue -ne $DCvalue) -and (IsLaptop))
{
    $res = Setpowersetting $false $subgroupguid $settingguid $DCvalue
    #if reset DC value successfully
    if($res -eq 0)
    {
        $DC_settingvalue_original = $DC_settingvalue

        $DC_settingvalue_reset = Getpowersetting $false $subgroupguid $settingguid

        $DC_setting = New-Object -TypeName System.Management.Automation.PSObject

        Add-Member -InputObject $DC_setting -MemberType NoteProperty -Name "DC_settingvalue_original"  -Value $DC_settingvalue_original
        Add-Member -InputObject $DC_setting -MemberType NoteProperty -Name "DC_settingvalue_reset"-Value $DC_settingvalue_reset

        $ObjectArray.add($DC_setting)
    }
    $res.tostring() | convertto-xml | Update-DiagReport -id USBSelective_DC_result -name $localizationString.Report_name_USBSelective_DC_result -verbosity Debug
}

if($ObjectArray.count -gt 0)
{
    $ObjectArray  | select-object -Property @{Name=$localizationString.AC_settingvalue_original; Expression={$_.AC_settingvalue_original}},  @{Name=$localizationString.AC_settingvalue_reset; Expression={$_.AC_settingvalue_reset}}, @{Name=$localizationString.DC_settingvalue_original; Expression={$_.DC_settingvalue_original}},  @{Name=$localizationString.DC_settingvalue_reset; Expression={$_.DC_settingvalue_reset}} | convertto-xml | Update-DiagReport -id USBSelective -name $localizationString.Report_name_USBSelective
}
