# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData  -BindingVariable localizationString -FileName IEBrowseWeb_TroubleShooter

. .\CL_Utility.ps1

#Get Module name and Guid from registry, then add into IE add-on modules hashtable
function GetModuleInfo([string]$module_guid = $(throw "No module guid is specified"), [System.Collections.Hashtable]$ModulesHash)
{
    [string]$moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"
    if(-not (Test-Path $moduleKey))
    {
        $moduleKey = "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    }
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $moduleName = Split-Path -leaf $prop."(default)"
            if(-not $ModulesHash.Containskey($module_guid))
            {
                $ModulesHash.Add($module_guid, $moduleName)
            }
        }
    }
}

#Get Registry sub items then add into IE add-on modules hashtable
function GetRegSubItems([string]$Reg_path = $(throw "No Registry path is specified"), [System.Collections.Hashtable]$ModulesHash)
{
    if(Test-Path $Reg_path)
    {
        $RegKey = Get-Item -path $Reg_path
        foreach($name in $RegKey.GetSubKeyNames())
        {
            GetModuleInfo $name $ModulesHash
        }
    }
}

#Get Registry properties then add into IE add-on modules hashtable
function GetRegProperties([string]$Reg_path = $(throw "No Registry path is specified"), [System.Collections.Hashtable]$ModulesHash)
{
    if(Test-Path $Reg_path)
    {
        $RegKey = Get-Item -path $Reg_path
        #add each property into hashtable
        for ($i=0; $i -lt $RegKey.Property.Length; $i++)
        {
            GetModuleInfo $RegKey.Property[$i] $ModulesHash
        }
    }
}
#retrieve IE add-on modules' guid and name from registry
function GetAddonModules()
{
    [System.Collections.Hashtable]$ModulesHash = New-Object System.Collections.Hashtable
    #Get properties from HKLM\SOFTWARE\Microsoft\Internet Explorer\Toolbar
    GetRegProperties "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Toolbar" $ModulesHash

    #Get sub items' name from HKLM\Software\Microsoft\Internet Explorer\Explorer Bars
    GetRegSubItems "HKLM:\Software\Microsoft\Internet Explorer\Explorer Bars" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\Microsoft\Code Store Database\Distribution Units
    GetRegSubItems "HKLM:\SOFTWARE\Microsoft\Code Store Database\Distribution Units" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\Microsoft\Internet Explorer\Extensions
    GetRegSubItems "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Extensions" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\Browser Helper Objects
    GetRegSubItems "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\Browser Helper Objects" $ModulesHash

    #Get properties from HKLM\SOFTWARE\WOW6432NODE\Microsoft\Internet Explorer\Toolbar
    GetRegProperties "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Internet Explorer\Toolbar" $ModulesHash

    #Get sub items' name from HKLM\Software\WOW6432NODE\Microsoft\Internet Explorer\Explorer Bars
    GetRegSubItems "HKLM:\Software\WOW6432NODE\Microsoft\Internet Explorer\Explorer Bars" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\WOW6432NODE\Microsoft\Code Store Database\Distribution Units
    GetRegSubItems "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Code Store Database\Distribution Units" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\WOW6432NODE\Microsoft\Internet Explorer\Extensions
    GetRegSubItems "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Internet Explorer\Extensions" $ModulesHash

    #Get sub items' name from HKLM\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\explorer\Browser Helper Objects
    GetRegSubItems "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\explorer\Browser Helper Objects" $ModulesHash
    return $ModulesHash
}

function IsDisabledAddon([string]$Module_guid = $(throw "No Module guid path is specified"))
{
    [bool]$result = $true

    $reg_path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\$Module_guid"

    $reg_flagsproperty = GetItemPropertyValue $reg_path "flags"

    $reg_Flags = $reg_flagsproperty."flags"

    $reg_versionproperty = GetItemPropertyValue $reg_path "Version"

    $reg_version = $reg_versionproperty."Version"

    if(($reg_Flags -ne 1) -or ($reg_version -ne "*"))
    {
        $result = $false
    }
    return $result
}

function CheckDefectiveAddon([System.Collections.Hashtable]$ModulesHash)
{
    [System.Collections.Hashtable]$DefectiveAddonParaHash = New-Object System.Collections.Hashtable
    $name = "NoExtensionManagement"
    $registrykey = "Software\Policies\Microsoft\Internet Explorer\Restrictions"

    if((UnderPolicySetting $name $registrykey) -eq $true)
    {
        [string]$message = $localizationString.Message_IEAddon
        $message | convertto-xml | Update-DiagReport -rid RC_defectiveIEaddon -id Message_defectiveIEaddon -name $localizationString.Report_name_IEAddon
        return $DefectiveAddonParaHash
    }

    #Read the latest 7 days iexplore crash events from the application channel

    $day = 7

    $timespan=New-Object system.timespan($day,0,0,0)

    $currenttime = [system.datetime]::today

    $starttime = $currenttime.Subtract($timespan)

    $ieerr = get-winevent -FilterHashtable @{logname="application"; providername="Application Error"; data="iexplore.exe"; starttime=$starttime}

    if(($ieerr -is [System.Diagnostics.Eventing.Reader.EventRecord]) -or ($ieerr.count -gt 0))
    {
        $ieerr | convertto-xml | Update-DiagReport -rid RC_defectiveIEaddon -id crashedIEAddon -name $localizationString.Report_name_crashedIEAddon -description $localizationString.Report_description_crashedIEAddon
    }

    if ($ieerr -ne $null)
    {
        foreach ($modulekey in $ModulesHash.keys)
        {
            foreach ($i in $ieerr)
            {
                foreach ($prop in $i.Properties)
                {
                    #if IE crash event properties contains the add-on module name, and the add-on does not disabled, it's a defective add-on
                    if ($prop.Value -contains $ModulesHash.item($modulekey))
                    {
                        if(((IsDisabledAddon $modulekey) -eq $false) -and (BinaryExists($modulekey)))
                        {
                            if(-not($DefectiveAddonParaHash.ContainsKey($modulekey)))
                            {
                                $defectiveaddonname = $ModulesHash.item($modulekey)
                                $DefectiveAddonParaHash.add($modulekey, $defectiveaddonname)
                            }
                        }
                    }
                }
            }
        }
    }
    return $DefectiveAddonParaHash
}

