# Copyright © 2008, Microsoft Corporation. All rights reserved.


#RS_ConfigurationErrors

$result = Get-DiagInput -id IT_ResetConfiguration

if ($result[0] -eq "Yes")
{
    $ConfigEntryPath = "HKCU:\Software\Microsoft\MediaPlayer\Preferences"

    $IsExist = Test-Path "HKCU:\Software\Microsoft\MediaPlayer\Preferences.old"

    if($IsExist -eq $true)
    {
        Remove-Item -path "HKCU:\Software\Microsoft\MediaPlayer\Preferences.old" -Recurse -Force
    }

    Rename-Item $ConfigEntryPath -NewName "Preferences.old"

    New-Item -path $ConfigEntryPath

    copy-itemproperty -path HKCU:\Software\Microsoft\MediaPlayer\Preferences.old -destination $ConfigEntryPath -name AcceptedPrivacyStatement
}
