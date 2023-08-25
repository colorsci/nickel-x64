# Copyright © 2008, Microsoft Corporation. All rights reserved.


#
# By modifying the related registry key and refreshing policy resolves the issue of spooler crashing.
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_rs_spoolerCrashing

#
# modify registry key
#
if(-not(Test-Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers"))
{
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers"
}

if((Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" "PrintDriverIsolationExecutionPolicy") -eq $null)
{
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" -Name "PrintDriverIsolationExecutionPolicy" -PropertyType DWORD -Value 1
}

if((Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" "PrintDriverIsolationOverrideCompat") -eq $null)
{
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" -Name "PrintDriverIsolationOverrideCompat" -PropertyType DWORD -Value 1
}

Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" "PrintDriverIsolationExecutionPolicy" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\Printers" "PrintDriverIsolationOverrideCompat" 1

#
# refresh polify
#
$RefreshPolicyDefinition = @"
[DllImport("Userenv.dll", SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool RefreshPolicy([MarshalAs(UnmanagedType.Bool)] bool bMachine);
"@

$RefreshPolicyType = Add-Type -MemberDefinition $RefreshPolicyDefinition -Name "RefreshPolicyType" -UsingNamespace "System.Reflection","System.Diagnostics" -PassThru

[bool]$return = $RefreshPolicyType::RefreshPolicy($true)
[int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
if(-not $return)
{
    WriteFileAPIExceptionReport "RS_SpoolerCrashing" "RefreshPolicy" $errorCode
}
