# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check screen brightness
function checkScreenBrightness
{
        Write-DiagProgress -activity $localizationString.Check_ScreenBrightness

        [bool]$result = $true
        if(-not(IsLaptop) -or -not(IsVideoDim))
        {
            return $result
        }

        $subgroupguid = "7516b95f-f776-4464-8c53-06167f40cc99"
        $settingguid = "aded5e82-b909-4619-9949-f5d71dac0bcb"

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if($DC_settingvalue -ne $null)
        {
            if((($DC_settingvalue -gt $DC_settingvalue_default) -and $access_DC))
            {
                $result = $false
            }
        }

        return $result
}

if((checkScreenBrightness) -eq $false)
{
    Update-DiagRootCause -id RC_ScreenBrightness -Detected $true
}
else
{
    Update-DiagRootCause -id RC_ScreenBrightness -Detected $false
}
