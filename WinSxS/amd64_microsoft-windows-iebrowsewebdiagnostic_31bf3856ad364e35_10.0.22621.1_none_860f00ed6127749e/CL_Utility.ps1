# Copyright © 2008, Microsoft Corporation. All rights reserved.


#get item property value from registry property
function GetItemPropertyValue([string]$reg_path = $(throw "No registry path is specified"), [string]$propertyname = $(throw "no registry path is specified"))
{
    return (Get-ItemProperty $reg_path $propertyname -ErrorAction silentlycontinue)
}

function GetAddonPublisher([string]$module_guid = $(throw "No module guid is specified"))
{
    [string]$moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"

    if(-not (Test-Path $moduleKey))
    {
        $moduleKey =  "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    }

    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"
            if(Test-Path $path)
            {
                return [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path).CompanyName
            }
        }
    }
}

function GetCertPublisher([string]$module_guid = $(throw "No module guid is specified"))
{
    $publisher = $null
    [string]$moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"

    if(-not (Test-Path $moduleKey))
    {
        $moduleKey =  "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    }

    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"
            if(Test-Path $path)
            {
                try
                {
                    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $path
                    $subject = $cert.Subject
                    [System.Text.RegularExpressions.MatchCollection]$matches = [System.Text.RegularExpressions.Regex]::matches($subject, "^.*?CN=(?<publisher>.*?),.*$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                    if($matches.Count -gt 0)
                    {
                        $publisher = $matches[0].groups["publisher"].Value
                    }
                }
                catch
                {
                }
            }
        }
    }
    return $publisher
}

#
# Get Addon Name
#
function GetAddonName([string]$module_guid = $(throw "No module guid is specified"))
{
    $addonName = ""
    $moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid
    if(-not (Test-Path $moduleKey))
    {
        $moduleKey = "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid
    }

    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $moduleName = $prop."(default)"
            if(-not [string]::IsNullOrEmpty($moduleName))
            {
                $addonName = $moduleName.Trim()
                $addonName = $addonName.Replace("&", "")
            }
        }
    }
    return $addonName
}

function GetAddonVersionInfo([string]$module_guid = $(throw "No module guid is specified"))
{
    $moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"

            if(Test-Path $path)
            {
                return [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path)
            }
        }
    }

    $moduleKey = "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"

            if(Test-Path $path)
            {
                return [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path)
            }
        }
    }
}

function GetAddonModifiedDate([string]$module_guid = $(throw "No module guid is specified"))
{
    $moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"
            if(Test-Path $path)
            {
                $fi = new-object System.IO.FileInfo($path)
                return $fi.LastWriteTime
            }
        }
    }

    $moduleKey = "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"
            if(Test-Path $path)
            {
                $fi = new-object System.IO.FileInfo($path)
                return $fi.LastWriteTime
            }
        }
    }
}

function BinaryExists([string]$module_guid = $(throw "No module guid is specified"))
{
    $moduleKey = "Registry::HKEY_CLASSES_ROOT\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"

            return Test-Path $path
        }
    }

    $moduleKey = "Registry::HKEY_CLASSES_ROOT\WOW6432NODE\CLSID\" + $module_guid + "\InprocServer32"
    if(Test-Path $moduleKey)
    {
        $prop = Get-ItemProperty -path $moduleKey
        if ($prop -ne $null)
        {
            $path = $prop."(default)"

            return Test-Path $path
        }
    }
}


function CreateRegObject([string]$reg_path = $(throw "No registry path is specified"),[string]$value_name = $(throw "No registry value name is specified"), [string]$regitemvalue_original = $(throw "No original registry value is specified"), [string]$regitemvalue_reset = $(throw "No new registry value is specified"))
{
    $regitemvalue_original = $regitemvalue_original

        $regitemvalue_reset = $regitemvalue_reset

        $regitem = New-Object -TypeName System.Management.Automation.PSObject  -ErrorAction Stop
        $regpath = $reg_path.replace("Registry::","")

        $valuename = $value_name

        Add-Member -InputObject $regitem -MemberType NoteProperty -Name "reg_path"-Value $regpath  -ErrorAction Stop
        Add-Member -InputObject $regitem -MemberType NoteProperty -Name "value_name"-Value $valuename -ErrorAction Stop
        Add-Member -InputObject $regitem -MemberType NoteProperty -Name "regitemvalue_original"  -Value $regitemvalue_original  -ErrorAction Stop
        Add-Member -InputObject $regitem -MemberType NoteProperty -Name "regitemvalue_reset"-Value $regitemvalue_reset  -ErrorAction Stop

        return $regitem
}

