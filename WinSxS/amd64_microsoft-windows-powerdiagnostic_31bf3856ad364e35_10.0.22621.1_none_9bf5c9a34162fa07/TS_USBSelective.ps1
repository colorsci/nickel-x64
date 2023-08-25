# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check USB Selective Suspend setting
function CheckUSBSelectiveSuspend
{
        Write-DiagProgress -activity $localizationString.Check_USBSelectiveSuspend
        [bool]$result = $true
        $subgroupguid = "2a737441-1930-4402-8d77-b2bebba308a3"
        $settingguid = "48e6b7a6-50f5-4782-a5d4-53bb8f07e226"
        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $AC_settingvalue_default = GetDefaultpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if((($AC_settingvalue -ne $AC_settingvalue_default) -and $access_AC) -or (($DC_settingvalue -ne $DC_settingvalue_default) -and $access_DC -and (IsLaptop)))
        {
            $result = $false
        }

        return $result
}

if((CheckUSBSelectiveSuspend) -eq $false)
{
    Update-DiagRootCause -id RC_USBSelectiveSuspend -Detected $true
}
else
{
    Update-DiagRootCause -id RC_USBSelectiveSuspend -Detected $false
}
