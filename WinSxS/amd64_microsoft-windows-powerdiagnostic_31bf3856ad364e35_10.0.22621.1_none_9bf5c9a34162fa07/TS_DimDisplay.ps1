# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check dim display after setting
function checkDimDisplayAfter {
        Write-DiagProgress -activity $localizationString.Check_DimDisplayAfter

        [bool]$result = $true
        if(-not(IsLaptop) -or -not(IsVideoDim)) {
            return $result
        }

        $subgroupguid = "7516b95f-f776-4464-8c53-06167f40cc99"
        $settingguid = "17aaa29b-8b43-4b94-aafe-35f64daaf1ee"

        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $AC_settingvalue_default = GetDefaultpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if(($DC_settingvalue -ne $null) -and ($AC_settingvalue -ne $null)) {
            if(((($DC_settingvalue -gt $DC_settingvalue_default) -and $access_DC) -or (($DC_settingvalue -eq 0) -and $access_DC)) -or ((($AC_settingvalue -gt $AC_settingvalue_default) -and $access_AC) -or (($AC_settingvalue -eq 0) -and $access_AC))) {
                $result = $false
            }
        }

        return $result
}

Update-DiagRootCause -id RC_DimDisplay -Detected (-not(checkDimDisplayAfter))