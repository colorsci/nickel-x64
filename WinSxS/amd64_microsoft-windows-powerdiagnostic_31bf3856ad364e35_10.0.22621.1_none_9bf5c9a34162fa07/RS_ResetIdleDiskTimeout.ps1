# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.reset_DiskIdleTimeout

$subgroupguid = "0012ee47-9041-4b5d-9b77-535fba8b1442"
$settingguid = "6738e2c4-e8a5-4a42-b16a-e040e769756e"
$ACvalue = GetDefaultpowersetting $true $subgroupguid $settingguid
$DCvalue = GetDefaultpowersetting $false $subgroupguid $settingguid
$AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
$DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid

$ObjectArray = new-object System.Collections.ArrayList

if(($AC_settingvalue -gt $ACvalue) -or ($AC_settingvalue -eq 0))
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
    $res.tostring() | convertto-xml | Update-DiagReport -id DiskIdleTimeout_AC_result -name $localizationString.Report_name_DiskIdleTimeout_AC_result -verbosity Debug
}

if((($DC_settingvalue -gt $DCvalue) -or ($DC_settingvalue -eq 0)) -and (IsLaptop))
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
    $res.tostring() | convertto-xml | Update-DiagReport -id DiskIdleTimeout_DC_result -name $localizationString.Report_name_DiskIdleTimeout_DC_result -verbosity Debug
}

if($ObjectArray.count -gt 0)
{
    $ObjectArray | select-object -Property @{Name=$localizationString.AC_settingvalue_original; Expression={$_.AC_settingvalue_original}},  @{Name=$localizationString.AC_settingvalue_reset; Expression={$_.AC_settingvalue_reset}}, @{Name=$localizationString.DC_settingvalue_original; Expression={$_.DC_settingvalue_original}},  @{Name=$localizationString.DC_settingvalue_reset; Expression={$_.DC_settingvalue_reset}} | convertto-xml | Update-DiagReport -id DiskIdleTimeout -name $localizationString.Report_name_DiskIdleTimeout
}
