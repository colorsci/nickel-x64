# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

$result = Get-DiagInput -id IT_TurnOnPhishingFilter
if ($result[0] -eq "Yes")
{
	Write-DiagProgress -activity $localizationString.Enable_PhishingFilter

	$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\PhishingFilter"

	$valuename = "EnabledV9"

	if(test-path $reg_path)
	{
		$IsEnabledproperty = GetItemPropertyValue $reg_path $valuename
		if($IsEnabledproperty -ne $null)
		{
			$IsEnabled = $IsEnabledproperty.$valuename

			Set-ItemProperty -path $reg_path -name $valuename -value "1"-ErrorAction Stop

			$IsEnabledproperty = GetItemPropertyValue $reg_path $valuename

			$regitemvalue_original = $IsEnabled

			$regitemvalue_reset = $IsEnabledproperty.$valuename

			$regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

			$regitem | select-object -Property  @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id EnabledV9Value -name $localizationString.Report_name_isphishingfilterenabled
		}
		else
		{
			New-ItemProperty -Path $reg_path -Name $valuename -PropertyType DWORD -Value 1 -ErrorAction Stop

			$IsEnabledproperty = GetItemPropertyValue $reg_path $valuename

			$regitemvalue_original = "null"

			$regitemvalue_reset = $IsEnabledproperty.$valuename

			$regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

			$regitem | select-object -Property  @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id EnabledV9Value -name $localizationString.Report_name_isphishingfilterenabled
		}
	}
	else
	{
		New-Item -path $reg_path -ErrorAction Stop

		New-ItemProperty -Path $reg_path -Name $valuename -PropertyType DWORD -Value 1 -ErrorAction Stop

		$IsEnabledproperty = GetItemPropertyValue $reg_path $valuename

		$regitemvalue_original = "null"

		$regitemvalue_reset = $IsEnabledproperty.$valuename

		$regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

		$regitem | select-object -Property  @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id EnabledV9Value -name $localizationString.Report_name_isphishingfilterenabled

	}
}




