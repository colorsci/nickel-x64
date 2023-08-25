# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  VF_HDAudioDriver verifies the resolver and update the result report

	ARGUMENTS:
	 deviceType : String value of Audio device ID
	 $pnpdevname : Name of the device type selected

	RETURNS:
	  None
#>


PARAM($PNPDevID,$PNPDevName)
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
$detected = $true
$flag = $true


#==================================================================================
# Main
#==================================================================================
if(test-path $env:temp\AudioTest.txt)
{
	$audioverify = get-content $env:temp\AudioTest.txt
	$reportDesc = ""
	$resolverPath = $localizationString.genericTestTone_verifierString_1 
	$resolverPath8 =  $localizationString.genericTestTone_verifierString_2 
	$resolverPath2 = $localizationString.IT_Choice2 +"/"+ $localizationString.IT_Choice1
	$resolverPath3 = $localizationString.IT_Choice3 +"/"+ $localizationString.IT_Choice1
	$resolverPath4 = $localizationString.IT_Choice3 +"/"+ $localizationString.IT_Choice2
	$resolverPath5 = $localizationString.IT_Choice3 +"/"+ $localizationString.IT_Choice3
	$resolverPath6 = $localizationString.IT_Choice2 +"/"+ $localizationString.IT_Choice3
	$resolverPath7 = $localizationString.IT_Choice2 +"/"+ $localizationString.IT_Choice2

	if($audioverify -eq $resolverPath)
	{
		$flag = $false
		$reportDesc = $resolverPath
	}
	elseif($audioverify -eq $resolverPath8)
	{
		$detected = $false
		$reportDesc = $resolverPath8
	}
	elseif($audioverify -eq $resolverPath4)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_3
	}
	elseif($audioverify -eq $resolverPath5)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_2
	}
	elseif($audioverify -eq $resolverPath6)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_4
	}
	elseif($audioverify -eq $resolverPath7)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_1
	}
	elseif($audioverify -eq $resolverPath2)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_1
		$detected = $false
	}
	elseif($audioverify -eq $resolverPath3)
	{
		$reportDesc = $localizationString.hdaudio_verifierstring_2
		$detected = $false
	}
	$PNPDevName | ConvertTo-Xml | Update-DiagReport -Id "VF_HDAudioDriver" -Name "VF_HDAudioDriver" -Description $reportDesc -Verbosity Debug
	Remove-Item $env:temp\AudioTest.txt -recurse -force -ErrorAction SilentlyContinue 
	if($flag)
	{
		Update-DiagRootCause -id "RC_HDAudioDriver" -iid $PNPDevID -Detected $detected 
	}
}