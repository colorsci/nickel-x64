# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_IsWMPUnavailable

$KeyPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{6BF52A52-394A-11d3-B153-00C04F79FAA6}\"
if((Test-Path $KeyPath) -eq $True)
{
    $InstallInfo = Get-ItemProperty -Path $KeyPath -Name "IsInstalled" -ErrorAction silentlycontinue
    if ($InstallInfo -ne $Null)
    {
        if($InstallInfo.IsInstalled -eq 1)
        {
            Update-DiagRootCause -ID "RC_WMPUnavailable" -Detected $false
            return $True
        }
    }
}

Update-DiagRootCause -ID "RC_WMPUnavailable" -Detected $true

return $False
