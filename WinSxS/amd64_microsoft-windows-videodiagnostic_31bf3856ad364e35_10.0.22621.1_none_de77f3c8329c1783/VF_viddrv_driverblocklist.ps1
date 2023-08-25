# Copyright © 2018, Microsoft Corporation. All rights reserved.
#*=================================================================================
# Parameters
#*=================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
#Run verifier logic
#*=================================================================================

# start HECI and HDCP service
NET START cphs
$status = (Get-Service -Name cphs).Status
if ($status -ne 'Running')
{
    $success = $false
}

NET START cplspcon
$status = (Get-Service -Name cplspcon).Status
if ($status -ne 'Running')
{
    $success = $false
}

if ($success -eq $false)
{
	get-diaginput -id "INT_driverblocklist" -Parameter @{'DriverName' = $DName ; 'DriverVersion' = $DVersion}
}

#*=================================================================================
#End
#*=================================================================================
