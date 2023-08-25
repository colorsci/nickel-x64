# Setting aliases for Install/Unistall-WindowsFeature cmdlets for backward compatibility.
Set-Alias -Name Add-WindowsFeature -Value Install-WindowsFeature
Set-Alias -Name Remove-WindowsFeature -Value Uninstall-WindowsFeature

# Export aliases to be visible in the global scope.
Export-ModuleMember -Alias "Add-WindowsFeature", "Remove-WindowsFeature" -Cmdlet "Get-WindowsFeature", "Install-WindowsFeature", "Uninstall-WindowsFeature"

# BEGIN SECTION Enable/Disable-ServerManagerStandardUserRemoting
Data Resources {
    # culture="en-US"
    ConvertFrom-StringData @'
ErrorOnUsernameMessage=The specified object does not exist or is not a user: {0}
ConfirmEnableMessage=Add users to groups {0}?\nThis action also gives users "Enable Account" and "Read Security" access rights to the root\\cimv2 WMI namespace, and grants users access rights to the following in Service Control Manager: SC_MANAGER_CONNECT, SC_MANAGER_ENUMERATE_SERVICE, SC_MANAGER_QUERY_LOCK_STATUS, and STANDARD_RIGHTS_READ
ConfirmDisableMessage=Remove users from groups {0}?\nThis action also removes all access rights for these users to the root\\cimv2 WMI namespace, and removes all access rights for these users from Service Control Manager.
ShouldProcessForUserMessage=Enable remote management for standard user {0}
ShouldProcessForUserMessageDisable=Disable remote management for standard user {0}
'@
}

Import-LocalizedData -BindingVariable Resources -filename Configure-ServerManagerStandardUserRemoting.psd1 -ErrorAction SilentlyContinue

$cimv2 = "root\cimv2"
$computerName = [System.Environment]::MachineName;
$listSeparator = [system.globalization.cultureinfo]::CurrentCulture.TextInfo.ListSeparator

# S-1-5-32-559 => Performance Log Users
# S-1-5-32-573 => Event Log Readers
# S-1-5-32-580 => Remote Management Users
$groupNames = @()
foreach($sid in @("S-1-5-32-559", "S-1-5-32-573", "S-1-5-32-580"))
{
    $groupNames = @(((New-Object System.Security.Principal.SecurityIdentifier ($sid)).Translate([System.Security.Principal.NTAccount]).Value -split "\\+")[1]) + $groupNames
}

# .ExternalHelp ServerManager.psm1-help.xml
Function Enable-ServerManagerStandardUserRemoting
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true, Position=0)][string[]]$User,
        [Parameter(Mandatory=$false)][switch]$Force)
    Process
    {
        if($Force -or $pscmdlet.ShouldContinue($User -join $listSeparator, $Resources.ConfirmEnableMessage -f ($groupNames -join $listSeparator)))
        {
            foreach($name in $User)
            {
                if($pscmdlet.ShouldProcess($Resources.ShouldProcessForUserMessage -f $name))
                {
                    $domainName, $userName = GetUserName $name
                    if($domainName -ne $null -and $userName -ne $null)
                    {
                        EnableDisable $userName $domainName $true
                    }
                }
            }
        }
    }
}

# .ExternalHelp ServerManager.psm1-help.xml  
Function Disable-ServerManagerStandardUserRemoting 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true, Position=0)][string[]]$User,
        [Parameter(Mandatory=$false)][switch]$Force)
    Process
    {
        if($Force -or $pscmdlet.ShouldContinue($User -join $listSeparator, $Resources.ConfirmDisableMessage -f ($groupNames -join $listSeparator)))
        {
            foreach($name in $User)
            {
                if($pscmdlet.ShouldProcess($Resources.ShouldProcessForUserMessageDisable -f $name))
                {
                    $domainName, $userName = GetUserName $name
                    if($domainName -ne $null -and $userName -ne $null)
                    {
                        EnableDisable $userName $domainName $false
                    }
                }
            }
        }
    }
}

