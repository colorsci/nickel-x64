# Copyright © 2008, Microsoft Corporation. All rights reserved.


# Get parameter from troubleshooting script
Param($originalSize)

trap { break }

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Delete admin troubleshooting history
Write-DiagProgress -Activity $localizationString.DeleteAdminTSHistory

[string]$adminTSHistoryPath = Get-AdminTSHistoryPath
Delete-OldFolders (Get-Item $adminTSHistoryPath)

[double]$adminTSHistorySize = Get-FolderSize $adminTSHistoryPath
[double]$reclaimedSpace = ($originalSize - $adminTSHistorySize)
if($reclaimedSpace -gt 0.0) {
    @{Name=$adminTSHistoryPath;ReclaimedSpace=$reclaimedSpace} | Select-Object -Property @{Name=$localizationString.adminTSHistoryPath;Expression={$_.Name}},@{Name=$localizationString.reclaimedAdminTSHistorySize;Expression={(Format-DiskSpaceMB $_.ReclaimedSpace) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id ReclaimedAdminTSHistoryInfo -Name $localizationString.ReclaimedAdminTSHistroyInfo_name -Description $localizationString.ReclaimedAdminTSHistroyInfo_description
}
