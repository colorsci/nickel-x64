# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
param($oldTimestamp)

# =============================================================
# Load Utilities
# =============================================================
. .\CL_Utility.ps1

# =============================================================

if((Check-WindowsVersion) -eq 61)
{
	$sdFolderDate = Get-Item $env:windir\SoftwareDistribution | Foreach {$_.LastWriteTime}
	[DateTime]$oldDate = [DateTime]$oldTimestamp

	$detected = ($oldDate.ToString() -eq $sdFolderDate.ToString())

	Remove-Item $Env:TEMP\DataStoreAndWULogFiles -recurse -force -ErrorAction SilentlyContinue
	Remove-Item $Env:TEMP\RS_DataStore_Verifier.txt -recurse -force -ErrorAction SilentlyContinue
}
else
{
	$sdFolderDate = Get-Item $env:windir\SoftwareDistribution | Foreach {$_.LastWriteTime}
	[DateTime]$oldDate = [DateTime]$oldTimestamp

	$detected = ($oldDate.ToString() -eq $sdFolderDate.ToString())
}

Update-Diagrootcause -Id RC_DataStore -Detected $detected
