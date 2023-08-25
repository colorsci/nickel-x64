# Copyright © 2008, Microsoft Corporation. All rights reserved.


# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.set_Balanced

$regpath = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}"

$BalancedSchemeGuid = ""

#if registry item PreferredPlan exist, retrieve the value
if(Test-Path $regpath)
{
    $itemproperty = Get-ItemProperty $regpath "PreferredPlan"

    if($itemproperty -ne $null)
    {
        $PreferredPlan = $itemproperty.PreferredPlan
        if([string]::IsNullOrEmpty($PreferredPlan) -eq $false)
        {
            $BalancedSchemeGuid = $PreferredPlan
        }
    }
}

$activeschemeguid = GetActiveSchemeGuid

$activeschemeguid_original = $activeschemeguid

# if balanced scheme guid is not retrieved from registry, get balanced guid from api
if([string]::IsNullOrEmpty($BalancedSchemeGuid))
{
    $BalancedSchemeGuid = GetBalancedPowerPlan
}

$res = SetActiveSchemeGuid($BalancedSchemeGuid)

$res.tostring() | convertto-xml | Update-DiagReport -id SetActiveSchemeGuid -name $localizationString.Report_name_SetActiveSchemeGuid_result -verbosity Debug

$activeschemeguid = GetActiveSchemeGuid

$activeschemeguid_reset = $activeschemeguid

$activescheme_Guid = New-Object -TypeName System.Management.Automation.PSObject

Add-Member -InputObject $activescheme_Guid -MemberType NoteProperty -Name "activeschemeguid_original"  -Value $activeschemeguid_original
Add-Member -InputObject $activescheme_Guid -MemberType NoteProperty -Name "activeschemeguid_reset"-Value $activeschemeguid_reset

$activescheme_Guid | select-object -Property @{Name=$localizationString.activeschemeguid_original; Expression={$_.activeschemeguid_original}},  @{Name=$localizationString.activeschemeguid_reset; Expression={$_.activeschemeguid_reset}} | convertto-xml | Update-DiagReport -id ActiveSchemeGuid -name $localizationString.Report_name_ActiveSchemeGuid
