# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.reset_SyncMode5

$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

$valuename = "SyncMode5"

$Syncmode5property = GetItemPropertyValue $reg_path $valuename

if($Syncmode5property -ne $null)
{
    $syncmode5 = $Syncmode5property.$valuename

    if($syncmode5 -ne "4")
    {
        Set-ItemProperty -path $reg_path -name $valuename  -value "4"
    }

    $Syncmode5property = GetItemPropertyValue $reg_path $valuename
    if ($Syncmode5property -ne $null)
    {
        $regitemvalue_original = $syncmode5

        $regitemvalue_reset = $Syncmode5property.$valuename

        $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset
        if ($regitem -ne $null)
	{
            $regitem | select-object -Property @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id Syncmode5value -name $localizationString.Report_name_Syncmode5value
	}
    }
}


