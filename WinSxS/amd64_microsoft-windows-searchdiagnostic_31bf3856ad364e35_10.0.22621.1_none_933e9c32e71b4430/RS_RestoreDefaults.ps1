# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Reset the SetupCompletedSuccessfully registry value and restart the indexing service (causing service to revert to default settings)

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_rs_restoreDefaults

if (-not(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows Search"))
{
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows Search"
}

if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Search" "SetupCompletedSuccessfully") -eq $null)
{
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -PropertyType DWORD -Value 0
}

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Search" "SetupCompletedSuccessfully" 0

Restart-Service WSearch -Force
