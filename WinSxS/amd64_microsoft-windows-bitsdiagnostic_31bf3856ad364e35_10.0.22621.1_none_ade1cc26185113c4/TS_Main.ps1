# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Service.ps1

#====================================================================================
# Main
#====================================================================================

Write-DiagProgress -Activity $Strings_Main.ID_PROG_MAIN_Initializing
	
# Checking for root causes
. .\RC_BITSDLL.ps1 | Out-Null
. .\RC_BITSACL.ps1 | Out-Null
. .\RC_BITSRegKeys.ps1 | Out-Null

Write-DiagProgress -Activity (($Strings_Main.ID_STATUS_START_SERVICE).Replace('%ServiceName%','Bits'))

# Clear bits queue
Set-Service bits -StartupType Automatic -ErrorAction SilentlyContinue
& "$env:windir\system32\bitsadmin.exe" /reset /allusers

$output = net start bits 2>&1
if ((IsServiceInstalled "bits") -eq $true)
{
	Get-Service bits -DependentServices -ErrorAction SilentlyContinue | Start-Service -ErrorAction SilentlyContinue
}

if($output)
{
	$sb = New-Object System.Text.StringBuilder
	$sb.Append(($Strings_Main.ID_BITS_ERROR_MSG_SERVICE))
	$sb.Append("`n")
	foreach($o in $output)
	{
		if($o)
		{
			$sb.append($o.tostring().Trim() + ' ')
		}
	}
	($sb.ToString()) | ConvertTo-Xml | Update-DiagReport -ID 'TS_Main' -Name 'Service Status' -Verbosity Informational;
}