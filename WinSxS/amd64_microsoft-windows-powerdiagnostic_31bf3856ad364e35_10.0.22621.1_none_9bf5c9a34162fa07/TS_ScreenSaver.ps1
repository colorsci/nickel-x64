# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName Power_Troubleshooter

# Break on uncaught exceptions
trap {break}

. .\Powerconfig.ps1

#check screen saver
function CheckScreenSaver
{
        Write-DiagProgress -activity $localizationString.Check_ScreenSaver

        [bool]$result = $true

        $isActiveScreenSaver = IsActiveScreenSaver

        if($isActiveScreenSaver -eq $true)
        {
            $result = $false
        }

        return $result
}

if((CheckScreenSaver) -eq $false)
{
    Update-DiagRootCause -id RC_ScreenSaver -Detected $true
}
else
{
    Update-DiagRootCause -id RC_ScreenSaver -Detected $false
}

