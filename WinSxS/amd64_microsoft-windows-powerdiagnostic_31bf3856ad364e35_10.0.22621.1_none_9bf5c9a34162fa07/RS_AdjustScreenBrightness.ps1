# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.reset_ScreenBrightness

$subgroupguid = "7516b95f-f776-4464-8c53-06167f40cc99"
$settingguid = "aded5e82-b909-4619-9949-f5d71dac0bcb"
$DCvalue = GetDefaultpowersetting $false $subgroupguid $settingguid
$DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
$activeSchemeGuid = $powerconfig::ActiveSchemeGuid()

$ObjectArray = new-object System.Collections.ArrayList

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
    $res.tostring() | convertto-xml | Update-DiagReport -id ScreenBrightness_DC_result -name $localizationString.Report_name_ScreenBrightness_DC_result -verbosity Debug
}

SetActiveSchemeGuid $activeSchemeGuid >> $null

if($ObjectArray.count -gt 0)
{
    $ObjectArray | select-object -Property @{Name=$localizationString.AC_settingvalue_original; Expression={$_.AC_settingvalue_original}},  @{Name=$localizationString.AC_settingvalue_reset; Expression={$_.AC_settingvalue_reset}}, @{Name=$localizationString.DC_settingvalue_original; Expression={$_.DC_settingvalue_original}},  @{Name=$localizationString.DC_settingvalue_reset; Expression={$_.DC_settingvalue_reset}} | convertto-xml | Update-DiagReport -id ScreenBrightness -name $localizationString.Report_name_ScreenBrightness
}
