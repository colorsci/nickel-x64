# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Get parameter from troubleshooting script
Param($originalSize)

trap { break }

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Delete user WER report folder
Write-DiagProgress -Activity $localizationString.DeleteUserWERQueue

[double]$thresholder = Get-ThresholdForFileDeleting
[double]$percentage = Get-Percentage
[string]$userReportPath = Get-UserReportPath
[double]$userReportSize = 0.0
[double]$freeSpace = 0.0

$folders = Get-ChildItem -LiteralPath $userReportPath -Force | Where-Object {$_.PSIsContainer} | Sort-Object -Property CreationTime
if(($folders -ne $null) -and ($percentage -ge 0)) {
    foreach($folder in $folders) {
        [string]$path = $folder.FullName
        if((Get-FolderSize $path) -gt $thresholder) {
            Delete-Folder $path
        }

        $freeSpace = Get-FreeSpace
        $userReportSize = Get-FolderSize $userReportPath

        if(($freeSpace + $userReportSize) -gt 0) {
            if(($userReportSize / ($freeSpace + $userReportSize)) * 100 -lt $percentage) {
                break
            }
        }
    }
}

[double]$reclaimedSpace = ($originalSize - $userReportSize)
if($reclaimedSpace -gt 0.0) {
    @{Name=$userReportPath;ReclaimedSpace=$reclaimedSpace} | Select-Object -Property @{Name=$localizationString.userReportPath;Expression={$_.Name}},@{Name=$localizationString.reclaimedUserReportSize;Expression={(Format-DiskSpaceMB $_.ReclaimedSpace) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id ReclaimedUserReprotInfo -Name $localizationString.ReclaimedUserReportInfo_name -Description $localizationString.ReclaimedUserReportInfo_description
}
