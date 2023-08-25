# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================

param($allError)
$verifierLogFileName = 'RS_DataStore_Verifier.log'

# ============================================================
# Load Utilities
# ============================================================
. .\CL_Utility.ps1

# ============================================================
# Main
# ============================================================

if(Test-Path -Path "$Env:TEMP/rsdatastoreWU.xml")
{
	Del "$Env:TEMP/rsdatastoreWU.xml" -Force
}


$oldTimestamp = Get-Item $env:windir\SoftwareDistribution | Foreach {$_.LastWriteTime} 
	
if($allError.Count -gt 0)
{
	Update-DiagRootCause -Id RC_DataStore -Detected $true -Parameter @{"oldTimestamp" = $oldTimestamp}
}
else
{
	Update-DiagRootCause -Id RC_DataStore -Detected $false -Parameter @{"oldTimestamp" = $oldTimestamp}
}