Function GetUserName ($User)
{
    $domainName, $userName = $User -split "\\+"
    if(! $username)
    {
        $userName = $domainName
        $domainName = $computername
    }

    try
    {
        # This only exists to force a failure if the name couldn't be looked up or isn't a user
        $null = ([ADSI]"WinNT://$domainName/$userName,user").Get("UserFlags")
    }
    catch
    {
        Write-Error ($Resources.ErrorOnUsernameMessage -f ("{0}\{1}" -f $domainName,  $userName)) -Category InvalidArgument
        return $null
    }
    
    return $domainName, $userName
}

Function BuildReplacementDescriptor ($oldDescriptor, $accessMask)
{
    $trustee = ([WMIClass]"Win32_Trustee").CreateInstance()
    $trustee.Domain = $domainName
    $trustee.Name = $userName

    $ace = ([WMIClass]"Win32_ACE").CreateInstance()
    $ace.AccessMask=$accessMask
    $ace.AceFlags = 0
    $ace.AceType = 0
    $ace.Trustee = $trustee

    $newAceList = @()
    if($enable)
    {
        $newAceList = @($ace)
    }
    
    $newDescriptor = ([WMIClass]"Win32_SecurityDescriptor").CreateInstance()
    $newDescriptor.DACL = $newAceList + [System.Management.ManagementBaseObject[]]($oldDescriptor.DACL | where {!($_.Trustee.Name -eq $userName -and $_.Trustee.Domain -eq $domainName)})
    $newDescriptor.Group = $oldDescriptor.Group
    $newDescriptor.Owner = $oldDescriptor.Owner
    $newDescriptor.ControlFlags = $oldDescriptor.ControlFlags
    return $newDescriptor
}

Function EnableDisable ($userName, $domainName, $enable)
{
    foreach($group in $groupNames)
    {
        try
        {
            $user = "WinNT://$domainName/$userName"
            $group = ([ADSI]"WinNT://$computerName/$group,group")
            if($enable)
            {
                $group.Add($user)
            }
            else
            {
                $group.Remove($user)
            }
        }
        catch [System.Management.Automation.MethodException]
        {
            $actualException = [System.Runtime.InteropServices.COMException]$_.Exception.InnerException
            $errorCode = $actualException.ErrorCode
            switch($errorCode)
            {
                -2147023518 { } #0x80070562 => "User already exists in group"
                -2147023519 { } #0x80070561 => "User does not exist in group that it is being removed from"
                default { throw }
            }
        }
    }

    # Magic number determined by setting properties in the WMI control MSC and reading output in WMI
    # See tool description at http://support.microsoft.com/kb/325353
    $oldDescriptor = (invoke-wmimethod -class __SystemSecurity -namespace $cimv2 -name GetSecurityDescriptor).Descriptor
    $newDescriptor = BuildReplacementDescriptor $oldDescriptor 131073 # "Enable Account" and "Read Security"
    $null = invoke-wmimethod -class __SystemSecurity -namespace $cimv2 -name SetSecurityDescriptor -ArgumentList $newDescriptor

    $scOutput = sc.exe sdshow SCMANAGER
    $scOutput = [string]::Join("", $scOutput).Trim()
    $oldDescriptor = (invoke-wmimethod -class Win32_SecurityDescriptorHelper -namespace $cimv2 -name SDDLToWin32SD -ArgumentList $scOutput).Descriptor

    # Magic number was acquired by reading the documentation here: http://support.microsoft.com/kb/907460
    # as well as here: http://msdn.microsoft.com/en-us/library/windows/desktop/ms685981(v=vs.85).aspx and then
    # looking at what LocalService had been granted by default on a fresh machine
    $newDescriptor = BuildReplacementDescriptor $oldDescriptor 131093 #SC_MANAGER_CONNECT, SC_MANAGER_ENUMERATE_SERVICE, SC_MANAGER_QUERY_LOCK_STATUS and STANDARD_RIGHTS_READ
    $newSDDL = (invoke-wmimethod -class Win32_SecurityDescriptorHelper -namespace $cimv2 -name Win32SDToSDDL -ArgumentList $newDescriptor).SDDL
    $null = sc.exe sdset SCMANAGER $newSDDL
}

Export-ModuleMember Enable-ServerManagerStandardUserRemoting, Disable-ServerManagerStandardUserRemoting
# END SECTION Enable/Disable-ServerManagerStandardUserRemoting