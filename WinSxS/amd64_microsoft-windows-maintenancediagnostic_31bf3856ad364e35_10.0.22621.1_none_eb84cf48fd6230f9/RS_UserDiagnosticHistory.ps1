# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Get parameter from troubleshooting script
Param($originalSize)


trap { break }

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Delete user troubleshooting history
Write-DiagProgress -Activity $localizationString.DeleteUserTSHistory

[string]$userTSHistoryPath = Get-UserTSHistoryPath
Delete-OldFolders (Get-Item $userTSHistoryPath)

[double]$userTSHistorySize = Get-FolderSize $userTSHistoryPath
[double]$reclaimedSpace = ($originalSize - $userTSHistorySize)
if($reclaimedSpace -gt 0.0) {
    @{Name=$userTSHistoryPath;ReclaimedSpace=$reclaimedSpace} | Select-Object -Property @{Name=$localizationString.userTSHistoryPath;Expression={$_.Name}},@{Name=$localizationString.reclaimedUserTSHistorySize;Expression={(Format-DiskSpaceMB $_.ReclaimedSpace) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id ReclaimedUserTSHistoryInfo -Name $localizationString.ReclaimedUserTSHistroyInfo_name -Description $localizationString.ReclaimedUserTSHistroyInfo_description
}
