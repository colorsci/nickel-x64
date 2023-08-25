# Copyright © 2017, Microsoft Corporation. All rights reserved.
#==============================================================
# Initialize
#==============================================================
Import-LocalizedData -BindingVariable RC_PendingRestart_LocalizedStrings -FileName CL_LocalizationData

# =============================================================
# Load Utilities
# =============================================================
. .\CL_WindowsUpdate.ps1
. .\CL_Utility.ps1

#==============================================================
# Main
#==============================================================
Write-DiagProgress -Activity $RC_PendingRestart_LocalizedStrings.ID_pending_restart

$status = Get-PendingReboot
if(($status.WindowsUpdate) -or ($status.CBServicing) -or (Get-PendingRebootOfflineUpdates))
{
 	Update-DiagRootCause -Id RC_PendingRestart -Detected $true
	return $true
}

return $false