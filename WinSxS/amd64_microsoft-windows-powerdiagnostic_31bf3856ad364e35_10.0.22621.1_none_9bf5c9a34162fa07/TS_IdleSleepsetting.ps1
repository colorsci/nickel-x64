# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check Idle sleep setting
function checkIdlesleepsetting
{

        Write-DiagProgress -activity $localizationString.Check_Idlesleepsetting
        [bool]$result = $true
        $subgroupguid = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
        $settingguid = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $AC_settingvalue_default = GetDefaultpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if(($AC_settingvalue -ne $null) -and ($DC_settingvalue -ne $null))
        {
            if((($AC_settingvalue -gt $AC_settingvalue_default) -and $access_AC) -or (($DC_settingvalue -gt $DC_settingvalue_default) -and $access_DC -and (IsLaptop)) -or (($AC_settingvalue -eq 0) -and $access_AC) -or (($DC_settingvalue -eq 0) -and $access_DC -and (IsLaptop)))
            {
                $result = $false
            }
        }

        return $result

}

if((checkIdlesleepsetting) -eq $false)
{
    Update-DiagRootCause -id RC_Idlesleepsettingistoolong -Detected $true
}
else
{
   Update-DiagRootCause -id RC_Idlesleepsettingistoolong -Detected $false
}
