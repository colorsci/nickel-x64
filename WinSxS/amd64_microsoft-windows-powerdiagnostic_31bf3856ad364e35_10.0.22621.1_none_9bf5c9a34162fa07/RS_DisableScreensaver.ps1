# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#Localization Data
Import-LocalizedData localizationString

Write-DiagProgress -activity $localizationString.Disable_Screensaver

$isActiveScreenSaver = IsActiveScreenSaver

if($isActiveScreenSaver -eq $true)
{
    DisableScreensaver
}


