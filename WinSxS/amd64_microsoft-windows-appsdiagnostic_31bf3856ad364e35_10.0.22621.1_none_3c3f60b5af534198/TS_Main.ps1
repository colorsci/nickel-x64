# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Load Utilities
#====================================================================================
. .\Utils_Apps.ps1

#====================================================================================
# Initialize
#====================================================================================
$rcDetected = $false

#====================================================================================
# Main
#====================================================================================

# Preventing execution during post back
if($Global:TS_MainExecuted -ne 1)
{
	$Global:TS_MainExecuted = 1
	
	$currentUser = Get-CurrentUser

	if($currentUser.IsTemporaryProfile)
	{
		# Stopping if temporary user profile is loaded.
		.\RC_TemporaryProfile.ps1
		return
	}

	if(.\RC_ConnectedAccount.ps1 -eq $true)
	{
		$rcDetected = $true
	}

	$uacName = .\RC_UAC.ps1 
	if($uacName.rcDetected -eq $true)
	{
		$rcDetected = $true
		
		# If user denied to enable UAC, stop
		if(!($uacName.uacConsent))
		{
			return
		}
	}
	
	$tempInet = .\RC_TempInetFolder.ps1 ($currentUser.SID) ($currentUser.LocalProfilePath)
	if($tempInet -eq $true)
	{
		$rcDetected = $true
	}

	# Check for hanging or crashing apps that need to be reset
	.\RC_WSReset.ps1
	
}
else
{
	# Final Cleanup
	Remove-Item $ENV:TEMP\TEMP.log -Recurse -Force -ErrorAction Ignore

	# Skipping detecting additional problems and checking for pending reboot.
	if((Get-PendingReboot).RebootPending)
	{
 		Get-DiagInput INT_RestartMachine
	}

	return
}