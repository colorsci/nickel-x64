# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData -BindingVariable localizationString -FileName IESecurity_TroubleShooter

. .\CL_Utility.ps1

function CheckBlockpopups
{
    Write-DiagProgress -activity $localizationString.Check_Blockpopups

	[bool]$result = $true

    $name = "NoPopupManagement"
    $registrykey = "Software\Policies\Microsoft\Internet Explorer\Restrictions"

    if((UnderPolicySetting $name $registrykey) -eq $true)
    {
        [string]$message = $localizationString.Message_Popupblocker

        $message | convertto-xml | Update-DiagReport -rid RC_Popupblocker -id Message_Popupblocker -name $localizationString.Report_name_Popupblocker

        return $true
    }

	$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\New Windows"

    $PopupMgrValueproperty = GetItemPropertyValue $reg_path "PopupMgr"

	$PopupMgrValue = $PopupMgrValueproperty."PopupMgr"

	if(($PopupMgrValue -eq "no") -or ($PopupMgrValue -eq "0"))
	{
	    $result = $false
	}
    return $result
}

if((CheckBlockpopups) -eq $false)
{
    Update-DiagRootCause -id RC_Popupblocker -Detected $true
} else {
    Update-DiagRootCause -id RC_Popupblocker -Detected $false
}
