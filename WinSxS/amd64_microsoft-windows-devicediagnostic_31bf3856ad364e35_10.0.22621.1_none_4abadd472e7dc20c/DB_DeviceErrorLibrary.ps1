# Copyright © 2017, Microsoft Corporation. All rights reserved.


#DB_DeviceErrorLibrary
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

if ($HashDeviceErrors -eq $Null)
{
    $HashDeviceErrors = New-Object System.Collections.HashTable
    if ($HashDeviceErrors.Values.Count -eq 0)
    {
        $HashDeviceErrors.Add("2", "")

        $HashDeviceErrors.Add("4", "")
        $HashDeviceErrors.Add("5", "")

        $HashDeviceErrors.Add("6", "")
        $HashDeviceErrors.Add("7", "")
        $HashDeviceErrors.Add("8", "")

        #$HashDeviceErrors.Add("9", "")
        $HashDeviceErrors.Add("11", "")
        #$HashDeviceErrors.Add("12", "")

        $HashDeviceErrors.Add("13", "")
        #$HashDeviceErrors.Add("14", "")
        $HashDeviceErrors.Add("15", "")

        #$HashDeviceErrors.Add("16", "")
        $HashDeviceErrors.Add("17", "")
        $HashDeviceErrors.Add("20", "")
        #$HashDeviceErrors.Add("21", "")

        $HashDeviceErrors.Add("23", "")
        #
        # We should not report DEVICE_NOT_THERE, as it usually is reported
        # by the PS/2 port when the computer is using USB mouse/keyboard.
        # This behavior is consistent with Device Manager/Center.
        #
        #$HashDeviceErrors.Add("24", "")
        $HashDeviceErrors.Add("25", "")

        $HashDeviceErrors.Add("26", "")
        $HashDeviceErrors.Add("27", "")
        #$HashDeviceErrors.Add("29", "")
        $HashDeviceErrors.Add("30", "")
        $HashDeviceErrors.Add("32", "")

        #$HashDeviceErrors.Add("33", "")
        #$HashDeviceErrors.Add("34", "")
        #$HashDeviceErrors.Add("35", "")

        #$HashDeviceErrors.Add("36", "")
        #$HashDeviceErrors.Add("38", "")

        $HashDeviceErrors.Add("41", "")
        #$HashDeviceErrors.Add("42", "")
        $HashDeviceErrors.Add("43", "")
        #$HashDeviceErrors.Add("44", "")
        $HashDeviceErrors.Add("45", "")
        #$HashDeviceErrors.Add("46", "")
        #$HashDeviceErrors.Add("47", "")
        $HashDeviceErrors.Add("48", "")
        #$HashDeviceErrors.Add("49", "")
    }
}

if ($HashDisabled -eq $Null)
{
    $HashDisabled = New-Object System.Collections.HashTable
    if ($HashDisabled.Values.Count -eq 0)
    {
        $HashDisabled.Add("22", "22")
    }
}

if ($HashUpdateDriver -eq $Null)
{
    $HashUpdateDriver = New-Object System.Collections.HashTable
    if ($HashUpdateDriver.Values.Count -eq 0)
    {
        $HashUpdateDriver.Add("1", "1")
        $HashUpdateDriver.Add("3", "3")
        $HashUpdateDriver.Add("10", "10")
        $HashUpdateDriver.Add("18", "18")
        $HashUpdateDriver.Add("19", "19")
        $HashUpdateDriver.Add("31", "31")

        $HashUpdateDriver.Add("37", "37")
        $HashUpdateDriver.Add("39", "39")
        $HashUpdateDriver.Add("40", "40")
    }
}

if ($HashDriverNotFound -eq $Null)
{
    $HashDriverNotFound = New-Object System.Collections.HashTable
    if ($HashDriverNotFound.Values.Count -eq 0)
    {
        $HashDriverNotFound.Add("28", "28")
    }
}

if ($HashTitle -eq $Null)
{
    $HashTitle = New-Object System.Collections.HashTable
    if ($HashTitle.Values.Count -eq 0)
    {
        $HashTitle.Add("14", $localizationString.Title_14)
        $HashTitle.Add("21", $localizationString.Title_21)
        $HashTitle.Add("41", $localizationString.Title_41)
        $HashTitle.Add("42", $localizationString.Title_42)
        $HashTitle.Add("44", $localizationString.Title_44)
        $HashTitle.Add("45", $localizationString.Title_45)
        $HashTitle.Add("47", $localizationString.Title_47)
    }
}

if ($HashHint -eq $Null)
{
    $HashHint = New-Object System.Collections.HashTable
    if ($HashHint.Values.Count -eq 0)
    {
        $HashHint.Add("14", $localizationString.Hint_14)
        $HashHint.Add("21", $localizationString.Hint_21)
        $HashHint.Add("41", $localizationString.Hint_41)
        $HashHint.Add("42", $localizationString.Hint_42)
        $HashHint.Add("44", $localizationString.Hint_44)
        $HashHint.Add("45", $localizationString.Hint_45)
        $HashHint.Add("47", $localizationString.Hint_47)
    }
}

# Adding all error codes where customer needs to be notified.
if ($HashInformCx -eq $Null)
{
    $HashInformCx = New-Object System.Collections.HashTable
    if ($HashInformCx.Values.Count -eq 0)
    {
        $HashInformCx.Add("9", "")

        $HashInformCx.Add("12", "")
        $HashInformCx.Add("21", "")

        $HashInformCx.Add("33", "")
        $HashInformCx.Add("35", "")
        $HashInformCx.Add("46", "")

        $HashInformCx.Add("47", "")
        $HashInformCx.Add("49", "")
        $HashInformCx.Add("51", "")

        $HashInformCx.Add("52", "")
        $HashInformCx.Add("29", "")
        $HashInformCx.Add("36", "")

        $HashInformCx.Add("16", "")
        $HashInformCx.Add("34", "")
        $HashInformCx.Add("14", "")
        $HashInformCx.Add("38", "")

        $HashInformCx.Add("42", "")

        $HashInformCx.Add("44", "")

        $HashInformCx.Add("54", "")
        
    }
}