function UnderPolicySetting([string]$name = $(throw "No name is specified"), [string]$registrykey = $(throw "No registrykey is specified"))
{
    $result = $false
    $userID = ([Security.Principal.WindowsIdentity]::GetCurrent()).user.value.Replace('-', '_')
    $policysetting =  Get-WmiObject -Namespace "root\rsop\user\$userID" -query "select name, registrykey from RSOP_RegistryPolicySetting" | foreach ($_) {if ($_.registryKey -like "*Internet*") {$_}} | Select-Object name, registrykey
    if($PolicySetting -ne $null)
    {
        foreach($policyitem in $policysetting)
        {
            if(($policyitem.name -eq $name) -and ($policyitem.registrykey -eq $registrykey))
            {
                return $true
            }
        }
    }
    $keyPath = "Registry::HKEY_LOCAL_MACHINE\$registrykey"
    if(Test-Path $keyPath)
    {
        $key = get-item $keyPath
        if($key -ne $null -and @($key.Property) -contains $name)
        {
            return $true
        }
    }
    return $result
}

function DisableAddon($values)
{
    $ObjectArray = new-object System.Collections.ArrayList  -ErrorAction Stop

    foreach($key in $values)
    {
        $reg_path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\$key"
        # if there is no HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\(key guid), create a new key guid
        if(-not(Test-Path $reg_path))
        {
            New-Item -path $reg_path
        }
        #if there is no Flags property under HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\(key guid), create a new property
        #if there have a Flags property, set the value to 1
        $flags = Get-ItemProperty $reg_path "Flags" -ErrorAction silentlycontinue

        if($flags -eq $null)
        {
            New-ItemProperty -Path $reg_path -Name "Flags" -PropertyType DWORD -Value 1 | out-null

            $regitemvalue_original = " "

            $valuename = "Flags"

            $regitemvalue_reset = (Get-ItemProperty $reg_path $valuename).$valuename

            $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

            $ObjectArray.add($regitem) | out-null
        }
        else
        {
            if((Get-ItemProperty $reg_path "Flags" -ErrorAction silentlycontinue).Flags -ne 1)
            {
                $valuename = "Flags"

                $regitemvalue_original = (Get-ItemProperty $reg_path $valuename).$valuename

                Set-ItemProperty -path $reg_path -name $valuename -value 1

                $regitemvalue_reset = (Get-ItemProperty $reg_path $valuename).$valuename

                $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

                $ObjectArray.add($regitem) | out-null
            }
        }
        #if there is no Version property under HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\(key guid), create a new property
        #if there have a Version property, set the value to *
        if((Get-ItemProperty $reg_path "Version" -ErrorAction silentlycontinue) -eq $null)
        {
            New-ItemProperty -Path $reg_path -Name "Version" -PropertyType string -Value "*" | out-null

            $regitemvalue_original = " "

            $valuename = "Version"

            $regitemvalue_reset = (Get-ItemProperty $reg_path $valuename).$valuename

            $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

            $ObjectArray.add($regitem) | out-null
        }
        else
        {
            if((Get-ItemProperty $reg_path "Version" -ErrorAction silentlycontinue).Version -ne "*")
            {
                $valuename = "Version"

                $regitemvalue_original = (Get-ItemProperty $reg_path $valuename).$valuename

                Set-ItemProperty -path $reg_path -name "Version" -value "*"

                $regitemvalue_reset = (Get-ItemProperty $reg_path $valuename).$valuename

                $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

                $ObjectArray.add($regitem) | out-null
            }
        }
    }
    return $ObjectArray
}
