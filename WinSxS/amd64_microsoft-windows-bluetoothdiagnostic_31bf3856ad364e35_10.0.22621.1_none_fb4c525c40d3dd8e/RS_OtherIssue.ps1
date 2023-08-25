# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Param ($problemDeviceName,$errorCode)

#====================================================================================
# Main
#====================================================================================
if(![string]::IsNullOrWhiteSpace($problemDeviceName))
{
	Get-DiagInput -ID 'INT_OEM' -Parameter @{'ProblemDeviceName'=$problemDeviceName;'ErrorCode'=$errorCode}
}