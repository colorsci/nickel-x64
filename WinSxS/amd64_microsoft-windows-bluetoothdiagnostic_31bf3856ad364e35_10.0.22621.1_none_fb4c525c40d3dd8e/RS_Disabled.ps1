# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Param ($problemDeviceID, $problemDeviceName)
Import-LocalizedData -BindingVariable Strings_RS_Disabled -FileName CL_LocalizationData 

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RS_Disabled.ID_EnableDevice
try
{
	Get-WmiObject -Class CIM_LogicalDevice | ?{$_.DeviceID -eq $problemDeviceID} | Enable-PnpDevice -Confirm:$false
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
    $_ | ConvertTo-Xml | Update-DiagReport -ID 'RS_Disabled' -Name 'RS_Disabled' -Verbosity Debug
}
