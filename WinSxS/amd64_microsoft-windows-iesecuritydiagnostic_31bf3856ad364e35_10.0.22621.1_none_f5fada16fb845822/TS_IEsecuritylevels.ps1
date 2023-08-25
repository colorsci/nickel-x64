# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName IESecurity_TroubleShooter

. .\CL_Utility.ps1
. .\IEsecuritysettings.ps1

$resetIESettingsHash = New-Object System.Collections.Hashtable
$resetIEProtectModeHash = New-Object System.Collections.Hashtable
$IEZoneHash = New-Object System.Collections.Hashtable

function CheckIEsecuritysettings
{
    Write-DiagProgress -activity $localizationString.Check_IEsecuritysettings

    [bool]$result = $true

    $name = "Security_options_edit"
    $registrykey = "Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"

    if((UnderPolicySetting $name $registrykey) -eq $true)
    {
        [string]$message = $localizationString.Message_IESecurityLevels

        $message | convertto-xml | Update-DiagReport -rid RC_IEsecuritylevels -id Message_IEsecuritylevels -name $localizationString.Report_name_IEsecuritylevels

        return $true
    }

    $resetIESettingsHash = $IERepair.CheckIESettings()

    $resetIEProtectModeHash = $IERepair.CheckIEProtectMode()

    $IEZoneHash = $IERepair.GetIEZones()

    $array = New-Object System.Collections.ArrayList
    foreach($key in $IEZoneHash.keys)
    {
        $item = New-Object -TypeName System.Management.Automation.PSObject
        $Securitylevel = ""
        $Protectedmode = ""

        if($resetIESettingsHash.contains($key))
        {
            $Securitylevel = $localizationString.non_default
        }
        else
        {
            $Securitylevel = $localizationString.default
        }

        if($resetIEProtectModeHash.contains($key))
        {
            $Protectedmode = $localizationString.non_default
        }
        else
        {
            $Protectedmode = $localizationString.default
        }

        Add-Member -InputObject $item -MemberType NoteProperty -Name "zone_name"-Value $key
        Add-Member -InputObject $item -MemberType NoteProperty -Name "protected_mode"-Value $Protectedmode
        Add-Member -InputObject $item -MemberType NoteProperty -Name "security_level"-Value $Securitylevel

        $array.add($item) >> $null
    }

    $array | select-object -Property @{Name=$localizationString.zone_name; Expression={$_.zone_name}}, @{Name=$localizationString.protected_mode; Expression={$_.protected_mode}}, @{Name=$localizationString.security_level; Expression={$_.security_level}} | convertto-xml | Update-DiagReport -rid RC_IEsecuritylevels -id nondefaultIEsettings -name $localizationString.Report_name_IEsettings -description $localizationString.Report_description_IEsettings

    if(($resetIESettingsHash.count -gt 0) -or ($resetIEProtectModeHash.count -gt 0))
    {
        $result = $false
    }
    return $result
}

if((CheckIEsecuritysettings) -eq $false)
{
    Update-DiagRootCause -id RC_IEsecuritylevels -Detected $true
}
else
{
    Update-DiagRootCause -id RC_IEsecuritylevels -Detected $false
}