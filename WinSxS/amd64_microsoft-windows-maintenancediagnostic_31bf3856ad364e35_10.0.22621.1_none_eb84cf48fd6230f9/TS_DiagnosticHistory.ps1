# Copyright © 2008, Microsoft Corporation. All rights reserved.

trap {break}

# Include common library
. .\CL_Utility.ps1

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

# function library
# Function to check whether have unnecessary files
function Test-UnnecessaryFiles([string]$folder = $(throw "No folder is specified")) {
    if([String]::IsNullOrEmpty($folder) -or (-not(Test-Path $folder))) {
        return $false
    }

    [int]$threshold = -1
    $folders = Get-ChildItem -literalPath $folder -Recurse -Force | Where-Object {($_.PSIsContainer) -and ((($_.CreationTime).CompareTo((Get-Date).AddMonths($threshold))) -lt 0)}

    return ($folders -ne $null)
}

# Check troubleshooting history
Write-DiagProgress -Activity $localizationString.CheckTSHistory

[string]$userTSHistoryPath = Get-UserTSHistoryPath
[string]$adminTSHistoryPath = Get-AdminTSHistoryPath
[double]$userTSHistorySize = (Get-FolderSize $userTSHistoryPath)
[double]$adminTSHistorySize = (Get-FolderSize $adminTSHistoryPath)
[double]$totalSize = Format-DiskSpaceMB ($userTSHistorySize + $adminTSHistorySize)

# Reporting
@{Name=$userTSHistoryPath;Space=$userTSHistorySize} | Select-Object -Property @{Name=$localizationString.userTSHistoryPath;Expression={$_.Name}},@{Name=$localizationString.userTSHistorySize;Expression={(Format-DiskSpaceMB $_.Space) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id UserTSHistorySizeInfo -Name $localizationString.UserTSHistoryInfo_name -Description $localizationString.UserTSHistoryInfo_description -rid "RC_DiagnosticHistory"

@{Name=$adminTSHistoryPath;Space=$adminTSHistorySize} | Select-Object -Property @{Name=$localizationString.adminTSHistoryPath;Expression={$_.Name}},@{Name=$localizationString.adminTSHistorySize;Expression={(Format-DiskSpaceMB $_.Space) + "MB"}} | ConvertTo-Xml | Update-DiagReport -id AdminTSHistorySizeInfo -Name $localizationString.AdminTSHistoryInfo_name -Description $localizationString.AdminTSHistoryInfo_description -rid "RC_DiagnosticHistory"


if(Test-UnnecessaryFiles $userTSHistoryPath) {
    Update-DiagRootcause -ID "RC_DiagnosticHistory" -Detected $true -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
    return
}

if(Test-UnnecessaryFiles $adminTSHistoryPath) {
    Update-DiagRootcause -ID "RC_DiagnosticHistory" -Detected $true -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
    return
}

Update-DiagRootcause -ID "RC_DiagnosticHistory" -Detected $false -Parameter @{'UnwantedSpace'=(Format-DiskSpaceMB $totalSize)}
