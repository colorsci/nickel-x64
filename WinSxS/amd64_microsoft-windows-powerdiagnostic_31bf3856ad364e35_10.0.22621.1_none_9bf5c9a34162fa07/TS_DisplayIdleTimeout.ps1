# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check Display Idle Timeout
function CheckDisplayIdleTimeout
{
        Write-DiagProgress -activity $localizationString.Check_DisplayIdleTimeout
        [bool]$result = $true
        $subgroupguid = "7516b95f-f776-4464-8c53-06167f40cc99"
        $settingguid = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
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

if((CheckDisplayIdleTimeout) -eq $false)
{
   Update-DiagRootCause -id RC_DisplayIdleTimeouttoolong -Detected $true
}
else
{
   Update-DiagRootCause -id RC_DisplayIdleTimeouttoolong -Detected $false
}