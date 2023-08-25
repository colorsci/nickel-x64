# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================
Import-LocalizedData -BindingVariable RC_PendingUpdates_LocalizedStrings -FileName CL_LocalizationData
$pendingUpdateFile = 'RS_PendingUpdateFile.txt'

# =============================================================
# Load Utilities
# =============================================================
. .\CL_WindowsUpdate.ps1
. .\CL_Utility.ps1

# ============================================================= 
# Main
# =============================================================
Write-DiagProgress -Activity $RC_PendingUpdates_LocalizedStrings.ID_pending_update -Status $RC_PendingUpdates_LocalizedStrings.ID_pending_updates_status


$detected = (Test-UpdateAvailable -eq $true)
Update-DiagRootCause -Id RC_PendingUpdates -Parameter @{'ScanFailure' = $false} -Detected $detected

