# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1


function HasWirelessAdapter
{
    $wirelessadapters = Get-WmiObject -Namespace "root\wmi" -Class MSNdis_PhysicalMediumType | where{($_.NdisPhysicalMediumType -eq 9) -or ($_.NdisPhysicalMediumType -eq 1)}
    if($null -ne $wirelessadapters)
    {
        return $true
    }
    else
    {
        return $false
    }
}

#check Idle sleep setting
function checkWirelessadaptersettings
{

        Write-DiagProgress -activity $localizationString.Check_Wirelessadaptersettings
        [bool]$result = $true

        if($false -eq (HasWirelessAdapter))
        {
            return $true
        }

        $subgroupguid = "19cbb8fa-5279-450e-9fac-8a3d5fedd0c1"
        $settingguid = "12bbebe6-58d6-4636-95bb-3217ef867c1a"
        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $AC_settingvalue_default = GetDefaultpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $DC_settingvalue_default = GetDefaultpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if(($AC_settingvalue -ne $null) -and ($DC_settingvalue -ne $null))
        {
            if((($AC_settingvalue -lt $AC_settingvalue_default) -and $access_AC) -or (($DC_settingvalue -lt $DC_settingvalue_default) -and $access_DC -and (IsLaptop)))
            {
                $result = $false
            }
        }

        return $result
}

if((checkWirelessadaptersettings) -eq $false)
{
    Update-DiagRootCause -id RC_Wirelessadaptersettings -Detected $true
}
else
{
    Update-DiagRootCause -id RC_Wirelessadaptersettings -Detected $false
}
