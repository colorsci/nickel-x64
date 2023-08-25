# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
 
#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utility.ps1

#====================================================================================
# Main
#====================================================================================

try
{
	Get-DiagInput -ID 'INT_NotSupport'
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
    $_ | ConvertTo-Xml | Update-DiagReport -ID 'RS_CheckBT' -Name 'RS_CheckBT' -Verbosity Debug
}