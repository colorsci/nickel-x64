# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Service.ps1

#====================================================================================
# Main
#====================================================================================
if (Test-Path $Global:sfcOputFile)
{
	Update-DiagReport -File $Global:sfcOputFile -ID 'RS_BITSDLL' -Name 'SFC Output' -Verbosity Informational
	Get-DiagInput -ID 'INT_RestartReq'
	del $Global:sfcOputFile -Force -ErrorAction SilentlyContinue
}