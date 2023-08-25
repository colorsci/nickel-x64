# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Load Utilities
# =============================================================
. ./CL_Utility.ps1

# =============================================================
# Main
# =============================================================

$correctValue = Get-AppDataExpectedString

Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\' -Name AppData -Value $correctValue