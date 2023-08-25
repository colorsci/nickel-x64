# Copyright © 2008, Microsoft Corporation. All rights reserved.


#get item property value from registry property
function GetItemPropertyValue([string]$reg_path = $(throw "No registry path is specified"), [string]$propertyname = $(throw "no registry path is specified"))
{
    return (Get-ItemProperty $reg_path $propertyname -ErrorAction silentlycontinue)
}

function CreateRegObject([string]$reg_path = $(throw "No registry path is specified"),[string]$value_name = $(throw "No registry value name is specified"), [string]$regitemvalue_original = $(throw "No original registry value is specified"), [string]$regitemvalue_reset = $(throw "No new registry value is specified"))
{
    $regitemvalue_original = $regitemvalue_original
    $regitemvalue_reset = $regitemvalue_reset
    $regitem = New-Object -TypeName System.Management.Automation.PSObject -ErrorAction Stop
    $regpath = $reg_path.replace("Registry::","")
    $valuename = $value_name

    Add-Member -InputObject $regitem -MemberType NoteProperty -Name "reg_path"-Value $regpath -ErrorAction Stop
    Add-Member -InputObject $regitem -MemberType NoteProperty -Name "value_name"-Value $valuename -ErrorAction Stop
    Add-Member -InputObject $regitem -MemberType NoteProperty -Name "regitemvalue_original"  -Value $regitemvalue_original -ErrorAction Stop
    Add-Member -InputObject $regitem -MemberType NoteProperty -Name "regitemvalue_reset"-Value $regitemvalue_reset -ErrorAction Stop

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
    $key = get-item "Registry::HKEY_LOCAL_MACHINE\$registrykey"
    if($key-ne $null -and @($key.Property) -contains $name)
    {
        return $true
    }
    return $result
}
