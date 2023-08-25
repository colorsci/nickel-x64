# Copyright © 2017, Microsoft Corporation. All rights reserved.

# =============================================================
# Initialize
# =============================================================
param($error)
Import-LocalizedData -BindingVariable DataSore_LocalizedStrings -FileName CL_LocalizationData

#================================================================================
# Main
#================================================================================

$WaaS = New-Object -ComObject "Microsoft.WaaSMedic.1"
$ret = $WaaS.LaunchRemediationOnly($error, "Troubleshooter")

[string]$str = ($DataSore_LocalizedStrings.ID_WAAS_MEDIC_ISSUE_FIXED) + $error
$str | ConvertTo-Xml | Update-Diagreport -Id RC_GenWUError -Name WaaSMedicService

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WaaS)
