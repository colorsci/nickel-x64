# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check high performance power plan
function Checkhighperformance
{

        Write-DiagProgress -activity $localizationString.Check_highperformance
        [bool]$result = $true

        if((CheckActiveSchemeAccess) -eq $false)
        {
            return "NotAccess"
        }

        $subgroupguid = "fea3413e-7e05-4911-9a71-700331f1c294"
        $settingguid = "245d8541-3943-4422-b025-13a784f679b7"
        $AC_settingvalue = Getpowersetting $true $subgroupguid $settingguid
        $access_AC = CheckPowerSettingAccess $true $settingguid

        $DC_settingvalue = Getpowersetting $false $subgroupguid $settingguid
        $access_DC = CheckPowerSettingAccess $false $settingguid

        if(($AC_settingvalue -ne $null) -and ($DC_settingvalue -ne $null))
        {
            if((($AC_settingvalue -eq 1) -and $access_AC) -or (($DC_settingvalue -eq 1) -and $access_DC -and (IsLaptop)))
            {
                $regpath = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}"

                if(Test-Path $regpath)
                {
                    $activeguid = GetActiveSchemeGuid

                    $itemproperty = Get-ItemProperty $regpath "PreferredPlan"
                    if($itemproperty -ne $null)
                    {
                        $PreferredPlan = $itemproperty.PreferredPlan
                        if([string]::IsNullOrEmpty($PreferredPlan) -eq $false)
                        {
                            if($PreferredPlan -ne $activeguid)
                            {
                                $result = $false
                                return $result
                            }
                            else
                            {
                                $result = $true
                                return $result
                            }
                        }
                    }
                }

                $result = $false
            }
        }

        return $result
}

$result = Checkhighperformance

if($result -eq $false)
{
    Update-DiagRootCause -id RC_highperformance -Detected $true

    return $false
}
elseif("NotAccess".equals($result))
{

    $ActiveSchemeName = GetActiveSchemeFriendlyName

    [string]$message = [System.String]::Format($localizationString.Message_PowerPlan, $ActiveSchemeName)

    $message  | convertto-xml | Update-DiagReport -id Message_PowerPlan -rid RC_highperformance -name $localizationString.Report_name_PowerPlan

    Update-DiagRootCause -id RC_highperformance -Detected $false

    return $false
}
else
{
    Update-DiagRootCause -id RC_highperformance -Detected $false
}
