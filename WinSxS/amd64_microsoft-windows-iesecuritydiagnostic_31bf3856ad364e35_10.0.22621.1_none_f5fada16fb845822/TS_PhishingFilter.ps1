# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName IESecurity_TroubleShooter

. .\CL_Utility.ps1

function CheckPhishingFilter
{
    Write-DiagProgress -activity $localizationString.Check_PhishingFilter

    [bool]$result = $true

    $name = "EnabledV9"
    $registrykey = "Software\Policies\Microsoft\Internet Explorer\PhishingFilter"

    if((UnderPolicySetting $name $registrykey) -eq $true)
    {
        [string]$message = $localizationString.Message_Phishingfilter

        $message | convertto-xml | Update-DiagReport -rid RC_Phishingfilter -id Message_Phishingfilter -name $localizationString.Report_name_Phishingfilter

        return $true
    }

    $reg_hkcu_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\PhishingFilter"
    $reg_hklm_path = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\PhishingFilter"    

    if((test-path $reg_hkcu_path) -or (test-path $reg_hklm_path))
    {
        if(test-path $reg_hklm_path)
        {
            $IsEnabledproperty = GetItemPropertyValue $reg_hklm_path "EnabledV9"
            $IsEnabled = $IsEnabledproperty."EnabledV9"

            $result = -not (($IsEnabled -eq 0) -or ($IsEnabled -eq $null))
        }

        # hkcu overrides the setting in hklm
        if(test-path $reg_hkcu_path)
        {
            $IsEnabledproperty = GetItemPropertyValue $reg_hkcu_path "EnabledV9"
            $IsEnabled = $IsEnabledproperty."EnabledV9"

            # if hkcu value is present, use it
            if($IsEnabled -ne $null)
            {
                $result = -not ($IsEnabled -eq 0)
            }
        }
    }
    else
    {
        $result = $false
    }
    return $result
}


if((CheckPhishingFilter) -eq $false)
{
    Update-DiagRootCause -id RC_Phishingfilter -Detected $true
} else {
    Update-DiagRootCause -id RC_Phishingfilter -Detected $false
}