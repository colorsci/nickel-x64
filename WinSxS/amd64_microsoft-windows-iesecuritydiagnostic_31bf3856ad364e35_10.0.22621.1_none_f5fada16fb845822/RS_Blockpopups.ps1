# Copyright © 2008, Microsoft Corporation. All rights reserved.


#Localization Data
Import-LocalizedData localizationString

. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.Enable_PopupsBloker

$reg_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\New Windows"

$valuename = "PopupMgr"

$PopupMgrValueproperty = GetItemPropertyValue $reg_path $valuename
if ($PopupMgrValueproperty -eq $null)
{
   return
}

$PopupMgrValue = $PopupMgrValueproperty.$valuename

if($PopupMgrValue -eq "no")
{
    Set-ItemProperty -path $reg_path -name $valuename -value "yes" -ErrorAction Stop
}

if($PopupMgrValue -eq "0")
{
    Set-ItemProperty -path $reg_path -name $valuename -value "1"-ErrorAction Stop
}

$PopupMgrValueproperty = GetItemPropertyValue $reg_path $valuename
if ($PopupMgrValueproperty -ne $null)
{

    $regitemvalue_original = $PopupMgrValue

    $regitemvalue_reset = $PopupMgrValueproperty.$valuename

    $regitem = CreateRegObject $reg_path $valuename $regitemvalue_original $regitemvalue_reset

    $regitem | select-object -Property  @{Name=$localizationString.reg_path; Expression={$_.reg_path}} , @{Name=$localizationString.value_name; Expression={$_.value_name}} , @{Name=$localizationString.regitemvalue_original; Expression={$_.regitemvalue_original}},@{Name=$localizationString.regitemvalue_reset; Expression={$_.regitemvalue_reset}} | convertto-xml | Update-DiagReport -id PopupMgrValue -name $localizationString.Report_name_PopupMgrValue
}

$reg_path = "registry::HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\New Windows\Allow"
if(Test-path $reg_path)
{
    Remove-ItemProperty -Path $reg_path * -ErrorAction Stop
}




