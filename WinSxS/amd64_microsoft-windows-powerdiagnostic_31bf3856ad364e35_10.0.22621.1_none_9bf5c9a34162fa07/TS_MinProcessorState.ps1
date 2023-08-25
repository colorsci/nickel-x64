# Copyright © 2008, Microsoft Corporation. All rights reserved.

#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check minimum processor state setting
function CheckMinimumProcessorState {
        Write-DiagProgress -activity $localizationString.Check_MinimumProcessorState
        [bool]$result = $true
        if(-not(CheckPPMCapability)) {
            return $result
        }

        $subgroupguid = "54533251-82be-4824-96c1-47b60b740d00"
        $settingguid = "893dee8e-2bef-41e0-89c6-b55d0929964c"
        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $AC_settingvalue_default = GetDefaultpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if(($AC_settingvalue -ne $null) -and ($DC_settingvalue -ne $null)) {
            if((($AC_settingvalue -gt $AC_settingvalue_default) -and $access_AC) -or (($DC_settingvalue -gt $DC_settingvalue_default) -and $access_DC -and (IsLaptop))) {
                $result = $false
            }
        }

        return $result

}

Update-DiagRootCause -id RC_MinimumProcessorState -Detected (-not(CheckMinimumProcessorState))