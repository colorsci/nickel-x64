# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. .\CL_Utility.ps1

# =============================================================

if((Check-WindowsVersion) -eq 61)
{
	Remove-Item $ENV:TEMP\RS_PendingUpdateFile.txt -recurse -force -ErrorAction SilentlyContinue
	$detected = $false
}
else
{
	$detected = ((Get-Content 'RS_PendingUpdateFile.txt' -EA 0 | ?{ $_ -match 'Resolved'}).Count -eq 0)
}

Update-Diagrootcause -Id RC_PendingUpdates -Detected $detected

