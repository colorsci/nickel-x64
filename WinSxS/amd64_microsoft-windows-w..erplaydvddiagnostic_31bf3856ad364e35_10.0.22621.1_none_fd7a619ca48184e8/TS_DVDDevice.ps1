# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_DVDDevice

trap { break }

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

$ProblematicDVDDeivces = New-Object -TypeName "HashTable"

$DvdDevices = Get-WmiObject Win32_CDRomDrive

if($DvdDevices -ne $NULL)
{
    foreach($DvdDevice in $DvdDevices)
    {
        $DvdDevice | Select-Object -Property @{Name=$localizationString.CDRomDeviceName; Expression={$_.Name}}, @{Name=$localizationString.PnPDeviceID; Expression={$_.PNPDeviceID}}, @{Name=$localizationString.Status; Expression={$_.Status}} | ConvertTo-XML | Update-DiagReport -ID CDRomDeviceInformation -Name $localizationString.Report_Name_CDRomDeviceInformation -Verbosity Informational -rid RC_MissingDVDDevice

        [string]$DeviceName = $DvdDevice.Name.ToLower()
        [string]$MediaType = $DvdDevice.MediaType.ToLower()

        $IsDVDValid = ($DeviceName.Contains("dvd") -or $MediaType.Contains("dvd"))

        if ($IsDVDValid -eq $True)
        {
            $ProblematicDVDDeivces.Add($DvdDevice.PNPDeviceID, $DvdDevice.ConfigManagerErrorCode)
        }
    }
}

return $ProblematicDVDDeivces
