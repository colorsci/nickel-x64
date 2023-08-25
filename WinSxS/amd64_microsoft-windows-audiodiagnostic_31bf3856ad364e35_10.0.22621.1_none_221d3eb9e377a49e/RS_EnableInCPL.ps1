# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
PARAM($deviceID)
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================
# Function to enable audio endpoint
function Enable-Endpoint([string]$id = $(throw "No ID is specified"))
{
    if([String]::IsNullOrEmpty($id))
    {
        throw "No id found"
    }

    Get-AudioManager
	[Microsoft.Windows.Diagnosis.AudioConfigManager]::EnableDevice($id, $true)
}

Write-DiagProgress -Activity $localizationString.enableEndpoint_progress

Enable-Endpoint $deviceID