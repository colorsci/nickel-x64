# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================
param($errorCodes, $instanceValue)

# =============================================================
# Load Utilities
# =============================================================
. .\CL_WindowsUpdate.ps1

# =============================================================
# Functions
# =============================================================
#function that checks whether a bunch of services are started or not using Test-ServiceStarted function
function Get-ServiceStatus()
{
	$services=@()
	$services += "CryptSvc"
	$services += "bits"
	foreach($s in $services)
	{
		if(((Test-ServiceStarted $s) -eq $false))
		{
			return $false
		}
	}
	return $true
}

# ============================================================
# Main
# ============================================================
$notResolved = ((Get-ServiceStatus) -eq $false) 

Update-DiagRootCause -Id "RC_GENWUError" -InstanceId $instanceValue -Detected $notResolved

