# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Get parameter from troubleshooting script
Param($originalSize)

trap { break }

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Delete machine WER report folder
Write-DiagProgress -Activity $localizationString.DeleteSystemWERQueue

[double]$thresholder = Get-ThresholdForFileDeleting
[double]$percentage = Get-Percentage
[string]$machineReportPath = Get-MachineReportPath
[double]$freeSpace = 0.0
[double]$machineReportSize = 0.0

$folders = Get-ChildItem -LiteralPath $machineReportPath | Where-Object {$_.PSIsContainer} | Sort-Object -Property CreationTime
if(($folders -ne $null) -and ($percentage -ge 0)) {
    foreach($folder in $folders) {
        [string]$path = $folder.FullName
        if((Get-FolderSize $path) -gt $thresholder) {
            Delete-Folder $path
        }

        $freeSpace = Get-FreeSpace
        $machineReportSize = Get-FolderSize $machineReportPath

        if(($freeSpace + $machineReportSize) -gt 0) {
            if(($machineReportSize / ($freeSpace + $machineReportSize)) * 100 -lt $percentage) {
                break
            }
        }
    }
}

[double]$reclaimedSpace = ($originalSize - $machineReportSize)
if($reclaimedSpace -gt 0.0) {
    @{Name=$machineReportPath;ReclaimedSpace=$reclaimedSpace} | Select-Object -Property @{Name=$localizationString.machineReportPath;Expression={$_.Name}},@{Name=$localizationString.reclaimedMachineReportSize;Expression={(Format-DiskSpaceMB $_.ReclaimedSpace) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id ReclaimedMachineReprotInfo -Name $localizationString.ReclaimedMachineReportInfo_name -Description $localizationString.ReclaimedMachineReportInfo_description
}
