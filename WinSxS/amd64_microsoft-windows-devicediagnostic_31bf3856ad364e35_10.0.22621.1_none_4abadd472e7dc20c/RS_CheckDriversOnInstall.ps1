# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_CheckDriversOnInstall checks for a registry key and if it is not present creates it and sets the value to 1.

	ARGUMENTS:
	  

	RETURNS:
#>

# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================

#*=================================================================================
# Function
#*=================================================================================
# Function to create the registry key paths based on the parameters passed

function CreateRegPath([string]$pathName1, [string]$pathName2, [string]$propertyName1, [string]$propertyName2)
{
	$gpSetting = Get-ItemProperty -path $pathName2 -ErrorAction SilentlyContinue
	if($gpSetting -eq $null)
	{
        if(!(Test-Path "$pathName1\$propertyName1"))
        {
		    New-Item -Path $pathName1 -Name $propertyName1
        }
		New-ItemProperty -Path $pathName2 -Name $propertyName2 -Value 1 -PropertyType DWORD
	}
	else
	{
        if((Get-ItemProperty -path $pathName2 -Name $propertyName2 -ErrorAction SilentlyContinue) -ne $null)
        {
		    Set-ItemProperty -Path $pathName2 -Name $propertyName2 -Value 1 -ErrorAction SilentlyContinue
        }
        else
        {
            New-ItemProperty -Path $pathName2 -Name $propertyName2 -Value 1 -PropertyType DWORD
        }
	}
}


#*=================================================================================
# Main
#*=================================================================================

# Show interaction to user to select a choice to either enable the setting or to leave it as disabled
try
{
	$choice = Get-DiagInput -ID "INT_INSTALLSETTINGS"
	if($choice -eq "Y")
	{
		$regPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
		$regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching"
		$regPath3 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
		$regPath4 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
		$regPath5 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata"

		CreateRegPath $regPath1 $regPath2 "DriverSearching" "DriverUpdateWizardWUSearchEnabled"
		CreateRegPath $regPath3 $regPath4 "DriverSearching" "SearchOrderConfig"
		CreateRegPath $regPath3 $regPath5 "Device Metadata" "PreventDeviceMetadataFromNetwork"

	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_CheckDriversOnInstall" $null $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_CheckDriversOnInstall" -Name "RS_CheckDriversOnInstall" -Verbosity Debug
}