# Copyright © 2008, Microsoft Corporation. All rights reserved.

trap {break}

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# Troubleshooting WER queue
Write-DiagProgress -Activity $localizationString.CheckWERQueue

[double]$freeSpace = Get-FreeSpace
[double]$percentage = Get-Percentage
[string]$userReportPath = Get-UserReportPath
[string]$machineReportPath = Get-MachineReportPath

[double]$userReportSize = Get-FolderSize $userReportPath
[double]$machineReportSize = Get-FolderSize $machineReportPath
[double]$totalSize = Format-DiskSpaceMB ($userReportSize + $machineReportSize)

# Reporting
$systemDrive = Get-SystemDriveInfo
if($systemDrive -ne $null) {
    $systemDrive | Select-Object -Property @{Name=$localizationString.driveName;Expression={$_.DeviceID}},@{Name=$localizationString.FreeSpace;Expression={(Format-DiskSpaceGB $_.FreeSpace) + "GB"}},@{Name=$localizationString.totalSpace;Expression={(Format-DiskSpaceGB $_.Size) + "GB"}} | ConvertTo-Xml | Update-DiagReport -id SystemDriveInfo -Name $localizationString.systemDriveInfo_name -Description $localizationString.systemDriveInfo_description -rid "RC_WERQueue"
}

@{Name=$userReportPath;Space=$userReportSize} | Select-Object -Property @{Name=$localizationString.userReportPath;Expression={$_.Name}},@{Name=$localizationString.userReportSpace;Expression={(Format-DiskSpaceMB $_.Space) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id UserReprotInfo -Name $localizationString.UserReportInfo_name -Description $localizationString.UserReportInfo_description -rid "RC_WERQueue"

@{Name=$machineReportPath;Space=$machineReportSize} | Select-Object -Property @{Name=$localizationString.MachineReportPath;Expression={$_.Name}},@{Name=$localizationString.MachineReportSpace;Expression={(Format-DiskSpaceMB $_.Space) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id AdminReprotInfo -Name $localizationString.MachineReportInfo_name -Description $localizationString.MachineReportInfo_description -rid "RC_WERQueue"

if((($freeSpace + $userReportSize) -gt 0) -and ($percentage -ge 0)) {
    if(($userReportSize / ($freeSpace + $userReportSize)) * 100 -gt $percentage) {
        Update-Diagrootcause -ID "RC_WERQueue" -Detected $true -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
        return
    }
}

if((($freeSpace + $machineReportSize) -gt 0) -and ($percentage -ge 0)) {
    if(($machineReportSize / ($freeSpace + $machineReportSize) * 100 -gt $percentage)) {
        Update-DiagRootcause -ID "RC_WERQueue" -Detected $true -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
        return
    }
}

Update-DiagRootcause -ID "RC_WERQueue" -Detected $false -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
