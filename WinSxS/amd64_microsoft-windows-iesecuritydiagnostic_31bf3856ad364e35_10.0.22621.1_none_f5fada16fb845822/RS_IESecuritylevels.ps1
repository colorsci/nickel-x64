# Copyright © 2008, Microsoft Corporation. All rights reserved.


. .\IEsecuritysettings.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.Reset_securitysettings

$repairIESettingsHash = $IERepair.RepairIESettings()

if($repairIESettingsHash.count -gt 0)
{
    $repairIESettingsHash.GetEnumerator() | select-object -Property @{Name=$localizationString.keys; Expression={$_.name}} | convertto-xml | Update-DiagReport -id resetIEsettings -name $localizationString.Report_name_resetIEsettings -description $localizationString.Report_description_resetIEsettings
}

$repairIEProtectModeHash = $IERepair.RepairIEProtectMode()

if($repairIEProtectModeHash.count -gt 0)
{
    $repairIEProtectModeHash.GetEnumerator() | select-object -Property @{Name=$localizationString.keys; Expression={$_.name}} | convertto-xml | Update-DiagReport -id resetIEprotectedmode -name $localizationString.Report_name_resetIEprotectedmode -description $localizationString.Report_description_resetIEprotectedmode
}
