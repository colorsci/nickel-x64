# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check Disk Idle Timeout setting
function checkDiskIdleTimeout
{

        Write-DiagProgress -activity $localizationString.Check_DiskIdleTimeout
        [bool]$result = $true
        $subgroupguid = "0012ee47-9041-4b5d-9b77-535fba8b1442"
        $settingguid = "6738e2c4-e8a5-4a42-b16a-e040e769756e"
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


if((checkDiskIdleTimeout) -eq $false)
{
    Update-DiagRootCause -id RC_DiskIdleTimeout -Detected $true
}
else
{
   Update-DiagRootCause -id RC_DiskIdleTimeout -Detected $false
}
