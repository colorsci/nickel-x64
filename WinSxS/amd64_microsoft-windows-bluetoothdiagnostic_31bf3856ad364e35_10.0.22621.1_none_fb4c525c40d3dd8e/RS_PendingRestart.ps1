# Copyright © 2018, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
    DESCRIPTION:
      RS_PendingRestart displays a message to the user to restart the machine.
      To display the message, it will use "Title" and "Description" 
      tags under "PauseInteraction" node with ID "INT_PendingReboot" 
      in DiagPackage.diag

    ARGUMENTS:

    RETURNS:
#>
#================================================================================
Get-DiagInput -Id "INT_PendingReboot"
Write-DiagTelemetry -Property "RestartRequired" -Value $true