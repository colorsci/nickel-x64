# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_BITSACL -FileName CL_LocalizationData
$detected = $false

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RC_BITSACL.ID_RC_BITSACL_Progress

$sd = sc.exe sdshow bits
$bitsAcl = 'D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;SAFA;WDWO;;;BA)'

if($sd[1].IndexOf($BitsAcl) -eq -1)
{
	$detected = $true
}

Update-DiagRootCause -ID 'RC_BITSACL' -Detected $detected -Parameter @{'bitsAcl' = $bitsAcl}
return $detected