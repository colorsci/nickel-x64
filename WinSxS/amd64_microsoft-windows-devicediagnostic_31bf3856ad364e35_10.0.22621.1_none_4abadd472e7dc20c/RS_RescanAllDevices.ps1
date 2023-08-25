# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_RescanAllDevices re-scan all the devices on system
	ARGUMENTS:
	  
	RETURNS:
#>
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.Resolution_RescanAllDevices

$Rescan = RescanAllDevices
