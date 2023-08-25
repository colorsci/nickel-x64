# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable RC_ConnectLocalizedString -FileName CL_LocalizationData

#====================================================================================
# Main
#====================================================================================
$rootCauseID = 'RC_ConnectedAccount'
$rootCauseDetected = $true

Write-DiagProgress $RC_ConnectLocalizedString.ID_Progress_VerifyAccount

# Registry values to check for Connected Accounts
$regPath1 = 'registry::HKCU\Software\Microsoft\IdentityCRL\UserExtendedProperties\*'
$regPath2 = 'registry::HKCU\Software\Microsoft\IdentityCRL\Immersive\*'

# No connected account if $regPath1 / $regpath2 is empty
if ((Test-Path -Path $regPath1) -and (Test-Path -Path $regPath2))
{
    $rootCauseDetected = $false
}

Update-DiagRootCause -Id $rootCauseId -Detected $rootCauseDetected

return $rootCauseDetected