#
# List of all Internet Explorer add-ons installed.
#
function WriteIEAddonReport([System.Collections.Hashtable]$addonHash, [string]$addonType)
{
    if($addonHash -ne $null -and $addonHash.count -gt 0)
    {
         $array = New-Object System.Collections.ArrayList
         foreach($key in $addonHash.keys)
         {
             $versioninfo = GetAddonVersionInfo $key
             $modifydate = GetAddonModifiedDate $key
             if($versioninfo -ne $null)
             {
                 $item = New-Object -TypeName System.Management.Automation.PSObject

                 Add-Member -InputObject $item -MemberType NoteProperty -Name "file_description"-Value $versioninfo.FileDescription
                 Add-Member -InputObject $item -MemberType NoteProperty -Name "file_version"-Value $versioninfo.FileVersion
                 Add-Member -InputObject $item -MemberType NoteProperty -Name "product_name"  -Value $versioninfo.ProductName
                 Add-Member -InputObject $item -MemberType NoteProperty -Name "date_modified"  -Value $modifydate
                 Add-Member -InputObject $item -MemberType NoteProperty -Name "full_path"  -Value $versioninfo.FileName
                 if($addonType -eq "loadTimeIEAddon")
                 {
                     Add-Member -InputObject $item -MemberType NoteProperty -Name "load_time"  -Value $addonHash.Item($key)
                 }

                 $array.add($item) >> $null
             }
         }
         if($addonType -eq "detectedIEAddon")
         {
             $array | select-object -Property @{Name=$localizationString.file_description; Expression={$_.file_description}}, @{Name=$localizationString.file_version; Expression={$_.file_version}}, @{Name=$localizationString.product_name; Expression={$_.product_name}}, @{Name=$localizationString.date_modified; Expression={$_.date_modified}}, @{Name=$localizationString.full_path; Expression={$_.full_path}} | convertto-xml | Update-DiagReport -rid RC_defectiveIEaddon -id detectedIEAddon -name $localizationString.Report_name_detectedIEAddon -description $localizationString.Report_description_detectedIEAddon
         }
         elseif($addonType -eq "defectiveaddon")
         {
             $array | select-object -Property @{Name=$localizationString.file_description; Expression={$_.file_description}}, @{Name=$localizationString.file_version; Expression={$_.file_version}}, @{Name=$localizationString.product_name; Expression={$_.product_name}}, @{Name=$localizationString.date_modified; Expression={$_.date_modified}}, @{Name=$localizationString.full_path; Expression={$_.full_path}} | convertto-xml | Update-DiagReport -rid RC_defectiveIEaddon -id defectiveIEAddon -name $localizationString.Report_name_defectiveaddon -description $localizationString.Report_description_defectiveaddon
         }
         elseif($addonType -eq "loadTimeIEAddon")
         {
             $array | select-object -Property @{Name=$localizationString.file_description; Expression={$_.file_description}}, @{Name=$localizationString.file_version; Expression={$_.file_version}}, @{Name=$localizationString.product_name; Expression={$_.product_name}}, @{Name=$localizationString.date_modified; Expression={$_.date_modified}}, @{Name=$localizationString.full_path; Expression={$_.full_path}}, @{Name=$localizationString.load_time; Expression={$_.load_time}} | convertto-xml | Update-DiagReport -rid RC_IEaddonLoadingTime -id detectedLoadTimeIEAddon -name $localizationString.Report_name_LoadTimeAddon -description $localizationString.Report_description_LoadTimeAddon
         }
    }
}

function GetIEEnabledAddon([System.Collections.Hashtable]$ModulesHash)
{
    [System.Collections.Hashtable]$addonHash = New-Object System.Collections.Hashtable
    $name = "NoExtensionManagement"
    $registrykey = "Software\Policies\Microsoft\Internet Explorer\Restrictions"

    if((UnderPolicySetting $name $registrykey) -eq $true)
    {
        [string]$message = $localizationString.Message_IEAddon

        $message | convertto-xml | Update-DiagReport -rid RC_defectiveIEaddon -id Message_defectiveIEaddon -name $localizationString.Report_name_IEAddon

        return $addonHash
    }

    foreach ($modulekey in $ModulesHash.keys)
    {
        if(((IsDisabledAddon $modulekey) -eq $false) -and (BinaryExists($modulekey)))
        {
            if(-not($addonHash.ContainsKey($modulekey)))
            {
                $defectiveaddonname = $ModulesHash.item($modulekey)
                $addonHash.add($modulekey, $defectiveaddonname)
            }
        }
    }
    return $addonHash
}

function GetIEAddonLoadingTime([System.Collections.Hashtable]$addonHash)
{
    [System.Collections.Hashtable]$loadingTimeHash = New-Object System.Collections.Hashtable
    foreach($key in $addonHash.keys)
    {
        $moduleKey = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Ext\Stats\" + $key + "\iexplore"

	if(Test-Path $moduleKey)
	{
	    $prop = "LoadTime"
	    $propValue  = (Get-ItemProperty -path $moduleKey -Name $prop).$prop
	    if($propValue -ne $null)
	    {
	        $loadingTimeHash.add($key, $propValue)
	    }
	}
    }
    return $loadingTimeHash
}
