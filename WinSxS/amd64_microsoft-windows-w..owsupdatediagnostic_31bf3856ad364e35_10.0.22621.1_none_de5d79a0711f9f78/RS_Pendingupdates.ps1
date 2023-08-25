# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. .\CL_WindowsUpdate.ps1
. .\CL_Utility.ps1

# ============================================================= 
# Main
# =============================================================
if((Check-WindowsVersion) -lt 100)
{
	[string]$linkValue = GetDiagString "new link" 
	Get-DiagInput -ID "INT_PendingUpdates" -Parameter @{"URL" = $linkValue}
}
else
{
		$osArch = (Gwmi Win32_Operatingsystem).OSArchitecture
		$bitness = $osArch.SubString(0,2)
		# If the OS architecture is 64-bit 
		if($bitness -eq 64)
		{
			# Start the usoclient.exe to download and install the updates
			if([IntPtr]::Size -eq 8)
			{
				& $env:windir\System32\UsoClient.exe StartScan
			}
			else
			{
				& $env:windir\sysnative\UsoClient.exe StartScan
			}
		}
		else
		{
			& $env:windir\System32\UsoClient.exe StartScan
		}
}
if((Check-WindowsVersion) -eq 61)
{
	'Resolved' > $Env:TEMP\RS_PendingUpdateFile.txt
}
else
{
	'Resolved' > 'RS_PendingUpdateFile.txt'
}